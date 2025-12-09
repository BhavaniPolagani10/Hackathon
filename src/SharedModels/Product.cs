namespace SharedModels;

public class Product
{
    public int ProductId { get; set; }
    public string ProductCode { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Brand { get; set; }
    public string? ModelNumber { get; set; }
    public string? Manufacturer { get; set; }
    public decimal? ListPrice { get; set; }
    public string CurrencyCode { get; set; } = "USD";
    public bool IsActive { get; set; }
    public int LeadTimeDays { get; set; }
}
