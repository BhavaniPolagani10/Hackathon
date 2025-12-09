# Backend Development Guide: Building Web Applications with .NET 8

## Heavy Machinery Dealer Management System

This comprehensive guide provides step-by-step instructions for building the backend services of the Heavy Machinery Dealer Management System using .NET 8, with a focus on the Quote Service and Inventory Service, and integration with PostgreSQL.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Getting Started with .NET 8](#getting-started-with-net-8)
3. [Project Structure](#project-structure)
4. [PostgreSQL Setup and Integration](#postgresql-setup-and-integration)
5. [Building the Quote Service](#building-the-quote-service)
6. [Building the Inventory Service](#building-the-inventory-service)
7. [API Implementation](#api-implementation)
8. [Database Migrations](#database-migrations)
9. [Testing](#testing)
10. [Deployment](#deployment)

---

## Prerequisites

Before you begin, ensure you have the following installed on your development machine:

### Required Software

```bash
# .NET 8 SDK
# Download from: https://dotnet.microsoft.com/download/dotnet/8.0
dotnet --version  # Should show 8.0.x

# PostgreSQL 15 or higher
# Download from: https://www.postgresql.org/download/
psql --version  # Should show PostgreSQL 15.x or higher

# Docker (optional, for containerization)
docker --version

# Git
git --version
```

### Development Tools (Recommended)

- **Visual Studio 2022** (v17.8 or later) OR **Visual Studio Code** with C# extension
- **Azure Data Studio** or **pgAdmin** for database management
- **Postman** or **Swagger UI** for API testing
- **Entity Framework Core Tools**

```bash
# Install EF Core tools globally
dotnet tool install --global dotnet-ef
dotnet ef --version
```

---

## Getting Started with .NET 8

### 1. Verify .NET 8 Installation

```bash
dotnet --list-sdks
# Should include: 8.0.xxx

dotnet --list-runtimes
# Should include: Microsoft.AspNetCore.App 8.0.x
```

### 2. Create Solution Structure

```bash
# Navigate to your project root
cd /path/to/Hackathon

# Create solution
dotnet new sln -n HeavyMachineryDealer

# Create backend directory
mkdir -p backend/src
cd backend/src
```

---

## Project Structure

The backend follows a microservices architecture with clean architecture principles:

```
backend/
├── src/
│   ├── Services/
│   │   ├── QuoteService/
│   │   │   ├── QuoteService.API/          # Web API project
│   │   │   ├── QuoteService.Application/  # Business logic
│   │   │   ├── QuoteService.Domain/       # Domain entities
│   │   │   └── QuoteService.Infrastructure/ # Data access
│   │   │
│   │   └── InventoryService/
│   │       ├── InventoryService.API/
│   │       ├── InventoryService.Application/
│   │       ├── InventoryService.Domain/
│   │       └── InventoryService.Infrastructure/
│   │
│   ├── Shared/
│   │   ├── Shared.Common/               # Common utilities
│   │   └── Shared.EventBus/             # Event bus abstractions
│   │
│   └── Gateway/
│       └── APIGateway/                  # API Gateway (Ocelot/YARP)
│
├── tests/
│   ├── QuoteService.Tests/
│   └── InventoryService.Tests/
│
└── docker/
    ├── docker-compose.yml
    └── Dockerfile
```

### Create Projects

```bash
cd backend/src

# Create Quote Service projects
mkdir -p Services/QuoteService
cd Services/QuoteService

dotnet new webapi -n QuoteService.API --framework net8.0
dotnet new classlib -n QuoteService.Application --framework net8.0
dotnet new classlib -n QuoteService.Domain --framework net8.0
dotnet new classlib -n QuoteService.Infrastructure --framework net8.0

# Create Inventory Service projects
cd ../
mkdir -p InventoryService
cd InventoryService

dotnet new webapi -n InventoryService.API --framework net8.0
dotnet new classlib -n InventoryService.Application --framework net8.0
dotnet new classlib -n InventoryService.Domain --framework net8.0
dotnet new classlib -n InventoryService.Infrastructure --framework net8.0

# Create Shared projects
cd ../../
mkdir -p Shared
cd Shared

dotnet new classlib -n Shared.Common --framework net8.0
dotnet new classlib -n Shared.EventBus --framework net8.0

# Add projects to solution
cd ../../
dotnet sln add src/Services/QuoteService/QuoteService.API/QuoteService.API.csproj
dotnet sln add src/Services/QuoteService/QuoteService.Application/QuoteService.Application.csproj
dotnet sln add src/Services/QuoteService/QuoteService.Domain/QuoteService.Domain.csproj
dotnet sln add src/Services/QuoteService/QuoteService.Infrastructure/QuoteService.Infrastructure.csproj

dotnet sln add src/Services/InventoryService/InventoryService.API/InventoryService.API.csproj
dotnet sln add src/Services/InventoryService/InventoryService.Application/InventoryService.Application.csproj
dotnet sln add src/Services/InventoryService/InventoryService.Domain/InventoryService.Domain.csproj
dotnet sln add src/Services/InventoryService/InventoryService.Infrastructure/InventoryService.Infrastructure.csproj

dotnet sln add src/Shared/Shared.Common/Shared.Common.csproj
dotnet sln add src/Shared/Shared.EventBus/Shared.EventBus.csproj
```

---

## PostgreSQL Setup and Integration

### 1. Install PostgreSQL

#### On Windows:
```powershell
# Download installer from postgresql.org
# Or using Chocolatey:
choco install postgresql

# Start PostgreSQL service
net start postgresql-x64-15
```

#### On macOS:
```bash
# Using Homebrew:
brew install postgresql@15
brew services start postgresql@15
```

#### On Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install postgresql-15 postgresql-contrib-15
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 2. Create Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create databases
CREATE DATABASE heavymachinery_crm;
CREATE DATABASE heavymachinery_inventory;

# Create user (replace {YOUR_SECURE_PASSWORD} with a strong password)
CREATE USER hmdealer WITH ENCRYPTED PASSWORD '{YOUR_SECURE_PASSWORD}';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE heavymachinery_crm TO hmdealer;
GRANT ALL PRIVILEGES ON DATABASE heavymachinery_inventory TO hmdealer;

# Exit psql
\q
```

### 3. Run Database Schema Scripts

```bash
# Navigate to schema directory
cd db/schema

# Apply CRM schema (for Quote Service)
psql -U hmdealer -d heavymachinery_crm -f crm_schema.sql

# Apply ERP schema (for Inventory Service - if needed)
psql -U hmdealer -d heavymachinery_inventory -f erp_schema.sql
```

### 4. Configure Connection Strings

Create `appsettings.Development.json` in each API project:

**QuoteService.API/appsettings.Development.json:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=heavymachinery_crm;Username=hmdealer;Password={YOUR_SECURE_PASSWORD}"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Information"
    }
  }
}
```

**Note:** Replace `{YOUR_SECURE_PASSWORD}` with your actual database password. For production, use environment variables or Azure Key Vault / AWS Secrets Manager instead of storing passwords in configuration files.

**InventoryService.API/appsettings.Development.json:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=heavymachinery_inventory;Username=hmdealer;Password={YOUR_SECURE_PASSWORD}"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Information"
    }
  }
}
```

---

## Building the Quote Service

The Quote Service handles all quotation-related operations including creation, management, pricing calculations, and PDF generation.

### 1. Install Required NuGet Packages

```bash
cd src/Services/QuoteService

# API project dependencies
cd QuoteService.API
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Swashbuckle.AspNetCore
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Serilog.AspNetCore

# Application project dependencies
cd ../QuoteService.Application
dotnet add package MediatR
dotnet add package FluentValidation
dotnet add package AutoMapper
dotnet add package Microsoft.Extensions.DependencyInjection.Abstractions

# Infrastructure project dependencies
cd ../QuoteService.Infrastructure
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.Relational

# Add project references
cd ../QuoteService.API
dotnet add reference ../QuoteService.Application/QuoteService.Application.csproj
dotnet add reference ../QuoteService.Infrastructure/QuoteService.Infrastructure.csproj

cd ../QuoteService.Application
dotnet add reference ../QuoteService.Domain/QuoteService.Domain.csproj

cd ../QuoteService.Infrastructure
dotnet add reference ../QuoteService.Domain/QuoteService.Domain.csproj
dotnet add reference ../QuoteService.Application/QuoteService.Application.csproj
```

### 2. Create Domain Entities

Create the core domain models that represent the business entities.

**QuoteService.Domain/Entities/Quote.cs:**
```csharp
using System;
using System.Collections.Generic;

namespace QuoteService.Domain.Entities
{
    public class Quote
    {
        public Guid QuoteId { get; set; }
        public string QuoteNumber { get; set; } = string.Empty;
        public Guid CustomerId { get; set; }
        public Guid SalesRepId { get; set; }
        public DateTime QuoteDate { get; set; }
        public DateTime ValidUntil { get; set; }
        public string Status { get; set; } = "DRAFT";
        public decimal Subtotal { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TaxAmount { get; set; }
        public decimal TotalAmount { get; set; }
        public string Currency { get; set; } = "USD";
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        // Navigation properties
        public ICollection<QuoteLineItem> LineItems { get; set; } = new List<QuoteLineItem>();
    }

    public class QuoteLineItem
    {
        public Guid LineItemId { get; set; }
        public Guid QuoteId { get; set; }
        public string ProductCode { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal DiscountPercent { get; set; }
        public decimal LineTotal { get; set; }

        // Navigation property
        public Quote Quote { get; set; } = null!;
        public MachineConfiguration? Configuration { get; set; }
    }

    public class MachineConfiguration
    {
        public Guid ConfigId { get; set; }
        public Guid QuoteLineItemId { get; set; }
        public string BaseModel { get; set; } = string.Empty;
        public string? BucketSize { get; set; }
        public string? TireType { get; set; }
        public string? Attachment1 { get; set; }
        public string? Attachment2 { get; set; }
        public string? WarrantyPackage { get; set; }
        public string? SpecialInstructions { get; set; }

        // Navigation property
        public QuoteLineItem LineItem { get; set; } = null!;
    }
}
```

### 3. Create DbContext

**QuoteService.Infrastructure/Data/QuoteDbContext.cs:**
```csharp
using Microsoft.EntityFrameworkCore;
using QuoteService.Domain.Entities;

namespace QuoteService.Infrastructure.Data
{
    public class QuoteDbContext : DbContext
    {
        public QuoteDbContext(DbContextOptions<QuoteDbContext> options) : base(options)
        {
        }

        public DbSet<Quote> Quotes { get; set; }
        public DbSet<QuoteLineItem> QuoteLineItems { get; set; }
        public DbSet<MachineConfiguration> MachineConfigurations { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure Quote entity
            modelBuilder.Entity<Quote>(entity =>
            {
                entity.ToTable("crm_quotation", "crm");
                entity.HasKey(e => e.QuoteId);
                entity.Property(e => e.QuoteId).HasColumnName("quotation_id");
                entity.Property(e => e.QuoteNumber).HasColumnName("quote_number").HasMaxLength(50);
                entity.Property(e => e.CustomerId).HasColumnName("customer_id");
                entity.Property(e => e.SalesRepId).HasColumnName("sales_rep_id");
                entity.Property(e => e.QuoteDate).HasColumnName("quote_date");
                entity.Property(e => e.ValidUntil).HasColumnName("valid_until");
                entity.Property(e => e.Status).HasColumnName("status").HasMaxLength(50);
                entity.Property(e => e.Subtotal).HasColumnName("subtotal").HasPrecision(15, 2);
                entity.Property(e => e.DiscountAmount).HasColumnName("discount_amount").HasPrecision(15, 2);
                entity.Property(e => e.TaxAmount).HasColumnName("tax_amount").HasPrecision(15, 2);
                entity.Property(e => e.TotalAmount).HasColumnName("total_amount").HasPrecision(15, 2);
                entity.Property(e => e.Currency).HasColumnName("currency").HasMaxLength(3);
                entity.Property(e => e.CreatedAt).HasColumnName("created_at");
                entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");

                // Configure relationships
                entity.HasMany(e => e.LineItems)
                    .WithOne(l => l.Quote)
                    .HasForeignKey(l => l.QuoteId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // Configure QuoteLineItem entity
            modelBuilder.Entity<QuoteLineItem>(entity =>
            {
                entity.ToTable("crm_quote_line_item", "crm");
                entity.HasKey(e => e.LineItemId);
                entity.Property(e => e.LineItemId).HasColumnName("line_item_id");
                entity.Property(e => e.QuoteId).HasColumnName("quotation_id");
                entity.Property(e => e.ProductCode).HasColumnName("product_code").HasMaxLength(50);
                entity.Property(e => e.ProductName).HasColumnName("product_name").HasMaxLength(200);
                entity.Property(e => e.Quantity).HasColumnName("quantity");
                entity.Property(e => e.UnitPrice).HasColumnName("unit_price").HasPrecision(15, 2);
                entity.Property(e => e.DiscountPercent).HasColumnName("discount_percent").HasPrecision(5, 2);
                entity.Property(e => e.LineTotal).HasColumnName("line_total").HasPrecision(15, 2);

                // Configure relationship with configuration
                entity.HasOne(e => e.Configuration)
                    .WithOne(c => c.LineItem)
                    .HasForeignKey<MachineConfiguration>(c => c.QuoteLineItemId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // Configure MachineConfiguration entity
            modelBuilder.Entity<MachineConfiguration>(entity =>
            {
                entity.ToTable("crm_machine_configuration", "crm");
                entity.HasKey(e => e.ConfigId);
                entity.Property(e => e.ConfigId).HasColumnName("config_id");
                entity.Property(e => e.QuoteLineItemId).HasColumnName("quote_line_item_id");
                entity.Property(e => e.BaseModel).HasColumnName("base_model").HasMaxLength(100);
                entity.Property(e => e.BucketSize).HasColumnName("bucket_size").HasMaxLength(50);
                entity.Property(e => e.TireType).HasColumnName("tire_type").HasMaxLength(50);
                entity.Property(e => e.Attachment1).HasColumnName("attachment_1").HasMaxLength(100);
                entity.Property(e => e.Attachment2).HasColumnName("attachment_2").HasMaxLength(100);
                entity.Property(e => e.WarrantyPackage).HasColumnName("warranty_package").HasMaxLength(100);
                entity.Property(e => e.SpecialInstructions).HasColumnName("special_instructions");
            });
        }
    }
}
```

### 4. Configure API Controller

**QuoteService.API/Controllers/QuotesController.cs:**
```csharp
using Microsoft.AspNetCore.Mvc;
using QuoteService.Application.DTOs;
using QuoteService.Application.Interfaces;

namespace QuoteService.API.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class QuotesController : ControllerBase
    {
        private readonly IQuoteService _quoteService;
        private readonly ILogger<QuotesController> _logger;

        public QuotesController(IQuoteService quoteService, ILogger<QuotesController> logger)
        {
            _quoteService = quoteService;
            _logger = logger;
        }

        [HttpPost]
        public async Task<ActionResult<QuoteDto>> CreateQuote([FromBody] CreateQuoteDto createQuoteDto)
        {
            try
            {
                var quote = await _quoteService.CreateQuoteAsync(createQuoteDto);
                return CreatedAtAction(nameof(GetQuote), new { id = quote.QuoteId }, quote);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating quote");
                return StatusCode(500, "An error occurred while creating the quote");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<QuoteDto>> GetQuote(Guid id)
        {
            try
            {
                var quote = await _quoteService.GetQuoteByIdAsync(id);
                return Ok(quote);
            }
            catch (KeyNotFoundException)
            {
                return NotFound();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving quote {QuoteId}", id);
                return StatusCode(500, "An error occurred while retrieving the quote");
            }
        }

        [HttpGet("customer/{customerId}")]
        public async Task<ActionResult<IEnumerable<QuoteDto>>> GetQuotesByCustomer(Guid customerId)
        {
            try
            {
                var quotes = await _quoteService.GetQuotesByCustomerAsync(customerId);
                return Ok(quotes);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving quotes for customer {CustomerId}", customerId);
                return StatusCode(500, "An error occurred while retrieving quotes");
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<QuoteDto>> UpdateQuote(Guid id, [FromBody] UpdateQuoteDto updateQuoteDto)
        {
            try
            {
                var quote = await _quoteService.UpdateQuoteAsync(id, updateQuoteDto);
                return Ok(quote);
            }
            catch (KeyNotFoundException)
            {
                return NotFound();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating quote {QuoteId}", id);
                return StatusCode(500, "An error occurred while updating the quote");
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteQuote(Guid id)
        {
            try
            {
                var result = await _quoteService.DeleteQuoteAsync(id);
                if (!result)
                    return NotFound();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting quote {QuoteId}", id);
                return StatusCode(500, "An error occurred while deleting the quote");
            }
        }

        [HttpPost("{id}/calculate-price")]
        public async Task<ActionResult<decimal>> CalculatePrice(Guid id)
        {
            try
            {
                var total = await _quoteService.CalculateQuotePriceAsync(id);
                return Ok(new { quoteId = id, totalAmount = total });
            }
            catch (KeyNotFoundException)
            {
                return NotFound();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calculating price for quote {QuoteId}", id);
                return StatusCode(500, "An error occurred while calculating the price");
            }
        }
    }
}
```

### 5. Configure Program.cs

**QuoteService.API/Program.cs:**
```csharp
using Microsoft.EntityFrameworkCore;
using QuoteService.Application.Interfaces;
using QuoteService.Application.Services;
using QuoteService.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure PostgreSQL
builder.Services.AddDbContext<QuoteDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Register application services
builder.Services.AddScoped<IQuoteService, QuoteApplicationService>();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

app.Run();
```

---

## Building the Inventory Service

The Inventory Service manages stock levels, reservations, and availability across multiple warehouses.

### 1. Install Required NuGet Packages

```bash
cd src/Services/InventoryService

# API project dependencies
cd InventoryService.API
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Swashbuckle.AspNetCore
dotnet add package StackExchange.Redis
dotnet add package Serilog.AspNetCore

# Application project dependencies
cd ../InventoryService.Application
dotnet add package MediatR
dotnet add package FluentValidation
dotnet add package AutoMapper

# Infrastructure project dependencies
cd ../InventoryService.Infrastructure
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package StackExchange.Redis

# Add project references
cd ../InventoryService.API
dotnet add reference ../InventoryService.Application/InventoryService.Application.csproj
dotnet add reference ../InventoryService.Infrastructure/InventoryService.Infrastructure.csproj

cd ../InventoryService.Application
dotnet add reference ../InventoryService.Domain/InventoryService.Domain.csproj

cd ../InventoryService.Infrastructure
dotnet add reference ../InventoryService.Domain/InventoryService.Domain.csproj
dotnet add reference ../InventoryService.Application/InventoryService.Application.csproj
```

### 2. Create Domain Entities

**InventoryService.Domain/Entities/Inventory.cs:**
```csharp
using System;

namespace InventoryService.Domain.Entities
{
    public class Product
    {
        public Guid ProductId { get; set; }
        public string ProductCode { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string Manufacturer { get; set; } = string.Empty;
        public decimal StandardPrice { get; set; }
        public string Status { get; set; } = "ACTIVE";

        // Navigation properties
        public ICollection<Inventory> InventoryRecords { get; set; } = new List<Inventory>();
    }

    public class Warehouse
    {
        public Guid WarehouseId { get; set; }
        public string WarehouseCode { get; set; } = string.Empty;
        public string WarehouseName { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string City { get; set; } = string.Empty;
        public string Country { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;

        // Navigation properties
        public ICollection<Inventory> InventoryRecords { get; set; } = new List<Inventory>();
    }

    public class Inventory
    {
        public Guid InventoryId { get; set; }
        public Guid ProductId { get; set; }
        public Guid WarehouseId { get; set; }
        public int QuantityOnHand { get; set; }
        public int QuantityReserved { get; set; }
        public int QuantityAvailable => QuantityOnHand - QuantityReserved;
        public int ReorderLevel { get; set; }
        public DateTime LastUpdated { get; set; }

        // Navigation properties
        public Product Product { get; set; } = null!;
        public Warehouse Warehouse { get; set; } = null!;
        public ICollection<StockReservation> Reservations { get; set; } = new List<StockReservation>();
    }

    public class StockReservation
    {
        public Guid ReservationId { get; set; }
        public Guid InventoryId { get; set; }
        public Guid QuoteId { get; set; }
        public int QuantityReserved { get; set; }
        public DateTime ReservedUntil { get; set; }
        public string Status { get; set; } = "ACTIVE";
        public DateTime CreatedAt { get; set; }

        // Navigation property
        public Inventory Inventory { get; set; } = null!;
    }

    public class StockMovement
    {
        public Guid MovementId { get; set; }
        public Guid ProductId { get; set; }
        public Guid WarehouseId { get; set; }
        public string MovementType { get; set; } = string.Empty; // IN, OUT, TRANSFER, ADJUSTMENT
        public int Quantity { get; set; }
        public string ReferenceType { get; set; } = string.Empty;
        public string ReferenceId { get; set; } = string.Empty;
        public DateTime MovementDate { get; set; }
        public Guid CreatedBy { get; set; }
    }
}
```

### 3. Create DbContext

**InventoryService.Infrastructure/Data/InventoryDbContext.cs:**
```csharp
using Microsoft.EntityFrameworkCore;
using InventoryService.Domain.Entities;

namespace InventoryService.Infrastructure.Data
{
    public class InventoryDbContext : DbContext
    {
        public InventoryDbContext(DbContextOptions<InventoryDbContext> options) : base(options)
        {
        }

        public DbSet<Product> Products { get; set; }
        public DbSet<Warehouse> Warehouses { get; set; }
        public DbSet<Inventory> Inventories { get; set; }
        public DbSet<StockReservation> StockReservations { get; set; }
        public DbSet<StockMovement> StockMovements { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure Product entity
            modelBuilder.Entity<Product>(entity =>
            {
                entity.ToTable("products");
                entity.HasKey(e => e.ProductId);
                entity.Property(e => e.ProductCode).HasMaxLength(50).IsRequired();
                entity.Property(e => e.ProductName).HasMaxLength(200).IsRequired();
                entity.Property(e => e.Category).HasMaxLength(100);
                entity.Property(e => e.Manufacturer).HasMaxLength(100);
                entity.Property(e => e.StandardPrice).HasPrecision(15, 2);
                entity.Property(e => e.Status).HasMaxLength(20);

                entity.HasIndex(e => e.ProductCode).IsUnique();
            });

            // Configure Warehouse entity
            modelBuilder.Entity<Warehouse>(entity =>
            {
                entity.ToTable("warehouses");
                entity.HasKey(e => e.WarehouseId);
                entity.Property(e => e.WarehouseCode).HasMaxLength(20).IsRequired();
                entity.Property(e => e.WarehouseName).HasMaxLength(100).IsRequired();
                entity.Property(e => e.Address).HasMaxLength(500);
                entity.Property(e => e.City).HasMaxLength(100);
                entity.Property(e => e.Country).HasMaxLength(100);

                entity.HasIndex(e => e.WarehouseCode).IsUnique();
            });

            // Configure Inventory entity
            modelBuilder.Entity<Inventory>(entity =>
            {
                entity.ToTable("inventory");
                entity.HasKey(e => e.InventoryId);
                entity.Property(e => e.LastUpdated).HasDefaultValueSql("CURRENT_TIMESTAMP");

                entity.HasOne(e => e.Product)
                    .WithMany(p => p.InventoryRecords)
                    .HasForeignKey(e => e.ProductId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(e => e.Warehouse)
                    .WithMany(w => w.InventoryRecords)
                    .HasForeignKey(e => e.WarehouseId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasIndex(e => new { e.ProductId, e.WarehouseId }).IsUnique();

                // Note: QuantityAvailable is a computed property (QuantityOnHand - QuantityReserved)
                // It's calculated in the entity but ignored in EF Core mapping
                // For better query performance, you can create a computed column in PostgreSQL:
                // ALTER TABLE inventory ADD COLUMN quantity_available INTEGER GENERATED ALWAYS AS (quantity_on_hand - quantity_reserved) STORED;
                entity.Ignore(e => e.QuantityAvailable);
            });

            // Configure StockReservation entity
            modelBuilder.Entity<StockReservation>(entity =>
            {
                entity.ToTable("stock_reservations");
                entity.HasKey(e => e.ReservationId);
                entity.Property(e => e.Status).HasMaxLength(20);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");

                entity.HasOne(e => e.Inventory)
                    .WithMany(i => i.Reservations)
                    .HasForeignKey(e => e.InventoryId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // Configure StockMovement entity
            modelBuilder.Entity<StockMovement>(entity =>
            {
                entity.ToTable("stock_movements");
                entity.HasKey(e => e.MovementId);
                entity.Property(e => e.MovementType).HasMaxLength(20);
                entity.Property(e => e.ReferenceType).HasMaxLength(50);
                entity.Property(e => e.ReferenceId).HasMaxLength(50);
                entity.Property(e => e.MovementDate).HasDefaultValueSql("CURRENT_TIMESTAMP");
            });
        }
    }
}
```

### 4. Configure API Controller

**InventoryService.API/Controllers/InventoryController.cs:**
```csharp
using Microsoft.AspNetCore.Mvc;
using InventoryService.Application.DTOs;
using InventoryService.Application.Interfaces;

namespace InventoryService.API.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class InventoryController : ControllerBase
    {
        private readonly IInventoryService _inventoryService;
        private readonly ILogger<InventoryController> _logger;

        public InventoryController(IInventoryService inventoryService, ILogger<InventoryController> logger)
        {
            _inventoryService = inventoryService;
            _logger = logger;
        }

        [HttpGet("availability")]
        public async Task<ActionResult<AvailabilityDto>> CheckAvailability(
            [FromQuery] Guid productId,
            [FromQuery] int quantity,
            [FromQuery] Guid? warehouseId = null)
        {
            try
            {
                var availability = await _inventoryService.CheckStockAvailabilityAsync(
                    productId, quantity, warehouseId);
                return Ok(availability);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking availability for product {ProductId}", productId);
                return StatusCode(500, "An error occurred while checking availability");
            }
        }

        [HttpPost("reserve")]
        public async Task<ActionResult<ReservationDto>> ReserveStock([FromBody] CreateReservationDto reservationDto)
        {
            try
            {
                var reservation = await _inventoryService.ReserveStockAsync(
                    reservationDto.ProductId,
                    reservationDto.Quantity,
                    reservationDto.QuoteId,
                    reservationDto.WarehouseId);
                return Ok(reservation);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error reserving stock");
                return StatusCode(500, "An error occurred while reserving stock");
            }
        }

        [HttpDelete("reservations/{reservationId}")]
        public async Task<IActionResult> ReleaseReservation(Guid reservationId)
        {
            try
            {
                var result = await _inventoryService.ReleaseReservationAsync(reservationId);
                if (!result)
                    return NotFound();

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error releasing reservation {ReservationId}", reservationId);
                return StatusCode(500, "An error occurred while releasing the reservation");
            }
        }

        [HttpGet("products/{productId}")]
        public async Task<ActionResult<ProductInventoryDto>> GetProductInventory(Guid productId)
        {
            try
            {
                var inventory = await _inventoryService.GetProductInventoryAsync(productId);
                return Ok(inventory);
            }
            catch (KeyNotFoundException)
            {
                return NotFound();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving inventory for product {ProductId}", productId);
                return StatusCode(500, "An error occurred while retrieving inventory");
            }
        }

        [HttpPost("movements")]
        public async Task<ActionResult> RecordStockMovement([FromBody] StockMovementDto movementDto)
        {
            try
            {
                await _inventoryService.RecordStockMovementAsync(movementDto);
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error recording stock movement");
                return StatusCode(500, "An error occurred while recording the stock movement");
            }
        }

        [HttpGet("low-stock")]
        public async Task<ActionResult<IEnumerable<LowStockDto>>> GetLowStockProducts()
        {
            try
            {
                var products = await _inventoryService.GetLowStockProductsAsync();
                return Ok(products);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving low stock products");
                return StatusCode(500, "An error occurred while retrieving low stock products");
            }
        }
    }
}
```

### 5. Configure Program.cs

**InventoryService.API/Program.cs:**
```csharp
using Microsoft.EntityFrameworkCore;
using InventoryService.Application.Interfaces;
using InventoryService.Application.Services;
using InventoryService.Infrastructure.Data;
using StackExchange.Redis;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure PostgreSQL
builder.Services.AddDbContext<InventoryDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Configure Redis for caching
builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
{
    var configuration = ConfigurationOptions.Parse(
        builder.Configuration.GetConnectionString("RedisConnection") ?? "localhost:6379");
    return ConnectionMultiplexer.Connect(configuration);
});

// Register application services
builder.Services.AddScoped<IInventoryService, InventoryApplicationService>();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

app.Run();
```

---

## Database Migrations

### Using Entity Framework Core Migrations

#### 1. Create Initial Migration for Quote Service

```bash
cd src/Services/QuoteService/QuoteService.API

# Create migration
dotnet ef migrations add InitialCreate --project ../QuoteService.Infrastructure/QuoteService.Infrastructure.csproj --context QuoteDbContext

# Apply migration to database
dotnet ef database update --project ../QuoteService.Infrastructure/QuoteService.Infrastructure.csproj --context QuoteDbContext
```

#### 2. Create Initial Migration for Inventory Service

```bash
cd src/Services/InventoryService/InventoryService.API

# Create migration
dotnet ef migrations add InitialCreate --project ../InventoryService.Infrastructure/InventoryService.Infrastructure.csproj --context InventoryDbContext

# Apply migration to database
dotnet ef database update --project ../InventoryService.Infrastructure/InventoryService.Infrastructure.csproj --context InventoryDbContext
```

#### 3. Update Schema After Changes

When you modify your domain entities:

```bash
# Create new migration
dotnet ef migrations add <MigrationName> --project ../[Service].Infrastructure/[Service].Infrastructure.csproj --context [Service]DbContext

# Apply migration
dotnet ef database update --project ../[Service].Infrastructure/[Service].Infrastructure.csproj --context [Service]DbContext

# Rollback to previous migration
dotnet ef database update <PreviousMigrationName> --project ../[Service].Infrastructure/[Service].Infrastructure.csproj --context [Service]DbContext

# Remove last migration (if not applied)
dotnet ef migrations remove --project ../[Service].Infrastructure/[Service].Infrastructure.csproj --context [Service]DbContext
```

---

## Testing

### 1. Unit Testing Setup

Create test projects for each service:

```bash
cd backend

# Create test projects
mkdir -p tests
cd tests

dotnet new xunit -n QuoteService.Tests --framework net8.0
dotnet new xunit -n InventoryService.Tests --framework net8.0

# Add test packages
cd QuoteService.Tests
dotnet add package Moq
dotnet add package FluentAssertions
dotnet add package Microsoft.EntityFrameworkCore.InMemory

# Add reference to service projects
dotnet add reference ../../src/Services/QuoteService/QuoteService.Application/QuoteService.Application.csproj
dotnet add reference ../../src/Services/QuoteService/QuoteService.Domain/QuoteService.Domain.csproj

# Add to solution
cd ../..
dotnet sln add tests/QuoteService.Tests/QuoteService.Tests.csproj
dotnet sln add tests/InventoryService.Tests/InventoryService.Tests.csproj
```

### 2. Sample Unit Test

**tests/QuoteService.Tests/QuoteServiceTests.cs:**
```csharp
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using QuoteService.Application.DTOs;
using QuoteService.Application.Services;
using QuoteService.Infrastructure.Data;

namespace QuoteService.Tests
{
    public class QuoteServiceTests
    {
        private QuoteDbContext CreateInMemoryContext()
        {
            var options = new DbContextOptionsBuilder<QuoteDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;

            return new QuoteDbContext(options);
        }

        [Fact]
        public async Task CreateQuote_ShouldCreateNewQuote_WithGeneratedQuoteNumber()
        {
            // Arrange
            var context = CreateInMemoryContext();
            var service = new QuoteApplicationService(context);
            var createDto = new CreateQuoteDto
            {
                CustomerId = Guid.NewGuid(),
                SalesRepId = Guid.NewGuid(),
                ValidUntil = DateTime.UtcNow.AddDays(30),
                LineItems = new List<CreateQuoteLineItemDto>
                {
                    new CreateQuoteLineItemDto
                    {
                        ProductCode = "EX-200",
                        ProductName = "Excavator 200",
                        Quantity = 1,
                        UnitPrice = 100000m,
                        DiscountPercent = 5m
                    }
                }
            };

            // Act
            var result = await service.CreateQuoteAsync(createDto);

            // Assert
            result.Should().NotBeNull();
            result.QuoteNumber.Should().NotBeNullOrEmpty();
            result.Status.Should().Be("DRAFT");
            result.LineItems.Should().HaveCount(1);
            result.TotalAmount.Should().BeGreaterThan(0);
        }

        [Fact]
        public async Task GetQuoteById_ShouldReturnQuote_WhenQuoteExists()
        {
            // Arrange
            var context = CreateInMemoryContext();
            var service = new QuoteApplicationService(context);
            var createDto = new CreateQuoteDto
            {
                CustomerId = Guid.NewGuid(),
                SalesRepId = Guid.NewGuid(),
                ValidUntil = DateTime.UtcNow.AddDays(30),
                LineItems = new List<CreateQuoteLineItemDto>()
            };
            var createdQuote = await service.CreateQuoteAsync(createDto);

            // Act
            var result = await service.GetQuoteByIdAsync(createdQuote.QuoteId);

            // Assert
            result.Should().NotBeNull();
            result.QuoteId.Should().Be(createdQuote.QuoteId);
        }

        [Fact]
        public async Task CalculateQuotePrice_ShouldCalculateCorrectTotal()
        {
            // Arrange
            var context = CreateInMemoryContext();
            var service = new QuoteApplicationService(context);
            var createDto = new CreateQuoteDto
            {
                CustomerId = Guid.NewGuid(),
                SalesRepId = Guid.NewGuid(),
                ValidUntil = DateTime.UtcNow.AddDays(30),
                LineItems = new List<CreateQuoteLineItemDto>
                {
                    new CreateQuoteLineItemDto
                    {
                        ProductCode = "EX-200",
                        ProductName = "Excavator 200",
                        Quantity = 2,
                        UnitPrice = 100000m,
                        DiscountPercent = 10m
                    }
                }
            };
            var quote = await service.CreateQuoteAsync(createDto);

            // Act
            var total = await service.CalculateQuotePriceAsync(quote.QuoteId);

            // Assert
            // Subtotal: 200000 - 10% = 180000
            // Tax (10%): 18000
            // Total: 198000
            total.Should().Be(198000m);
        }
    }
}
```

### 3. Run Tests

```bash
# Run all tests
dotnet test

# Run tests with coverage
dotnet test --collect:"XPlat Code Coverage"

# Run tests for specific project
dotnet test tests/QuoteService.Tests/QuoteService.Tests.csproj
```

---

## Running the Services

### 1. Run Quote Service

```bash
cd src/Services/QuoteService/QuoteService.API
dotnet run
```

The service will be available at:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`
- Swagger UI: `https://localhost:5001/swagger`

### 2. Run Inventory Service

```bash
cd src/Services/InventoryService/InventoryService.API
dotnet run --urls "https://localhost:5003;http://localhost:5002"
```

The service will be available at:
- HTTP: `http://localhost:5002`
- HTTPS: `https://localhost:5003`
- Swagger UI: `https://localhost:5003/swagger`

### 3. Test API Endpoints

Using curl or Postman, test the endpoints:

**Create a Quote:**
```bash
curl -X POST https://localhost:5001/api/v1/quotes \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "123e4567-e89b-12d3-a456-426614174000",
    "salesRepId": "123e4567-e89b-12d3-a456-426614174001",
    "validUntil": "2025-01-31T00:00:00Z",
    "lineItems": [
      {
        "productCode": "EX-200",
        "productName": "Excavator 200",
        "quantity": 1,
        "unitPrice": 150000,
        "discountPercent": 5
      }
    ]
  }'
```

**Check Inventory Availability:**
```bash
curl "https://localhost:5003/api/v1/inventory/availability?productId=123e4567-e89b-12d3-a456-426614174000&quantity=2"
```

---

## Deployment

### 1. Docker Deployment

Create **Dockerfile** for each service:

**QuoteService.API/Dockerfile:**
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["QuoteService.API/QuoteService.API.csproj", "QuoteService.API/"]
COPY ["QuoteService.Application/QuoteService.Application.csproj", "QuoteService.Application/"]
COPY ["QuoteService.Domain/QuoteService.Domain.csproj", "QuoteService.Domain/"]
COPY ["QuoteService.Infrastructure/QuoteService.Infrastructure.csproj", "QuoteService.Infrastructure/"]
RUN dotnet restore "QuoteService.API/QuoteService.API.csproj"
COPY . .
WORKDIR "/src/QuoteService.API"
RUN dotnet build "QuoteService.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "QuoteService.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "QuoteService.API.dll"]
```

### 2. Docker Compose

Create **docker-compose.yml** at the backend root:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: hmdealer
      POSTGRES_PASSWORD: ${DB_PASSWORD}  # Set via environment variable or .env file
      POSTGRES_DB: heavymachinery_crm
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./db/schema:/docker-entrypoint-initdb.d

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  quote-service:
    build:
      context: ./src/Services/QuoteService
      dockerfile: QuoteService.API/Dockerfile
    ports:
      - "5001:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=heavymachinery_crm;Username=hmdealer;Password=${DB_PASSWORD}
    depends_on:
      - postgres

  inventory-service:
    build:
      context: ./src/Services/InventoryService
      dockerfile: InventoryService.API/Dockerfile
    ports:
      - "5003:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=heavymachinery_inventory;Username=hmdealer;Password=${DB_PASSWORD}
      - ConnectionStrings__RedisConnection=redis:6379
    depends_on:
      - postgres
      - redis

volumes:
  postgres_data:
  redis_data:
```

**Create a `.env` file** in the same directory as docker-compose.yml:

```bash
# .env file (DO NOT commit this file to version control)
DB_PASSWORD=YourSecurePasswordHere123!
```

**Important:** Add `.env` to your `.gitignore` file to prevent committing secrets to version control.

### 3. Run with Docker Compose

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### 4. Production Deployment (Kubernetes Example)

Create Kubernetes deployment manifests:

**k8s/quote-service-deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quote-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: quote-service
  template:
    metadata:
      labels:
        app: quote-service
    spec:
      containers:
      - name: quote-service
        image: your-registry/quote-service:latest
        ports:
        - containerPort: 80
        env:
        - name: ASPNETCORE_ENVIRONMENT
          value: "Production"
        - name: ConnectionStrings__DefaultConnection
          valueFrom:
            secretKeyRef:
              name: database-secrets
              key: quote-db-connection
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: quote-service
spec:
  selector:
    app: quote-service
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

Apply Kubernetes manifests:
```bash
kubectl apply -f k8s/
kubectl get pods
kubectl get services
```

---

## Best Practices and Recommendations

### 1. Security

- **Never commit secrets**: 
  - Use environment variables for all passwords and sensitive configuration
  - Use secret management services (Azure Key Vault, AWS Secrets Manager, HashiCorp Vault)
  - Add `.env`, `appsettings.*.json` with secrets to `.gitignore`
  - Throughout this guide, placeholders like `{YOUR_SECURE_PASSWORD}` and `${DB_PASSWORD}` are used
  - Replace these placeholders with actual secrets only in your local environment or CI/CD pipelines
- **Enable HTTPS**: Always use TLS in production
- **Implement authentication**: Use JWT tokens with proper validation
- **Rate limiting**: Protect APIs from abuse
- **Input validation**: Validate all user inputs
- **SQL injection prevention**: Use parameterized queries (Entity Framework does this automatically)
- **Dependency scanning**: Regularly update NuGet packages and scan for vulnerabilities

### 2. Performance

- **Use caching**: Implement Redis caching for frequently accessed data
- **Database indexing**: Create appropriate indexes on frequently queried columns
- **Connection pooling**: Configure proper connection pool sizes
- **Async/await**: Use async operations for I/O bound operations
- **Pagination**: Implement pagination for large result sets

### 3. Monitoring and Logging

- **Structured logging**: Use Serilog with structured logging
- **Application metrics**: Implement health checks and metrics endpoints
- **Distributed tracing**: Use OpenTelemetry or Application Insights
- **Error tracking**: Integrate error tracking services

### 4. Code Quality

- **Follow SOLID principles**: Keep code maintainable and testable
- **Use dependency injection**: Leverage .NET's built-in DI container
- **Write tests**: Maintain good test coverage
- **Code reviews**: Implement peer review process
- **Documentation**: Keep API documentation up to date

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Database Connection Errors

**Issue**: `Npgsql.NpgsqlException: Connection refused`

**Solution**:
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Verify connection string
# Ensure host, database, username, and password are correct

# Check firewall settings
sudo ufw allow 5432/tcp
```

#### 2. Migration Errors

**Issue**: `A migration has already been applied to the database`

**Solution**:
```bash
# Check migration history
dotnet ef migrations list

# Remove last migration if not needed
dotnet ef migrations remove

# Force update if needed
dotnet ef database update --force
```

#### 3. Port Already in Use

**Issue**: `Unable to bind to https://localhost:5001`

**Solution**:
```bash
# Find process using the port
lsof -i :5001  # macOS/Linux
netstat -ano | findstr :5001  # Windows

# Kill the process or use a different port
dotnet run --urls "https://localhost:5011;http://localhost:5010"
```

#### 4. Entity Framework Core Not Found

**Issue**: `The Entity Framework Core tools version is older than that of the runtime`

**Solution**:
```bash
# Update EF Core tools
dotnet tool update --global dotnet-ef

# Verify version
dotnet ef --version
```

---

## Additional Resources

### Documentation

- [.NET 8 Documentation](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-8)
- [ASP.NET Core Documentation](https://learn.microsoft.com/en-us/aspnet/core/)
- [Entity Framework Core Documentation](https://learn.microsoft.com/en-us/ef/core/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Npgsql Documentation](https://www.npgsql.org/doc/)

### Related Project Documents

- [High-Level Design](./hld/HIGH_LEVEL_DESIGN.md)
- [Low-Level Design](./lld/LOW_LEVEL_DESIGN.md)
- [Architecture Decision Records](./adr/)
- [API Documentation](./api/)

---

## Conclusion

This guide provides a comprehensive foundation for building the backend services of the Heavy Machinery Dealer Management System using .NET 8 and PostgreSQL. The Quote Service and Inventory Service implementations follow clean architecture principles, ensuring maintainability, testability, and scalability.

### Next Steps

1. **Extend Services**: Add remaining services (Customer Service, Email Service, etc.)
2. **Implement Authentication**: Add JWT-based authentication and authorization
3. **Add Event Bus**: Implement RabbitMQ for inter-service communication
4. **Set Up CI/CD**: Configure automated build and deployment pipelines
5. **Implement API Gateway**: Set up Ocelot or YARP for unified API access
6. **Add Monitoring**: Integrate Application Insights or Prometheus
7. **Performance Testing**: Conduct load testing and optimize bottlenecks
8. **Security Hardening**: Implement comprehensive security measures

---

**Document Control:**
- Version: 1.0
- Last Updated: 2025-12-09
- Status: Active
- Owner: Development Team
- Related Documents: HIGH_LEVEL_DESIGN.md, LOW_LEVEL_DESIGN.md
