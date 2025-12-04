-- =====================================================================
-- ERP SYSTEM MOCK DATA
-- PostgreSQL Mock Data Generation for Enterprise Resource Planning
-- =====================================================================
-- 
-- Document Version: 1.0
-- Created: December 2025
-- Purpose: Generate realistic mock data for ERP system testing
-- 
-- Total Records Target: ~10,000 records across ERP tables
-- Data is derived from:
--   - /MLP/Automated_Purchase_Order_Management_MLP.md
--   - /MockData/MockMailConversations.md (vendor names and PO patterns)
--
-- =====================================================================

SET search_path TO erp;

-- =====================================================================
-- HELPER FUNCTIONS FOR DATA GENERATION
-- =====================================================================

-- Function to generate random integer in range
CREATE OR REPLACE FUNCTION erp.random_between(low INT, high INT) 
RETURNS INT AS $$
BEGIN
   RETURN floor(random() * (high - low + 1) + low);
END;
$$ LANGUAGE plpgsql;

-- Function to generate random decimal in range
CREATE OR REPLACE FUNCTION erp.random_decimal(low DECIMAL, high DECIMAL, precision INT DEFAULT 2) 
RETURNS DECIMAL AS $$
BEGIN
   RETURN ROUND((random() * (high - low) + low)::DECIMAL, precision);
END;
$$ LANGUAGE plpgsql;

-- Function to pick random element from array
CREATE OR REPLACE FUNCTION erp.random_element(arr TEXT[]) 
RETURNS TEXT AS $$
BEGIN
   RETURN arr[erp.random_between(1, array_length(arr, 1))];
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- VENDOR DATA (Based on MockMailConversations.md)
-- =====================================================================

-- Insert Vendors (Heavy Equipment Suppliers from the MLP docs)
INSERT INTO erp_vendor (vendor_code, vendor_name, legal_name, vendor_type, tax_id, website_url, preferred_currency_id, preferred_integration_type_id, payment_terms_days, credit_limit, is_preferred, is_active) VALUES
('V001', 'CAT Heavy Equipment Supply', 'Caterpillar Equipment Supply LLC', 'SUPPLIER', '12-3456789', 'https://www.catheavyequip.com', 1, 1, 30, 5000000.00, TRUE, TRUE),
('V002', 'Komatsu Dealer Network', 'Komatsu Equipment Distribution Inc', 'SUPPLIER', '23-4567890', 'https://www.komatsudealer.com', 1, 3, 45, 4000000.00, TRUE, TRUE),
('V003', 'Kubota Equipment Direct', 'Kubota Direct Sales Corp', 'SUPPLIER', '34-5678901', 'https://www.kubotadirect.com', 1, 1, 30, 2000000.00, FALSE, TRUE),
('V004', 'Caterpillar Dealer Supply', 'CAT Dealer Supply Network', 'SUPPLIER', '45-6789012', 'https://www.catdealersupply.com', 1, 2, 30, 6000000.00, TRUE, TRUE),
('V005', 'Volvo Construction Equipment', 'Volvo CE North America LLC', 'SUPPLIER', '56-7890123', 'https://www.volvoce.com', 1, 3, 45, 5000000.00, TRUE, TRUE),
('V006', 'CAT Government Sales', 'Caterpillar Government Sales Division', 'SUPPLIER', '67-8901234', 'https://www.catgov.com', 1, 2, 60, 10000000.00, TRUE, TRUE),
('V007', 'CAT Factory Orders', 'Caterpillar Factory Direct', 'SUPPLIER', '78-9012345', 'https://factory.caterpillar.com', 1, 3, 30, 8000000.00, TRUE, TRUE),
('V008', 'CAT Express Delivery', 'Caterpillar Express Logistics', 'SUPPLIER', '89-0123456', 'https://express.catheavyequip.com', 1, 1, 15, 3000000.00, FALSE, TRUE),
('V009', 'CAT National Accounts', 'Caterpillar National Account Services', 'SUPPLIER', '90-1234567', 'https://national.caterpillar.com', 1, 3, 45, 15000000.00, TRUE, TRUE),
('V010', 'John Deere Equipment', 'John Deere Commercial Equipment', 'SUPPLIER', '01-2345678', 'https://www.deere.com', 1, 2, 30, 4500000.00, FALSE, TRUE),
('V011', 'Hitachi Construction', 'Hitachi Construction Machinery Americas', 'SUPPLIER', '11-3456780', 'https://www.hitachicm.us', 1, 1, 45, 3500000.00, FALSE, TRUE),
('V012', 'Liebherr USA', 'Liebherr USA Co', 'SUPPLIER', '22-4567891', 'https://www.liebherr.com', 1, 2, 30, 6000000.00, TRUE, TRUE),
('V013', 'Case Construction', 'CNH Industrial America LLC', 'SUPPLIER', '33-5678902', 'https://www.casece.com', 1, 1, 30, 3000000.00, FALSE, TRUE),
('V014', 'Bobcat Company', 'Bobcat Company North America', 'SUPPLIER', '44-6789013', 'https://www.bobcat.com', 1, 1, 30, 2500000.00, FALSE, TRUE),
('V015', 'SANY America', 'SANY America Inc', 'SUPPLIER', '55-7890124', 'https://www.sanyamerica.com', 1, 3, 45, 2000000.00, FALSE, TRUE);

-- Generate more vendors dynamically
INSERT INTO erp_vendor (vendor_code, vendor_name, legal_name, vendor_type, tax_id, preferred_currency_id, preferred_integration_type_id, payment_terms_days, credit_limit, is_preferred, is_active)
SELECT 
    'V' || LPAD((15 + row_number() OVER ())::TEXT, 3, '0'),
    erp.random_element(ARRAY['Pacific', 'Atlantic', 'Mountain', 'Central', 'Western', 'Eastern', 'Northern', 'Southern']) || ' ' ||
    erp.random_element(ARRAY['Equipment', 'Machinery', 'Industrial', 'Heavy Duty', 'Commercial']) || ' ' ||
    erp.random_element(ARRAY['Supply', 'Distribution', 'Services', 'Solutions', 'Partners']),
    erp.random_element(ARRAY['Pacific', 'Atlantic', 'Mountain', 'Central']) || ' ' ||
    erp.random_element(ARRAY['Equipment', 'Machinery', 'Industrial']) || ' ' ||
    erp.random_element(ARRAY['LLC', 'Inc', 'Corp', 'Co']),
    'SUPPLIER',
    LPAD(erp.random_between(10, 99)::TEXT, 2, '0') || '-' || LPAD(erp.random_between(1000000, 9999999)::TEXT, 7, '0'),
    erp.random_between(1, 5),
    erp.random_between(1, 5),
    erp.random_element(ARRAY[15, 30, 45, 60])::INT,
    erp.random_decimal(500000, 5000000, 2),
    (random() < 0.3),
    TRUE
