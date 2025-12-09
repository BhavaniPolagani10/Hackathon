# Heavy Machinery Dealer Management System - .NET 8 Web Application

This repository contains a comprehensive .NET 8 web application for managing quotes and inventory for a heavy machinery dealer. The application consists of two microservices that integrate with PostgreSQL databases.

## Architecture Overview

The application follows a microservices architecture with:

- **Quote Service**: Manages quotations, customers, and products from the CRM database
- **Inventory Service**: Manages inventory, warehouses, and stock from the ERP database
- **Shared Models**: Common data models used across services
- **PostgreSQL Database**: Backend database with separate CRM and ERP schemas

## Prerequisites

Before building and running the application, ensure you have the following installed:

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) (version 8.0 or later)
- [PostgreSQL](https://www.postgresql.org/download/) (version 12 or later)
- [pgAdmin](https://www.pgadmin.org/) or any PostgreSQL client (optional, for database management)

## Database Setup

### 1. Install PostgreSQL

If PostgreSQL is not already installed:

**On Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

**On macOS:**
```bash
brew install postgresql@16
brew services start postgresql@16
```

**On Windows:**
Download and install from https://www.postgresql.org/download/windows/

### 2. Create Database and Schemas

Connect to PostgreSQL and create the database:

```bash
# Connect as postgres user
sudo -u postgres psql

# Or on Windows/macOS
psql -U postgres
```

Run the following SQL commands:

```sql
-- Create database
CREATE DATABASE heavy_machinery_dealer;

-- Connect to the database
\c heavy_machinery_dealer

-- Create schemas (run the schema files)
-- Run db/schema/crm_schema.sql
-- Run db/schema/erp_schema.sql
```

Alternatively, run the schema files directly:

```bash
# From the repository root
psql -U postgres -d heavy_machinery_dealer -f db/schema/crm_schema.sql
psql -U postgres -d heavy_machinery_dealer -f db/schema/erp_schema.sql
```

### 3. Configure Database Connection

Update the connection strings in the application settings if your PostgreSQL setup differs:

**For Quote Service** - `src/QuoteService/appsettings.json`:
```json
{
  "ConnectionStrings": {
    "QuoteDb": "Host=localhost;Port=5432;Database=heavy_machinery_dealer;Username=postgres;Password=your_password"
  }
}
```

**For Inventory Service** - `src/InventoryService/appsettings.json`:
```json
{
  "ConnectionStrings": {
    "InventoryDb": "Host=localhost;Port=5432;Database=heavy_machinery_dealer;Username=postgres;Password=your_password"
  }
}
```

## Building the Application

### Build All Projects

From the repository root:

```bash
# Restore dependencies
dotnet restore

# Build the entire solution
dotnet build

# Or build in Release mode
dotnet build --configuration Release
```

### Build Individual Services

**Build Quote Service:**
```bash
cd src/QuoteService
dotnet build
```

**Build Inventory Service:**
```bash
cd src/InventoryService
dotnet build
```

## Running the Services

### Run Quote Service

```bash
cd src/QuoteService
dotnet run
```

The Quote Service will start on:
- HTTP: http://localhost:5000
- HTTPS: https://localhost:7123

Swagger UI available at: https://localhost:7123/swagger

### Run Inventory Service

```bash
cd src/InventoryService
dotnet run
```

The Inventory Service will start on:
- HTTP: http://localhost:5041
- HTTPS: https://localhost:7220

Swagger UI available at: https://localhost:7220/swagger

### Run Both Services Simultaneously

Open two terminal windows and run each service separately, or use a process manager like `tmux` or `screen`.

## API Endpoints

### Quote Service (Port 7123)

#### Get All Quotes
```bash
GET /api/quotes
Query Parameters:
  - customerId (optional): Filter by customer ID
  - statusId (optional): Filter by status ID
  - page (default: 1): Page number
  - pageSize (default: 20): Items per page
```

#### Get Single Quote
```bash
GET /api/quotes/{id}
```

#### Create Quote
```bash
POST /api/quotes
Content-Type: application/json

{
  "customerId": 1,
  "contactId": 1,
  "opportunityId": 1,
  "ownerId": 1,
  "validUntil": "2025-12-31",
  "currencyCode": "USD",
  "lineItems": [
    {
      "productId": 1,
      "productCode": "CAT-320",
      "productName": "Caterpillar 320 Excavator",
      "description": "Mid-size excavator",
      "quantity": 1,
      "unitPrice": 150000.00,
      "discountPercent": 5.0
    }
  ],
  "notes": "Initial quote for construction project"
}
```

#### Update Quote
```bash
PUT /api/quotes/{id}
Content-Type: application/json

{
  "customerId": 1,
  "validUntil": "2025-12-31",
  "lineItems": [...],
  "notes": "Updated quote"
}
```

#### Delete Quote
```bash
DELETE /api/quotes/{id}
```

### Inventory Service (Port 7220)

#### Get All Inventory
```bash
GET /api/inventory
Query Parameters:
  - warehouseId (optional): Filter by warehouse ID
  - productId (optional): Filter by product ID
  - page (default: 1): Page number
  - pageSize (default: 50): Items per page
```

#### Get Product Availability
```bash
GET /api/inventory/availability/{productId}
```

#### Reserve Inventory
```bash
POST /api/inventory/reserve
Content-Type: application/json

{
  "productId": 1,
  "warehouseId": 1,
  "quantity": 1,
  "referenceType": "QUOTE",
  "referenceId": 123
}
```

#### Update Inventory
```bash
POST /api/inventory/update
Content-Type: application/json

{
  "productId": 1,
  "warehouseId": 1,
  "quantity": 10,
  "transactionType": "ADJUSTMENT",
  "notes": "Physical count adjustment"
}
```

## Testing the Services

### Using Swagger UI

1. Navigate to the Swagger UI for each service:
   - Quote Service: https://localhost:7123/swagger
   - Inventory Service: https://localhost:7220/swagger

2. Use the "Try it out" feature to test endpoints interactively

### Using cURL

**Get all quotes:**
```bash
curl -X GET "https://localhost:7123/api/quotes" -k
```

**Get inventory availability:**
```bash
curl -X GET "https://localhost:7220/api/inventory/availability/1" -k
```

**Create a quote:**
```bash
curl -X POST "https://localhost:7123/api/quotes" \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": 1,
    "ownerId": 1,
    "validUntil": "2025-12-31",
    "lineItems": [
      {
        "productCode": "TEST-001",
        "productName": "Test Product",
        "quantity": 1,
        "unitPrice": 1000.00,
        "discountPercent": 0
      }
    ]
  }' -k
```

## Project Structure

```
.
├── HeavyMachineryDealer.sln          # Solution file
├── README.md                          # This file
├── db/
│   └── schema/
│       ├── crm_schema.sql            # CRM database schema
│       └── erp_schema.sql            # ERP database schema
├── doc/                               # Documentation
├── frontend/                          # Frontend application (existing)
└── src/
    ├── QuoteService/
    │   ├── Controllers/
    │   │   └── QuotesController.cs   # Quote API endpoints
    │   ├── Data/
    │   │   └── QuoteDbContext.cs     # EF Core context for CRM
    │   ├── Models/
    │   │   └── QuoteEntity.cs        # Database entities
    │   ├── Program.cs                # Application entry point
    │   ├── appsettings.json          # Configuration
    │   └── QuoteService.csproj       # Project file
    ├── InventoryService/
    │   ├── Controllers/
    │   │   └── InventoryController.cs # Inventory API endpoints
    │   ├── Data/
    │   │   └── InventoryDbContext.cs  # EF Core context for ERP
    │   ├── Models/
    │   │   └── InventoryEntity.cs     # Database entities
    │   ├── Program.cs                 # Application entry point
    │   ├── appsettings.json           # Configuration
    │   └── InventoryService.csproj    # Project file
    └── SharedModels/
        ├── Quote.cs                   # Shared quote models
        ├── Inventory.cs               # Shared inventory models
        ├── Product.cs                 # Shared product models
        └── SharedModels.csproj        # Project file
```

## PostgreSQL Integration Details

### Entity Framework Core

The application uses Entity Framework Core with Npgsql provider for PostgreSQL integration.

**Key Features:**
- Database-first approach using existing schemas
- Schema mapping to snake_case PostgreSQL conventions
- Support for both CRM and ERP schemas in the same database
- Connection pooling for improved performance

### Database Context Configuration

Both services configure their DbContext in `Program.cs`:

```csharp
builder.Services.AddDbContext<QuoteDbContext>(options =>
    options.UseNpgsql(connectionString));
```

### Schema Mapping

The DbContext classes map C# entities to PostgreSQL tables with proper schema prefixes:

```csharp
modelBuilder.HasDefaultSchema("crm");  // or "erp"

modelBuilder.Entity<QuoteEntity>(entity =>
{
    entity.ToTable("crm_quotation");
    entity.Property(e => e.QuoteId).HasColumnName("quote_id");
    // ... more mappings
});
```

## Deployment

### Development Environment

1. Ensure PostgreSQL is running
2. Run database migrations (if any)
3. Start both services
4. Access via Swagger UI or integrate with frontend

### Production Deployment

For production deployment:

1. **Update Configuration:**
   - Set production connection strings in environment variables
   - Configure proper authentication and authorization
   - Enable HTTPS with valid certificates

2. **Build for Production:**
   ```bash
   dotnet publish -c Release -o ./publish
   ```

3. **Deploy:**
   - Deploy to Azure App Service, AWS Elastic Beanstalk, or similar
   - Use Docker containers for containerized deployment
   - Set up load balancing for high availability

### Docker Deployment

Create a `Dockerfile` for each service:

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["QuoteService/QuoteService.csproj", "QuoteService/"]
COPY ["SharedModels/SharedModels.csproj", "SharedModels/"]
RUN dotnet restore "QuoteService/QuoteService.csproj"
COPY . .
WORKDIR "/src/QuoteService"
RUN dotnet build "QuoteService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "QuoteService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "QuoteService.dll"]
```

Build and run with Docker:
```bash
docker build -t quote-service -f src/QuoteService/Dockerfile .
docker run -p 5001:80 quote-service
```

## Troubleshooting

### Cannot connect to PostgreSQL

1. Check if PostgreSQL is running:
   ```bash
   sudo service postgresql status
   ```

2. Verify connection string in appsettings.json
3. Check PostgreSQL authentication (pg_hba.conf)
4. Ensure database and schemas exist

### Port already in use

If ports 5001 or 5003 are already in use, you can specify different ports:

```bash
dotnet run --urls "https://localhost:5011;http://localhost:5010"
```

### Database migration errors

If you encounter schema-related errors:
1. Verify that the schema SQL files have been executed
2. Check that the database user has proper permissions
3. Review Entity Framework Core logs in the console

## Contributing

When contributing to this project:

1. Follow C# coding conventions
2. Use snake_case for database column names (PostgreSQL convention)
3. Use PascalCase for C# properties and classes
4. Write unit tests for new features
5. Update documentation as needed

## License

This project is part of the Heavy Machinery Dealer Management System.

## Support

For issues and questions:
- Check the documentation in the `/doc` directory
- Review database schema diagrams
- Consult the API documentation via Swagger UI

## Related Documentation

- [High-Level Design](doc/hld/HIGH_LEVEL_DESIGN.md)
- [Low-Level Design](doc/lld/LOW_LEVEL_DESIGN.md)
- [Architecture Decision Records](doc/adr/)
- [Database Schema](db/schema/)
