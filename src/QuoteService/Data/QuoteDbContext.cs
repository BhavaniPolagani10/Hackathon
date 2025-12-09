using Microsoft.EntityFrameworkCore;
using QuoteService.Models;

namespace QuoteService.Data;

public class QuoteDbContext : DbContext
{
    public QuoteDbContext(DbContextOptions<QuoteDbContext> options) : base(options)
    {
    }

    public DbSet<QuoteEntity> Quotations { get; set; }
    public DbSet<QuoteLineItemEntity> QuoteLineItems { get; set; }
    public DbSet<CustomerEntity> Customers { get; set; }
    public DbSet<ProductEntity> Products { get; set; }
    public DbSet<QuoteStatusEntity> QuoteStatuses { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("crm");

        modelBuilder.Entity<QuoteEntity>(entity =>
        {
            entity.ToTable("crm_quotation");
            entity.HasKey(e => e.QuoteId);
            entity.Property(e => e.QuoteId).HasColumnName("quote_id");
            entity.Property(e => e.QuoteNumber).HasColumnName("quote_number").HasMaxLength(50);
            entity.Property(e => e.QuoteName).HasColumnName("quote_name").HasMaxLength(300);
            entity.Property(e => e.RevisionNumber).HasColumnName("revision_number");
            entity.Property(e => e.CustomerId).HasColumnName("customer_id");
            entity.Property(e => e.ContactId).HasColumnName("contact_id");
            entity.Property(e => e.OpportunityId).HasColumnName("opportunity_id");
            entity.Property(e => e.StatusId).HasColumnName("status_id");
            entity.Property(e => e.OwnerId).HasColumnName("owner_id");
            entity.Property(e => e.QuoteDate).HasColumnName("quote_date");
            entity.Property(e => e.ValidUntil).HasColumnName("valid_until");
            entity.Property(e => e.CurrencyId).HasColumnName("currency_id");
            entity.Property(e => e.Subtotal).HasColumnName("subtotal").HasPrecision(15, 2);
            entity.Property(e => e.DiscountAmount).HasColumnName("discount_amount").HasPrecision(15, 2);
            entity.Property(e => e.TaxAmount).HasColumnName("tax_amount").HasPrecision(15, 2);
            entity.Property(e => e.ShippingAmount).HasColumnName("shipping_amount").HasPrecision(15, 2);
            entity.Property(e => e.TotalAmount).HasColumnName("total_amount").HasPrecision(15, 2);
            entity.Property(e => e.Notes).HasColumnName("notes");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
        });

        modelBuilder.Entity<QuoteLineItemEntity>(entity =>
        {
            entity.ToTable("crm_quote_line_item");
            entity.HasKey(e => e.LineItemId);
            entity.Property(e => e.LineItemId).HasColumnName("line_item_id");
            entity.Property(e => e.QuoteId).HasColumnName("quote_id");
            entity.Property(e => e.LineNumber).HasColumnName("line_number");
            entity.Property(e => e.ProductId).HasColumnName("product_id");
            entity.Property(e => e.ProductCode).HasColumnName("product_code").HasMaxLength(100);
            entity.Property(e => e.ProductName).HasColumnName("product_name").HasMaxLength(300);
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.Quantity).HasColumnName("quantity");
            entity.Property(e => e.UnitPrice).HasColumnName("unit_price").HasPrecision(15, 4);
            entity.Property(e => e.DiscountPercent).HasColumnName("discount_percent").HasPrecision(5, 2);
            entity.Property(e => e.LineTotal).HasColumnName("line_total").HasPrecision(15, 2);
            entity.Property(e => e.Notes).HasColumnName("notes");
        });

        modelBuilder.Entity<CustomerEntity>(entity =>
        {
            entity.ToTable("crm_customer");
            entity.HasKey(e => e.CustomerId);
            entity.Property(e => e.CustomerId).HasColumnName("customer_id");
            entity.Property(e => e.CustomerCode).HasColumnName("customer_code").HasMaxLength(50);
            entity.Property(e => e.CustomerName).HasColumnName("customer_name").HasMaxLength(300);
        });

        modelBuilder.Entity<ProductEntity>(entity =>
        {
            entity.ToTable("crm_product");
            entity.HasKey(e => e.ProductId);
            entity.Property(e => e.ProductId).HasColumnName("product_id");
            entity.Property(e => e.ProductCode).HasColumnName("product_code").HasMaxLength(100);
            entity.Property(e => e.ProductName).HasColumnName("product_name").HasMaxLength(300);
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.Brand).HasColumnName("brand").HasMaxLength(100);
            entity.Property(e => e.ModelNumber).HasColumnName("model_number").HasMaxLength(100);
            entity.Property(e => e.Manufacturer).HasColumnName("manufacturer").HasMaxLength(200);
            entity.Property(e => e.IsActive).HasColumnName("is_active");
            entity.Property(e => e.LeadTimeDays).HasColumnName("lead_time_days");
        });

        modelBuilder.Entity<QuoteStatusEntity>(entity =>
        {
            entity.ToTable("crm_quote_status");
            entity.HasKey(e => e.StatusId);
            entity.Property(e => e.StatusId).HasColumnName("status_id");
            entity.Property(e => e.StatusCode).HasColumnName("status_code").HasMaxLength(50);
            entity.Property(e => e.StatusName).HasColumnName("status_name").HasMaxLength(100);
        });
    }
}