FROM generate_series(1, 35);

-- Vendor Addresses
INSERT INTO erp_vendor_address (vendor_id, address_type, address_line1, city, state_province, postal_code, country_id, is_primary)
SELECT 
    v.vendor_id,
    'MAIN',
    erp.random_between(100, 9999)::TEXT || ' ' || 
    erp.random_element(ARRAY['Industrial', 'Commerce', 'Business', 'Factory', 'Manufacturing', 'Distribution']) || ' ' ||
    erp.random_element(ARRAY['Blvd', 'Drive', 'Way', 'Road', 'Street', 'Ave', 'Parkway']),
    erp.random_element(ARRAY['Chicago', 'Detroit', 'Houston', 'Phoenix', 'Denver', 'Atlanta', 'Seattle', 'Dallas', 'Miami', 'Los Angeles', 'Boston', 'Philadelphia']),
    erp.random_element(ARRAY['IL', 'MI', 'TX', 'AZ', 'CO', 'GA', 'WA', 'FL', 'CA', 'MA', 'PA', 'OH']),
    LPAD(erp.random_between(10000, 99999)::TEXT, 5, '0'),
    1,
    TRUE
FROM erp_vendor v;

-- Vendor Contacts (Based on MockMailConversations.md patterns)
INSERT INTO erp_vendor_contact (vendor_id, contact_type, first_name, last_name, job_title, email, phone, is_primary, notification_preference)
SELECT 
    v.vendor_id,
    'ORDERS',
    erp.random_element(ARRAY['James', 'John', 'Robert', 'Michael', 'David', 'Sarah', 'Jennifer', 'Lisa', 'Karen', 'Nancy', 'Mary', 'Patricia']),
    erp.random_element(ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Anderson', 'Taylor']),
    erp.random_element(ARRAY['Order Manager', 'Sales Coordinator', 'Account Manager', 'Operations Lead', 'Supply Chain Manager']),
    'orders@' || LOWER(REPLACE(REPLACE(v.vendor_name, ' ', ''), '''', '')) || '.com',
    '(' || erp.random_between(200, 999)::TEXT || ') ' || erp.random_between(200, 999)::TEXT || '-' || erp.random_between(1000, 9999)::TEXT,
    TRUE,
    'EMAIL'
FROM erp_vendor v;

-- Additional vendor contacts
INSERT INTO erp_vendor_contact (vendor_id, contact_type, first_name, last_name, job_title, email, phone, is_primary, notification_preference)
SELECT 
    v.vendor_id,
    erp.random_element(ARRAY['SUPPORT', 'BILLING', 'GENERAL']),
    erp.random_element(ARRAY['William', 'Richard', 'Joseph', 'Thomas', 'Charles', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Margaret']),
    erp.random_element(ARRAY['Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson']),
    erp.random_element(ARRAY['Support Specialist', 'Billing Coordinator', 'Customer Service Rep', 'Technical Support']),
    'support' || v.vendor_id::TEXT || '@' || LOWER(REPLACE(REPLACE(v.vendor_name, ' ', ''), '''', '')) || '.com',
    '(' || erp.random_between(200, 999)::TEXT || ') ' || erp.random_between(200, 999)::TEXT || '-' || erp.random_between(1000, 9999)::TEXT,
    FALSE,
    'EMAIL'
FROM erp_vendor v
WHERE random() < 0.7;

-- =====================================================================
-- PRODUCT DATA (Heavy Equipment from MLP docs)
-- =====================================================================

-- Product Categories
INSERT INTO erp_product_category (category_code, category_name, description) VALUES
('EXCAVATOR', 'Excavators', 'Hydraulic excavators and track hoes'),
('LOADER', 'Loaders', 'Wheel loaders and track loaders'),
('BULLDOZER', 'Bulldozers', 'Track-type tractors and dozers'),
('GRADER', 'Motor Graders', 'Road graders and maintainers'),
('DUMP_TRUCK', 'Dump Trucks', 'Articulated and rigid dump trucks'),
('CRANE', 'Cranes', 'Mobile and truck cranes'),
('COMPACTOR', 'Compactors', 'Soil and asphalt compactors'),
('BACKHOE', 'Backhoe Loaders', 'Backhoe loader combinations'),
('SKID_STEER', 'Skid Steer Loaders', 'Compact track and skid steer loaders'),
('ATTACHMENT', 'Attachments', 'Equipment attachments and accessories'),
('PARTS', 'Parts', 'Replacement parts and components'),
('SERVICE', 'Services', 'Maintenance and repair services');

-- Products (Based on equipment mentioned in MockMailConversations.md)
INSERT INTO erp_product (product_code, product_name, description, category_id, brand, model_number, manufacturer, uom_id, weight_kg, is_active, lead_time_days, specifications) VALUES
-- Excavators
('CAT-320-NG', 'CAT 320 Next Gen Hydraulic Excavator', '42" bucket, standard tracks, AC cabin, rear camera', 1, 'Caterpillar', '320', 'Caterpillar Inc', 1, 22000, TRUE, 21, '{"bucket_width": "42 inch", "track_type": "standard", "cabin": "AC", "camera": "rear"}'),
('CAT-325-HEX', 'CAT 325 Hydraulic Excavator', 'Heavy duty excavator with advanced hydraulics', 1, 'Caterpillar', '325', 'Caterpillar Inc', 1, 25000, TRUE, 28, '{"operating_weight": "25000 kg", "bucket_capacity": "1.4 m3"}'),
('CAT-336-NG', 'CAT 336 Next Gen Hydraulic Excavator', 'Standard bucket, 24" tracks, AC cabin', 1, 'Caterpillar', '336', 'Caterpillar Inc', 1, 37000, TRUE, 42, '{"bucket_width": "48 inch", "track_width": "24 inch"}'),
('KOM-PC210', 'Komatsu PC210 Excavator', 'Mid-size hydraulic excavator', 1, 'Komatsu', 'PC210', 'Komatsu Ltd', 1, 21000, TRUE, 28, '{"engine_power": "155 hp", "bucket_capacity": "1.0 m3"}'),
('KUB-KX040', 'Kubota KX040-4 Mini Excavator', 'Compact mini excavator for small jobs', 1, 'Kubota', 'KX040-4', 'Kubota Corporation', 1, 4200, TRUE, 7, '{"operating_weight": "4200 kg", "digging_depth": "3.5 m"}'),
-- Loaders
('CAT-980M', 'CAT 980M Wheel Loader', 'Large wheel loader with high-lift boom', 2, 'Caterpillar', '980M', 'Caterpillar Inc', 1, 32000, TRUE, 35, '{"bucket_capacity": "6.5 m3", "engine_power": "347 hp"}'),
('KOM-WA380', 'Komatsu WA380-8 Wheel Loader', 'Medium wheel loader with extended warranty', 2, 'Komatsu', 'WA380-8', 'Komatsu Ltd', 1, 20000, TRUE, 42, '{"bucket_capacity": "4.2 m3", "engine_power": "238 hp"}'),
('BOB-CTL', 'Bobcat Compact Track Loader', 'Compact track loader for landscaping', 2, 'Bobcat', 'T770', 'Bobcat Company', 1, 4500, TRUE, 14, '{"operating_capacity": "1500 kg", "engine_power": "92 hp"}'),
-- Bulldozers
('CAT-D5-LGP', 'CAT D5 LGP Bulldozer', 'Low ground pressure dozer with standard config', 3, 'Caterpillar', 'D5', 'Caterpillar Inc', 1, 15000, TRUE, 28, '{"track_type": "LGP", "blade_type": "6-way"}'),
('CAT-D6', 'CAT D6 Bulldozer', 'Medium track-type tractor', 3, 'Caterpillar', 'D6', 'Caterpillar Inc', 1, 21000, TRUE, 35, '{"engine_power": "215 hp", "blade_capacity": "5.5 m3"}'),
('CAT-D4K2', 'CAT D4K2 Bulldozer', 'Small dozer for utility work', 3, 'Caterpillar', 'D4K2', 'Caterpillar Inc', 1, 8500, TRUE, 21, '{"engine_power": "85 hp", "operating_weight": "8500 kg"}'),
-- Motor Graders
('CAT-140M', 'CAT 140M Motor Grader', 'Road grader with snow plow capability', 4, 'Caterpillar', '140M', 'Caterpillar Inc', 1, 17000, TRUE, 42, '{"blade_width": "14 ft", "engine_power": "183 hp"}'),
-- Dump Trucks
('VOL-A30G', 'Volvo A30G Articulated Hauler', 'Articulated dump truck for earthmoving', 5, 'Volvo', 'A30G', 'Volvo CE', 1, 28000, TRUE, 35, '{"payload_capacity": "28 tonnes", "engine_power": "340 hp"}'),
-- Cranes
('GRO-TMS9000', 'Grove TMS9000E Truck Crane', 'Truck mounted crane for heavy lifting', 6, 'Grove', 'TMS9000E', 'Manitowoc Company', 1, 36000, TRUE, 56, '{"max_capacity": "90 tonnes", "max_reach": "50 m"}'),
-- Attachments
('ATT-SPLOW', 'Snow Plow Attachment', 'Heavy duty snow plow for motor graders', 10, 'Various', 'SP-14', 'Various', 1, 500, TRUE, 14, '{"blade_width": "14 ft", "mounting": "quick-attach"}'),
('ATT-WING', 'Wing Kit', 'Wing attachment for extended reach', 10, 'Various', 'WK-12', 'Various', 1, 300, TRUE, 14, '{"extension": "6 ft each side"}'),
('ATT-BUCKET-42', 'Rock Bucket 42"', 'Heavy duty rock bucket', 10, 'Caterpillar', 'B42', 'Caterpillar Inc', 1, 800, TRUE, 7, '{"width": "42 inch", "capacity": "1.2 m3"}'),
('ATT-BUCKET-65', 'Rock Bucket 6.5 CY', 'Large rock bucket for wheel loaders', 10, 'Caterpillar', 'B65', 'Caterpillar Inc', 1, 1200, TRUE, 14, '{"capacity": "6.5 cubic yard"}');

-- Add more products dynamically
INSERT INTO erp_product (product_code, product_name, description, category_id, brand, model_number, manufacturer, uom_id, weight_kg, is_active, lead_time_days)
SELECT 
    'PROD-' || LPAD(row_number() OVER ()::TEXT, 4, '0'),
    erp.random_element(ARRAY['Heavy Duty', 'Industrial', 'Commercial', 'Professional', 'Premium']) || ' ' ||
    erp.random_element(ARRAY['Excavator', 'Loader', 'Dozer', 'Grader', 'Compactor', 'Backhoe']) || ' ' ||
    erp.random_element(ARRAY['Series', 'Model', 'Type']) || ' ' || erp.random_between(100, 999)::TEXT,
    'Standard configuration equipment',
    erp.random_between(1, 9),
    erp.random_element(ARRAY['Caterpillar', 'Komatsu', 'Volvo', 'Hitachi', 'John Deere', 'Case', 'Liebherr']),
    'M' || erp.random_between(100, 999)::TEXT,
    erp.random_element(ARRAY['Caterpillar Inc', 'Komatsu Ltd', 'Volvo CE', 'Hitachi CM', 'John Deere', 'CNH Industrial', 'Liebherr']),
    1,
    erp.random_between(5000, 50000),
    TRUE,
    erp.random_between(7, 56)
FROM generate_series(1, 80);

-- Product Pricing
INSERT INTO erp_product_pricing (product_id, vendor_id, currency_id, unit_cost, list_price, minimum_order_qty, effective_from, is_active)
SELECT 
    p.product_id,
    v.vendor_id,
    1,
    CASE 
        WHEN p.category_id = 1 THEN erp.random_decimal(150000, 400000, 2)
        WHEN p.category_id = 2 THEN erp.random_decimal(100000, 500000, 2)
        WHEN p.category_id = 3 THEN erp.random_decimal(200000, 450000, 2)
        WHEN p.category_id = 4 THEN erp.random_decimal(250000, 400000, 2)
        WHEN p.category_id = 5 THEN erp.random_decimal(300000, 600000, 2)
        WHEN p.category_id = 6 THEN erp.random_decimal(400000, 800000, 2)
        WHEN p.category_id = 10 THEN erp.random_decimal(5000, 50000, 2)
        ELSE erp.random_decimal(50000, 300000, 2)
    END,
    CASE 
        WHEN p.category_id = 1 THEN erp.random_decimal(200000, 500000, 2)
        WHEN p.category_id = 2 THEN erp.random_decimal(150000, 600000, 2)
        WHEN p.category_id = 3 THEN erp.random_decimal(280000, 550000, 2)
        WHEN p.category_id = 4 THEN erp.random_decimal(300000, 500000, 2)
        WHEN p.category_id = 5 THEN erp.random_decimal(400000, 750000, 2)
        WHEN p.category_id = 6 THEN erp.random_decimal(500000, 1000000, 2)
        WHEN p.category_id = 10 THEN erp.random_decimal(8000, 70000, 2)
        ELSE erp.random_decimal(80000, 400000, 2)
    END,
    1,
    CURRENT_DATE - INTERVAL '6 months',
    TRUE
FROM erp_product p
CROSS JOIN (SELECT vendor_id FROM erp_vendor WHERE is_active = TRUE ORDER BY random() LIMIT 3) v
WHERE random() < 0.5;

-- =====================================================================
-- WAREHOUSE DATA
-- =====================================================================

INSERT INTO erp_warehouse (warehouse_code, warehouse_name, warehouse_type, address_line1, city, state_province, postal_code, country_id, is_active) VALUES
('WH-CHI', 'Chicago Distribution Center', 'DISTRIBUTION', '1234 Industrial Blvd', 'Chicago', 'IL', '60601', 1, TRUE),
('WH-DAL', 'Dallas Regional Warehouse', 'REGIONAL', '5678 Commerce Drive', 'Dallas', 'TX', '75201', 1, TRUE),
('WH-PHX', 'Phoenix Operations Hub', 'OPERATIONS', '9012 Desert Way', 'Phoenix', 'AZ', '85001', 1, TRUE),
('WH-DEN', 'Denver Mountain Center', 'REGIONAL', '3456 Mountain Road', 'Denver', 'CO', '80201', 1, TRUE),
('WH-SEA', 'Seattle Northwest Hub', 'DISTRIBUTION', '7890 Pacific Ave', 'Seattle', 'WA', '98101', 1, TRUE),
('WH-ATL', 'Atlanta Southeast Center', 'REGIONAL', '2345 Peachtree Street', 'Atlanta', 'GA', '30301', 1, TRUE),
('WH-HOU', 'Houston Gulf Center', 'OPERATIONS', '6789 Energy Drive', 'Houston', 'TX', '77001', 1, TRUE),
('WH-LAX', 'Los Angeles West Coast Hub', 'DISTRIBUTION', '1357 Harbor Blvd', 'Los Angeles', 'CA', '90001', 1, TRUE);

-- Inventory
INSERT INTO erp_inventory (product_id, warehouse_id, quantity_on_hand, quantity_reserved, quantity_on_order, bin_location)
SELECT 
    p.product_id,
    w.warehouse_id,
    erp.random_between(0, 20),
    erp.random_between(0, 5),
    erp.random_between(0, 10),
    'BIN-' || UPPER(SUBSTRING(w.warehouse_code FROM 4)) || '-' || LPAD(erp.random_between(1, 50)::TEXT, 3, '0')
FROM erp_product p
CROSS JOIN erp_warehouse w
WHERE random() < 0.4;

-- =====================================================================
-- CARRIER DATA
-- =====================================================================

INSERT INTO erp_carrier (carrier_code, carrier_name, carrier_type, tracking_url_template, is_active) VALUES
('FEDEX', 'FedEx Freight', 'FREIGHT', 'https://www.fedex.com/tracking?tracknumbers={tracking_number}', TRUE),
('UPS', 'UPS Freight', 'FREIGHT', 'https://www.ups.com/track?tracknum={tracking_number}', TRUE),
('YRC', 'YRC Worldwide', 'LTL', 'https://www.yrc.com/tools/track-shipment?pro={tracking_number}', TRUE),
('ODFL', 'Old Dominion Freight', 'LTL', 'https://www.odfl.com/Trace/standardResult.faces?pro={tracking_number}', TRUE),
('XPO', 'XPO Logistics', 'FREIGHT', 'https://www.xpo.com/track?id={tracking_number}', TRUE),
('SAIA', 'Saia LTL Freight', 'LTL', 'https://www.saia.com/track?pro={tracking_number}', TRUE),
('FLAT', 'Flatbed Express', 'FLATBED', 'https://www.flatbedexpress.com/track/{tracking_number}', TRUE),
('HEAVY', 'Heavy Haul Transport', 'SPECIALIZED', 'https://www.heavyhaul.com/tracking/{tracking_number}', TRUE);

-- =====================================================================
-- DEPARTMENT AND BUDGET DATA
-- =====================================================================

INSERT INTO erp_department (department_code, department_name, cost_center, is_active) VALUES
('PROC', 'Procurement', 'CC-PROC', TRUE),
('SALES', 'Sales Operations', 'CC-SALES', TRUE),
('OPS', 'Operations', 'CC-OPS', TRUE),
('FIN', 'Finance', 'CC-FIN', TRUE),
('LEGAL', 'Legal', 'CC-LEGAL', TRUE),
('IT', 'Information Technology', 'CC-IT', TRUE),
('MAINT', 'Maintenance', 'CC-MAINT', TRUE),
('FLEET', 'Fleet Management', 'CC-FLEET', TRUE);

-- Budgets
INSERT INTO erp_budget (budget_code, budget_name, department_id, fiscal_year, currency_id, budgeted_amount, committed_amount, spent_amount, start_date, end_date, status)
SELECT 
    'BUD-' || d.department_code || '-2025',
    d.department_name || ' Budget 2025',
    d.department_id,
    2025,
    1,
    erp.random_decimal(500000, 5000000, 2),
    erp.random_decimal(100000, 1000000, 2),
    erp.random_decimal(50000, 500000, 2),
    '2025-01-01',
    '2025-12-31',
    'ACTIVE'
FROM erp_department d;

-- =====================================================================
-- PURCHASE ORDER DATA (Based on MockMailConversations.md PO patterns)
-- =====================================================================

-- Insert ERP Users first
INSERT INTO erp_user (username, email, first_name, last_name, department_id, job_title, is_active) VALUES
('lisa.anderson', 'lisa.anderson@heavyequipdealer.com', 'Lisa', 'Anderson', 1, 'Sales Representative', TRUE),
('mike.thompson', 'mike.thompson@heavyequipdealer.com', 'Mike', 'Thompson', 1, 'Senior Sales Representative', TRUE),
('sarah.johnson', 'sarah.johnson@heavyequipdealer.com', 'Sarah', 'Johnson', 1, 'Sales Representative', TRUE),
('david.brown', 'david.brown@heavyequipdealer.com', 'David', 'Brown', 1, 'Sales Representative', TRUE),
('jennifer.adams', 'jennifer.adams@heavyequipdealer.com', 'Jennifer', 'Adams', 1, 'Procurement Officer', TRUE),
('procurement.mgr', 'procurement@heavyequipdealer.com', 'Robert', 'Wilson', 1, 'Procurement Manager', TRUE),
('operations.mgr', 'operations@heavyequipdealer.com', 'Patricia', 'Davis', 3, 'Operations Manager', TRUE),
('finance.approver', 'finance@heavyequipdealer.com', 'Christopher', 'Martinez', 4, 'Finance Approver', TRUE);

-- Purchase Orders (Based on conversations 21-30 from MockMailConversations.md)
INSERT INTO erp_purchase_order (po_number, vendor_id, quote_reference, status_id, priority_id, order_date, required_date, promised_date, currency_id, subtotal, tax_amount, total_amount, payment_terms, notes, created_by, created_at) VALUES
-- From Conversation 21
('PO-2025-0301', 1, 'Q-2025-1201', 8, 3, '2025-12-11', '2026-01-08', '2026-01-05', 1, 288000.00, 0, 288000.00, 'Net 30', 'CAT 320 Excavator for Thompson Excavating. Includes free delivery and operator training.', 1, '2025-12-11 10:00:00'),
-- From Conversation 22
('PO-2025-0302', 2, 'Q-2025-1202', 8, 3, '2025-12-13', '2026-02-01', '2026-01-25', 1, 781000.00, 0, 781000.00, 'Net 45', 'Fleet order - 3 Komatsu WA380-8 Wheel Loaders for Baker Quarry Operations', 2, '2025-12-13 09:00:00'),
-- From Conversation 23
('PO-2025-0303', 3, 'Q-2025-1203', 10, 1, '2025-12-14', '2025-12-16', '2025-12-16', 1, 52000.00, 0, 52000.00, 'Wire Transfer', 'RUSH ORDER - Kubota KX040-4 Mini Excavator for Russo Landscaping', 3, '2025-12-14 09:30:00'),
-- From Conversation 24
('PO-2025-0304', 4, 'Q-2025-1204', 8, 3, '2025-12-16', '2026-01-10', '2026-01-08', 1, 280000.00, 0, 280000.00, 'Net 30', 'CAT D5 LGP Bulldozer - Trade-in deal for Martinez Grading', 4, '2025-12-16 09:00:00'),
-- From Conversation 25
('PO-2025-0305', 5, 'Q-2025-1205', 8, 3, '2025-12-19', '2026-01-20', '2026-01-18', 1, 485000.00, 0, 485000.00, 'Financing - 60 months', 'Volvo A30G Articulated Hauler - Financed purchase for Williams Earthworks', 1, '2025-12-19 09:00:00'),
-- From Conversation 26
('PO-2025-0306', 6, 'CH-PO-2025-456', 8, 3, '2025-12-22', '2026-02-15', '2026-02-10', 1, 375500.00, 0, 375500.00, 'Net 60', 'Government Contract - CAT 140M Motor Grader with Snow Plow for County Highway Dept', 2, '2025-12-22 14:00:00'),
-- From Conversation 27
('PO-2025-0307', 1, 'Q-2025-1207', 8, 3, '2025-12-23', '2026-01-30', '2026-01-28', 1, 280000.00, 0, 280000.00, 'Net 30', 'Repeat customer - CAT 320 for Patterson Construction', 3, '2025-12-23 15:00:00'),
-- From Conversation 28
('PO-2025-0308', 7, 'Q-2025-1208', 5, 3, '2025-12-27', '2026-03-15', '2026-03-10', 1, 485000.00, 0, 485000.00, 'Net 30', 'FACTORY ORDER - Custom CAT 980M Wheel Loader for Chen Aggregate', 4, '2025-12-27 11:00:00'),
-- From Conversation 29
('PO-2025-0309', 8, 'Q-2025-1209', 10, 1, '2025-12-28', '2025-12-30', '2025-12-29', 1, 315000.00, 0, 315000.00, 'Insurance Payment', 'EMERGENCY - CAT 325 Excavator replacement for Stewart Demolition (fire damage)', 1, '2025-12-28 09:00:00'),
-- From Conversation 30
('PO-2025-0310', 9, 'Q-2025-1210', 5, 2, '2025-12-30', '2026-03-15', NULL, 1, 2369000.00, 0, 2369000.00, 'Net 45', 'National Fleet Order - 8 units for National Build Corp (multi-location delivery)', 2, '2025-12-30 11:00:00');

-- Generate additional POs
INSERT INTO erp_purchase_order (po_number, vendor_id, quote_reference, status_id, priority_id, order_date, required_date, currency_id, subtotal, total_amount, payment_terms, created_by, created_at)
SELECT 
    'PO-2025-' || LPAD((310 + row_number() OVER ())::TEXT, 4, '0'),
    erp.random_between(1, 15),
    'Q-2025-' || LPAD(erp.random_between(1000, 9999)::TEXT, 4, '0'),
    erp.random_between(1, 10),
    erp.random_between(1, 4),
    CURRENT_DATE - (erp.random_between(1, 180) || ' days')::INTERVAL,
    CURRENT_DATE + (erp.random_between(7, 90) || ' days')::INTERVAL,
    1,
    erp.random_decimal(50000, 500000, 2),
    erp.random_decimal(50000, 500000, 2),
    erp.random_element(ARRAY['Net 30', 'Net 45', 'Net 60', 'Wire Transfer']),
    erp.random_between(1, 8),
    CURRENT_TIMESTAMP - (erp.random_between(1, 180) || ' days')::INTERVAL
FROM generate_series(1, 490);

-- PO Line Items for specific POs from MockMailConversations
INSERT INTO erp_po_line_item (po_id, line_number, product_id, product_code, product_description, quantity_ordered, quantity_received, uom_id, unit_price, line_total, required_date) VALUES
-- PO-2025-0301: CAT 320 Excavator
(1, 1, 1, 'CAT-320-NG', 'CAT 320 Next Gen Hydraulic Excavator - 42" bucket, standard tracks, AC cabin, rear camera', 1, 1, 1, 288000.00, 288000.00, '2026-01-05'),
-- PO-2025-0302: Fleet of Wheel Loaders
(2, 1, 7, 'KOM-WA380', 'Komatsu WA380-8 Wheel Loader with Extended Warranty', 3, 2, 1, 265000.00, 795000.00, '2026-01-25'),
(2, 2, NULL, 'WARRANTY-5YR', 'Extended Warranty Package (5 years)', 3, 3, 1, 12000.00, 36000.00, '2026-01-25'),
-- PO-2025-0303: Mini Excavator (Rush)
(3, 1, 5, 'KUB-KX040', 'Kubota KX040-4 Mini Excavator', 1, 1, 1, 52000.00, 52000.00, '2025-12-16'),
-- PO-2025-0304: Bulldozer Trade-in
(4, 1, 9, 'CAT-D5-LGP', 'CAT D5 LGP Bulldozer with LGP tracks', 1, 1, 1, 380000.00, 380000.00, '2026-01-08'),
-- PO-2025-0305: Articulated Hauler
(5, 1, 13, 'VOL-A30G', 'Volvo A30G Articulated Hauler - Standard Configuration', 1, 0, 1, 485000.00, 485000.00, '2026-01-18'),
-- PO-2025-0306: Government - Grader with Attachments
(6, 1, 12, 'CAT-140M', 'CAT 140M Motor Grader', 1, 0, 1, 345000.00, 345000.00, '2026-02-10'),
(6, 2, 15, 'ATT-SPLOW', 'Snow Plow Attachment', 1, 0, 1, 18500.00, 18500.00, '2026-02-10'),
(6, 3, 16, 'ATT-WING', 'Wing Kit', 1, 0, 1, 12000.00, 12000.00, '2026-02-10'),
-- PO-2025-0307: Repeat Customer
(7, 1, 1, 'CAT-320-NG', 'CAT 320 Next Gen Hydraulic Excavator - Same config as previous order', 1, 0, 1, 280000.00, 280000.00, '2026-01-28'),
-- PO-2025-0308: Custom Factory Order
(8, 1, 6, 'CAT-980M', 'CAT 980M Wheel Loader - CUSTOM BUILD with High-lift boom, 6.5CY rock bucket, auto-lube, rear camera, heated/cooled seats', 1, 0, 1, 485000.00, 485000.00, '2026-03-10'),
-- PO-2025-0309: Emergency Replacement
(9, 1, 2, 'CAT-325-HEX', 'CAT 325 Hydraulic Excavator - Emergency Replacement', 1, 1, 1, 315000.00, 315000.00, '2025-12-29'),
-- PO-2025-0310: Fleet Order (multi-location)
(10, 1, 1, 'CAT-320-NG', 'CAT 320 Excavator - Dallas', 2, 0, 1, 290000.00, 580000.00, '2026-01-15'),
(10, 2, 1, 'CAT-320-NG', 'CAT 320 Excavator - Phoenix', 1, 0, 1, 290000.00, 290000.00, '2026-01-30'),
(10, 3, 10, 'CAT-D6', 'CAT D6 Bulldozer - Denver', 2, 0, 1, 365000.00, 730000.00, '2026-02-15'),
(10, 4, 6, 'CAT-980M', 'CAT 980M Wheel Loader - Seattle', 1, 0, 1, 395000.00, 395000.00, '2026-03-01'),
(10, 5, 1, 'CAT-320-NG', 'CAT 320 Excavator - Atlanta', 2, 0, 1, 290000.00, 580000.00, '2026-03-15');

-- Generate line items for other POs
INSERT INTO erp_po_line_item (po_id, line_number, product_id, product_description, quantity_ordered, quantity_received, uom_id, unit_price, line_total)
SELECT 
    po.po_id,
    row_number() OVER (PARTITION BY po.po_id),
    p.product_id,
    p.product_name,
    erp.random_between(1, 5),
    CASE WHEN po.status_id >= 8 THEN erp.random_between(1, 5) ELSE 0 END,
    1,
    erp.random_decimal(50000, 500000, 2),
    erp.random_decimal(50000, 500000, 2)
FROM erp_purchase_order po
CROSS JOIN LATERAL (
    SELECT product_id, product_name 
    FROM erp_product 
    WHERE is_active = TRUE 
    ORDER BY random() 
    LIMIT erp.random_between(1, 3)
) p
WHERE po.po_id > 10
AND random() < 0.8;

-- PO Status History
INSERT INTO erp_po_status_history (po_id, old_status_id, new_status_id, changed_at, changed_by, notes)
SELECT 
    po.po_id,
    CASE WHEN s.status_id = 1 THEN NULL ELSE s.status_id - 1 END,
    s.status_id,
    po.created_at + (s.display_order * INTERVAL '1 day'),
    po.created_by,
    'Status updated to ' || s.status_name
FROM erp_purchase_order po
CROSS JOIN erp_po_status s
WHERE s.display_order <= (SELECT display_order FROM erp_po_status WHERE status_id = po.status_id)
ORDER BY po.po_id, s.display_order;

-- =====================================================================
-- SHIPMENT AND DELIVERY DATA
-- =====================================================================

-- Shipments for completed/shipped POs
INSERT INTO erp_shipment (shipment_number, po_id, carrier_id, tracking_number, shipment_status, ship_date, estimated_delivery_date, actual_delivery_date, shipping_cost, package_count)
SELECT 
    'SHP-' || LPAD(row_number() OVER ()::TEXT, 6, '0'),
    po.po_id,
    erp.random_between(1, 8),
    UPPER(SUBSTRING(MD5(random()::TEXT) FROM 1 FOR 4)) || erp.random_between(10000000, 99999999)::TEXT,
    CASE 
        WHEN po.status_id = 10 THEN 'DELIVERED'
        WHEN po.status_id >= 6 THEN 'IN_TRANSIT'
        ELSE 'PENDING'
    END,
    po.order_date + INTERVAL '3 days',
    po.required_date,
    CASE WHEN po.status_id = 10 THEN po.required_date - INTERVAL '2 days' ELSE NULL END,
    erp.random_decimal(500, 5000, 2),
    erp.random_between(1, 5)
FROM erp_purchase_order po
WHERE po.status_id >= 5;

-- Delivery Tracking Events
INSERT INTO erp_delivery_tracking (shipment_id, tracking_status, status_description, location, event_timestamp)
SELECT 
    s.shipment_id,
    status_info.status,
    status_info.description,
    status_info.location,
    s.ship_date + (status_info.day_offset || ' days')::INTERVAL
FROM erp_shipment s
CROSS JOIN LATERAL (
    VALUES 
        ('PICKED_UP', 'Package picked up from vendor', 'Vendor Facility', 0),
        ('IN_TRANSIT', 'Package in transit', 'Regional Hub', 1),
        ('OUT_FOR_DELIVERY', 'Out for delivery', 'Local Facility', 3),
        ('DELIVERED', 'Package delivered', 'Delivery Address', 4)
) AS status_info(status, description, location, day_offset)
WHERE s.shipment_status IN ('DELIVERED', 'IN_TRANSIT')
AND (s.shipment_status = 'DELIVERED' OR status_info.status != 'DELIVERED');

-- Goods Receipts
INSERT INTO erp_goods_receipt (receipt_number, po_id, shipment_id, warehouse_id, receipt_date, receipt_status, received_by)
SELECT 
    'GR-' || LPAD(row_number() OVER ()::TEXT, 6, '0'),
    s.po_id,
    s.shipment_id,
    erp.random_between(1, 8),
    s.actual_delivery_date,
    'COMPLETED',
    erp.random_between(1, 8)
FROM erp_shipment s
WHERE s.shipment_status = 'DELIVERED';

-- =====================================================================
-- INVOICE DATA
-- =====================================================================

INSERT INTO erp_invoice (invoice_number, vendor_id, po_id, vendor_invoice_number, invoice_date, due_date, currency_id, subtotal, tax_amount, total_amount, status, payment_status)
SELECT 
    'INV-' || LPAD(row_number() OVER ()::TEXT, 6, '0'),
    po.vendor_id,
    po.po_id,
    'VI-' || LPAD(erp.random_between(10000, 99999)::TEXT, 5, '0'),
    po.order_date + INTERVAL '7 days',
    po.order_date + INTERVAL '37 days',
    1,
    po.subtotal,
    po.subtotal * 0.08,
    po.total_amount * 1.08,
    CASE WHEN po.status_id >= 8 THEN 'APPROVED' ELSE 'PENDING' END,
    CASE 
        WHEN po.status_id = 10 THEN 'PAID'
        WHEN po.status_id >= 8 THEN 'PARTIAL'
        ELSE 'UNPAID'
    END
FROM erp_purchase_order po
WHERE po.status_id >= 5
AND random() < 0.8;

-- =====================================================================
-- NOTIFICATION AND COMMUNICATION DATA
-- =====================================================================

INSERT INTO erp_notification_template (template_code, template_name, notification_type, channel, subject_template, body_template, is_active) VALUES
('PO_SENT', 'PO Sent to Vendor', 'PO_NOTIFICATION', 'EMAIL', 'Purchase Order #{PO_NUMBER} - {COMPANY_NAME}', 'Dear {VENDOR_NAME}, Please find attached Purchase Order #{PO_NUMBER} for the following items: {LINE_ITEMS}. Required Delivery Date: {DELIVERY_DATE}. Please acknowledge this order within 24 hours.', TRUE),
('PO_REMINDER', 'PO Reminder', 'PO_REMINDER', 'EMAIL', 'Reminder: Purchase Order #{PO_NUMBER} Awaiting Acknowledgment', 'This is a reminder that Purchase Order #{PO_NUMBER} is still awaiting your acknowledgment. Please respond within 24 hours.', TRUE),
('DELAY_ALERT', 'Delivery Delay Alert', 'DELAY_ALERT', 'EMAIL', '⚠️ Delivery Alert - PO #{PO_NUMBER}', 'A potential delay has been detected for PO #{PO_NUMBER}. Customer: {CUSTOMER_NAME}. Original Delivery Date: {ORIGINAL_DATE}. New Estimated Date: {NEW_DATE}.', TRUE),
('DELIVERY_CONFIRM', 'Delivery Confirmation', 'DELIVERY_CONFIRM', 'EMAIL', 'Delivery Confirmed - PO #{PO_NUMBER}', 'Good news! PO #{PO_NUMBER} has been delivered to {DELIVERY_ADDRESS}.', TRUE);

-- Vendor Communication Log
INSERT INTO erp_vendor_communication_log (vendor_id, po_id, communication_type, direction, channel, subject, content, sender_email, recipient_email, sent_at, status)
SELECT 
    po.vendor_id,
    po.po_id,
    'PO_NOTIFICATION',
    'OUTBOUND',
    'EMAIL',
    'Purchase Order #' || po.po_number || ' - Heavy Equipment Dealer',
    'Dear Vendor, Please find attached Purchase Order #' || po.po_number || '. Required Delivery Date: ' || po.required_date::TEXT,
    'procurement@heavyequipdealer.com',
    vc.email,
    po.created_at,
    'DELIVERED'
FROM erp_purchase_order po
JOIN erp_vendor_contact vc ON vc.vendor_id = po.vendor_id AND vc.is_primary = TRUE
WHERE random() < 0.9;

-- =====================================================================
-- ISSUE AND ESCALATION DATA
-- =====================================================================

INSERT INTO erp_issue (issue_number, issue_type, category_id, priority_id, reference_type, reference_id, subject, description, status, detected_at, created_by)
SELECT 
    'ISS-' || LPAD(row_number() OVER ()::TEXT, 6, '0'),
    erp.random_element(ARRAY['DELIVERY_DELAY', 'QUALITY_ISSUE', 'VENDOR_RESPONSE', 'PRICING_ISSUE']),
    erp.random_between(1, 7),
    erp.random_between(1, 4),
    'PURCHASE_ORDER',
    po.po_id,
    'Issue with PO #' || po.po_number,
    'Issue detected for purchase order requiring attention',
    erp.random_element(ARRAY['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']),
    po.created_at + INTERVAL '5 days',
    erp.random_between(1, 8)
FROM erp_purchase_order po
WHERE random() < 0.15;

-- =====================================================================
-- AI/ML DATA
-- =====================================================================

-- Vendor AI Scores
INSERT INTO erp_vendor_ai_score (vendor_id, product_category_id, price_score, delivery_score, quality_score, location_score, overall_score, calculation_date, model_version, factors)
SELECT 
    v.vendor_id,
    pc.category_id,
    erp.random_decimal(0.5, 1.0, 2),
    erp.random_decimal(0.5, 1.0, 2),
    erp.random_decimal(0.5, 1.0, 2),
    erp.random_decimal(0.5, 1.0, 2),
    erp.random_decimal(0.6, 0.95, 2),
    CURRENT_DATE - (erp.random_between(0, 30) || ' days')::INTERVAL,
    'v1.0',
    '{"response_time": ' || erp.random_between(1, 24) || ', "on_time_rate": ' || erp.random_decimal(0.8, 1.0, 2) || '}'
FROM erp_vendor v
CROSS JOIN erp_product_category pc
WHERE random() < 0.3;

-- Delivery Predictions
INSERT INTO erp_delivery_prediction (po_id, predicted_delivery_date, confidence_score, model_version, prediction_factors)
SELECT 
    po.po_id,
    po.required_date - (erp.random_between(-3, 3) || ' days')::INTERVAL,
    erp.random_decimal(0.7, 0.98, 4),
    'v1.0',
    '{"vendor_history": 0.85, "distance_factor": 0.92, "complexity_factor": 0.88}'
FROM erp_purchase_order po
WHERE po.required_date IS NOT NULL
AND random() < 0.7;

-- =====================================================================
-- REPORTING DATA
-- =====================================================================

-- Daily PO Summary (Last 90 days)
INSERT INTO erp_daily_po_summary (summary_date, total_pos_created, total_pos_completed, total_pos_cancelled, total_pos_delayed, total_value_ordered, total_value_received, avg_processing_time_hours, on_time_delivery_rate, vendor_response_rate)
SELECT 
    d::DATE,
    erp.random_between(5, 20),
    erp.random_between(3, 15),
    erp.random_between(0, 3),
    erp.random_between(0, 5),
    erp.random_decimal(500000, 2000000, 2),
    erp.random_decimal(300000, 1500000, 2),
    erp.random_decimal(4, 24, 2),
    erp.random_decimal(0.85, 0.98, 2),
    erp.random_decimal(0.90, 0.99, 2)
FROM generate_series(CURRENT_DATE - INTERVAL '90 days', CURRENT_DATE, '1 day') d
ON CONFLICT (summary_date) DO NOTHING;

-- Vendor Performance Summary
INSERT INTO erp_vendor_performance_summary (vendor_id, summary_period, period_start, period_end, total_orders, total_value, on_time_deliveries, late_deliveries, avg_delivery_days, quality_issues, overall_rating)
SELECT 
    v.vendor_id,
    'MONTHLY',
    DATE_TRUNC('month', CURRENT_DATE) - (m || ' months')::INTERVAL,
    DATE_TRUNC('month', CURRENT_DATE) - ((m - 1) || ' months')::INTERVAL - INTERVAL '1 day',
    erp.random_between(5, 50),
    erp.random_decimal(100000, 2000000, 2),
    erp.random_between(3, 45),
    erp.random_between(0, 5),
    erp.random_decimal(5, 21, 2),
    erp.random_between(0, 3),
    erp.random_decimal(3.5, 5.0, 2)
FROM erp_vendor v
CROSS JOIN generate_series(1, 6) m
ON CONFLICT (vendor_id, summary_period, period_start) DO NOTHING;

-- =====================================================================
-- CLEANUP HELPER FUNCTIONS
-- =====================================================================

-- Optionally drop helper functions after data generation
-- DROP FUNCTION IF EXISTS erp.random_between(INT, INT);
-- DROP FUNCTION IF EXISTS erp.random_decimal(DECIMAL, DECIMAL, INT);
-- DROP FUNCTION IF EXISTS erp.random_element(TEXT[]);

-- =====================================================================
-- DATA GENERATION SUMMARY
-- =====================================================================

-- Generate statistics comment
DO $$
DECLARE
    vendor_count INT;
    product_count INT;
    po_count INT;
    line_item_count INT;
    shipment_count INT;
    invoice_count INT;
BEGIN
    SELECT COUNT(*) INTO vendor_count FROM erp_vendor;
    SELECT COUNT(*) INTO product_count FROM erp_product;
    SELECT COUNT(*) INTO po_count FROM erp_purchase_order;
    SELECT COUNT(*) INTO line_item_count FROM erp_po_line_item;
    SELECT COUNT(*) INTO shipment_count FROM erp_shipment;
    SELECT COUNT(*) INTO invoice_count FROM erp_invoice;
    
    RAISE NOTICE 'ERP Mock Data Generation Complete:';
    RAISE NOTICE '  Vendors: %', vendor_count;
    RAISE NOTICE '  Products: %', product_count;
    RAISE NOTICE '  Purchase Orders: %', po_count;
    RAISE NOTICE '  PO Line Items: %', line_item_count;
    RAISE NOTICE '  Shipments: %', shipment_count;
    RAISE NOTICE '  Invoices: %', invoice_count;
END $$;

-- =====================================================================
-- END OF ERP MOCK DATA
-- =====================================================================
