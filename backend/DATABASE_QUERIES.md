# PostgreSQL Database Schema and SQL Queries Documentation

## Overview

This document contains all SQL queries and database schema information for the Dealer Management System. The database uses PostgreSQL for data storage.

---

## Database Setup

### Create Database

```sql
-- Create the database
CREATE DATABASE dealer_management;

-- Connect to the database
\c dealer_management;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

---

## Table Schemas

### 1. Users Table

```sql
CREATE TABLE users (
    user_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    firebase_uid VARCHAR(128) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role VARCHAR(50) DEFAULT 'SALES_REP',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Indexes
CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX idx_users_email ON users(email);
```

### 2. Customers Table

```sql
CREATE TABLE customers (
    customer_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    customer_code VARCHAR(50) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    tax_number VARCHAR(50),
    email VARCHAR(255),
    phone VARCHAR(50),
    customer_type VARCHAR(50) DEFAULT 'STANDARD',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    credit_limit NUMERIC(15, 2) DEFAULT 0,
    payment_terms INTEGER DEFAULT 30,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_customers_code ON customers(customer_code);
CREATE INDEX idx_customers_company_name ON customers(company_name);
CREATE INDEX idx_customers_status ON customers(status);
```

### 3. Customer Addresses Table

```sql
CREATE TABLE customer_addresses (
    address_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    customer_id VARCHAR(36) REFERENCES customers(customer_id) ON DELETE CASCADE,
    address_type VARCHAR(50) NOT NULL,
    street_address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    is_primary BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_customer_addresses_customer_id ON customer_addresses(customer_id);
```

### 4. Customer Contacts Table

```sql
CREATE TABLE customer_contacts (
    contact_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    customer_id VARCHAR(36) REFERENCES customers(customer_id) ON DELETE CASCADE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    designation VARCHAR(100),
    is_primary BOOLEAN DEFAULT FALSE,
    is_decision_maker BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_customer_contacts_customer_id ON customer_contacts(customer_id);
```

### 5. Products Table

```sql
CREATE TABLE products (
    product_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    product_code VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    manufacturer VARCHAR(100),
    base_price NUMERIC(15, 2),
    description TEXT,
    specifications JSONB,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_code ON products(product_code);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_manufacturer ON products(manufacturer);
```

### 6. Product Options Table

```sql
CREATE TABLE product_options (
    option_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    product_id VARCHAR(36) REFERENCES products(product_id) ON DELETE CASCADE,
    option_type VARCHAR(50) NOT NULL,
    option_name VARCHAR(100) NOT NULL,
    option_value VARCHAR(255),
    additional_price NUMERIC(15, 2) DEFAULT 0,
    is_default BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_product_options_product_id ON product_options(product_id);
```

### 7. Warehouses Table

```sql
CREATE TABLE warehouses (
    warehouse_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    warehouse_code VARCHAR(50) UNIQUE NOT NULL,
    warehouse_name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_warehouses_code ON warehouses(warehouse_code);
```

### 8. Inventory Table

```sql
CREATE TABLE inventory (
    inventory_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    product_id VARCHAR(36) REFERENCES products(product_id) ON DELETE CASCADE,
    warehouse_id VARCHAR(36) REFERENCES warehouses(warehouse_id) ON DELETE CASCADE,
    quantity_on_hand INTEGER DEFAULT 0,
    quantity_reserved INTEGER DEFAULT 0,
    reorder_level INTEGER DEFAULT 5,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, warehouse_id)
);

CREATE INDEX idx_inventory_product_id ON inventory(product_id);
CREATE INDEX idx_inventory_warehouse_id ON inventory(warehouse_id);
```

### 9. Quotes Table

```sql
CREATE TABLE quotes (
    quote_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    quote_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id VARCHAR(36) REFERENCES customers(customer_id),
    sales_rep_id VARCHAR(36) REFERENCES users(user_id),
    quote_date DATE DEFAULT CURRENT_DATE,
    valid_until DATE,
    status VARCHAR(50) DEFAULT 'DRAFT',
    subtotal NUMERIC(15, 2),
    discount_amount NUMERIC(15, 2) DEFAULT 0,
    discount_percent NUMERIC(5, 2) DEFAULT 0,
    tax_amount NUMERIC(15, 2) DEFAULT 0,
    total_amount NUMERIC(15, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quotes_number ON quotes(quote_number);
CREATE INDEX idx_quotes_customer_id ON quotes(customer_id);
CREATE INDEX idx_quotes_sales_rep_id ON quotes(sales_rep_id);
CREATE INDEX idx_quotes_status ON quotes(status);
```

### 10. Quote Line Items Table

```sql
CREATE TABLE quote_line_items (
    line_item_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    quote_id VARCHAR(36) REFERENCES quotes(quote_id) ON DELETE CASCADE,
    product_id VARCHAR(36) REFERENCES products(product_id),
    product_code VARCHAR(50),
    product_name VARCHAR(255),
    quantity INTEGER DEFAULT 1,
    unit_price NUMERIC(15, 2),
    discount_percent NUMERIC(5, 2) DEFAULT 0,
    line_total NUMERIC(15, 2),
    configuration_id VARCHAR(36)
);

CREATE INDEX idx_quote_line_items_quote_id ON quote_line_items(quote_id);
```

### 11. Machine Configurations Table

```sql
CREATE TABLE machine_configurations (
    config_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    line_item_id VARCHAR(36) REFERENCES quote_line_items(line_item_id) ON DELETE CASCADE,
    base_model VARCHAR(100),
    bucket_size VARCHAR(50),
    tire_type VARCHAR(50),
    attachment_1 VARCHAR(100),
    attachment_2 VARCHAR(100),
    warranty_package VARCHAR(50),
    special_instructions TEXT,
    configuration_data JSONB
);

CREATE INDEX idx_machine_configurations_line_item_id ON machine_configurations(line_item_id);
```

### 12. Vendors Table

```sql
CREATE TABLE vendors (
    vendor_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    vendor_code VARCHAR(50) UNIQUE NOT NULL,
    vendor_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    payment_terms INTEGER DEFAULT 30,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    rating NUMERIC(3, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vendors_code ON vendors(vendor_code);
```

### 13. Purchase Orders Table

```sql
CREATE TABLE purchase_orders (
    po_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    po_number VARCHAR(50) UNIQUE NOT NULL,
    vendor_id VARCHAR(36) REFERENCES vendors(vendor_id),
    quote_id VARCHAR(36) REFERENCES quotes(quote_id),
    customer_id VARCHAR(36) REFERENCES customers(customer_id),
    po_date DATE DEFAULT CURRENT_DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    status VARCHAR(50) DEFAULT 'DRAFT',
    total_amount NUMERIC(15, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    shipping_address TEXT,
    notes TEXT,
    created_by VARCHAR(36) REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_purchase_orders_number ON purchase_orders(po_number);
CREATE INDEX idx_purchase_orders_vendor_id ON purchase_orders(vendor_id);
CREATE INDEX idx_purchase_orders_status ON purchase_orders(status);
```

### 14. PO Line Items Table

```sql
CREATE TABLE po_line_items (
    po_line_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    po_id VARCHAR(36) REFERENCES purchase_orders(po_id) ON DELETE CASCADE,
    product_id VARCHAR(36) REFERENCES products(product_id),
    product_code VARCHAR(50),
    product_description TEXT,
    quantity INTEGER DEFAULT 1,
    unit_price NUMERIC(15, 2),
    line_total NUMERIC(15, 2),
    configuration_data JSONB
);

CREATE INDEX idx_po_line_items_po_id ON po_line_items(po_id);
```

---

## Common SQL Queries

### User Authentication Queries

```sql
-- Register new user (after Firebase authentication)
INSERT INTO users (firebase_uid, email, first_name, last_name, role)
VALUES ($1, $2, $3, $4, $5)
RETURNING *;

-- Login - Find user by Firebase UID
SELECT * FROM users WHERE firebase_uid = $1;

-- Update last login
UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE firebase_uid = $1;

-- Get user profile
SELECT * FROM users WHERE firebase_uid = $1;

-- Update user profile
UPDATE users 
SET first_name = $1, last_name = $2, updated_at = CURRENT_TIMESTAMP
WHERE firebase_uid = $3
RETURNING *;
```

### Customer Queries

```sql
-- Get all customers with pagination
SELECT * FROM customers 
WHERE status = $1
ORDER BY company_name
LIMIT $2 OFFSET $3;

-- Search customers
SELECT * FROM customers 
WHERE company_name ILIKE '%' || $1 || '%'
ORDER BY company_name;

-- Get customer 360 view
SELECT c.*, 
       json_agg(DISTINCT ca.*) as addresses,
       json_agg(DISTINCT cc.*) as contacts
FROM customers c
LEFT JOIN customer_addresses ca ON c.customer_id = ca.customer_id
LEFT JOIN customer_contacts cc ON c.customer_id = cc.customer_id
WHERE c.customer_id = $1
GROUP BY c.customer_id;

-- Create customer
INSERT INTO customers (customer_code, company_name, tax_number, email, phone, customer_type, credit_limit)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;
```

### Inventory Queries

```sql
-- Check stock availability
SELECT i.*, w.warehouse_name, p.product_name
FROM inventory i
JOIN warehouses w ON i.warehouse_id = w.warehouse_id
JOIN products p ON i.product_id = p.product_id
WHERE i.product_id = $1 
  AND (i.quantity_on_hand - i.quantity_reserved) >= $2;

-- Get low stock items
SELECT i.*, p.product_name, p.product_code, w.warehouse_name
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN warehouses w ON i.warehouse_id = w.warehouse_id
WHERE (i.quantity_on_hand - i.quantity_reserved) <= i.reorder_level;

-- Update stock
UPDATE inventory 
SET quantity_on_hand = $1, 
    quantity_reserved = $2, 
    last_updated = CURRENT_TIMESTAMP
WHERE product_id = $3 AND warehouse_id = $4
RETURNING *;
```

### Quote Queries

```sql
-- Generate quote number
SELECT 'QT-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || 
       LPAD(CAST(COUNT(*) + 1 AS VARCHAR), 4, '0')
FROM quotes 
WHERE quote_number LIKE 'QT-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '%';

-- Create quote
INSERT INTO quotes (quote_number, customer_id, sales_rep_id, quote_date, valid_until, status, currency)
VALUES ($1, $2, $3, CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 'DRAFT', $4)
RETURNING *;

-- Get quote with line items
SELECT q.*, c.company_name as customer_name,
       json_agg(
           json_build_object(
               'line_item_id', qli.line_item_id,
               'product_code', qli.product_code,
               'product_name', qli.product_name,
               'quantity', qli.quantity,
               'unit_price', qli.unit_price,
               'line_total', qli.line_total
           )
       ) as line_items
FROM quotes q
JOIN customers c ON q.customer_id = c.customer_id
LEFT JOIN quote_line_items qli ON q.quote_id = qli.quote_id
WHERE q.quote_id = $1
GROUP BY q.quote_id, c.company_name;

-- Calculate quote totals
UPDATE quotes
SET subtotal = (
        SELECT COALESCE(SUM(line_total), 0) 
        FROM quote_line_items 
        WHERE quote_id = $1
    ),
    discount_amount = subtotal * discount_percent / 100,
    tax_amount = (subtotal - discount_amount) * 0.10,
    total_amount = subtotal - discount_amount + tax_amount,
    updated_at = CURRENT_TIMESTAMP
WHERE quote_id = $1
RETURNING *;
```

### Sales Pipeline Queries

```sql
-- Get quotes by status (pipeline view)
SELECT status, COUNT(*) as count, SUM(total_amount) as total_value
FROM quotes
WHERE sales_rep_id = $1
GROUP BY status;

-- Get quotes requiring follow-up
SELECT q.*, c.company_name, c.email
FROM quotes q
JOIN customers c ON q.customer_id = c.customer_id
WHERE q.status = 'SENT'
  AND q.updated_at < CURRENT_TIMESTAMP - INTERVAL '3 days';
```

---

## Seed Data

### Sample Customers

```sql
INSERT INTO customers (customer_code, company_name, tax_number, email, customer_type, credit_limit)
VALUES 
    ('CUST-001', 'ABC Construction Ltd', 'TAX123456', 'procurement@abcconstruction.com', 'ENTERPRISE', 500000.00),
    ('CUST-002', 'XYZ Mining Corp', 'TAX234567', 'orders@xyzmining.com', 'ENTERPRISE', 1000000.00),
    ('CUST-003', 'Metro Infrastructure', 'TAX345678', 'purchasing@metroinfra.com', 'GOVERNMENT', 750000.00);
```

### Sample Products

```sql
INSERT INTO products (product_code, product_name, category, manufacturer, base_price, specifications)
VALUES 
    ('EXC-XL500', 'Excavator XL-500', 'EXCAVATORS', 'HeavyMach Inc', 450000.00, 
     '{"weight_tons": 25, "engine_hp": 180, "bucket_capacity_m3": 1.2}'),
    ('LDR-M300', 'Loader M-300', 'LOADERS', 'HeavyMach Inc', 280000.00, 
     '{"weight_tons": 15, "engine_hp": 150, "bucket_capacity_m3": 2.5}'),
    ('BLD-D400', 'Bulldozer D-400', 'BULLDOZERS', 'HeavyMach Inc', 520000.00, 
     '{"weight_tons": 30, "engine_hp": 220, "blade_width_m": 4.2}');
```

### Sample Warehouses

```sql
INSERT INTO warehouses (warehouse_code, warehouse_name, city, country)
VALUES 
    ('WH-MAIN', 'Main Distribution Center', 'Chicago', 'USA'),
    ('WH-WEST', 'West Coast Facility', 'Los Angeles', 'USA'),
    ('WH-EAST', 'East Coast Facility', 'Newark', 'USA');
```

### Sample Vendors

```sql
INSERT INTO vendors (vendor_code, vendor_name, email, phone, payment_terms, rating)
VALUES 
    ('VND-001', 'HeavyMach Manufacturing Inc', 'orders@heavymach.com', '+1-800-555-0001', 30, 4.8),
    ('VND-002', 'LiftMax Corporation', 'sales@liftmax.com', '+1-800-555-0002', 45, 4.6);
```

---

## Database Maintenance

### Backup Commands

```bash
# Full database backup
pg_dump -U postgres -d dealer_management > backup_$(date +%Y%m%d).sql

# Restore database
psql -U postgres -d dealer_management < backup_20251202.sql
```

### Performance Optimization

```sql
-- Analyze tables for query optimization
ANALYZE customers;
ANALYZE quotes;
ANALYZE inventory;

-- Vacuum to reclaim storage
VACUUM ANALYZE;
```

---

## Notes

1. All UUID primary keys use the `uuid_generate_v4()` function for generation
2. Timestamps use `CURRENT_TIMESTAMP` for automatic time setting
3. Cascade deletes are configured for related tables
4. Indexes are created on foreign keys and frequently queried columns
5. JSONB type is used for flexible schema fields like `specifications` and `configuration_data`
