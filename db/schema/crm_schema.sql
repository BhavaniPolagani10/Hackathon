-- =====================================================================
-- CRM SYSTEM DATABASE SCHEMA
-- PostgreSQL Database Schema for Customer Relationship Management
-- =====================================================================
-- 
-- Document Version: 1.0
-- Created: December 2025
-- Purpose: Database schema supporting Automated Quotation Generation
-- 
-- This schema is derived from:
--   - /MLP/Automated_Quotation_Generation_MLP.md
--   - /MLP/Automated_Purchase_Order_Management_MLP.md
--   - /PRD/Multiphase_PRD.md
--   - /MockData/MockMailConversations.md
--
-- =====================================================================
-- ASSUMPTIONS
-- =====================================================================
-- 
-- 1. Module Assumptions:
--    - Quotation lifecycle includes: Draft, PendingReview, Approved, RequiresChanges,
--      SentToCustomer, Accepted, Rejected, Negotiating, Expired
--    - Sales representatives manage leads, opportunities, and quotations
--    - Multi-currency and multi-language support required
--    - AI-powered cost estimation and product recommendations
--
-- 2. Missing Details Inferred:
--    - Added lead scoring tables for AI model training
--    - Added email thread tracking based on MockMailConversations.md
--    - Added product recommendation history for analytics
--    - Added price history for AI cost estimation
--
-- 3. Optional Tables Added for Completeness:
--    - crm_system_configuration - System-wide settings
--    - crm_audit_log - Change tracking
--    - crm_email_template - Email automation templates
--    - crm_ai_recommendation_log - AI recommendation tracking
--    - crm_quote_analytics - Quotation performance metrics
--
-- =====================================================================
-- ENTITY RELATIONSHIP DIAGRAM (Mermaid Format)
-- =====================================================================
/*
erDiagram
    crm_customer ||--o{ crm_contact : has
    crm_customer ||--o{ crm_lead : generates
    crm_customer ||--o{ crm_opportunity : creates
    crm_customer ||--o{ crm_quotation : receives
    crm_lead ||--o| crm_opportunity : converts_to
    crm_opportunity ||--|{ crm_quotation : generates
    crm_quotation ||--|{ crm_quote_line_item : contains
    crm_quotation ||--o{ crm_quote_status_history : tracks
    crm_sales_rep ||--o{ crm_lead : manages
    crm_sales_rep ||--o{ crm_opportunity : owns
    crm_sales_rep ||--o{ crm_quotation : creates
    crm_product ||--o{ crm_quote_line_item : includes
    crm_quote_template ||--o{ crm_quotation : uses
    crm_email_thread ||--|{ crm_email_message : contains
    crm_quotation ||--o{ crm_email_thread : references
*/

-- =====================================================================
-- DROP EXISTING SCHEMA (for clean installation)
-- =====================================================================

DROP SCHEMA IF EXISTS crm CASCADE;
CREATE SCHEMA crm;

SET search_path TO crm;

-- =====================================================================
-- LOOKUP/REFERENCE TABLES
-- =====================================================================

