using Microsoft.EntityFrameworkCore;
using InventoryService.Models;

namespace InventoryService.Data;

public class InventoryDbContext : DbContext
{
    public InventoryDbContext(DbContextOptions<InventoryDbContext> options) : base(options)
    {
    }

    public DbSet<InventoryEntity> Inventories { get; set; }
    public DbSet<ProductEntity> Products { get; set; }
    public DbSet<WarehouseEntity> Warehouses { get; set; }
    public DbSet<InventoryTransactionEntity> InventoryTransactions { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("erp");

        modelBuilder.Entity<InventoryEntity>(entity =>
        {
            entity.ToTable("erp_inventory");
            entity.HasKey(e => e.InventoryId);
            entity.Property(e => e.InventoryId).HasColumnName("inventory_id");
            entity.Property(e => e.ProductId).HasColumnName("product_id");
            entity.Property(e => e.WarehouseId).HasColumnName("warehouse_id");
            entity.Property(e => e.QuantityOnHand).HasColumnName("quantity_on_hand");
            entity.Property(e => e.QuantityReserved).HasColumnName("quantity_reserved");
            entity.Property(e => e.QuantityOnOrder).HasColumnName("quantity_on_order");
            entity.Property(e => e.BinLocation).HasColumnName("bin_location").HasMaxLength(50);
            entity.Property(e => e.LastCountDate).HasColumnName("last_count_date");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.Ignore(e => e.QuantityAvailable);
        });

        modelBuilder.Entity<ProductEntity>(entity =>
        {
            entity.ToTable("erp_product");
            entity.HasKey(e => e.ProductId);
            entity.Property(e => e.ProductId).HasColumnName("product_id");
            entity.Property(e => e.ProductCode).HasColumnName("product_code").HasMaxLength(100);
            entity.Property(e => e.ProductName).HasColumnName("product_name").HasMaxLength(300);
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.Brand).HasColumnName("brand").HasMaxLength(100);
            entity.Property(e => e.ModelNumber).HasColumnName("model_number").HasMaxLength(100);
            entity.Property(e => e.IsActive).HasColumnName("is_active");
        });

        modelBuilder.Entity<WarehouseEntity>(entity =>
        {
            entity.ToTable("erp_warehouse");
            entity.HasKey(e => e.WarehouseId);
            entity.Property(e => e.WarehouseId).HasColumnName("warehouse_id");
            entity.Property(e => e.WarehouseCode).HasColumnName("warehouse_code").HasMaxLength(50);
            entity.Property(e => e.WarehouseName).HasColumnName("warehouse_name").HasMaxLength(200);
            entity.Property(e => e.IsActive).HasColumnName("is_active");
        });

        modelBuilder.Entity<InventoryTransactionEntity>(entity =>
        {
            entity.ToTable("erp_inventory_transaction");
            entity.HasKey(e => e.TransactionId);
            entity.Property(e => e.TransactionId).HasColumnName("transaction_id");
            entity.Property(e => e.ProductId).HasColumnName("product_id");
            entity.Property(e => e.WarehouseId).HasColumnName("warehouse_id");
            entity.Property(e => e.TransactionType).HasColumnName("transaction_type").HasMaxLength(50);
            entity.Property(e => e.Quantity).HasColumnName("quantity");
            entity.Property(e => e.ReferenceType).HasColumnName("reference_type").HasMaxLength(50);
            entity.Property(e => e.ReferenceId).HasColumnName("reference_id");
            entity.Property(e => e.TransactionDate).HasColumnName("transaction_date");
            entity.Property(e => e.Notes).HasColumnName("notes");
        });
    }
}
