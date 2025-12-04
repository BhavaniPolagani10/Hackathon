-- =====================================================================
-- ERP SYSTEM DATABASE SCHEMA
-- PostgreSQL Database Schema for Enterprise Resource Planning
-- =====================================================================
-- 
-- Document Version: 1.0
-- Created: December 2025
-- Purpose: Database schema supporting Automated Purchase Order Management
-- 
-- This schema is derived from:
--   - /MLP/Automated_Purchase_Order_Management_MLP.md
--   - /MLP/Automated_Quotation_Generation_MLP.md
--   - /PRD/Multiphase_PRD.md
--   - /MockData/MockMailConversations.md
--
-- =====================================================================
-- ASSUMPTIONS
-- =====================================================================
-- 
-- 1. Module Assumptions:
--    - PO lifecycle includes: Created, Sent, Acknowledged, InProgress, 
--      Shipped, PartiallyShipped, Delivered, Completed, Delayed, Escalated, Cancelled
--    - Multiple vendors can fulfill a single PO (split orders)
--    - Vendors have different integration methods (Email, EDI, API, Portal, SMS)
--    - Carrier tracking is integrated for delivery monitoring
--
-- 2. Missing Details Inferred:
--    - Added audit tables for compliance tracking
--    - Added performance metrics tables for AI model training
--    - Added notification queue for async processing
--    - Added budget management for finance team requirements
--
-- 3. Optional Tables Added for Completeness:
--    - erp_system_configuration - System-wide settings
--    - erp_audit_log - Change tracking
--    - erp_notification_queue - Async notification handling
--    - erp_carrier_mapping - Carrier integration settings
--    - erp_exchange_rate_history - Historical exchange rates
--
-- =====================================================================
-- ENTITY RELATIONSHIP DIAGRAM (Mermaid Format)
-- =====================================================================
/*
erDiagram
    erp_vendor ||--o{ erp_purchase_order : supplies
    erp_purchase_order ||--|{ erp_po_line_item : contains
    erp_purchase_order ||--o{ erp_po_status_history : tracks
    erp_purchase_order ||--o{ erp_delivery_tracking : monitors
    erp_vendor ||--o{ erp_vendor_performance : measures
    erp_vendor ||--o{ erp_vendor_contact : has
    erp_product ||--o{ erp_po_line_item : ordered
    erp_product ||--o{ erp_inventory : stored
    erp_warehouse ||--o{ erp_inventory : contains
    erp_carrier ||--o{ erp_shipment : handles
    erp_shipment ||--o{ erp_shipment_item : includes
    erp_department ||--o{ erp_budget : allocated
    erp_purchase_order }|--|| erp_budget : charged
    erp_invoice ||--o{ erp_invoice_line_item : contains
    erp_invoice }|--|| erp_purchase_order : references
*/

-- =====================================================================
-- DROP EXISTING SCHEMA (for clean installation)
-- =====================================================================

DROP SCHEMA IF EXISTS erp CASCADE;
CREATE SCHEMA erp;

SET search_path TO erp;

-- =====================================================================
-- LOOKUP/REFERENCE TABLES
-- =====================================================================

