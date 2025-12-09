# Quick Start Guide

Get the Heavy Machinery Dealer Management System up and running in minutes!

## Prerequisites

- .NET 8 SDK installed
- PostgreSQL installed and running

## Quick Setup (5 minutes)

### 1. Clone and Build

```bash
git clone https://github.com/BhavaniPolagani10/Hackathon.git
cd Hackathon
dotnet build
```

### 2. Setup PostgreSQL Database

```bash
# Create database
psql -U postgres -c "CREATE DATABASE heavy_machinery_dealer;"

# Run schemas
psql -U postgres -d heavy_machinery_dealer -f db/schema/crm_schema.sql
psql -U postgres -d heavy_machinery_dealer -f db/schema/erp_schema.sql
```

### 3. Update Connection Strings (if needed)

If your PostgreSQL password is not `postgres`, update these files:
- `src/QuoteService/appsettings.json`
- `src/InventoryService/appsettings.json`

Replace `Password=postgres` with your actual password.

### 4. Run the Services

**Terminal 1 - Quote Service:**
```bash
cd src/QuoteService
dotnet run
```

**Terminal 2 - Inventory Service:**
```bash
cd src/InventoryService
dotnet run
```

### 5. Test with Swagger

Open your browser:
- Quote Service: https://localhost:7123/swagger
- Inventory Service: https://localhost:7220/swagger

## Sample API Calls

### Create a Quote

```bash
curl -X POST "https://localhost:7123/api/quotes" \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": 1,
    "ownerId": 1,
    "validUntil": "2025-12-31",
    "lineItems": [{
      "productCode": "TEST-001",
      "productName": "Test Equipment",
      "quantity": 1,
      "unitPrice": 50000.00,
      "discountPercent": 0
    }]
  }' -k
```

### Get All Quotes

```bash
curl -X GET "https://localhost:7123/api/quotes" -k
```

### Check Inventory

```bash
curl -X GET "https://localhost:7220/api/inventory" -k
```

## What's Next?

- Read the full [README.md](README.md) for detailed documentation
- Check [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for comprehensive setup guide
- Review the database schemas in `db/schema/`

## Troubleshooting

**"Cannot connect to database"**
- Check if PostgreSQL is running: `sudo systemctl status postgresql`
- Verify your connection string in appsettings.json

**"Port already in use"**
- Run services on different ports:
  ```bash
  dotnet run --urls "https://localhost:8001;http://localhost:8000"
  ```

**"Database schema not found"**
- Re-run the schema files:
  ```bash
  psql -U postgres -d heavy_machinery_dealer -f db/schema/crm_schema.sql
  psql -U postgres -d heavy_machinery_dealer -f db/schema/erp_schema.sql
  ```

## Architecture Overview

```
┌─────────────────┐     ┌──────────────────┐
│  Quote Service  │     │ Inventory Service│
│  (Port 7123)    │     │   (Port 7220)    │
└────────┬────────┘     └────────┬─────────┘
         │                       │
         └───────────┬───────────┘
                     │
              ┌──────▼──────┐
              │  PostgreSQL │
              │  ┌────────┐ │
              │  │  CRM   │ │
              │  │ Schema │ │
              │  └────────┘ │
              │  ┌────────┐ │
              │  │  ERP   │ │
              │  │ Schema │ │
              │  └────────┘ │
              └─────────────┘
```

## Features

### Quote Service
- ✅ Create, Read, Update, Delete quotes
- ✅ Automatic quote number generation
- ✅ Line item management with discounts
- ✅ Quote total calculations
- ✅ Customer integration

### Inventory Service
- ✅ Real-time inventory tracking
- ✅ Multi-warehouse support
- ✅ Inventory reservations
- ✅ Transaction history
- ✅ Product availability checks

## Support

For detailed documentation and troubleshooting:
- [Full Documentation](README.md)
- [Build Instructions](BUILD_INSTRUCTIONS.md)
- [Database Schemas](db/schema/)
- [Architecture Docs](doc/)

Happy coding! 🚀
