namespace SharedModels;

public class InventoryItem
{
    public int InventoryId { get; set; }
    public int ProductId { get; set; }
    public string ProductCode { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public int WarehouseId { get; set; }
    public string WarehouseCode { get; set; } = string.Empty;
    public string WarehouseName { get; set; } = string.Empty;
    public int QuantityOnHand { get; set; }
    public int QuantityReserved { get; set; }
    public int QuantityAvailable { get; set; }
    public int QuantityOnOrder { get; set; }
    public string? BinLocation { get; set; }
    public DateTime? LastCountDate { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class InventoryReservation
{
    public int ProductId { get; set; }
    public string ProductCode { get; set; } = string.Empty;
    public int WarehouseId { get; set; }
    public int Quantity { get; set; }
    public string ReferenceType { get; set; } = string.Empty;
    public int ReferenceId { get; set; }
    public DateTime ReservedAt { get; set; }
}

public class CreateInventoryReservationRequest
{
    public int ProductId { get; set; }
    public int WarehouseId { get; set; }
    public int Quantity { get; set; }
    public string ReferenceType { get; set; } = "QUOTE";
    public int ReferenceId { get; set; }
}

public class UpdateInventoryRequest
{
    public int ProductId { get; set; }
    public int WarehouseId { get; set; }
    public int Quantity { get; set; }
    public string TransactionType { get; set; } = "ADJUSTMENT";
    public string? Notes { get; set; }
}

public class InventoryAvailability
{
    public int ProductId { get; set; }
    public string ProductCode { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public List<WarehouseInventory> Warehouses { get; set; } = new();
    public int TotalAvailable { get; set; }
    public int TotalReserved { get; set; }
    public int TotalOnOrder { get; set; }
}

public class WarehouseInventory
{
    public int WarehouseId { get; set; }
    public string WarehouseCode { get; set; } = string.Empty;
    public string WarehouseName { get; set; } = string.Empty;
    public int QuantityAvailable { get; set; }
    public int QuantityReserved { get; set; }
    public string? BinLocation { get; set; }
}
