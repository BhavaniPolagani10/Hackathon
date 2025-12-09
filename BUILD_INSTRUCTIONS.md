# Build Instructions for Heavy Machinery Dealer Management System

This document provides step-by-step instructions for building the Quote Service and Inventory Service, and integrating them with PostgreSQL.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setting Up PostgreSQL](#setting-up-postgresql)
3. [Building the Quote Service](#building-the-quote-service)
4. [Building the Inventory Service](#building-the-inventory-service)
5. [Running the Services](#running-the-services)
6. [Testing the Integration](#testing-the-integration)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

1. **.NET 8 SDK** (version 8.0 or later)
   - Download from: https://dotnet.microsoft.com/download/dotnet/8.0
   - Verify installation: `dotnet --version`

2. **PostgreSQL** (version 12 or later)
   - Download from: https://www.postgresql.org/download/
   - Recommended version: PostgreSQL 15 or 16

3. **Git** (for cloning the repository)
   - Download from: https://git-scm.com/downloads

### Optional Tools

- **pgAdmin** - PostgreSQL management tool (https://www.pgadmin.org/)
- **Postman** or **curl** - For testing API endpoints
- **Visual Studio 2022** or **VS Code** - For development

## Setting Up PostgreSQL

### Step 1: Install PostgreSQL

#### On Ubuntu/Debian:
```bash
# Update package lists
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Check status
sudo systemctl status postgresql
```

#### On macOS (using Homebrew):
```bash
# Install PostgreSQL
brew install postgresql@16

# Start PostgreSQL service
brew services start postgresql@16

# Verify installation
psql --version
```

#### On Windows:
1. Download the PostgreSQL installer from https://www.postgresql.org/download/windows/
2. Run the installer and follow the setup wizard
3. Remember the password you set for the `postgres` user
4. Add PostgreSQL bin directory to your PATH (usually done automatically)

### Step 2: Create Database and User

Connect to PostgreSQL:

```bash
# On Linux/macOS
sudo -u postgres psql

# On Windows (using Command Prompt as Administrator)
psql -U postgres
```

Run the following SQL commands:

```sql
-- Create the database
CREATE DATABASE heavy_machinery_dealer;

-- Optional: Create a dedicated user for the application
CREATE USER app_user WITH PASSWORD 'secure_password_here';

-- Grant privileges to the user
GRANT ALL PRIVILEGES ON DATABASE heavy_machinery_dealer TO app_user;

-- Connect to the new database
\c heavy_machinery_dealer

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO app_user;

-- Exit psql
\q
```

### Step 3: Initialize Database Schemas

Navigate to the repository root and run:

```bash
# Set the repository root path
cd /path/to/Hackathon

# Run CRM schema
psql -U postgres -d heavy_machinery_dealer -f db/schema/crm_schema.sql

# Run ERP schema
psql -U postgres -d heavy_machinery_dealer -f db/schema/erp_schema.sql
```

Verify the schemas were created:

```bash
psql -U postgres -d heavy_machinery_dealer -c "\dn"
```

You should see `crm` and `erp` schemas listed.

### Step 4: Verify Database Setup

Connect to the database and check tables:

```sql
psql -U postgres -d heavy_machinery_dealer

-- List all tables in CRM schema
\dt crm.*

-- List all tables in ERP schema
\dt erp.*

-- Check quote statuses (should show pre-populated data)
SELECT * FROM crm.crm_quote_status;

-- Check inventory data structure
\d erp.erp_inventory

-- Exit
\q
```

## Building the Quote Service

### Step 1: Navigate to Quote Service Directory

```bash
cd src/QuoteService
```

### Step 2: Configure Database Connection

Edit `appsettings.json` to update the PostgreSQL connection string:

```json
{
  "ConnectionStrings": {
    "QuoteDb": "Host=localhost;Port=5432;Database=heavy_machinery_dealer;Username=postgres;Password=your_password_here;Include Error Detail=true"
  }
}
```

Replace `your_password_here` with your actual PostgreSQL password.

### Step 3: Restore Dependencies

```bash
dotnet restore
```

### Step 4: Build the Service

```bash
# Build in Debug mode
dotnet build

# Or build in Release mode for production
dotnet build --configuration Release
```

Expected output:
```
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

### Step 5: Verify Build Artifacts

```bash
# Check that DLL was created
ls bin/Debug/net10.0/

# You should see QuoteService.dll
```

## Building the Inventory Service

### Step 1: Navigate to Inventory Service Directory

```bash
cd ../InventoryService
```

### Step 2: Configure Database Connection

Edit `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "InventoryDb": "Host=localhost;Port=5432;Database=heavy_machinery_dealer;Username=postgres;Password=your_password_here;Include Error Detail=true"
  }
}
```

### Step 3: Restore Dependencies

```bash
dotnet restore
```

### Step 4: Build the Service

```bash
# Build in Debug mode
dotnet build

# Or build in Release mode for production
dotnet build --configuration Release
```

### Step 5: Verify Build Artifacts

```bash
# Check that DLL was created
ls bin/Debug/net10.0/

# You should see InventoryService.dll
```

## Running the Services

### Option 1: Run from Command Line

#### Terminal 1 - Quote Service:
```bash
cd src/QuoteService
dotnet run
```

The service will start on:
- HTTP: http://localhost:5000
- HTTPS: https://localhost:5001

#### Terminal 2 - Inventory Service:
```bash
cd src/InventoryService
dotnet run
```

The service will start on:
- HTTP: http://localhost:5041
- HTTPS: https://localhost:7220

### Option 2: Run with Custom Ports

If the default ports are already in use:

```bash
# Quote Service on custom ports
dotnet run --urls "https://localhost:5011;http://localhost:5010"

# Inventory Service on custom ports
dotnet run --urls "https://localhost:5013;http://localhost:5012"
```

### Option 3: Run in Background

#### Using systemd (Linux):

Create service files for each service:

```bash
sudo nano /etc/systemd/system/quote-service.service
```

Add:
```ini
[Unit]
Description=Quote Service
After=network.target postgresql.service

[Service]
WorkingDirectory=/path/to/Hackathon/src/QuoteService
ExecStart=/usr/bin/dotnet run
Restart=always
RestartSec=10
User=your_username
Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable quote-service
sudo systemctl start quote-service
sudo systemctl status quote-service
```

## Testing the Integration

### Step 1: Verify Services are Running

Check that both services are responding:

```bash
# Test Quote Service
curl -k https://localhost:7123/api/quotes

# Test Inventory Service
curl -k https://localhost:7220/api/inventory
```

### Step 2: Access Swagger UI

Open your browser and navigate to:

- Quote Service: https://localhost:7123/swagger
- Inventory Service: https://localhost:7220/swagger

### Step 3: Test Quote Service

#### Create a Test Customer (via database):

```sql
psql -U postgres -d heavy_machinery_dealer

INSERT INTO crm.crm_customer (customer_code, customer_name, customer_type, is_active, created_at, updated_at)
VALUES ('CUST001', 'Test Construction Company', 'COMPANY', true, NOW(), NOW());

-- Get the customer_id
SELECT customer_id, customer_name FROM crm.crm_customer WHERE customer_code = 'CUST001';

\q
```

#### Create a Quote via API:

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
        "productName": "Test Heavy Equipment",
        "description": "Test item for quote",
        "quantity": 1,
        "unitPrice": 50000.00,
        "discountPercent": 5.0
      }
    ],
    "notes": "Test quote created via API"
  }' -k
```

#### Retrieve the Quote:

```bash
curl -k "https://localhost:7123/api/quotes" | jq
```

### Step 4: Test Inventory Service

#### Create Test Data (via database):

```sql
psql -U postgres -d heavy_machinery_dealer

-- Insert test product
INSERT INTO erp.erp_product (product_code, product_name, description, is_active, created_at, updated_at)
VALUES ('PROD001', 'Test Equipment', 'Test heavy equipment', true, NOW(), NOW());

-- Insert test warehouse
INSERT INTO erp.erp_warehouse (warehouse_code, warehouse_name, is_active, created_at, updated_at)
VALUES ('WH001', 'Main Warehouse', true, NOW(), NOW());

-- Insert test inventory
INSERT INTO erp.erp_inventory (product_id, warehouse_id, quantity_on_hand, quantity_reserved, quantity_on_order, updated_at, created_at)
VALUES (1, 1, 10, 0, 0, NOW(), NOW());

\q
```

#### Check Inventory via API:

```bash
curl -k "https://localhost:7220/api/inventory" | jq
```

#### Check Product Availability:

```bash
curl -k "https://localhost:7220/api/inventory/availability/1" | jq
```

#### Reserve Inventory:

```bash
curl -X POST "https://localhost:7220/api/inventory/reserve" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 1,
    "warehouseId": 1,
    "quantity": 2,
    "referenceType": "QUOTE",
    "referenceId": 1
  }' -k | jq
```

### Step 5: Verify Database Integration

Check that data was properly created:

```sql
psql -U postgres -d heavy_machinery_dealer

-- Check quotes
SELECT quote_id, quote_number, customer_id, total_amount, created_at 
FROM crm.crm_quotation 
ORDER BY created_at DESC 
LIMIT 5;

-- Check inventory transactions
SELECT transaction_id, product_id, warehouse_id, transaction_type, quantity, transaction_date
FROM erp.erp_inventory_transaction
ORDER BY transaction_date DESC
LIMIT 5;

\q
```

## Troubleshooting

### Issue: "Cannot connect to PostgreSQL"

**Solution 1:** Check if PostgreSQL is running
```bash
# Linux/macOS
sudo systemctl status postgresql
# or
brew services list

# Windows
services.msc  # Look for "postgresql-x64-XX" service
```

**Solution 2:** Verify connection parameters
```bash
# Test connection
psql -U postgres -h localhost -d heavy_machinery_dealer

# If this fails, check:
# 1. Username/password
# 2. Database name
# 3. PostgreSQL port (default: 5432)
```

**Solution 3:** Check pg_hba.conf
```bash
# Linux
sudo nano /etc/postgresql/15/main/pg_hba.conf

# Look for this line:
# host    all             all             127.0.0.1/32            md5

# Restart PostgreSQL after changes
sudo systemctl restart postgresql
```

### Issue: "Port already in use"

**Solution:** Run services on different ports
```bash
dotnet run --urls "https://localhost:6001;http://localhost:6000"
```

### Issue: "Build failed with errors"

**Solution 1:** Clean and rebuild
```bash
dotnet clean
dotnet restore
dotnet build
```

**Solution 2:** Check .NET SDK version
```bash
dotnet --version
# Should be 8.0.x or later
```

### Issue: "Database schema not found"

**Solution:** Re-run schema scripts
```bash
psql -U postgres -d heavy_machinery_dealer -f db/schema/crm_schema.sql
psql -U postgres -d heavy_machinery_dealer -f db/schema/erp_schema.sql
```

### Issue: "Swagger UI not loading"

**Solution:** Check that the service is running in Development mode
```bash
export ASPNETCORE_ENVIRONMENT=Development
dotnet run
```

### Issue: "Entity Framework errors"

**Solution 1:** Verify database connectivity
```csharp
// Add this to Program.cs temporarily for debugging
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<QuoteDbContext>();
    var canConnect = await db.Database.CanConnectAsync();
    Console.WriteLine($"Can connect to database: {canConnect}");
}
```

**Solution 2:** Check entity mappings
- Verify table names match exactly (case-sensitive)
- Verify column names use snake_case
- Check that schema names are correct (crm/erp)

## Production Deployment

For production deployment:

1. **Update Connection Strings**
   - Use environment variables instead of appsettings.json
   - Use strong passwords
   - Enable SSL for PostgreSQL connections

2. **Build for Production**
   ```bash
   dotnet publish -c Release -o ./publish
   ```

3. **Configure Reverse Proxy**
   - Use nginx or Apache as a reverse proxy
   - Configure SSL certificates
   - Set up load balancing if needed

4. **Set Up Monitoring**
   - Configure application logging
   - Set up database connection pooling
   - Monitor performance metrics

5. **Security Best Practices**
   - Use connection string encryption
   - Implement authentication/authorization
   - Enable CORS properly for your domain
   - Regular security updates

## Additional Resources

- [.NET 8 Documentation](https://docs.microsoft.com/en-us/dotnet/core/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Entity Framework Core Documentation](https://docs.microsoft.com/en-us/ef/core/)
- [ASP.NET Core Web API Documentation](https://docs.microsoft.com/en-us/aspnet/core/web-api/)

## Support

For issues specific to this application:
- Check the main [README.md](README.md)
- Review the [database schemas](db/schema/)
- Consult the [architecture documentation](doc/)
