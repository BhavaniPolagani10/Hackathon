using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using InventoryService.Data;
using InventoryService.Models;
using SharedModels;

namespace InventoryService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class InventoryController : ControllerBase
{
    private readonly InventoryDbContext _context;
    private readonly ILogger<InventoryController> _logger;

    public InventoryController(InventoryDbContext context, ILogger<InventoryController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<InventoryItem>>> GetInventory(
        [FromQuery] int? warehouseId = null,
        [FromQuery] int? productId = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        try
        {
            var query = _context.Inventories.AsQueryable();

            if (warehouseId.HasValue)
                query = query.Where(i => i.WarehouseId == warehouseId.Value);

            if (productId.HasValue)
                query = query.Where(i => i.ProductId == productId.Value);

            var inventories = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var productIds = inventories.Select(i => i.ProductId).Distinct().ToList();
            var products = await _context.Products
                .Where(p => productIds.Contains(p.ProductId))
                .ToListAsync();

            var warehouseIds = inventories.Select(i => i.WarehouseId).Distinct().ToList();
            var warehouses = await _context.Warehouses
                .Where(w => warehouseIds.Contains(w.WarehouseId))
                .ToListAsync();

            var result = inventories.Select(i =>
            {
                var product = products.FirstOrDefault(p => p.ProductId == i.ProductId);
                var warehouse = warehouses.FirstOrDefault(w => w.WarehouseId == i.WarehouseId);

                return new InventoryItem
                {
                    InventoryId = i.InventoryId,
                    ProductId = i.ProductId,
                    ProductCode = product?.ProductCode ?? "",
                    ProductName = product?.ProductName ?? "",
                    WarehouseId = i.WarehouseId,
                    WarehouseCode = warehouse?.WarehouseCode ?? "",
                    WarehouseName = warehouse?.WarehouseName ?? "",
                    QuantityOnHand = i.QuantityOnHand,
                    QuantityReserved = i.QuantityReserved,
                    QuantityAvailable = i.QuantityAvailable,
                    QuantityOnOrder = i.QuantityOnOrder,
                    BinLocation = i.BinLocation,
                    LastCountDate = i.LastCountDate,
                    UpdatedAt = i.UpdatedAt
                };
            }).ToList();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving inventory");
            return StatusCode(500, "An error occurred while retrieving inventory");
        }
    }

    [HttpGet("availability/{productId}")]
    public async Task<ActionResult<InventoryAvailability>> GetProductAvailability(int productId)
    {
        try
        {
            var product = await _context.Products.FindAsync(productId);
            if (product == null)
                return NotFound($"Product with ID {productId} not found");

            var inventories = await _context.Inventories
                .Where(i => i.ProductId == productId)
                .ToListAsync();

            var warehouseIds = inventories.Select(i => i.WarehouseId).Distinct().ToList();
            var warehouses = await _context.Warehouses
                .Where(w => warehouseIds.Contains(w.WarehouseId))
                .ToListAsync();

            var result = new InventoryAvailability
            {
                ProductId = productId,
                ProductCode = product.ProductCode,
                ProductName = product.ProductName,
                TotalAvailable = inventories.Sum(i => i.QuantityAvailable),
                TotalReserved = inventories.Sum(i => i.QuantityReserved),
                TotalOnOrder = inventories.Sum(i => i.QuantityOnOrder),
                Warehouses = inventories.Select(i =>
                {
                    var warehouse = warehouses.FirstOrDefault(w => w.WarehouseId == i.WarehouseId);
                    return new WarehouseInventory
                    {
                        WarehouseId = i.WarehouseId,
                        WarehouseCode = warehouse?.WarehouseCode ?? "",
                        WarehouseName = warehouse?.WarehouseName ?? "",
                        QuantityAvailable = i.QuantityAvailable,
                        QuantityReserved = i.QuantityReserved,
                        BinLocation = i.BinLocation
                    };
                }).ToList()
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving product availability for product {ProductId}", productId);
            return StatusCode(500, "An error occurred while retrieving product availability");
        }
    }

    [HttpPost("reserve")]
    public async Task<ActionResult<InventoryReservation>> ReserveInventory([FromBody] CreateInventoryReservationRequest request)
    {
        try
        {
            var inventory = await _context.Inventories
                .FirstOrDefaultAsync(i => i.ProductId == request.ProductId && i.WarehouseId == request.WarehouseId);

            if (inventory == null)
                return NotFound($"Inventory not found for product {request.ProductId} in warehouse {request.WarehouseId}");

            if (inventory.QuantityAvailable < request.Quantity)
                return BadRequest($"Insufficient inventory. Available: {inventory.QuantityAvailable}, Requested: {request.Quantity}");

            // Update reservation
            inventory.QuantityReserved += request.Quantity;
            inventory.UpdatedAt = DateTime.UtcNow;

            // Create transaction record
            var transaction = new InventoryTransactionEntity
            {
                ProductId = request.ProductId,
                WarehouseId = request.WarehouseId,
                TransactionType = "RESERVE",
                Quantity = request.Quantity,
                ReferenceType = request.ReferenceType,
                ReferenceId = request.ReferenceId,
                TransactionDate = DateTime.UtcNow,
                Notes = $"Reserved {request.Quantity} units for {request.ReferenceType} {request.ReferenceId}"
            };

            _context.InventoryTransactions.Add(transaction);
            await _context.SaveChangesAsync();

            var product = await _context.Products.FindAsync(request.ProductId);

            var result = new InventoryReservation
            {
                ProductId = request.ProductId,
                ProductCode = product?.ProductCode ?? "",
                WarehouseId = request.WarehouseId,
                Quantity = request.Quantity,
                ReferenceType = request.ReferenceType,
                ReferenceId = request.ReferenceId,
                ReservedAt = DateTime.UtcNow
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error reserving inventory");
            return StatusCode(500, "An error occurred while reserving inventory");
        }
    }

    [HttpPost("update")]
    public async Task<ActionResult<InventoryItem>> UpdateInventory([FromBody] UpdateInventoryRequest request)
    {
        try
        {
            var inventory = await _context.Inventories
                .FirstOrDefaultAsync(i => i.ProductId == request.ProductId && i.WarehouseId == request.WarehouseId);

            if (inventory == null)
            {
                // Create new inventory record
                inventory = new InventoryEntity
                {
                    ProductId = request.ProductId,
                    WarehouseId = request.WarehouseId,
                    QuantityOnHand = request.Quantity,
                    QuantityReserved = 0,
                    QuantityOnOrder = 0,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Inventories.Add(inventory);
            }
            else
            {
                // Update existing inventory
                inventory.QuantityOnHand = request.Quantity;
                inventory.UpdatedAt = DateTime.UtcNow;
            }

            // Create transaction record
            var transaction = new InventoryTransactionEntity
            {
                ProductId = request.ProductId,
                WarehouseId = request.WarehouseId,
                TransactionType = request.TransactionType,
                Quantity = request.Quantity,
                TransactionDate = DateTime.UtcNow,
                Notes = request.Notes
            };

            _context.InventoryTransactions.Add(transaction);
            await _context.SaveChangesAsync();

            var product = await _context.Products.FindAsync(request.ProductId);
            var warehouse = await _context.Warehouses.FindAsync(request.WarehouseId);

            var result = new InventoryItem
            {
                InventoryId = inventory.InventoryId,
                ProductId = inventory.ProductId,
                ProductCode = product?.ProductCode ?? "",
                ProductName = product?.ProductName ?? "",
                WarehouseId = inventory.WarehouseId,
                WarehouseCode = warehouse?.WarehouseCode ?? "",
                WarehouseName = warehouse?.WarehouseName ?? "",
                QuantityOnHand = inventory.QuantityOnHand,
                QuantityReserved = inventory.QuantityReserved,
                QuantityAvailable = inventory.QuantityAvailable,
                QuantityOnOrder = inventory.QuantityOnOrder,
                BinLocation = inventory.BinLocation,
                LastCountDate = inventory.LastCountDate,
                UpdatedAt = inventory.UpdatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating inventory");
            return StatusCode(500, "An error occurred while updating inventory");
        }
    }
}