-- Quotation Status Lookup
CREATE TABLE crm_quote_status (
    status_id SERIAL PRIMARY KEY,
    status_code VARCHAR(50) NOT NULL UNIQUE,
    status_name VARCHAR(100) NOT NULL,
    status_description TEXT,
    is_terminal BOOLEAN DEFAULT FALSE,
    requires_approval BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Lead Status Lookup
CREATE TABLE crm_lead_status (
    status_id SERIAL PRIMARY KEY,
    status_code VARCHAR(50) NOT NULL UNIQUE,
    status_name VARCHAR(100) NOT NULL,
    status_description TEXT,
    is_terminal BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Opportunity Stage Lookup
CREATE TABLE crm_opportunity_stage (
    stage_id SERIAL PRIMARY KEY,
    stage_code VARCHAR(50) NOT NULL UNIQUE,
    stage_name VARCHAR(100) NOT NULL,
    stage_description TEXT,
    probability_percent INTEGER DEFAULT 0,
    is_terminal BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Lead Source Lookup
CREATE TABLE crm_lead_source (
    source_id SERIAL PRIMARY KEY,
    source_code VARCHAR(50) NOT NULL UNIQUE,
    source_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Industry Lookup
CREATE TABLE crm_industry (
    industry_id SERIAL PRIMARY KEY,
    industry_code VARCHAR(50) NOT NULL UNIQUE,
    industry_name VARCHAR(200) NOT NULL,
    parent_industry_id INTEGER REFERENCES crm_industry(industry_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Currency Reference
CREATE TABLE crm_currency (
    currency_id SERIAL PRIMARY KEY,
    currency_code VARCHAR(3) NOT NULL UNIQUE,
    currency_name VARCHAR(100) NOT NULL,
    currency_symbol VARCHAR(10),
    decimal_places INTEGER DEFAULT 2,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Language Reference
CREATE TABLE crm_language (
    language_id SERIAL PRIMARY KEY,
    language_code VARCHAR(10) NOT NULL UNIQUE,
    language_name VARCHAR(100) NOT NULL,
    native_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Country Reference
CREATE TABLE crm_country (
    country_id SERIAL PRIMARY KEY,
    country_code VARCHAR(3) NOT NULL UNIQUE,
    country_name VARCHAR(100) NOT NULL,
    region VARCHAR(50),
    default_currency_id INTEGER REFERENCES crm_currency(currency_id),
    default_language_id INTEGER REFERENCES crm_language(language_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Unit of Measure
CREATE TABLE crm_unit_of_measure (
    uom_id SERIAL PRIMARY KEY,
    uom_code VARCHAR(20) NOT NULL UNIQUE,
    uom_name VARCHAR(100) NOT NULL,
    uom_category VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- SALES TEAM TABLES
-- =====================================================================

-- Sales Team
CREATE TABLE crm_sales_team (
    team_id SERIAL PRIMARY KEY,
    team_code VARCHAR(50) NOT NULL UNIQUE,
    team_name VARCHAR(200) NOT NULL,
    team_manager_id INTEGER,
    region VARCHAR(100),
    target_quota DECIMAL(15,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sales_team_code ON crm_sales_team(team_code);

-- Sales Representative
CREATE TABLE crm_sales_rep (
    sales_rep_id SERIAL PRIMARY KEY,
    employee_code VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50),
    mobile VARCHAR(50),
    job_title VARCHAR(100),
    team_id INTEGER REFERENCES crm_sales_team(team_id),
    manager_id INTEGER REFERENCES crm_sales_rep(sales_rep_id),
    territory VARCHAR(200),
    quota_amount DECIMAL(15,2),
    commission_rate DECIMAL(5,2),
    hire_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    profile_image_url VARCHAR(500),
    signature_html TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sales_rep_code ON crm_sales_rep(employee_code);
CREATE INDEX idx_sales_rep_email ON crm_sales_rep(email);
CREATE INDEX idx_sales_rep_team ON crm_sales_rep(team_id);
CREATE INDEX idx_sales_rep_manager ON crm_sales_rep(manager_id);

-- Sales Rep Performance
CREATE TABLE crm_sales_rep_performance (
    performance_id SERIAL PRIMARY KEY,
    sales_rep_id INTEGER NOT NULL REFERENCES crm_sales_rep(sales_rep_id) ON DELETE CASCADE,
    period_type VARCHAR(20) NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    quota_amount DECIMAL(15,2),
    revenue_closed DECIMAL(15,2) DEFAULT 0,
    quotes_generated INTEGER DEFAULT 0,
    quotes_won INTEGER DEFAULT 0,
    quotes_lost INTEGER DEFAULT 0,
    win_rate DECIMAL(5,2),
    avg_deal_size DECIMAL(15,2),
    avg_sales_cycle_days INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_sales_rep_performance UNIQUE (sales_rep_id, period_type, period_start)
);

CREATE INDEX idx_sales_perf_rep ON crm_sales_rep_performance(sales_rep_id);
CREATE INDEX idx_sales_perf_period ON crm_sales_rep_performance(period_start, period_end);

-- =====================================================================
-- CUSTOMER MANAGEMENT TABLES
-- =====================================================================

-- Customer Master
CREATE TABLE crm_customer (
    customer_id SERIAL PRIMARY KEY,
    customer_code VARCHAR(50) NOT NULL UNIQUE,
    customer_name VARCHAR(300) NOT NULL,
    legal_name VARCHAR(300),
    customer_type VARCHAR(50) DEFAULT 'COMPANY',
    industry_id INTEGER REFERENCES crm_industry(industry_id),
    company_size VARCHAR(50),
    annual_revenue DECIMAL(15,2),
    employee_count INTEGER,
    website_url VARCHAR(255),
    tax_id VARCHAR(50),
    preferred_currency_id INTEGER REFERENCES crm_currency(currency_id),
    preferred_language_id INTEGER REFERENCES crm_language(language_id),
    credit_limit DECIMAL(15,2),
    payment_terms_days INTEGER DEFAULT 30,
    assigned_sales_rep_id INTEGER REFERENCES crm_sales_rep(sales_rep_id),
    account_status VARCHAR(50) DEFAULT 'ACTIVE',
    customer_since DATE,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER
);

CREATE INDEX idx_customer_code ON crm_customer(customer_code);
CREATE INDEX idx_customer_name ON crm_customer(customer_name);
CREATE INDEX idx_customer_industry ON crm_customer(industry_id);
CREATE INDEX idx_customer_sales_rep ON crm_customer(assigned_sales_rep_id);
CREATE INDEX idx_customer_active ON crm_customer(is_active);

-- Customer Address
CREATE TABLE crm_customer_address (
    address_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES crm_customer(customer_id) ON DELETE CASCADE,
    address_type VARCHAR(50) DEFAULT 'BILLING',
    address_name VARCHAR(100),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country_id INTEGER REFERENCES crm_country(country_id),
    is_primary BOOLEAN DEFAULT FALSE,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customer_address_customer ON crm_customer_address(customer_id);
CREATE INDEX idx_customer_address_type ON crm_customer_address(address_type);

-- Contact (Customer Contact)
CREATE TABLE crm_contact (
    contact_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES crm_customer(customer_id) ON DELETE SET NULL,
    salutation VARCHAR(20),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    job_title VARCHAR(100),
    department VARCHAR(100),
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    mobile VARCHAR(50),
    linkedin_url VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    is_decision_maker BOOLEAN DEFAULT FALSE,
    preferred_contact_method VARCHAR(50) DEFAULT 'EMAIL',
    preferred_language_id INTEGER REFERENCES crm_language(language_id),
    do_not_email BOOLEAN DEFAULT FALSE,
    do_not_call BOOLEAN DEFAULT FALSE,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER
);

CREATE INDEX idx_contact_customer ON crm_contact(customer_id);
CREATE INDEX idx_contact_email ON crm_contact(email);
CREATE INDEX idx_contact_name ON crm_contact(last_name, first_name);
CREATE INDEX idx_contact_active ON crm_contact(is_active);

-- =====================================================================
-- LEAD MANAGEMENT TABLES
-- =====================================================================

-- Lead
CREATE TABLE crm_lead (
    lead_id SERIAL PRIMARY KEY,
    lead_number VARCHAR(50) NOT NULL UNIQUE,
    company_name VARCHAR(300),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    job_title VARCHAR(100),
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    mobile VARCHAR(50),
    website VARCHAR(255),
    industry_id INTEGER REFERENCES crm_industry(industry_id),
    company_size VARCHAR(50),
    annual_revenue DECIMAL(15,2),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country_id INTEGER REFERENCES crm_country(country_id),
    source_id INTEGER REFERENCES crm_lead_source(source_id),
    campaign_id INTEGER,
    status_id INTEGER NOT NULL REFERENCES crm_lead_status(status_id),
    lead_score INTEGER DEFAULT 0,
    assigned_to_id INTEGER REFERENCES crm_sales_rep(sales_rep_id),
    description TEXT,
    requirements TEXT,
    budget DECIMAL(15,2),
    currency_id INTEGER REFERENCES crm_currency(currency_id),
    expected_close_date DATE,
    converted_to_customer_id INTEGER REFERENCES crm_customer(customer_id),
    converted_to_opportunity_id INTEGER,
    converted_at TIMESTAMP WITH TIME ZONE,
    is_qualified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER
);

CREATE INDEX idx_lead_number ON crm_lead(lead_number);
CREATE INDEX idx_lead_email ON crm_lead(email);
CREATE INDEX idx_lead_company ON crm_lead(company_name);
CREATE INDEX idx_lead_status ON crm_lead(status_id);
CREATE INDEX idx_lead_assigned ON crm_lead(assigned_to_id);
CREATE INDEX idx_lead_source ON crm_lead(source_id);
CREATE INDEX idx_lead_score ON crm_lead(lead_score DESC);
CREATE INDEX idx_lead_created ON crm_lead(created_at);

-- Lead Activity
CREATE TABLE crm_lead_activity (
    activity_id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL REFERENCES crm_lead(lead_id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL,
    activity_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subject VARCHAR(500),
    description TEXT,
    outcome VARCHAR(100),
    next_action VARCHAR(500),
    next_action_date DATE,
    created_by INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lead_activity_lead ON crm_lead_activity(lead_id);
CREATE INDEX idx_lead_activity_date ON crm_lead_activity(activity_date);
CREATE INDEX idx_lead_activity_type ON crm_lead_activity(activity_type);

-- Lead Score History
CREATE TABLE crm_lead_score_history (
    score_history_id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL REFERENCES crm_lead(lead_id) ON DELETE CASCADE,
    previous_score INTEGER,
    new_score INTEGER NOT NULL,
    score_change INTEGER,
    change_reason VARCHAR(200),
    scoring_factors JSONB,
    model_version VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lead_score_lead ON crm_lead_score_history(lead_id);
CREATE INDEX idx_lead_score_date ON crm_lead_score_history(created_at);

-- =====================================================================
-- OPPORTUNITY MANAGEMENT TABLES
-- =====================================================================

-- Opportunity
CREATE TABLE crm_opportunity (
    opportunity_id SERIAL PRIMARY KEY,
    opportunity_number VARCHAR(50) NOT NULL UNIQUE,
    opportunity_name VARCHAR(300) NOT NULL,
    customer_id INTEGER REFERENCES crm_customer(customer_id),
    lead_id INTEGER REFERENCES crm_lead(lead_id),
    primary_contact_id INTEGER REFERENCES crm_contact(contact_id),
    stage_id INTEGER NOT NULL REFERENCES crm_opportunity_stage(stage_id),
    probability_percent INTEGER,
    amount DECIMAL(15,2),
    currency_id INTEGER REFERENCES crm_currency(currency_id),
    expected_close_date DATE,
    actual_close_date DATE,
    owner_id INTEGER NOT NULL REFERENCES crm_sales_rep(sales_rep_id),
    team_id INTEGER REFERENCES crm_sales_team(team_id),
    source_id INTEGER REFERENCES crm_lead_source(source_id),
    campaign_id INTEGER,
    competitor_info TEXT,
    win_reason TEXT,
    loss_reason TEXT,
    next_step VARCHAR(500),
    description TEXT,
    is_won BOOLEAN,
    is_closed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER
);

CREATE INDEX idx_opportunity_number ON crm_opportunity(opportunity_number);
CREATE INDEX idx_opportunity_customer ON crm_opportunity(customer_id);
CREATE INDEX idx_opportunity_lead ON crm_opportunity(lead_id);
CREATE INDEX idx_opportunity_stage ON crm_opportunity(stage_id);
CREATE INDEX idx_opportunity_owner ON crm_opportunity(owner_id);
CREATE INDEX idx_opportunity_close_date ON crm_opportunity(expected_close_date);
CREATE INDEX idx_opportunity_created ON crm_opportunity(created_at);

-- Opportunity Stage History
CREATE TABLE crm_opportunity_stage_history (
    history_id SERIAL PRIMARY KEY,
    opportunity_id INTEGER NOT NULL REFERENCES crm_opportunity(opportunity_id) ON DELETE CASCADE,
    old_stage_id INTEGER REFERENCES crm_opportunity_stage(stage_id),
    new_stage_id INTEGER NOT NULL REFERENCES crm_opportunity_stage(stage_id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    changed_by INTEGER,
    reason TEXT,
    notes TEXT
);

CREATE INDEX idx_opp_stage_hist_opp ON crm_opportunity_stage_history(opportunity_id);
CREATE INDEX idx_opp_stage_hist_date ON crm_opportunity_stage_history(changed_at);

-- Opportunity Team Member
CREATE TABLE crm_opportunity_team (
    team_member_id SERIAL PRIMARY KEY,
    opportunity_id INTEGER NOT NULL REFERENCES crm_opportunity(opportunity_id) ON DELETE CASCADE,
    sales_rep_id INTEGER NOT NULL REFERENCES crm_sales_rep(sales_rep_id),
    role VARCHAR(100),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_opp_team UNIQUE (opportunity_id, sales_rep_id)
);

CREATE INDEX idx_opp_team_opp ON crm_opportunity_team(opportunity_id);
CREATE INDEX idx_opp_team_rep ON crm_opportunity_team(sales_rep_id);

-- =====================================================================
-- PRODUCT CATALOG TABLES
-- =====================================================================

-- Product Category
CREATE TABLE crm_product_category (
    category_id SERIAL PRIMARY KEY,
    category_code VARCHAR(50) NOT NULL UNIQUE,
    category_name VARCHAR(200) NOT NULL,
    parent_category_id INTEGER REFERENCES crm_product_category(category_id),
    description TEXT,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_cat_parent ON crm_product_category(parent_category_id);

-- Product Master
CREATE TABLE crm_product (
    product_id SERIAL PRIMARY KEY,
    product_code VARCHAR(100) NOT NULL UNIQUE,
    product_name VARCHAR(300) NOT NULL,
    description TEXT,
    category_id INTEGER REFERENCES crm_product_category(category_id),
    brand VARCHAR(100),
    model_number VARCHAR(100),
    manufacturer VARCHAR(200),
    uom_id INTEGER REFERENCES crm_unit_of_measure(uom_id),
    is_configurable BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    lead_time_days INTEGER DEFAULT 0,
    warranty_months INTEGER,
    specifications JSONB,
    features TEXT[],
    image_urls TEXT[],
    brochure_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_code ON crm_product(product_code);
CREATE INDEX idx_product_name ON crm_product(product_name);
CREATE INDEX idx_product_category ON crm_product(category_id);
CREATE INDEX idx_product_active ON crm_product(is_active);

-- Product Pricing (List Price)
CREATE TABLE crm_product_pricing (
    pricing_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES crm_product(product_id) ON DELETE CASCADE,
    price_list_name VARCHAR(100) DEFAULT 'STANDARD',
    currency_id INTEGER NOT NULL REFERENCES crm_currency(currency_id),
    list_price DECIMAL(15,4) NOT NULL,
    minimum_price DECIMAL(15,4),
    cost_price DECIMAL(15,4),
    margin_percent DECIMAL(5,2),
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_pricing_product ON crm_product_pricing(product_id);
CREATE INDEX idx_product_pricing_dates ON crm_product_pricing(effective_from, effective_to);
CREATE INDEX idx_product_pricing_list ON crm_product_pricing(price_list_name);

-- Product Price History (for AI training)
CREATE TABLE crm_product_price_history (
    history_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES crm_product(product_id),
    currency_id INTEGER NOT NULL REFERENCES crm_currency(currency_id),
    quoted_price DECIMAL(15,4) NOT NULL,
    list_price DECIMAL(15,4),
    discount_percent DECIMAL(5,2),
    customer_id INTEGER REFERENCES crm_customer(customer_id),
    customer_industry_id INTEGER REFERENCES crm_industry(industry_id),
    customer_size VARCHAR(50),
    quantity INTEGER,
    quote_id INTEGER,
    was_accepted BOOLEAN,
    quote_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_price_hist_product ON crm_product_price_history(product_id);
CREATE INDEX idx_price_hist_customer ON crm_product_price_history(customer_id);
CREATE INDEX idx_price_hist_date ON crm_product_price_history(quote_date);
CREATE INDEX idx_price_hist_accepted ON crm_product_price_history(was_accepted);

-- Product Configuration Option
CREATE TABLE crm_product_config_option (
    option_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES crm_product(product_id) ON DELETE CASCADE,
    option_group VARCHAR(100) NOT NULL,
    option_name VARCHAR(200) NOT NULL,
    option_value VARCHAR(500),
    price_adjustment DECIMAL(15,4) DEFAULT 0,
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_config_product ON crm_product_config_option(product_id);
CREATE INDEX idx_product_config_group ON crm_product_config_option(option_group);

-- Product Stock Availability (Cache from ERP)
CREATE TABLE crm_product_availability (
    availability_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES crm_product(product_id),
    warehouse_code VARCHAR(50),
    warehouse_location VARCHAR(200),
    quantity_available INTEGER NOT NULL DEFAULT 0,
    quantity_reserved INTEGER NOT NULL DEFAULT 0,
    lead_time_days INTEGER,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_product_availability UNIQUE (product_id, warehouse_code)
);

CREATE INDEX idx_product_avail_product ON crm_product_availability(product_id);

-- =====================================================================
-- QUOTATION MANAGEMENT TABLES
-- =====================================================================

-- Quote Template
CREATE TABLE crm_quote_template (
    template_id SERIAL PRIMARY KEY,
    template_code VARCHAR(50) NOT NULL UNIQUE,
    template_name VARCHAR(200) NOT NULL,
    template_type VARCHAR(50) DEFAULT 'STANDARD',
    description TEXT,
    header_content TEXT,
    footer_content TEXT,
    terms_conditions TEXT,
    logo_url VARCHAR(500),
    primary_color VARCHAR(20),
    secondary_color VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    language_id INTEGER REFERENCES crm_language(language_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quote_template_code ON crm_quote_template(template_code);

-- Quotation
CREATE TABLE crm_quotation (
    quote_id SERIAL PRIMARY KEY,
    quote_number VARCHAR(50) NOT NULL UNIQUE,
    quote_name VARCHAR(300),
    revision_number INTEGER DEFAULT 1,
    parent_quote_id INTEGER REFERENCES crm_quotation(quote_id),
    customer_id INTEGER NOT NULL REFERENCES crm_customer(customer_id),
    contact_id INTEGER REFERENCES crm_contact(contact_id),
    opportunity_id INTEGER REFERENCES crm_opportunity(opportunity_id),
    template_id INTEGER REFERENCES crm_quote_template(template_id),
    status_id INTEGER NOT NULL REFERENCES crm_quote_status(status_id),
    owner_id INTEGER NOT NULL REFERENCES crm_sales_rep(sales_rep_id),
    quote_date DATE NOT NULL DEFAULT CURRENT_DATE,
    valid_until DATE NOT NULL,
    currency_id INTEGER NOT NULL REFERENCES crm_currency(currency_id),
    exchange_rate DECIMAL(18,8) DEFAULT 1,
    subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
    discount_type VARCHAR(20) DEFAULT 'PERCENT',
    discount_value DECIMAL(15,4) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    shipping_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    estimated_delivery_days INTEGER,
    delivery_terms VARCHAR(200),
    payment_terms VARCHAR(200),
    shipping_address_id INTEGER REFERENCES crm_customer_address(address_id),
    billing_address_id INTEGER REFERENCES crm_customer_address(address_id),
    introduction_text TEXT,
    notes TEXT,
    internal_notes TEXT,
    terms_conditions TEXT,
    ai_generated_pricing BOOLEAN DEFAULT FALSE,
    ai_confidence_score DECIMAL(5,4),
    ai_model_version VARCHAR(50),
    sent_at TIMESTAMP WITH TIME ZONE,
    opened_at TIMESTAMP WITH TIME ZONE,
    responded_at TIMESTAMP WITH TIME ZONE,
    accepted_at TIMESTAMP WITH TIME ZONE,
    rejected_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    po_reference VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER,
    updated_by INTEGER,
    approved_by INTEGER,
    approved_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_quote_number ON crm_quotation(quote_number);
CREATE INDEX idx_quote_customer ON crm_quotation(customer_id);
CREATE INDEX idx_quote_opportunity ON crm_quotation(opportunity_id);
CREATE INDEX idx_quote_status ON crm_quotation(status_id);
CREATE INDEX idx_quote_owner ON crm_quotation(owner_id);
CREATE INDEX idx_quote_date ON crm_quotation(quote_date);
CREATE INDEX idx_quote_valid_until ON crm_quotation(valid_until);
CREATE INDEX idx_quote_parent ON crm_quotation(parent_quote_id);
CREATE INDEX idx_quote_created ON crm_quotation(created_at);

-- Quote Line Item
CREATE TABLE crm_quote_line_item (
    line_item_id SERIAL PRIMARY KEY,
    quote_id INTEGER NOT NULL REFERENCES crm_quotation(quote_id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    product_id INTEGER REFERENCES crm_product(product_id),
    product_code VARCHAR(100),
    product_name VARCHAR(300) NOT NULL,
    description TEXT,
    quantity INTEGER NOT NULL DEFAULT 1,
    uom_id INTEGER REFERENCES crm_unit_of_measure(uom_id),
    list_price DECIMAL(15,4),
    unit_price DECIMAL(15,4) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    line_total DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    lead_time_days INTEGER,
    is_optional BOOLEAN DEFAULT FALSE,
    is_alternative BOOLEAN DEFAULT FALSE,
    alternative_for_line INTEGER,
    configuration_options JSONB,
    notes TEXT,
    sort_order INTEGER DEFAULT 0,
    is_included BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_quote_line UNIQUE (quote_id, line_number)
);

CREATE INDEX idx_quote_line_quote ON crm_quote_line_item(quote_id);
CREATE INDEX idx_quote_line_product ON crm_quote_line_item(product_id);

-- Quote Status History
CREATE TABLE crm_quote_status_history (
    history_id SERIAL PRIMARY KEY,
    quote_id INTEGER NOT NULL REFERENCES crm_quotation(quote_id) ON DELETE CASCADE,
    old_status_id INTEGER REFERENCES crm_quote_status(status_id),
    new_status_id INTEGER NOT NULL REFERENCES crm_quote_status(status_id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    changed_by INTEGER,
    reason TEXT,
    notes TEXT
);

CREATE INDEX idx_quote_status_hist_quote ON crm_quote_status_history(quote_id);
CREATE INDEX idx_quote_status_hist_date ON crm_quote_status_history(changed_at);

-- Quote Approval
CREATE TABLE crm_quote_approval (
    approval_id SERIAL PRIMARY KEY,
    quote_id INTEGER NOT NULL REFERENCES crm_quotation(quote_id) ON DELETE CASCADE,
    approval_level INTEGER NOT NULL DEFAULT 1,
    approver_type VARCHAR(50) NOT NULL,
    approver_id INTEGER,
    approver_name VARCHAR(200),
    approval_status VARCHAR(50) DEFAULT 'PENDING',
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP WITH TIME ZONE,
    comments TEXT,
    approval_threshold DECIMAL(15,2)
);

CREATE INDEX idx_quote_approval_quote ON crm_quote_approval(quote_id);
CREATE INDEX idx_quote_approval_approver ON crm_quote_approval(approver_id);
CREATE INDEX idx_quote_approval_status ON crm_quote_approval(approval_status);

-- Quote Attachment
CREATE TABLE crm_quote_attachment (
    attachment_id SERIAL PRIMARY KEY,
    quote_id INTEGER NOT NULL REFERENCES crm_quotation(quote_id) ON DELETE CASCADE,
    attachment_type VARCHAR(50) DEFAULT 'DOCUMENT',
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(50),
    file_size INTEGER,
    file_url VARCHAR(500) NOT NULL,
    description TEXT,
    is_customer_visible BOOLEAN DEFAULT TRUE,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    uploaded_by INTEGER
);

CREATE INDEX idx_quote_attachment_quote ON crm_quote_attachment(quote_id);

-- Quote Competitor
CREATE TABLE crm_quote_competitor (
    competitor_id SERIAL PRIMARY KEY,
    quote_id INTEGER NOT NULL REFERENCES crm_quotation(quote_id) ON DELETE CASCADE,
    competitor_name VARCHAR(200) NOT NULL,
    competitor_price DECIMAL(15,2),
    currency_id INTEGER REFERENCES crm_currency(currency_id),
    strengths TEXT,
    weaknesses TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quote_competitor_quote ON crm_quote_competitor(quote_id);

-- =====================================================================
-- EMAIL & COMMUNICATION TABLES
-- =====================================================================

-- Email Thread
CREATE TABLE crm_email_thread (
    thread_id SERIAL PRIMARY KEY,
    thread_subject VARCHAR(500) NOT NULL,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    customer_id INTEGER REFERENCES crm_customer(customer_id),
    contact_id INTEGER REFERENCES crm_contact(contact_id),
    lead_id INTEGER REFERENCES crm_lead(lead_id),
    assigned_to_id INTEGER REFERENCES crm_sales_rep(sales_rep_id),
    status VARCHAR(50) DEFAULT 'OPEN',
    message_count INTEGER DEFAULT 0,
    first_message_at TIMESTAMP WITH TIME ZONE,
    last_message_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_thread_reference ON crm_email_thread(reference_type, reference_id);
CREATE INDEX idx_email_thread_customer ON crm_email_thread(customer_id);
CREATE INDEX idx_email_thread_contact ON crm_email_thread(contact_id);
CREATE INDEX idx_email_thread_lead ON crm_email_thread(lead_id);
CREATE INDEX idx_email_thread_assigned ON crm_email_thread(assigned_to_id);
CREATE INDEX idx_email_thread_status ON crm_email_thread(status);

-- Email Message
CREATE TABLE crm_email_message (
    message_id SERIAL PRIMARY KEY,
    thread_id INTEGER NOT NULL REFERENCES crm_email_thread(thread_id) ON DELETE CASCADE,
    message_uid VARCHAR(255),
    direction VARCHAR(20) NOT NULL,
    from_email VARCHAR(255) NOT NULL,
    from_name VARCHAR(200),
    to_emails TEXT[] NOT NULL,
    cc_emails TEXT[],
    bcc_emails TEXT[],
    subject VARCHAR(500) NOT NULL,
    body_text TEXT,
    body_html TEXT,
    sent_at TIMESTAMP WITH TIME ZONE,
    received_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    is_read BOOLEAN DEFAULT FALSE,
    has_attachments BOOLEAN DEFAULT FALSE,
    importance VARCHAR(20) DEFAULT 'NORMAL',
    headers JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_message_thread ON crm_email_message(thread_id);
CREATE INDEX idx_email_message_from ON crm_email_message(from_email);
CREATE INDEX idx_email_message_sent ON crm_email_message(sent_at);
CREATE INDEX idx_email_message_read ON crm_email_message(is_read);

-- Email Attachment
CREATE TABLE crm_email_attachment (
    attachment_id SERIAL PRIMARY KEY,
    message_id INTEGER NOT NULL REFERENCES crm_email_message(message_id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(100),
    file_size INTEGER,
    file_url VARCHAR(500),
    content_id VARCHAR(255),
    is_inline BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_attach_message ON crm_email_attachment(message_id);

-- Email Template
CREATE TABLE crm_email_template (
    template_id SERIAL PRIMARY KEY,
    template_code VARCHAR(100) NOT NULL UNIQUE,
    template_name VARCHAR(200) NOT NULL,
    template_type VARCHAR(50) NOT NULL,
    subject_template VARCHAR(500) NOT NULL,
    body_template TEXT NOT NULL,
    body_html_template TEXT,
    language_id INTEGER REFERENCES crm_language(language_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_template_code ON crm_email_template(template_code);
CREATE INDEX idx_email_template_type ON crm_email_template(template_type);

-- =====================================================================
-- ACTIVITY & TASK TABLES
-- =====================================================================

-- Activity
CREATE TABLE crm_activity (
    activity_id SERIAL PRIMARY KEY,
    activity_type VARCHAR(50) NOT NULL,
    subject VARCHAR(500) NOT NULL,
    description TEXT,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    customer_id INTEGER REFERENCES crm_customer(customer_id),
    contact_id INTEGER REFERENCES crm_contact(contact_id),
    owner_id INTEGER NOT NULL REFERENCES crm_sales_rep(sales_rep_id),
    activity_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    duration_minutes INTEGER,
    location VARCHAR(255),
    outcome VARCHAR(100),
    outcome_notes TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER
);

CREATE INDEX idx_activity_type ON crm_activity(activity_type);
CREATE INDEX idx_activity_reference ON crm_activity(reference_type, reference_id);
CREATE INDEX idx_activity_customer ON crm_activity(customer_id);
CREATE INDEX idx_activity_owner ON crm_activity(owner_id);
CREATE INDEX idx_activity_date ON crm_activity(activity_date);
CREATE INDEX idx_activity_completed ON crm_activity(is_completed);

-- Task
CREATE TABLE crm_task (
    task_id SERIAL PRIMARY KEY,
    task_name VARCHAR(500) NOT NULL,
    description TEXT,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    customer_id INTEGER REFERENCES crm_customer(customer_id),
    assigned_to_id INTEGER NOT NULL REFERENCES crm_sales_rep(sales_rep_id),
    priority VARCHAR(20) DEFAULT 'NORMAL',
    status VARCHAR(50) DEFAULT 'NOT_STARTED',
    due_date DATE,
    due_time TIME,
    reminder_date TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_pattern JSONB,
    parent_task_id INTEGER REFERENCES crm_task(task_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER
);

CREATE INDEX idx_task_reference ON crm_task(reference_type, reference_id);
CREATE INDEX idx_task_customer ON crm_task(customer_id);
CREATE INDEX idx_task_assigned ON crm_task(assigned_to_id);
CREATE INDEX idx_task_due_date ON crm_task(due_date);
CREATE INDEX idx_task_status ON crm_task(status);
CREATE INDEX idx_task_priority ON crm_task(priority);

-- =====================================================================
-- AI/ML SUPPORT TABLES
-- =====================================================================

-- AI Recommendation Log
CREATE TABLE crm_ai_recommendation_log (
    recommendation_id SERIAL PRIMARY KEY,
    recommendation_type VARCHAR(50) NOT NULL,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    customer_id INTEGER REFERENCES crm_customer(customer_id),
    input_data JSONB,
    recommendation_data JSONB,
    confidence_score DECIMAL(5,4),
    model_version VARCHAR(50),
    was_accepted BOOLEAN,
    user_feedback TEXT,
    processing_time_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ai_rec_type ON crm_ai_recommendation_log(recommendation_type);
CREATE INDEX idx_ai_rec_reference ON crm_ai_recommendation_log(reference_type, reference_id);
CREATE INDEX idx_ai_rec_customer ON crm_ai_recommendation_log(customer_id);
CREATE INDEX idx_ai_rec_date ON crm_ai_recommendation_log(created_at);
CREATE INDEX idx_ai_rec_accepted ON crm_ai_recommendation_log(was_accepted);

-- Cost Estimation Model Log
CREATE TABLE crm_cost_estimation_log (
    estimation_id SERIAL PRIMARY KEY,
    quote_id INTEGER REFERENCES crm_quotation(quote_id),
    product_id INTEGER REFERENCES crm_product(product_id),
    quantity INTEGER,
    customer_id INTEGER REFERENCES crm_customer(customer_id),
    estimated_cost DECIMAL(15,4),
    actual_cost DECIMAL(15,4),
    estimation_factors JSONB,
    confidence_score DECIMAL(5,4),
    model_version VARCHAR(50),
    processing_time_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_cost_est_quote ON crm_cost_estimation_log(quote_id);
CREATE INDEX idx_cost_est_product ON crm_cost_estimation_log(product_id);
CREATE INDEX idx_cost_est_customer ON crm_cost_estimation_log(customer_id);
CREATE INDEX idx_cost_est_date ON crm_cost_estimation_log(created_at);

-- Product Recommendation Log
CREATE TABLE crm_product_recommendation_log (
    recommendation_id SERIAL PRIMARY KEY,
    quote_id INTEGER REFERENCES crm_quotation(quote_id),
    customer_id INTEGER REFERENCES crm_customer(customer_id),
    requested_product_id INTEGER REFERENCES crm_product(product_id),
    recommended_products JSONB,
    recommendation_reason TEXT,
    confidence_score DECIMAL(5,4),
    model_version VARCHAR(50),
    was_selected BOOLEAN,
    selected_product_id INTEGER REFERENCES crm_product(product_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_prod_rec_quote ON crm_product_recommendation_log(quote_id);
CREATE INDEX idx_prod_rec_customer ON crm_product_recommendation_log(customer_id);
CREATE INDEX idx_prod_rec_date ON crm_product_recommendation_log(created_at);

-- =====================================================================
-- ANALYTICS & REPORTING TABLES
-- =====================================================================

-- Quote Analytics (Pre-aggregated)
CREATE TABLE crm_quote_analytics (
    analytics_id SERIAL PRIMARY KEY,
    analytics_date DATE NOT NULL,
    sales_rep_id INTEGER REFERENCES crm_sales_rep(sales_rep_id),
    team_id INTEGER REFERENCES crm_sales_team(team_id),
    industry_id INTEGER REFERENCES crm_industry(industry_id),
    quotes_created INTEGER DEFAULT 0,
    quotes_sent INTEGER DEFAULT 0,
    quotes_accepted INTEGER DEFAULT 0,
    quotes_rejected INTEGER DEFAULT 0,
    quotes_expired INTEGER DEFAULT 0,
    total_value_quoted DECIMAL(15,2) DEFAULT 0,
    total_value_won DECIMAL(15,2) DEFAULT 0,
    avg_quote_value DECIMAL(15,2),
    avg_discount_percent DECIMAL(5,2),
    avg_response_time_hours DECIMAL(10,2),
    conversion_rate DECIMAL(5,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_quote_analytics UNIQUE (analytics_date, sales_rep_id, team_id, industry_id)
);

CREATE INDEX idx_quote_analytics_date ON crm_quote_analytics(analytics_date);
CREATE INDEX idx_quote_analytics_rep ON crm_quote_analytics(sales_rep_id);
CREATE INDEX idx_quote_analytics_team ON crm_quote_analytics(team_id);

-- Pipeline Summary
CREATE TABLE crm_pipeline_summary (
    summary_id SERIAL PRIMARY KEY,
    summary_date DATE NOT NULL,
    sales_rep_id INTEGER REFERENCES crm_sales_rep(sales_rep_id),
    team_id INTEGER REFERENCES crm_sales_team(team_id),
    stage_id INTEGER REFERENCES crm_opportunity_stage(stage_id),
    opportunity_count INTEGER DEFAULT 0,
    total_value DECIMAL(15,2) DEFAULT 0,
    weighted_value DECIMAL(15,2) DEFAULT 0,
    avg_days_in_stage DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_pipeline_summary UNIQUE (summary_date, sales_rep_id, team_id, stage_id)
);

CREATE INDEX idx_pipeline_summary_date ON crm_pipeline_summary(summary_date);
CREATE INDEX idx_pipeline_summary_rep ON crm_pipeline_summary(sales_rep_id);
CREATE INDEX idx_pipeline_summary_stage ON crm_pipeline_summary(stage_id);

-- =====================================================================
-- SYSTEM & AUDIT TABLES
-- =====================================================================

-- User (simplified for CRM context)
CREATE TABLE crm_user (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    sales_rep_id INTEGER REFERENCES crm_sales_rep(sales_rep_id),
    role VARCHAR(50) DEFAULT 'SALES_REP',
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    preferences JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_crm_user_username ON crm_user(username);
CREATE INDEX idx_crm_user_email ON crm_user(email);
CREATE INDEX idx_crm_user_sales_rep ON crm_user(sales_rep_id);

-- System Configuration
CREATE TABLE crm_system_configuration (
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

CREATE INDEX idx_crm_sys_config_key ON crm_system_configuration(config_key);

-- Audit Log
CREATE TABLE crm_audit_log (
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

CREATE INDEX idx_crm_audit_table ON crm_audit_log(table_name);
CREATE INDEX idx_crm_audit_record ON crm_audit_log(table_name, record_id);
CREATE INDEX idx_crm_audit_user ON crm_audit_log(user_id);
CREATE INDEX idx_crm_audit_date ON crm_audit_log(created_at);

-- Exchange Rate History
CREATE TABLE crm_exchange_rate_history (
    rate_id SERIAL PRIMARY KEY,
    from_currency_id INTEGER NOT NULL REFERENCES crm_currency(currency_id),
    to_currency_id INTEGER NOT NULL REFERENCES crm_currency(currency_id),
    exchange_rate DECIMAL(18,8) NOT NULL,
    rate_date DATE NOT NULL,
    source VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_crm_exchange_rate_currencies ON crm_exchange_rate_history(from_currency_id, to_currency_id);
CREATE INDEX idx_crm_exchange_rate_date ON crm_exchange_rate_history(rate_date);

-- =====================================================================
-- END OF CRM SCHEMA
-- =====================================================================

-- Insert default lookup data
INSERT INTO crm_quote_status (status_code, status_name, status_description, is_terminal, requires_approval, display_order) VALUES
('DRAFT', 'Draft', 'Quote is being prepared', FALSE, FALSE, 1),
('PENDING_REVIEW', 'Pending Review', 'Quote submitted for internal review', FALSE, TRUE, 2),
('APPROVED', 'Approved', 'Quote approved by manager/finance', FALSE, FALSE, 3),
('REQUIRES_CHANGES', 'Requires Changes', 'Quote returned with requested changes', FALSE, FALSE, 4),
('SENT', 'Sent to Customer', 'Quote sent to customer', FALSE, FALSE, 5),
('OPENED', 'Opened', 'Customer has opened the quote', FALSE, FALSE, 6),
('NEGOTIATING', 'Negotiating', 'Customer is negotiating terms', FALSE, FALSE, 7),
('ACCEPTED', 'Accepted', 'Customer accepted the quote', TRUE, FALSE, 8),
('REJECTED', 'Rejected', 'Customer rejected the quote', TRUE, FALSE, 9),
('EXPIRED', 'Expired', 'Quote validity period has expired', TRUE, FALSE, 10);

INSERT INTO crm_lead_status (status_code, status_name, status_description, is_terminal, display_order) VALUES
('NEW', 'New', 'New lead, not yet contacted', FALSE, 1),
('CONTACTED', 'Contacted', 'Initial contact made', FALSE, 2),
('QUALIFIED', 'Qualified', 'Lead has been qualified', FALSE, 3),
('UNQUALIFIED', 'Unqualified', 'Lead does not meet criteria', TRUE, 4),
('CONVERTED', 'Converted', 'Lead converted to opportunity', TRUE, 5),
('CLOSED_LOST', 'Closed - Lost', 'Lead closed without conversion', TRUE, 6),
('NURTURING', 'Nurturing', 'Lead in nurturing campaign', FALSE, 7);

INSERT INTO crm_opportunity_stage (stage_code, stage_name, probability_percent, is_terminal, display_order) VALUES
('PROSPECTING', 'Prospecting', 10, FALSE, 1),
('QUALIFICATION', 'Qualification', 20, FALSE, 2),
('NEEDS_ANALYSIS', 'Needs Analysis', 40, FALSE, 3),
('VALUE_PROPOSITION', 'Value Proposition', 60, FALSE, 4),
('DECISION_MAKERS', 'Decision Makers', 70, FALSE, 5),
('PROPOSAL', 'Proposal/Quote', 75, FALSE, 6),
('NEGOTIATION', 'Negotiation', 90, FALSE, 7),
('CLOSED_WON', 'Closed Won', 100, TRUE, 8),
('CLOSED_LOST', 'Closed Lost', 0, TRUE, 9);

INSERT INTO crm_lead_source (source_code, source_name, description) VALUES
('WEBSITE', 'Website', 'Lead from company website'),
('REFERRAL', 'Referral', 'Customer or partner referral'),
('TRADE_SHOW', 'Trade Show', 'Lead from trade show or event'),
('COLD_CALL', 'Cold Call', 'Outbound sales call'),
('ADVERTISEMENT', 'Advertisement', 'Print or online advertising'),
('EMAIL_CAMPAIGN', 'Email Campaign', 'Email marketing campaign'),
('SOCIAL_MEDIA', 'Social Media', 'Social media engagement'),
('PARTNER', 'Partner', 'Partner channel lead'),
('EXISTING_CUSTOMER', 'Existing Customer', 'Upsell/cross-sell to existing customer');

INSERT INTO crm_industry (industry_code, industry_name) VALUES
('CONSTRUCTION', 'Construction'),
('MINING', 'Mining & Quarrying'),
('AGRICULTURE', 'Agriculture'),
('MANUFACTURING', 'Manufacturing'),
('TRANSPORTATION', 'Transportation & Logistics'),
('GOVERNMENT', 'Government'),
('UTILITIES', 'Utilities'),
('OIL_GAS', 'Oil & Gas'),
('REAL_ESTATE', 'Real Estate'),
('LANDSCAPING', 'Landscaping & Grounds Maintenance');

INSERT INTO crm_currency (currency_code, currency_name, currency_symbol, decimal_places) VALUES
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

INSERT INTO crm_language (language_code, language_name, native_name) VALUES
('en-US', 'English (US)', 'English'),
('en-GB', 'English (UK)', 'English'),
('es-ES', 'Spanish', 'Español'),
('fr-FR', 'French', 'Français'),
('de-DE', 'German', 'Deutsch'),
('zh-CN', 'Chinese (Simplified)', '简体中文'),
('ja-JP', 'Japanese', '日本語');

INSERT INTO crm_country (country_code, country_name, region) VALUES
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

INSERT INTO crm_unit_of_measure (uom_code, uom_name, uom_category) VALUES
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

INSERT INTO crm_quote_template (template_code, template_name, template_type, description, is_default) VALUES
('STANDARD', 'Standard Quote', 'STANDARD', 'Standard quotation template for general use', TRUE),
('DETAILED', 'Detailed Quote', 'DETAILED', 'Detailed quotation with full specifications', FALSE),
('EXECUTIVE', 'Executive Summary', 'EXECUTIVE', 'High-level executive summary format', FALSE);

-- Grant permissions (adjust as needed for your environment)
-- GRANT ALL PRIVILEGES ON SCHEMA crm TO crm_app_user;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA crm TO crm_app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA crm TO crm_app_user;

COMMENT ON SCHEMA crm IS 'CRM System schema for Quotation Management and Sales Operations';