-- PO Status Lookup
CREATE TABLE erp_po_status (
    status_id SERIAL PRIMARY KEY,
    status_code VARCHAR(50) NOT NULL UNIQUE,
    status_name VARCHAR(100) NOT NULL,
    status_description TEXT,
    is_terminal BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Vendor Integration Types
CREATE TABLE erp_integration_type (
    integration_type_id SERIAL PRIMARY KEY,
    type_code VARCHAR(50) NOT NULL UNIQUE,
    type_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Priority Levels
CREATE TABLE erp_priority_level (
    priority_id SERIAL PRIMARY KEY,
    priority_code VARCHAR(20) NOT NULL UNIQUE,
    priority_name VARCHAR(50) NOT NULL,
    escalation_hours INTEGER DEFAULT 24,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Currency Reference
CREATE TABLE erp_currency (
    currency_id SERIAL PRIMARY KEY,
    currency_code VARCHAR(3) NOT NULL UNIQUE,
    currency_name VARCHAR(100) NOT NULL,
    currency_symbol VARCHAR(10),
    decimal_places INTEGER DEFAULT 2,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Unit of Measure
CREATE TABLE erp_unit_of_measure (
    uom_id SERIAL PRIMARY KEY,
    uom_code VARCHAR(20) NOT NULL UNIQUE,
    uom_name VARCHAR(100) NOT NULL,
    uom_category VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Country Reference
CREATE TABLE erp_country (
    country_id SERIAL PRIMARY KEY,
    country_code VARCHAR(3) NOT NULL UNIQUE,
    country_name VARCHAR(100) NOT NULL,
    region VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- VENDOR MANAGEMENT TABLES
-- =====================================================================

-- Vendor Master
CREATE TABLE erp_vendor (
    vendor_id SERIAL PRIMARY KEY,
    vendor_code VARCHAR(50) NOT NULL UNIQUE,
    vendor_name VARCHAR(200) NOT NULL,
    legal_name VARCHAR(200),
    vendor_type VARCHAR(50) DEFAULT 'SUPPLIER',
    tax_id VARCHAR(50),
    registration_number VARCHAR(100),
    website_url VARCHAR(255),
    preferred_currency_id INTEGER REFERENCES erp_currency(currency_id),
    preferred_integration_type_id INTEGER REFERENCES erp_integration_type(integration_type_id),
    payment_terms_days INTEGER DEFAULT 30,
    credit_limit DECIMAL(15,2),
    credit_rating VARCHAR(20),
    is_preferred BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER
);

CREATE INDEX idx_vendor_code ON erp_vendor(vendor_code);
CREATE INDEX idx_vendor_name ON erp_vendor(vendor_name);
CREATE INDEX idx_vendor_active ON erp_vendor(is_active);

-- Vendor Address
CREATE TABLE erp_vendor_address (
    address_id SERIAL PRIMARY KEY,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id) ON DELETE CASCADE,
    address_type VARCHAR(50) DEFAULT 'MAIN',
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country_id INTEGER REFERENCES erp_country(country_id),
    is_primary BOOLEAN DEFAULT FALSE,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vendor_address_vendor ON erp_vendor_address(vendor_id);

-- Vendor Contacts
CREATE TABLE erp_vendor_contact (
    contact_id SERIAL PRIMARY KEY,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id) ON DELETE CASCADE,
    contact_type VARCHAR(50) DEFAULT 'GENERAL',
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    job_title VARCHAR(100),
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    mobile VARCHAR(50),
    is_primary BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    notification_preference VARCHAR(50) DEFAULT 'EMAIL',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vendor_contact_vendor ON erp_vendor_contact(vendor_id);
CREATE INDEX idx_vendor_contact_email ON erp_vendor_contact(email);

-- Vendor Bank Account
CREATE TABLE erp_vendor_bank_account (
    bank_account_id SERIAL PRIMARY KEY,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id) ON DELETE CASCADE,
    bank_name VARCHAR(200) NOT NULL,
    account_name VARCHAR(200) NOT NULL,
    account_number VARCHAR(100) NOT NULL,
    routing_number VARCHAR(50),
    swift_code VARCHAR(20),
    iban VARCHAR(50),
    currency_id INTEGER REFERENCES erp_currency(currency_id),
    is_primary BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vendor_bank_vendor ON erp_vendor_bank_account(vendor_id);

-- Vendor Performance Metrics
CREATE TABLE erp_vendor_performance (
    performance_id SERIAL PRIMARY KEY,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id) ON DELETE CASCADE,
    evaluation_period_start DATE NOT NULL,
    evaluation_period_end DATE NOT NULL,
    total_orders INTEGER DEFAULT 0,
    on_time_deliveries INTEGER DEFAULT 0,
    late_deliveries INTEGER DEFAULT 0,
    quality_rating DECIMAL(3,2),
    response_time_avg_hours DECIMAL(10,2),
    defect_rate_percent DECIMAL(5,2),
    overall_score DECIMAL(5,2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER
);

CREATE INDEX idx_vendor_perf_vendor ON erp_vendor_performance(vendor_id);
CREATE INDEX idx_vendor_perf_period ON erp_vendor_performance(evaluation_period_start, evaluation_period_end);

-- Vendor Certification
CREATE TABLE erp_vendor_certification (
    certification_id SERIAL PRIMARY KEY,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id) ON DELETE CASCADE,
    certification_name VARCHAR(200) NOT NULL,
    certification_body VARCHAR(200),
    certificate_number VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    document_url VARCHAR(500),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vendor_cert_vendor ON erp_vendor_certification(vendor_id);
CREATE INDEX idx_vendor_cert_expiry ON erp_vendor_certification(expiry_date);

-- Vendor Contract
CREATE TABLE erp_vendor_contract (
    contract_id SERIAL PRIMARY KEY,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id) ON DELETE CASCADE,
    contract_number VARCHAR(100) NOT NULL UNIQUE,
    contract_name VARCHAR(200) NOT NULL,
    contract_type VARCHAR(50) DEFAULT 'STANDARD',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_value DECIMAL(15,2),
    currency_id INTEGER REFERENCES erp_currency(currency_id),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    terms_conditions TEXT,
    document_url VARCHAR(500),
    auto_renewal BOOLEAN DEFAULT FALSE,
    notice_period_days INTEGER DEFAULT 30,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    approved_by INTEGER,
    approved_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_vendor_contract_vendor ON erp_vendor_contract(vendor_id);
CREATE INDEX idx_vendor_contract_status ON erp_vendor_contract(status);
CREATE INDEX idx_vendor_contract_dates ON erp_vendor_contract(start_date, end_date);

-- =====================================================================
-- PRODUCT & INVENTORY TABLES
-- =====================================================================

-- Product Category
CREATE TABLE erp_product_category (
    category_id SERIAL PRIMARY KEY,
    category_code VARCHAR(50) NOT NULL UNIQUE,
    category_name VARCHAR(200) NOT NULL,
    parent_category_id INTEGER REFERENCES erp_product_category(category_id),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_cat_parent ON erp_product_category(parent_category_id);

-- Product Master
CREATE TABLE erp_product (
    product_id SERIAL PRIMARY KEY,
    product_code VARCHAR(100) NOT NULL UNIQUE,
    product_name VARCHAR(300) NOT NULL,
    description TEXT,
    category_id INTEGER REFERENCES erp_product_category(category_id),
    brand VARCHAR(100),
    model_number VARCHAR(100),
    manufacturer VARCHAR(200),
    uom_id INTEGER REFERENCES erp_unit_of_measure(uom_id),
    weight_kg DECIMAL(10,3),
    length_cm DECIMAL(10,2),
    width_cm DECIMAL(10,2),
    height_cm DECIMAL(10,2),
    is_serialized BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    lead_time_days INTEGER DEFAULT 0,
    reorder_point INTEGER DEFAULT 0,
    reorder_quantity INTEGER DEFAULT 0,
    specifications JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_code ON erp_product(product_code);
CREATE INDEX idx_product_name ON erp_product(product_name);
CREATE INDEX idx_product_category ON erp_product(category_id);
CREATE INDEX idx_product_active ON erp_product(is_active);

-- Product Pricing
CREATE TABLE erp_product_pricing (
    pricing_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES erp_product(product_id) ON DELETE CASCADE,
    vendor_id INTEGER REFERENCES erp_vendor(vendor_id),
    currency_id INTEGER NOT NULL REFERENCES erp_currency(currency_id),
    unit_cost DECIMAL(15,4) NOT NULL,
    list_price DECIMAL(15,4),
    minimum_order_qty INTEGER DEFAULT 1,
    volume_discount_percent DECIMAL(5,2),
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_pricing_product ON erp_product_pricing(product_id);
CREATE INDEX idx_product_pricing_vendor ON erp_product_pricing(vendor_id);
CREATE INDEX idx_product_pricing_dates ON erp_product_pricing(effective_from, effective_to);

-- Warehouse
CREATE TABLE erp_warehouse (
    warehouse_id SERIAL PRIMARY KEY,
    warehouse_code VARCHAR(50) NOT NULL UNIQUE,
    warehouse_name VARCHAR(200) NOT NULL,
    warehouse_type VARCHAR(50) DEFAULT 'STANDARD',
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country_id INTEGER REFERENCES erp_country(country_id),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    manager_name VARCHAR(200),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_warehouse_code ON erp_warehouse(warehouse_code);
CREATE INDEX idx_warehouse_active ON erp_warehouse(is_active);

-- Inventory
CREATE TABLE erp_inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES erp_product(product_id),
    warehouse_id INTEGER NOT NULL REFERENCES erp_warehouse(warehouse_id),
    quantity_on_hand INTEGER NOT NULL DEFAULT 0,
    quantity_reserved INTEGER NOT NULL DEFAULT 0,
    quantity_available INTEGER GENERATED ALWAYS AS (quantity_on_hand - quantity_reserved) STORED,
    quantity_on_order INTEGER NOT NULL DEFAULT 0,
    last_count_date DATE,
    last_movement_date DATE,
    bin_location VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_inventory_product_warehouse UNIQUE (product_id, warehouse_id)
);

CREATE INDEX idx_inventory_product ON erp_inventory(product_id);
CREATE INDEX idx_inventory_warehouse ON erp_inventory(warehouse_id);

-- Inventory Transaction
CREATE TABLE erp_inventory_transaction (
    transaction_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES erp_product(product_id),
    warehouse_id INTEGER NOT NULL REFERENCES erp_warehouse(warehouse_id),
    transaction_type VARCHAR(50) NOT NULL,
    quantity INTEGER NOT NULL,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    transaction_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_by INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inv_trans_product ON erp_inventory_transaction(product_id);
CREATE INDEX idx_inv_trans_warehouse ON erp_inventory_transaction(warehouse_id);
CREATE INDEX idx_inv_trans_date ON erp_inventory_transaction(transaction_date);
CREATE INDEX idx_inv_trans_reference ON erp_inventory_transaction(reference_type, reference_id);

-- =====================================================================
-- PURCHASE ORDER TABLES
-- =====================================================================

-- Purchase Order
CREATE TABLE erp_purchase_order (
    po_id SERIAL PRIMARY KEY,
    po_number VARCHAR(50) NOT NULL UNIQUE,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id),
    quote_reference VARCHAR(100),
    status_id INTEGER NOT NULL REFERENCES erp_po_status(status_id),
    priority_id INTEGER REFERENCES erp_priority_level(priority_id),
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    required_date DATE,
    promised_date DATE,
    currency_id INTEGER NOT NULL REFERENCES erp_currency(currency_id),
    subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    shipping_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    payment_terms VARCHAR(100),
    shipping_method VARCHAR(100),
    shipping_address_id INTEGER,
    billing_address_id INTEGER,
    notes TEXT,
    internal_notes TEXT,
    is_split_order BOOLEAN DEFAULT FALSE,
    parent_po_id INTEGER REFERENCES erp_purchase_order(po_id),
    acknowledgment_received BOOLEAN DEFAULT FALSE,
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    vendor_confirmation_number VARCHAR(100),
    budget_id INTEGER,
    cost_center VARCHAR(50),
    department_id INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER,
    approved_by INTEGER,
    approved_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_po_number ON erp_purchase_order(po_number);
CREATE INDEX idx_po_vendor ON erp_purchase_order(vendor_id);
CREATE INDEX idx_po_status ON erp_purchase_order(status_id);
CREATE INDEX idx_po_order_date ON erp_purchase_order(order_date);
CREATE INDEX idx_po_required_date ON erp_purchase_order(required_date);
CREATE INDEX idx_po_quote_ref ON erp_purchase_order(quote_reference);
CREATE INDEX idx_po_parent ON erp_purchase_order(parent_po_id);

-- PO Line Item
CREATE TABLE erp_po_line_item (
    line_item_id SERIAL PRIMARY KEY,
    po_id INTEGER NOT NULL REFERENCES erp_purchase_order(po_id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    product_id INTEGER REFERENCES erp_product(product_id),
    product_code VARCHAR(100),
    product_description VARCHAR(500) NOT NULL,
    quantity_ordered INTEGER NOT NULL,
    quantity_received INTEGER DEFAULT 0,
    quantity_outstanding INTEGER GENERATED ALWAYS AS (quantity_ordered - quantity_received) STORED,
    uom_id INTEGER REFERENCES erp_unit_of_measure(uom_id),
    unit_price DECIMAL(15,4) NOT NULL,
    line_total DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    required_date DATE,
    promised_date DATE,
    notes TEXT,
    is_cancelled BOOLEAN DEFAULT FALSE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancelled_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_po_line UNIQUE (po_id, line_number)
);

CREATE INDEX idx_po_line_po ON erp_po_line_item(po_id);
CREATE INDEX idx_po_line_product ON erp_po_line_item(product_id);

-- PO Status History
CREATE TABLE erp_po_status_history (
    history_id SERIAL PRIMARY KEY,
    po_id INTEGER NOT NULL REFERENCES erp_purchase_order(po_id) ON DELETE CASCADE,
    old_status_id INTEGER REFERENCES erp_po_status(status_id),
    new_status_id INTEGER NOT NULL REFERENCES erp_po_status(status_id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    changed_by INTEGER,
    reason TEXT,
    notes TEXT
);

CREATE INDEX idx_po_status_hist_po ON erp_po_status_history(po_id);
CREATE INDEX idx_po_status_hist_date ON erp_po_status_history(changed_at);

-- PO Approval
CREATE TABLE erp_po_approval (
    approval_id SERIAL PRIMARY KEY,
    po_id INTEGER NOT NULL REFERENCES erp_purchase_order(po_id) ON DELETE CASCADE,
    approval_level INTEGER NOT NULL DEFAULT 1,
    approver_id INTEGER NOT NULL,
    approver_name VARCHAR(200),
    approval_status VARCHAR(50) DEFAULT 'PENDING',
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP WITH TIME ZONE,
    comments TEXT
);

CREATE INDEX idx_po_approval_po ON erp_po_approval(po_id);
CREATE INDEX idx_po_approval_approver ON erp_po_approval(approver_id);
CREATE INDEX idx_po_approval_status ON erp_po_approval(approval_status);

-- PO Attachment
CREATE TABLE erp_po_attachment (
    attachment_id SERIAL PRIMARY KEY,
    po_id INTEGER NOT NULL REFERENCES erp_purchase_order(po_id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(50),
    file_size INTEGER,
    file_url VARCHAR(500) NOT NULL,
    description TEXT,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    uploaded_by INTEGER
);

CREATE INDEX idx_po_attachment_po ON erp_po_attachment(po_id);

-- =====================================================================
-- DELIVERY & SHIPPING TABLES
-- =====================================================================

-- Carrier
CREATE TABLE erp_carrier (
    carrier_id SERIAL PRIMARY KEY,
    carrier_code VARCHAR(50) NOT NULL UNIQUE,
    carrier_name VARCHAR(200) NOT NULL,
    carrier_type VARCHAR(50) DEFAULT 'FREIGHT',
    api_endpoint VARCHAR(500),
    api_key_encrypted VARCHAR(500),
    tracking_url_template VARCHAR(500),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_carrier_code ON erp_carrier(carrier_code);
CREATE INDEX idx_carrier_active ON erp_carrier(is_active);

-- Shipment
CREATE TABLE erp_shipment (
    shipment_id SERIAL PRIMARY KEY,
    shipment_number VARCHAR(50) NOT NULL UNIQUE,
    po_id INTEGER NOT NULL REFERENCES erp_purchase_order(po_id),
    carrier_id INTEGER REFERENCES erp_carrier(carrier_id),
    tracking_number VARCHAR(100),
    shipment_status VARCHAR(50) DEFAULT 'PENDING',
    ship_date DATE,
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    ship_from_address TEXT,
    ship_to_address TEXT,
    shipping_cost DECIMAL(10,2),
    weight_kg DECIMAL(10,3),
    package_count INTEGER DEFAULT 1,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_shipment_number ON erp_shipment(shipment_number);
CREATE INDEX idx_shipment_po ON erp_shipment(po_id);
CREATE INDEX idx_shipment_tracking ON erp_shipment(tracking_number);
CREATE INDEX idx_shipment_status ON erp_shipment(shipment_status);

-- Shipment Item
CREATE TABLE erp_shipment_item (
    shipment_item_id SERIAL PRIMARY KEY,
    shipment_id INTEGER NOT NULL REFERENCES erp_shipment(shipment_id) ON DELETE CASCADE,
    po_line_item_id INTEGER REFERENCES erp_po_line_item(line_item_id),
    product_id INTEGER REFERENCES erp_product(product_id),
    quantity_shipped INTEGER NOT NULL,
    serial_numbers TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_shipment_item_shipment ON erp_shipment_item(shipment_id);
CREATE INDEX idx_shipment_item_po_line ON erp_shipment_item(po_line_item_id);

-- Delivery Tracking
CREATE TABLE erp_delivery_tracking (
    tracking_id SERIAL PRIMARY KEY,
    shipment_id INTEGER NOT NULL REFERENCES erp_shipment(shipment_id) ON DELETE CASCADE,
    tracking_status VARCHAR(100) NOT NULL,
    status_description TEXT,
    location VARCHAR(200),
    event_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    carrier_status_code VARCHAR(50),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_delivery_track_shipment ON erp_delivery_tracking(shipment_id);
CREATE INDEX idx_delivery_track_timestamp ON erp_delivery_tracking(event_timestamp);

-- Goods Receipt
CREATE TABLE erp_goods_receipt (
    receipt_id SERIAL PRIMARY KEY,
    receipt_number VARCHAR(50) NOT NULL UNIQUE,
    po_id INTEGER NOT NULL REFERENCES erp_purchase_order(po_id),
    shipment_id INTEGER REFERENCES erp_shipment(shipment_id),
    warehouse_id INTEGER NOT NULL REFERENCES erp_warehouse(warehouse_id),
    receipt_date DATE NOT NULL DEFAULT CURRENT_DATE,
    receipt_status VARCHAR(50) DEFAULT 'PENDING',
    received_by INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_goods_receipt_number ON erp_goods_receipt(receipt_number);
CREATE INDEX idx_goods_receipt_po ON erp_goods_receipt(po_id);
CREATE INDEX idx_goods_receipt_date ON erp_goods_receipt(receipt_date);

-- Goods Receipt Item
CREATE TABLE erp_goods_receipt_item (
    receipt_item_id SERIAL PRIMARY KEY,
    receipt_id INTEGER NOT NULL REFERENCES erp_goods_receipt(receipt_id) ON DELETE CASCADE,
    po_line_item_id INTEGER NOT NULL REFERENCES erp_po_line_item(line_item_id),
    product_id INTEGER REFERENCES erp_product(product_id),
    quantity_received INTEGER NOT NULL,
    quantity_accepted INTEGER NOT NULL,
    quantity_rejected INTEGER DEFAULT 0,
    rejection_reason TEXT,
    bin_location VARCHAR(50),
    serial_numbers TEXT[],
    inspection_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_receipt_item_receipt ON erp_goods_receipt_item(receipt_id);
CREATE INDEX idx_receipt_item_po_line ON erp_goods_receipt_item(po_line_item_id);

-- =====================================================================
-- FINANCIAL TABLES
-- =====================================================================

-- Department
CREATE TABLE erp_department (
    department_id SERIAL PRIMARY KEY,
    department_code VARCHAR(50) NOT NULL UNIQUE,
    department_name VARCHAR(200) NOT NULL,
    parent_department_id INTEGER REFERENCES erp_department(department_id),
    manager_id INTEGER,
    cost_center VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_department_code ON erp_department(department_code);

-- Budget
CREATE TABLE erp_budget (
    budget_id SERIAL PRIMARY KEY,
    budget_code VARCHAR(50) NOT NULL UNIQUE,
    budget_name VARCHAR(200) NOT NULL,
    department_id INTEGER REFERENCES erp_department(department_id),
    fiscal_year INTEGER NOT NULL,
    fiscal_period VARCHAR(20),
    currency_id INTEGER NOT NULL REFERENCES erp_currency(currency_id),
    budgeted_amount DECIMAL(15,2) NOT NULL,
    committed_amount DECIMAL(15,2) DEFAULT 0,
    spent_amount DECIMAL(15,2) DEFAULT 0,
    available_amount DECIMAL(15,2) GENERATED ALWAYS AS (budgeted_amount - committed_amount - spent_amount) STORED,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    approved_by INTEGER
);

CREATE INDEX idx_budget_code ON erp_budget(budget_code);
CREATE INDEX idx_budget_department ON erp_budget(department_id);
CREATE INDEX idx_budget_year ON erp_budget(fiscal_year);

-- Budget Transaction
CREATE TABLE erp_budget_transaction (
    transaction_id SERIAL PRIMARY KEY,
    budget_id INTEGER NOT NULL REFERENCES erp_budget(budget_id),
    transaction_type VARCHAR(50) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    description TEXT,
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER
);

CREATE INDEX idx_budget_trans_budget ON erp_budget_transaction(budget_id);
CREATE INDEX idx_budget_trans_date ON erp_budget_transaction(transaction_date);
CREATE INDEX idx_budget_trans_ref ON erp_budget_transaction(reference_type, reference_id);

-- Invoice Header
CREATE TABLE erp_invoice (
    invoice_id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(100) NOT NULL UNIQUE,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id),
    po_id INTEGER REFERENCES erp_purchase_order(po_id),
    vendor_invoice_number VARCHAR(100),
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    currency_id INTEGER NOT NULL REFERENCES erp_currency(currency_id),
    subtotal DECIMAL(15,2) NOT NULL,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    amount_paid DECIMAL(15,2) DEFAULT 0,
    balance_due DECIMAL(15,2) GENERATED ALWAYS AS (total_amount - amount_paid) STORED,
    status VARCHAR(50) DEFAULT 'PENDING',
    payment_status VARCHAR(50) DEFAULT 'UNPAID',
    payment_method VARCHAR(50),
    payment_reference VARCHAR(100),
    paid_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    document_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    approved_by INTEGER,
    approved_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_invoice_number ON erp_invoice(invoice_number);
CREATE INDEX idx_invoice_vendor ON erp_invoice(vendor_id);
CREATE INDEX idx_invoice_po ON erp_invoice(po_id);
CREATE INDEX idx_invoice_status ON erp_invoice(status);
CREATE INDEX idx_invoice_due_date ON erp_invoice(due_date);

-- Invoice Line Item
CREATE TABLE erp_invoice_line_item (
    line_item_id SERIAL PRIMARY KEY,
    invoice_id INTEGER NOT NULL REFERENCES erp_invoice(invoice_id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    po_line_item_id INTEGER REFERENCES erp_po_line_item(line_item_id),
    product_id INTEGER REFERENCES erp_product(product_id),
    description VARCHAR(500) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(15,4) NOT NULL,
    line_total DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_invoice_line UNIQUE (invoice_id, line_number)
);

CREATE INDEX idx_invoice_line_invoice ON erp_invoice_line_item(invoice_id);
CREATE INDEX idx_invoice_line_po_line ON erp_invoice_line_item(po_line_item_id);

-- Payment
CREATE TABLE erp_payment (
    payment_id SERIAL PRIMARY KEY,
    payment_number VARCHAR(50) NOT NULL UNIQUE,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id),
    payment_date DATE NOT NULL,
    currency_id INTEGER NOT NULL REFERENCES erp_currency(currency_id),
    total_amount DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    bank_account_id INTEGER REFERENCES erp_vendor_bank_account(bank_account_id),
    reference_number VARCHAR(100),
    status VARCHAR(50) DEFAULT 'PENDING',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    approved_by INTEGER
);

CREATE INDEX idx_payment_number ON erp_payment(payment_number);
CREATE INDEX idx_payment_vendor ON erp_payment(vendor_id);
CREATE INDEX idx_payment_date ON erp_payment(payment_date);

-- Payment Allocation
CREATE TABLE erp_payment_allocation (
    allocation_id SERIAL PRIMARY KEY,
    payment_id INTEGER NOT NULL REFERENCES erp_payment(payment_id) ON DELETE CASCADE,
    invoice_id INTEGER NOT NULL REFERENCES erp_invoice(invoice_id),
    allocated_amount DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payment_alloc_payment ON erp_payment_allocation(payment_id);
CREATE INDEX idx_payment_alloc_invoice ON erp_payment_allocation(invoice_id);

-- Exchange Rate History
CREATE TABLE erp_exchange_rate_history (
    rate_id SERIAL PRIMARY KEY,
    from_currency_id INTEGER NOT NULL REFERENCES erp_currency(currency_id),
    to_currency_id INTEGER NOT NULL REFERENCES erp_currency(currency_id),
    exchange_rate DECIMAL(18,8) NOT NULL,
    rate_date DATE NOT NULL,
    source VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_exchange_rate_currencies ON erp_exchange_rate_history(from_currency_id, to_currency_id);
CREATE INDEX idx_exchange_rate_date ON erp_exchange_rate_history(rate_date);

-- =====================================================================
-- NOTIFICATION & COMMUNICATION TABLES
-- =====================================================================

-- Notification Queue
CREATE TABLE erp_notification_queue (
    notification_id SERIAL PRIMARY KEY,
    notification_type VARCHAR(50) NOT NULL,
    recipient_type VARCHAR(50) NOT NULL,
    recipient_id INTEGER,
    recipient_email VARCHAR(255),
    recipient_phone VARCHAR(50),
    subject VARCHAR(500),
    body TEXT NOT NULL,
    template_id VARCHAR(100),
    template_data JSONB,
    channel VARCHAR(50) DEFAULT 'EMAIL',
    priority VARCHAR(20) DEFAULT 'NORMAL',
    status VARCHAR(50) DEFAULT 'PENDING',
    scheduled_at TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    error_message TEXT,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notification_status ON erp_notification_queue(status);
CREATE INDEX idx_notification_scheduled ON erp_notification_queue(scheduled_at);
CREATE INDEX idx_notification_reference ON erp_notification_queue(reference_type, reference_id);

-- Notification Template
CREATE TABLE erp_notification_template (
    template_id SERIAL PRIMARY KEY,
    template_code VARCHAR(100) NOT NULL UNIQUE,
    template_name VARCHAR(200) NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    channel VARCHAR(50) DEFAULT 'EMAIL',
    subject_template VARCHAR(500),
    body_template TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notif_template_code ON erp_notification_template(template_code);

-- Vendor Communication Log
CREATE TABLE erp_vendor_communication_log (
    log_id SERIAL PRIMARY KEY,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id),
    po_id INTEGER REFERENCES erp_purchase_order(po_id),
    communication_type VARCHAR(50) NOT NULL,
    direction VARCHAR(20) NOT NULL,
    channel VARCHAR(50) NOT NULL,
    subject VARCHAR(500),
    content TEXT,
    sender_email VARCHAR(255),
    recipient_email VARCHAR(255),
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) DEFAULT 'SENT',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vendor_comm_vendor ON erp_vendor_communication_log(vendor_id);
CREATE INDEX idx_vendor_comm_po ON erp_vendor_communication_log(po_id);
CREATE INDEX idx_vendor_comm_date ON erp_vendor_communication_log(sent_at);

-- =====================================================================
-- ISSUE & ESCALATION TABLES
-- =====================================================================

-- Issue Category
CREATE TABLE erp_issue_category (
    category_id SERIAL PRIMARY KEY,
    category_code VARCHAR(50) NOT NULL UNIQUE,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    default_priority_id INTEGER REFERENCES erp_priority_level(priority_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Issue
CREATE TABLE erp_issue (
    issue_id SERIAL PRIMARY KEY,
    issue_number VARCHAR(50) NOT NULL UNIQUE,
    issue_type VARCHAR(50) NOT NULL,
    category_id INTEGER REFERENCES erp_issue_category(category_id),
    priority_id INTEGER REFERENCES erp_priority_level(priority_id),
    reference_type VARCHAR(50),
    reference_id INTEGER,
    subject VARCHAR(500) NOT NULL,
    description TEXT,
    impact_level VARCHAR(50),
    status VARCHAR(50) DEFAULT 'OPEN',
    resolution TEXT,
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE,
    assigned_to INTEGER,
    assigned_team VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER
);

CREATE INDEX idx_issue_number ON erp_issue(issue_number);
CREATE INDEX idx_issue_status ON erp_issue(status);
CREATE INDEX idx_issue_priority ON erp_issue(priority_id);
CREATE INDEX idx_issue_reference ON erp_issue(reference_type, reference_id);
CREATE INDEX idx_issue_assigned ON erp_issue(assigned_to);

-- Issue Comment
CREATE TABLE erp_issue_comment (
    comment_id SERIAL PRIMARY KEY,
    issue_id INTEGER NOT NULL REFERENCES erp_issue(issue_id) ON DELETE CASCADE,
    comment_text TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER
);

CREATE INDEX idx_issue_comment_issue ON erp_issue_comment(issue_id);

-- Escalation Rule
CREATE TABLE erp_escalation_rule (
    rule_id SERIAL PRIMARY KEY,
    rule_name VARCHAR(200) NOT NULL,
    issue_category_id INTEGER REFERENCES erp_issue_category(category_id),
    priority_id INTEGER REFERENCES erp_priority_level(priority_id),
    escalation_level INTEGER NOT NULL DEFAULT 1,
    escalation_after_hours INTEGER NOT NULL,
    escalate_to_role VARCHAR(100),
    escalate_to_user_id INTEGER,
    notification_template_id INTEGER REFERENCES erp_notification_template(template_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_escalation_rule_category ON erp_escalation_rule(issue_category_id);
CREATE INDEX idx_escalation_rule_priority ON erp_escalation_rule(priority_id);

-- Escalation Log
CREATE TABLE erp_escalation_log (
    escalation_id SERIAL PRIMARY KEY,
    issue_id INTEGER NOT NULL REFERENCES erp_issue(issue_id),
    rule_id INTEGER REFERENCES erp_escalation_rule(rule_id),
    escalation_level INTEGER NOT NULL,
    escalated_to INTEGER,
    escalated_to_name VARCHAR(200),
    escalated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notification_sent BOOLEAN DEFAULT FALSE,
    notes TEXT
);

CREATE INDEX idx_escalation_log_issue ON erp_escalation_log(issue_id);
CREATE INDEX idx_escalation_log_date ON erp_escalation_log(escalated_at);

-- =====================================================================
-- AI/ML SUPPORT TABLES
-- =====================================================================

-- Vendor Selection AI Score
CREATE TABLE erp_vendor_ai_score (
    score_id SERIAL PRIMARY KEY,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id),
    product_category_id INTEGER REFERENCES erp_product_category(category_id),
    price_score DECIMAL(5,2),
    delivery_score DECIMAL(5,2),
    quality_score DECIMAL(5,2),
    location_score DECIMAL(5,2),
    overall_score DECIMAL(5,2),
    calculation_date DATE NOT NULL,
    model_version VARCHAR(50),
    factors JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vendor_ai_vendor ON erp_vendor_ai_score(vendor_id);
CREATE INDEX idx_vendor_ai_category ON erp_vendor_ai_score(product_category_id);
CREATE INDEX idx_vendor_ai_date ON erp_vendor_ai_score(calculation_date);

-- Delivery Prediction
CREATE TABLE erp_delivery_prediction (
    prediction_id SERIAL PRIMARY KEY,
    po_id INTEGER NOT NULL REFERENCES erp_purchase_order(po_id),
    predicted_delivery_date DATE NOT NULL,
    confidence_score DECIMAL(5,4),
    prediction_factors JSONB,
    model_version VARCHAR(50),
    actual_delivery_date DATE,
    prediction_accuracy DECIMAL(5,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_delivery_pred_po ON erp_delivery_prediction(po_id);
CREATE INDEX idx_delivery_pred_date ON erp_delivery_prediction(predicted_delivery_date);

-- Issue Prediction
CREATE TABLE erp_issue_prediction (
    prediction_id SERIAL PRIMARY KEY,
    reference_type VARCHAR(50) NOT NULL,
    reference_id INTEGER NOT NULL,
    issue_type VARCHAR(50) NOT NULL,
    risk_score DECIMAL(5,4),
    risk_factors JSONB,
    prediction_date DATE NOT NULL,
    model_version VARCHAR(50),
    was_accurate BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_issue_pred_reference ON erp_issue_prediction(reference_type, reference_id);
CREATE INDEX idx_issue_pred_date ON erp_issue_prediction(prediction_date);

-- =====================================================================
-- SYSTEM & AUDIT TABLES
-- =====================================================================

-- User (simplified for ERP context)
CREATE TABLE erp_user (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    department_id INTEGER REFERENCES erp_department(department_id),
    job_title VARCHAR(100),
    phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_username ON erp_user(username);
CREATE INDEX idx_user_email ON erp_user(email);
CREATE INDEX idx_user_department ON erp_user(department_id);

-- System Configuration
CREATE TABLE erp_system_configuration (
    config_id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value TEXT,
    config_type VARCHAR(50) DEFAULT 'STRING',
    description TEXT,
    is_encrypted BOOLEAN DEFAULT FALSE,
    is_editable BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER
);

CREATE INDEX idx_sys_config_key ON erp_system_configuration(config_key);

-- Audit Log
CREATE TABLE erp_audit_log (
    audit_id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER NOT NULL,
    action VARCHAR(20) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],
    user_id INTEGER,
    user_ip VARCHAR(50),
    session_id VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_table ON erp_audit_log(table_name);
CREATE INDEX idx_audit_record ON erp_audit_log(table_name, record_id);
CREATE INDEX idx_audit_user ON erp_audit_log(user_id);
CREATE INDEX idx_audit_date ON erp_audit_log(created_at);

-- API Integration Log
CREATE TABLE erp_api_integration_log (
    log_id SERIAL PRIMARY KEY,
    integration_type VARCHAR(50) NOT NULL,
    endpoint VARCHAR(500),
    http_method VARCHAR(20),
    request_payload JSONB,
    response_payload JSONB,
    response_status_code INTEGER,
    duration_ms INTEGER,
    is_success BOOLEAN,
    error_message TEXT,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_api_log_type ON erp_api_integration_log(integration_type);
CREATE INDEX idx_api_log_reference ON erp_api_integration_log(reference_type, reference_id);
CREATE INDEX idx_api_log_date ON erp_api_integration_log(created_at);

-- =====================================================================
-- REPORTING TABLES
-- =====================================================================

-- Daily PO Summary
CREATE TABLE erp_daily_po_summary (
    summary_id SERIAL PRIMARY KEY,
    summary_date DATE NOT NULL,
    total_pos_created INTEGER DEFAULT 0,
    total_pos_completed INTEGER DEFAULT 0,
    total_pos_cancelled INTEGER DEFAULT 0,
    total_pos_delayed INTEGER DEFAULT 0,
    total_value_ordered DECIMAL(15,2) DEFAULT 0,
    total_value_received DECIMAL(15,2) DEFAULT 0,
    avg_processing_time_hours DECIMAL(10,2),
    on_time_delivery_rate DECIMAL(5,2),
    vendor_response_rate DECIMAL(5,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_daily_po_summary UNIQUE (summary_date)
);

CREATE INDEX idx_daily_po_summary_date ON erp_daily_po_summary(summary_date);

-- Vendor Performance Summary
CREATE TABLE erp_vendor_performance_summary (
    summary_id SERIAL PRIMARY KEY,
    vendor_id INTEGER NOT NULL REFERENCES erp_vendor(vendor_id),
    summary_period VARCHAR(20) NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_orders INTEGER DEFAULT 0,
    total_value DECIMAL(15,2) DEFAULT 0,
    on_time_deliveries INTEGER DEFAULT 0,
    late_deliveries INTEGER DEFAULT 0,
    avg_delivery_days DECIMAL(5,2),
    quality_issues INTEGER DEFAULT 0,
    response_time_hours_avg DECIMAL(10,2),
    overall_rating DECIMAL(3,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_vendor_perf_summary UNIQUE (vendor_id, summary_period, period_start)
);

CREATE INDEX idx_vendor_perf_summary_vendor ON erp_vendor_performance_summary(vendor_id);
CREATE INDEX idx_vendor_perf_summary_period ON erp_vendor_performance_summary(period_start, period_end);

-- =====================================================================
-- END OF ERP SCHEMA
-- =====================================================================

-- Insert default lookup data
INSERT INTO erp_po_status (status_code, status_name, status_description, is_terminal, display_order) VALUES
('CREATED', 'Created', 'PO has been created but not yet sent to vendor', FALSE, 1),
('SENT', 'Sent', 'PO has been sent to vendor', FALSE, 2),
('ACKNOWLEDGED', 'Acknowledged', 'Vendor has acknowledged receipt of PO', FALSE, 3),
('ESCALATED', 'Escalated', 'PO has been escalated due to no response', FALSE, 4),
('IN_PROGRESS', 'In Progress', 'Vendor is fulfilling the order', FALSE, 5),
('SHIPPED', 'Shipped', 'Order has been shipped', FALSE, 6),
('PARTIALLY_SHIPPED', 'Partially Shipped', 'Partial shipment has been sent', FALSE, 7),
('DELIVERED', 'Delivered', 'Order has been delivered', FALSE, 8),
('DELAYED', 'Delayed', 'Delivery has been delayed', FALSE, 9),
('COMPLETED', 'Completed', 'PO has been fully completed', TRUE, 10),
('CANCELLED', 'Cancelled', 'PO has been cancelled', TRUE, 11);

INSERT INTO erp_integration_type (type_code, type_name, description) VALUES
('EMAIL', 'Email', 'Standard email communication with PDF attachments'),
('EDI', 'EDI', 'Electronic Data Interchange for enterprise vendors'),
('API', 'API', 'REST API integration'),
('PORTAL', 'Vendor Portal', 'Web-based vendor self-service portal'),
('SMS', 'SMS', 'SMS text message notifications');

INSERT INTO erp_priority_level (priority_code, priority_name, escalation_hours) VALUES
('CRITICAL', 'Critical', 4),
('HIGH', 'High', 8),
('NORMAL', 'Normal', 24),
('LOW', 'Low', 48);

INSERT INTO erp_currency (currency_code, currency_name, currency_symbol, decimal_places) VALUES
('USD', 'US Dollar', '$', 2),
('EUR', 'Euro', '€', 2),
('GBP', 'British Pound', '£', 2),
('CAD', 'Canadian Dollar', 'C$', 2),
('AUD', 'Australian Dollar', 'A$', 2),
('JPY', 'Japanese Yen', '¥', 0),
('CHF', 'Swiss Franc', 'CHF', 2),
('CNY', 'Chinese Yuan', '¥', 2),
('INR', 'Indian Rupee', '₹', 2),
('MXN', 'Mexican Peso', 'MX$', 2);

INSERT INTO erp_unit_of_measure (uom_code, uom_name, uom_category) VALUES
('EA', 'Each', 'COUNT'),
('PCS', 'Pieces', 'COUNT'),
('SET', 'Set', 'COUNT'),
('KG', 'Kilogram', 'WEIGHT'),
('LB', 'Pound', 'WEIGHT'),
('M', 'Meter', 'LENGTH'),
('FT', 'Feet', 'LENGTH'),
('L', 'Liter', 'VOLUME'),
('GAL', 'Gallon', 'VOLUME'),
('HR', 'Hour', 'TIME');

INSERT INTO erp_country (country_code, country_name, region) VALUES
('USA', 'United States', 'North America'),
('CAN', 'Canada', 'North America'),
('MEX', 'Mexico', 'North America'),
('GBR', 'United Kingdom', 'Europe'),
('DEU', 'Germany', 'Europe'),
('FRA', 'France', 'Europe'),
('JPN', 'Japan', 'Asia'),
('CHN', 'China', 'Asia'),
('IND', 'India', 'Asia'),
('AUS', 'Australia', 'Oceania');

INSERT INTO erp_issue_category (category_code, category_name, description) VALUES
('DELIVERY_DELAY', 'Delivery Delay', 'Issues related to late delivery'),
('QUALITY_ISSUE', 'Quality Issue', 'Product quality problems'),
('QUANTITY_MISMATCH', 'Quantity Mismatch', 'Received quantity differs from ordered'),
('DAMAGE', 'Damaged Goods', 'Products damaged during shipping'),
('VENDOR_RESPONSE', 'Vendor Response', 'No response from vendor'),
('PRICING_ISSUE', 'Pricing Issue', 'Invoice pricing differs from PO'),
('DOCUMENTATION', 'Documentation Issue', 'Missing or incorrect documents');

-- Grant permissions (adjust as needed for your environment)
-- GRANT ALL PRIVILEGES ON SCHEMA erp TO erp_app_user;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA erp TO erp_app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA erp TO erp_app_user;

COMMENT ON SCHEMA erp IS 'ERP System schema for Purchase Order Management and related operations';
