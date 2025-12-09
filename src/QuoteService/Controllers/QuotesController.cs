using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuoteService.Data;
using QuoteService.Models;
using SharedModels;

namespace QuoteService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class QuotesController : ControllerBase
{
    private readonly QuoteDbContext _context;
    private readonly ILogger<QuotesController> _logger;

    public QuotesController(QuoteDbContext context, ILogger<QuotesController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Quote>>> GetQuotes(
        [FromQuery] int? customerId = null,
        [FromQuery] int? statusId = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        try
        {
            var query = _context.Quotations.AsQueryable();

            if (customerId.HasValue)
                query = query.Where(q => q.CustomerId == customerId.Value);

            if (statusId.HasValue)
                query = query.Where(q => q.StatusId == statusId.Value);

            var quotes = await query
                .OrderByDescending(q => q.QuoteDate)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var customerIds = quotes.Select(q => q.CustomerId).Distinct().ToList();
            var customers = await _context.Customers
                .Where(c => customerIds.Contains(c.CustomerId))
                .ToListAsync();

            var statusIds = quotes.Select(q => q.StatusId).Distinct().ToList();
            var statuses = await _context.QuoteStatuses
                .Where(s => statusIds.Contains(s.StatusId))
                .ToListAsync();

            var result = quotes.Select(q => new Quote
            {
                QuoteId = q.QuoteId,
                QuoteNumber = q.QuoteNumber,
                QuoteName = q.QuoteName,
                RevisionNumber = q.RevisionNumber,
                CustomerId = q.CustomerId,
                CustomerName = customers.FirstOrDefault(c => c.CustomerId == q.CustomerId)?.CustomerName ?? "",
                ContactId = q.ContactId,
                OpportunityId = q.OpportunityId,
                StatusId = q.StatusId,
                StatusName = statuses.FirstOrDefault(s => s.StatusId == q.StatusId)?.StatusName ?? "",
                OwnerId = q.OwnerId,
                OwnerName = "",
                QuoteDate = q.QuoteDate,
                ValidUntil = q.ValidUntil,
                CurrencyCode = "USD",
                Subtotal = q.Subtotal,
                DiscountAmount = q.DiscountAmount,
                TaxAmount = q.TaxAmount,
                ShippingAmount = q.ShippingAmount,
                TotalAmount = q.TotalAmount,
                Notes = q.Notes,
                CreatedAt = q.CreatedAt,
                UpdatedAt = q.UpdatedAt
            }).ToList();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving quotes");
            return StatusCode(500, "An error occurred while retrieving quotes");
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Quote>> GetQuote(int id)
    {
        try
        {
            var quote = await _context.Quotations.FindAsync(id);
            if (quote == null)
                return NotFound($"Quote with ID {id} not found");

            var lineItems = await _context.QuoteLineItems
                .Where(li => li.QuoteId == id)
                .OrderBy(li => li.LineNumber)
                .ToListAsync();

            var customer = await _context.Customers.FindAsync(quote.CustomerId);
            var status = await _context.QuoteStatuses.FindAsync(quote.StatusId);

            var result = new Quote
            {
                QuoteId = quote.QuoteId,
                QuoteNumber = quote.QuoteNumber,
                QuoteName = quote.QuoteName,
                RevisionNumber = quote.RevisionNumber,
                CustomerId = quote.CustomerId,
                CustomerName = customer?.CustomerName ?? "",
                ContactId = quote.ContactId,
                OpportunityId = quote.OpportunityId,
                StatusId = quote.StatusId,
                StatusName = status?.StatusName ?? "",
                OwnerId = quote.OwnerId,
                OwnerName = "",
                QuoteDate = quote.QuoteDate,
                ValidUntil = quote.ValidUntil,
                CurrencyCode = "USD",
                Subtotal = quote.Subtotal,
                DiscountAmount = quote.DiscountAmount,
                TaxAmount = quote.TaxAmount,
                ShippingAmount = quote.ShippingAmount,
                TotalAmount = quote.TotalAmount,
                LineItems = lineItems.Select(li => new QuoteLineItem
                {
                    LineItemId = li.LineItemId,
                    QuoteId = li.QuoteId,
                    LineNumber = li.LineNumber,
                    ProductId = li.ProductId,
                    ProductCode = li.ProductCode,
                    ProductName = li.ProductName,
                    Description = li.Description,
                    Quantity = li.Quantity,
                    UnitPrice = li.UnitPrice,
                    DiscountPercent = li.DiscountPercent,
                    LineTotal = li.LineTotal,
                    Notes = li.Notes
                }).ToList(),
                Notes = quote.Notes,
                CreatedAt = quote.CreatedAt,
                UpdatedAt = quote.UpdatedAt
            };

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving quote {QuoteId}", id);
            return StatusCode(500, "An error occurred while retrieving the quote");
        }
    }

    [HttpPost]
    public async Task<ActionResult<Quote>> CreateQuote([FromBody] CreateQuoteRequest request)
    {
        try
        {
            // Validate customer exists
            var customer = await _context.Customers.FindAsync(request.CustomerId);
            if (customer == null)
                return BadRequest($"Customer with ID {request.CustomerId} not found");

            // Get default draft status
            var draftStatus = await _context.QuoteStatuses
                .FirstOrDefaultAsync(s => s.StatusCode == "DRAFT");
            if (draftStatus == null)
                return StatusCode(500, "Default quote status not found");

            // Generate quote number
            var quoteNumber = $"Q-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString("N").Substring(0, 6).ToUpper()}";

            // Calculate totals
            decimal subtotal = 0;
            foreach (var item in request.LineItems)
            {
                var lineTotal = item.Quantity * item.UnitPrice * (1 - item.DiscountPercent / 100);
                subtotal += lineTotal;
            }

            var quote = new QuoteEntity
            {
                QuoteNumber = quoteNumber,
                CustomerId = request.CustomerId,
                ContactId = request.ContactId,
                OpportunityId = request.OpportunityId,
                StatusId = draftStatus.StatusId,
                OwnerId = request.OwnerId,
                QuoteDate = DateTime.UtcNow.Date,
                ValidUntil = request.ValidUntil,
                CurrencyId = 1, // USD
                Subtotal = subtotal,
                DiscountAmount = 0,
                TaxAmount = 0,
                ShippingAmount = 0,
                TotalAmount = subtotal,
                Notes = request.Notes,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.Quotations.Add(quote);
            await _context.SaveChangesAsync();

            // Add line items
            int lineNumber = 1;
            foreach (var item in request.LineItems)
            {
                var lineTotal = item.Quantity * item.UnitPrice * (1 - item.DiscountPercent / 100);
                var lineItem = new QuoteLineItemEntity
                {
                    QuoteId = quote.QuoteId,
                    LineNumber = lineNumber++,
                    ProductId = item.ProductId,
                    ProductCode = item.ProductCode,
                    ProductName = item.ProductName,
                    Description = item.Description,
                    Quantity = item.Quantity,
                    UnitPrice = item.UnitPrice,
                    DiscountPercent = item.DiscountPercent,
                    LineTotal = lineTotal
                };
                _context.QuoteLineItems.Add(lineItem);
            }

            await _context.SaveChangesAsync();

            // Return created quote
            return await GetQuote(quote.QuoteId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating quote");
            return StatusCode(500, "An error occurred while creating the quote");
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<Quote>> UpdateQuote(int id, [FromBody] CreateQuoteRequest request)
    {
        try
        {
            var quote = await _context.Quotations.FindAsync(id);
            if (quote == null)
                return NotFound($"Quote with ID {id} not found");

            // Update quote
            decimal subtotal = 0;
            foreach (var item in request.LineItems)
            {
                var lineTotal = item.Quantity * item.UnitPrice * (1 - item.DiscountPercent / 100);
                subtotal += lineTotal;
            }

            quote.ValidUntil = request.ValidUntil;
            quote.Subtotal = subtotal;
            quote.TotalAmount = subtotal;
            quote.Notes = request.Notes;
            quote.UpdatedAt = DateTime.UtcNow;

            // Remove existing line items and add new ones
            var existingItems = await _context.QuoteLineItems
                .Where(li => li.QuoteId == id)
                .ToListAsync();
            _context.QuoteLineItems.RemoveRange(existingItems);

            int lineNumber = 1;
            foreach (var item in request.LineItems)
            {
                var lineTotal = item.Quantity * item.UnitPrice * (1 - item.DiscountPercent / 100);
                var lineItem = new QuoteLineItemEntity
                {
                    QuoteId = quote.QuoteId,
                    LineNumber = lineNumber++,
                    ProductId = item.ProductId,
                    ProductCode = item.ProductCode,
                    ProductName = item.ProductName,
                    Description = item.Description,
                    Quantity = item.Quantity,
                    UnitPrice = item.UnitPrice,
                    DiscountPercent = item.DiscountPercent,
                    LineTotal = lineTotal
                };
                _context.QuoteLineItems.Add(lineItem);
            }

            await _context.SaveChangesAsync();

            return await GetQuote(id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating quote {QuoteId}", id);
            return StatusCode(500, "An error occurred while updating the quote");
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteQuote(int id)
    {
        try
        {
            var quote = await _context.Quotations.FindAsync(id);
            if (quote == null)
                return NotFound($"Quote with ID {id} not found");

            var lineItems = await _context.QuoteLineItems
                .Where(li => li.QuoteId == id)
                .ToListAsync();
            
            _context.QuoteLineItems.RemoveRange(lineItems);
            _context.Quotations.Remove(quote);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting quote {QuoteId}", id);
            return StatusCode(500, "An error occurred while deleting the quote");
        }
    }
}
