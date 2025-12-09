namespace InventoryService.Models;

public class InventoryEntity
{
    public int InventoryId { get; set; }
    public int ProductId { get; set; }
    public int WarehouseId { get; set; }
    public int QuantityOnHand { get; set; }
    public int QuantityReserved { get; set; }
    public int QuantityAvailable => QuantityOnHand - QuantityReserved;
    public int QuantityOnOrder { get; set; }
    public string? BinLocation { get; set; }
    public DateTime? LastCountDate { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class ProductEntity
{
    public int ProductId { get; set; }
    public string ProductCode { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Brand { get; set; }
    public string? ModelNumber { get; set; }
    public bool IsActive { get; set; }
}

public class WarehouseEntity
{
    public int WarehouseId { get; set; }
    public string WarehouseCode { get; set; } = string.Empty;
    public string WarehouseName { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}

public class InventoryTransactionEntity
{
    public int TransactionId { get; set; }
    public int ProductId { get; set; }
    public int WarehouseId { get; set; }
    public string TransactionType { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public string? ReferenceType { get; set; }
    public int? ReferenceId { get; set; }
    public DateTime TransactionDate { get; set; }
    public string? Notes { get; set; }
}
