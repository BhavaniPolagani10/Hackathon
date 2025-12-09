namespace QuoteService.Models;

public class QuoteEntity
{
    public int QuoteId { get; set; }
    public string QuoteNumber { get; set; } = string.Empty;
    public string? QuoteName { get; set; }
    public int RevisionNumber { get; set; } = 1;
    public int CustomerId { get; set; }
    public int? ContactId { get; set; }
    public int? OpportunityId { get; set; }
    public int StatusId { get; set; }
    public int OwnerId { get; set; }
    public DateTime QuoteDate { get; set; }
    public DateTime ValidUntil { get; set; }
    public int CurrencyId { get; set; }
    public decimal Subtotal { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal ShippingAmount { get; set; }
    public decimal TotalAmount { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class QuoteLineItemEntity
{
    public int LineItemId { get; set; }
    public int QuoteId { get; set; }
    public int LineNumber { get; set; }
    public int? ProductId { get; set; }
    public string ProductCode { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal DiscountPercent { get; set; }
    public decimal LineTotal { get; set; }
    public string? Notes { get; set; }
}

public class CustomerEntity
{
    public int CustomerId { get; set; }
    public string CustomerCode { get; set; } = string.Empty;
    public string CustomerName { get; set; } = string.Empty;
}

public class ProductEntity
{
    public int ProductId { get; set; }
    public string ProductCode { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Brand { get; set; }
    public string? ModelNumber { get; set; }
    public string? Manufacturer { get; set; }
    public bool IsActive { get; set; }
    public int LeadTimeDays { get; set; }
}

public class QuoteStatusEntity
{
    public int StatusId { get; set; }
    public string StatusCode { get; set; } = string.Empty;
    public string StatusName { get; set; } = string.Empty;
}
