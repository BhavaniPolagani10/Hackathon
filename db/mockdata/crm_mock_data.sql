-- =====================================================================
-- CRM SYSTEM MOCK DATA
-- PostgreSQL Mock Data Generation for Customer Relationship Management
-- =====================================================================
-- 
-- Document Version: 1.0
-- Created: December 2025
-- Purpose: Generate realistic mock data for CRM system testing
-- 
-- Total Records Target: ~10,000 records across CRM tables
-- Data is derived from:
--   - /MLP/Automated_Quotation_Generation_MLP.md
--   - /MockData/MockMailConversations.md (customer names, quotation patterns)
--
-- =====================================================================

SET search_path TO crm;

-- =====================================================================
-- HELPER FUNCTIONS FOR DATA GENERATION
-- =====================================================================

CREATE OR REPLACE FUNCTION crm.random_between(low INT, high INT) 
RETURNS INT AS $$
BEGIN
   RETURN floor(random() * (high - low + 1) + low);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION crm.random_decimal(low DECIMAL, high DECIMAL, precision INT DEFAULT 2) 
RETURNS DECIMAL AS $$
BEGIN
   RETURN ROUND((random() * (high - low) + low)::DECIMAL, precision);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION crm.random_element(arr TEXT[]) 
RETURNS TEXT AS $$
BEGIN
   RETURN arr[crm.random_between(1, array_length(arr, 1))];
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- SALES TEAM DATA
-- =====================================================================

INSERT INTO crm_sales_team (team_code, team_name, region, target_quota, is_active) VALUES
('TEAM-WEST', 'Western Region Sales', 'West', 5000000.00, TRUE),
('TEAM-EAST', 'Eastern Region Sales', 'East', 4500000.00, TRUE),
('TEAM-CENT', 'Central Region Sales', 'Central', 4000000.00, TRUE),
('TEAM-SOUTH', 'Southern Region Sales', 'South', 3500000.00, TRUE);

-- Sales Representatives (Based on MockMailConversations.md)
INSERT INTO crm_sales_rep (employee_code, first_name, last_name, email, phone, job_title, team_id, territory, quota_amount, commission_rate, hire_date, is_active) VALUES
('EMP001', 'Sarah', 'Johnson', 'sarah.johnson@heavyequipdealer.com', '(555) 123-4567', 'Sales Representative', 1, 'California, Nevada, Arizona', 1200000.00, 5.00, '2020-03-15', TRUE),
('EMP002', 'Mike', 'Thompson', 'mike.thompson@heavyequipdealer.com', '(555) 234-5678', 'Senior Sales Representative', 2, 'New York, New Jersey, Pennsylvania', 1500000.00, 6.00, '2018-06-01', TRUE),
('EMP003', 'Lisa', 'Anderson', 'lisa.anderson@heavyequipdealer.com', '(555) 345-6789', 'Sales Representative', 3, 'Texas, Oklahoma, Louisiana', 1100000.00, 5.00, '2021-01-10', TRUE),
('EMP004', 'David', 'Brown', 'david.brown@heavyequipdealer.com', '(555) 456-7890', 'Sales Representative', 4, 'Florida, Georgia, Alabama', 1000000.00, 5.00, '2022-04-20', TRUE),
('EMP005', 'Jennifer', 'Martinez', 'jennifer.martinez@heavyequipdealer.com', '(555) 567-8901', 'Sales Manager', 1, 'Western Region', 2000000.00, 7.00, '2017-09-01', TRUE),
('EMP006', 'Robert', 'Wilson', 'robert.wilson@heavyequipdealer.com', '(555) 678-9012', 'Account Executive', 2, 'Northeast', 1300000.00, 5.50, '2019-11-15', TRUE),
('EMP007', 'Emily', 'Davis', 'emily.davis@heavyequipdealer.com', '(555) 789-0123', 'Sales Representative', 3, 'Midwest', 1000000.00, 5.00, '2023-02-01', TRUE),
('EMP008', 'Christopher', 'Garcia', 'christopher.garcia@heavyequipdealer.com', '(555) 890-1234', 'Senior Account Executive', 4, 'Southeast', 1400000.00, 6.00, '2016-07-10', TRUE);

-- =====================================================================
-- CUSTOMER DATA (Based on MockMailConversations.md)
-- =====================================================================

INSERT INTO crm_customer (customer_code, customer_name, legal_name, customer_type, industry_id, company_size, annual_revenue, website_url, preferred_currency_id, payment_terms_days, assigned_sales_rep_id, account_status, customer_since, is_active) VALUES
-- From MockMailConversations.md
('CUST001', 'Thompson Excavating', 'Thompson Excavating LLC', 'COMPANY', 1, 'MEDIUM', 15000000.00, 'https://thompsonexcavating.com', 1, 30, 3, 'ACTIVE', '2023-01-15', TRUE),
('CUST002', 'Baker Quarry Operations', 'Baker Quarry Operations Inc', 'COMPANY', 2, 'LARGE', 50000000.00, 'https://bakerquarry.com', 1, 45, 2, 'ACTIVE', '2022-06-01', TRUE),
('CUST003', 'Russo Landscaping', 'Russo Landscaping Services LLC', 'COMPANY', 10, 'SMALL', 2500000.00, 'https://russolandscaping.com', 1, 30, 1, 'ACTIVE', '2024-03-10', TRUE),
('CUST004', 'Martinez Grading', 'Martinez Grading Inc', 'COMPANY', 1, 'MEDIUM', 12000000.00, 'https://martinezgrading.com', 1, 30, 4, 'ACTIVE', '2021-09-20', TRUE),
('CUST005', 'Williams Earthworks', 'Williams Earthworks Corporation', 'COMPANY', 1, 'MEDIUM', 18000000.00, 'https://williamsearthworks.com', 1, 45, 3, 'ACTIVE', '2022-02-15', TRUE),
('CUST006', 'County Highway Department', 'County Highway Department', 'GOVERNMENT', 6, 'LARGE', NULL, 'https://countyhighway.gov', 1, 60, 2, 'ACTIVE', '2020-01-01', TRUE),
('CUST007', 'Patterson Construction', 'Patterson Construction Company', 'COMPANY', 1, 'LARGE', 75000000.00, 'https://pattersonconst.com', 1, 30, 1, 'ACTIVE', '2019-05-01', TRUE),
('CUST008', 'Chen Aggregate', 'Chen Aggregate Inc', 'COMPANY', 2, 'LARGE', 45000000.00, 'https://chenaggregate.com', 1, 30, 4, 'ACTIVE', '2021-11-15', TRUE),
('CUST009', 'Stewart Demolition', 'Stewart Demolition Services LLC', 'COMPANY', 1, 'MEDIUM', 20000000.00, 'https://stewartdem.com', 1, 30, 3, 'ACTIVE', '2020-08-01', TRUE),
('CUST010', 'National Build Corp', 'National Build Corporation', 'COMPANY', 1, 'ENTERPRISE', 250000000.00, 'https://nationalbuild.com', 1, 45, 2, 'ACTIVE', '2018-03-01', TRUE),
-- Additional customers from lead scenarios
('CUST011', 'Construction Pro Inc', 'Construction Pro Inc', 'COMPANY', 1, 'MEDIUM', 10000000.00, NULL, 1, 30, 1, 'ACTIVE', '2024-11-20', TRUE),
('CUST012', 'Small Contractors LLC', 'Small Contractors LLC', 'COMPANY', 1, 'SMALL', 1500000.00, NULL, 1, 30, 2, 'INACTIVE', '2024-11-16', FALSE),
('CUST013', 'Mining Corp International', 'Mining Corp International', 'COMPANY', 2, 'ENTERPRISE', 500000000.00, 'https://miningcorp.com', 1, 45, 3, 'ACTIVE', '2023-05-01', TRUE),
('CUST014', 'InfraDev Corporation', 'Infrastructure Development Corp', 'COMPANY', 1, 'LARGE', 80000000.00, 'https://infradev.com', 1, 30, 4, 'ACTIVE', '2022-07-15', TRUE),
('CUST015', 'BuildRite Construction', 'BuildRite Construction LLC', 'COMPANY', 1, 'MEDIUM', 25000000.00, 'https://buildrite.com', 1, 30, 1, 'ACTIVE', '2024-11-21', TRUE);

-- Generate more customers
INSERT INTO crm_customer (customer_code, customer_name, customer_type, industry_id, company_size, preferred_currency_id, payment_terms_days, assigned_sales_rep_id, account_status, is_active)
SELECT 
    'CUST' || LPAD((15 + row_number() OVER ())::TEXT, 3, '0'),
    crm.random_element(ARRAY['Pacific', 'Atlantic', 'Mountain', 'Central', 'Metro', 'Valley', 'Coastal']) || ' ' ||
    crm.random_element(ARRAY['Construction', 'Excavating', 'Grading', 'Earthworks', 'Paving', 'Mining', 'Demolition']) || ' ' ||
    crm.random_element(ARRAY['Inc', 'LLC', 'Corp', 'Co', 'Services', 'Group']),
    'COMPANY',
    crm.random_between(1, 10),
    crm.random_element(ARRAY['SMALL', 'MEDIUM', 'LARGE']),
    1,
    crm.random_element(ARRAY[30, 45, 60])::INT,
    crm.random_between(1, 8),
    'ACTIVE',
    TRUE
FROM generate_series(1, 85);

-- Customer Contacts (Based on MockMailConversations.md)
INSERT INTO crm_contact (customer_id, first_name, last_name, job_title, email, phone, is_primary, is_decision_maker, is_active) VALUES
(1, 'Mark', 'Thompson', 'Owner', 'm.thompson@thompsonexcavating.com', '(555) 111-2222', TRUE, TRUE, TRUE),
(2, 'Susan', 'Baker', 'Operations Manager', 's.baker@bakerquarry.com', '(555) 222-3333', TRUE, TRUE, TRUE),
(3, 'Tony', 'Russo', 'President', 't.russo@russolandscaping.com', '(555) 333-4444', TRUE, TRUE, TRUE),
(4, 'Frank', 'Martinez', 'Owner', 'f.martinez@martinezgrading.com', '(555) 444-5555', TRUE, TRUE, TRUE),
(5, 'Robert', 'Williams', 'CEO', 'r.williams@williamsearthworks.com', '(555) 555-6666', TRUE, TRUE, TRUE),
(6, 'Jennifer', 'Adams', 'Procurement Officer', 'j.adams@countyhighway.gov', '(555) 666-7777', TRUE, TRUE, TRUE),
(7, 'George', 'Patterson', 'VP Operations', 'g.patterson@pattersonconst.com', '(555) 777-8888', TRUE, TRUE, TRUE),
(8, 'Michelle', 'Chen', 'Operations Director', 'm.chen@chenaggregate.com', '(555) 888-9999', TRUE, TRUE, TRUE),
(9, 'Paul', 'Stewart', 'Owner', 'p.stewart@stewartdem.com', '(555) 999-0000', TRUE, TRUE, TRUE),
(10, 'Andrew', 'Collins', 'VP Operations', 'a.collins@nationalbuild.com', '(555) 000-1111', TRUE, TRUE, TRUE),
(11, 'John', 'Martinez', 'Project Manager', 'john.martinez@constructionpro.com', '(555) 123-1111', TRUE, TRUE, TRUE),
(12, 'Maria', 'Garcia', 'Purchasing Manager', 'maria.garcia@smallcontractors.com', '(555) 234-2222', TRUE, FALSE, TRUE),
(13, 'Robert', 'Chen', 'Procurement Manager', 'r.chen@miningcorp.com', '(555) 345-3333', TRUE, TRUE, TRUE),
(14, 'Amanda', 'Williams', 'Project Director', 'a.williams@infradev.com', '(555) 456-4444', TRUE, TRUE, TRUE),
(15, 'Tom', 'Richards', 'Equipment Manager', 'tom.richards@buildrite.com', '(555) 567-5555', TRUE, TRUE, TRUE);

-- Generate contacts for other customers
INSERT INTO crm_contact (customer_id, first_name, last_name, job_title, email, phone, is_primary, is_decision_maker, is_active)
SELECT 
    c.customer_id,
    crm.random_element(ARRAY['James', 'John', 'Robert', 'Michael', 'David', 'William', 'Richard', 'Joseph', 'Thomas', 'Charles', 'Mary', 'Patricia', 'Jennifer', 'Linda', 'Barbara', 'Elizabeth', 'Susan', 'Jessica', 'Sarah', 'Karen']),
    crm.random_element(ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Anderson', 'Taylor', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Moore', 'Wilson']),
    crm.random_element(ARRAY['Owner', 'President', 'CEO', 'Operations Manager', 'Purchasing Manager', 'Project Manager', 'Equipment Manager', 'VP Operations']),
    'contact' || c.customer_id || '@' || LOWER(REPLACE(c.customer_name, ' ', '')) || '.com',
    '(' || crm.random_between(200, 999)::TEXT || ') ' || crm.random_between(200, 999)::TEXT || '-' || crm.random_between(1000, 9999)::TEXT,
    TRUE,
    (random() < 0.7),
    TRUE
FROM crm_customer c
WHERE c.customer_id > 15;

-- =====================================================================
-- LEAD DATA (Based on MockMailConversations.md Conversations 1-10)
-- =====================================================================

INSERT INTO crm_lead (lead_number, company_name, first_name, last_name, job_title, email, phone, industry_id, source_id, status_id, lead_score, assigned_to_id, description, budget, currency_id, is_active) VALUES
-- Conversation 1: Initial Inquiry - No Response
('LEAD-001', 'Construction Pro Inc', 'John', 'Martinez', 'Project Manager', 'john.martinez@constructionpro.com', '(555) 123-1111', 1, 1, 6, 25, 1, 'Inquiry about CAT 320 excavators for highway project', 300000.00, 1, FALSE),
-- Conversation 2: Budget Constraint Lead
('LEAD-002', 'Small Contractors LLC', 'Maria', 'Garcia', 'Owner', 'maria.garcia@smallcontractors.com', '(555) 234-2222', 1, 1, 4, 15, 2, 'Looking for used wheel loaders, budget $25,000 - too low', 25000.00, 1, FALSE),
-- Conversation 3: Competitor Already Selected
('LEAD-003', 'Mining Corp International', 'Robert', 'Chen', 'Procurement Manager', 'r.chen@miningcorp.com', '(555) 345-3333', 2, 2, 6, 30, 3, 'Mining project equipment needs - signed with competitor', 1000000.00, 1, FALSE),
-- Conversation 4: Project Postponed
('LEAD-004', 'InfraDev Corporation', 'Amanda', 'Williams', 'Project Director', 'a.williams@infradev.com', '(555) 456-4444', 1, 1, 6, 40, 4, 'Bulldozer fleet inquiry - project postponed due to funding', 500000.00, 1, FALSE),
-- Conversation 5: Information Request Only (Research)
('LEAD-005', 'State University', 'Kevin', 'Park', 'Researcher', 'kevin.park@university.edu', '(555) 567-5555', NULL, 1, 4, 5, 1, 'Academic research on excavator efficiency - not a buyer', NULL, 1, FALSE),
-- Conversation 6: Wrong Contact Person
('LEAD-006', 'BuildRite Construction', 'Tom', 'Richards', 'Equipment Manager', 'tom.richards@buildrite.com', '(555) 678-6666', 1, 1, 2, 50, 2, 'Heavy equipment interest - initial contact made', 400000.00, 1, TRUE),
-- Conversation 7: Seasonal Business - Wrong Timing
('LEAD-007', 'City Services Department', 'Jennifer', 'Lee', 'Department Head', 'j.lee@cityservices.gov', '(555) 789-7777', 6, 1, 7, 35, 3, 'Snow removal equipment - budget cycle starts July', 200000.00, 1, TRUE),
-- Conversation 8: Rental Interest Only
('LEAD-008', 'Short Term Build LLC', 'Carlos', 'Mendez', 'Project Manager', 'carlos@shorttermbuild.com', '(555) 890-8888', 1, 1, 4, 10, 4, 'Mini excavator rental for 3-month project - referred to rental company', NULL, 1, FALSE),
-- Conversation 9: Vague Inquiry
('LEAD-009', NULL, 'Unknown', 'Sender', NULL, 'unknown_sender@gmail.com', NULL, NULL, 1, 6, 5, 1, 'Vague equipment inquiry - no response to follow-up', NULL, 1, FALSE),
-- Conversation 10: Price Shopping
('LEAD-010', 'Earth Movers Inc', 'Brian', 'Foster', 'Purchasing', 'bfoster@earthmovers.com', '(555) 012-0000', 1, 1, 6, 20, 2, 'Komatsu PC210 price check - only price shopping', 285000.00, 1, FALSE);

-- Generate additional leads
INSERT INTO crm_lead (lead_number, company_name, first_name, last_name, email, industry_id, source_id, status_id, lead_score, assigned_to_id, is_active, created_at)
SELECT 
    'LEAD-' || LPAD((10 + row_number() OVER ())::TEXT, 3, '0'),
    crm.random_element(ARRAY['Metro', 'Valley', 'Coastal', 'Highland', 'Summit', 'Prairie']) || ' ' ||
    crm.random_element(ARRAY['Construction', 'Excavating', 'Development', 'Builders', 'Contractors']),
    crm.random_element(ARRAY['James', 'John', 'Robert', 'Michael', 'David', 'William', 'Mary', 'Patricia', 'Jennifer', 'Linda']),
    crm.random_element(ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis']),
    'lead' || (10 + row_number() OVER ()) || '@example.com',
    crm.random_between(1, 10),
    crm.random_between(1, 9),
    crm.random_between(1, 7),
    crm.random_between(10, 90),
    crm.random_between(1, 8),
    (random() < 0.6),
    CURRENT_TIMESTAMP - (crm.random_between(1, 180) || ' days')::INTERVAL
FROM generate_series(1, 290);

-- =====================================================================
-- OPPORTUNITY DATA
-- =====================================================================

INSERT INTO crm_opportunity (opportunity_number, opportunity_name, customer_id, stage_id, probability_percent, amount, currency_id, expected_close_date, owner_id, source_id, is_closed) VALUES
-- Active opportunities
('OPP-001', 'Thompson Excavating - CAT 320', 1, 8, 100, 288000.00, 1, '2025-12-15', 3, 2, TRUE),
('OPP-002', 'Baker Quarry - Wheel Loader Fleet', 2, 8, 100, 781000.00, 1, '2025-12-20', 2, 1, TRUE),
('OPP-003', 'Russo Landscaping - Mini Excavator', 3, 8, 100, 52000.00, 1, '2025-12-14', 1, 1, TRUE),
('OPP-004', 'Martinez Grading - Bulldozer', 4, 8, 100, 280000.00, 1, '2025-12-18', 4, 2, TRUE),
('OPP-005', 'Williams Earthworks - Dump Truck', 5, 8, 100, 485000.00, 1, '2025-12-22', 3, 1, TRUE),
('OPP-006', 'County Highway - Motor Grader', 6, 8, 100, 375500.00, 1, '2025-12-25', 2, 8, TRUE),
('OPP-007', 'Patterson - Repeat Order', 7, 8, 100, 280000.00, 1, '2025-12-28', 1, 9, TRUE),
('OPP-008', 'Chen Aggregate - Custom Loader', 8, 6, 75, 485000.00, 1, '2026-03-15', 4, 1, FALSE),
('OPP-009', 'Stewart Demolition - Emergency', 9, 8, 100, 315000.00, 1, '2025-12-29', 3, 1, TRUE),
('OPP-010', 'National Build - Fleet Order', 10, 6, 90, 2369000.00, 1, '2026-03-30', 2, 2, FALSE);

-- Generate more opportunities
INSERT INTO crm_opportunity (opportunity_number, opportunity_name, customer_id, stage_id, probability_percent, amount, currency_id, expected_close_date, owner_id, source_id, is_closed, created_at)
SELECT 
    'OPP-' || LPAD((10 + row_number() OVER ())::TEXT, 3, '0'),
    c.customer_name || ' - ' || crm.random_element(ARRAY['Equipment Purchase', 'Fleet Upgrade', 'New Project', 'Expansion', 'Replacement']),
    c.customer_id,
    crm.random_between(1, 9),
    crm.random_between(10, 100),
    crm.random_decimal(50000, 1000000, 2),
    1,
    CURRENT_DATE + (crm.random_between(7, 180) || ' days')::INTERVAL,
    crm.random_between(1, 8),
    crm.random_between(1, 9),
    (random() < 0.3),
    CURRENT_TIMESTAMP - (crm.random_between(1, 120) || ' days')::INTERVAL
FROM crm_customer c
WHERE random() < 0.7;

-- =====================================================================
-- PRODUCT DATA
-- =====================================================================

INSERT INTO crm_product_category (category_code, category_name, description, is_active) VALUES
('EXCAVATOR', 'Excavators', 'Hydraulic excavators and track hoes', TRUE),
('LOADER', 'Loaders', 'Wheel loaders and track loaders', TRUE),
('BULLDOZER', 'Bulldozers', 'Track-type tractors and dozers', TRUE),
('GRADER', 'Motor Graders', 'Road graders and maintainers', TRUE),
('DUMP_TRUCK', 'Dump Trucks', 'Articulated and rigid dump trucks', TRUE),
('CRANE', 'Cranes', 'Mobile and truck cranes', TRUE),
('COMPACT', 'Compact Equipment', 'Mini excavators, skid steers, compact loaders', TRUE),
('ATTACHMENT', 'Attachments', 'Equipment attachments and accessories', TRUE);

INSERT INTO crm_product (product_code, product_name, description, category_id, brand, model_number, manufacturer, uom_id, is_active, lead_time_days, warranty_months, specifications) VALUES
('CAT-320-NG', 'CAT 320 Next Gen Hydraulic Excavator', '42" bucket, standard tracks, AC cabin, rear camera', 1, 'Caterpillar', '320', 'Caterpillar Inc', 1, TRUE, 21, 24, '{"bucket_width": "42 inch", "track_type": "standard", "cabin": "AC", "camera": "rear"}'),
('CAT-325-HEX', 'CAT 325 Hydraulic Excavator', 'Heavy duty excavator with advanced hydraulics', 1, 'Caterpillar', '325', 'Caterpillar Inc', 1, TRUE, 28, 24, '{"operating_weight": "25000 kg"}'),
('CAT-336-NG', 'CAT 336 Next Gen Hydraulic Excavator', 'Standard bucket, 24" tracks, AC cabin', 1, 'Caterpillar', '336', 'Caterpillar Inc', 1, TRUE, 42, 24, '{"bucket_width": "48 inch"}'),
('KOM-PC210', 'Komatsu PC210 Excavator', 'Mid-size hydraulic excavator', 1, 'Komatsu', 'PC210', 'Komatsu Ltd', 1, TRUE, 28, 24, '{"engine_power": "155 hp"}'),
('KUB-KX040', 'Kubota KX040-4 Mini Excavator', 'Compact mini excavator', 7, 'Kubota', 'KX040-4', 'Kubota Corporation', 1, TRUE, 7, 24, '{"operating_weight": "4200 kg"}'),
('CAT-980M', 'CAT 980M Wheel Loader', 'Large wheel loader', 2, 'Caterpillar', '980M', 'Caterpillar Inc', 1, TRUE, 35, 24, '{"bucket_capacity": "6.5 m3"}'),
('KOM-WA380', 'Komatsu WA380-8 Wheel Loader', 'Medium wheel loader', 2, 'Komatsu', 'WA380-8', 'Komatsu Ltd', 1, TRUE, 42, 36, '{"bucket_capacity": "4.2 m3"}'),
('CAT-D5-LGP', 'CAT D5 LGP Bulldozer', 'Low ground pressure dozer', 3, 'Caterpillar', 'D5', 'Caterpillar Inc', 1, TRUE, 28, 24, '{"track_type": "LGP"}'),
('CAT-D6', 'CAT D6 Bulldozer', 'Medium track-type tractor', 3, 'Caterpillar', 'D6', 'Caterpillar Inc', 1, TRUE, 35, 24, '{"engine_power": "215 hp"}'),
('CAT-140M', 'CAT 140M Motor Grader', 'Road grader with snow plow capability', 4, 'Caterpillar', '140M', 'Caterpillar Inc', 1, TRUE, 42, 24, '{"blade_width": "14 ft"}'),
('VOL-A30G', 'Volvo A30G Articulated Hauler', 'Articulated dump truck', 5, 'Volvo', 'A30G', 'Volvo CE', 1, TRUE, 35, 24, '{"payload_capacity": "28 tonnes"}'),
('GRO-TMS9000', 'Grove TMS9000E Truck Crane', 'Truck mounted crane', 6, 'Grove', 'TMS9000E', 'Manitowoc Company', 1, TRUE, 56, 24, '{"max_capacity": "90 tonnes"}'),
('BOB-CTL', 'Bobcat Compact Track Loader', 'Compact track loader', 7, 'Bobcat', 'T770', 'Bobcat Company', 1, TRUE, 14, 24, '{"operating_capacity": "1500 kg"}'),
('ATT-SPLOW', 'Snow Plow Attachment', 'Heavy duty snow plow', 8, 'Various', 'SP-14', 'Various', 1, TRUE, 14, 12, '{"blade_width": "14 ft"}'),
('ATT-WING', 'Wing Kit', 'Wing attachment', 8, 'Various', 'WK-12', 'Various', 1, TRUE, 14, 12, '{"extension": "6 ft"}');

-- Product Pricing
INSERT INTO crm_product_pricing (product_id, currency_id, list_price, minimum_price, cost_price, margin_percent, effective_from, is_active)
SELECT 
    p.product_id,
    1,
    CASE 
        WHEN p.category_id = 1 THEN crm.random_decimal(250000, 500000, 2)
        WHEN p.category_id = 2 THEN crm.random_decimal(200000, 600000, 2)
        WHEN p.category_id = 3 THEN crm.random_decimal(280000, 450000, 2)
        WHEN p.category_id = 4 THEN crm.random_decimal(300000, 400000, 2)
        WHEN p.category_id = 5 THEN crm.random_decimal(400000, 600000, 2)
        WHEN p.category_id = 6 THEN crm.random_decimal(500000, 900000, 2)
        WHEN p.category_id = 7 THEN crm.random_decimal(40000, 80000, 2)
        ELSE crm.random_decimal(10000, 50000, 2)
    END,
    CASE 
        WHEN p.category_id = 1 THEN crm.random_decimal(220000, 450000, 2)
        WHEN p.category_id = 2 THEN crm.random_decimal(180000, 550000, 2)
        WHEN p.category_id = 3 THEN crm.random_decimal(250000, 400000, 2)
        WHEN p.category_id = 4 THEN crm.random_decimal(270000, 360000, 2)
        WHEN p.category_id = 5 THEN crm.random_decimal(360000, 540000, 2)
        WHEN p.category_id = 6 THEN crm.random_decimal(450000, 810000, 2)
        WHEN p.category_id = 7 THEN crm.random_decimal(35000, 70000, 2)
        ELSE crm.random_decimal(8000, 40000, 2)
    END,
    CASE 
        WHEN p.category_id = 1 THEN crm.random_decimal(180000, 380000, 2)
        WHEN p.category_id = 2 THEN crm.random_decimal(150000, 480000, 2)
        WHEN p.category_id = 3 THEN crm.random_decimal(200000, 340000, 2)
        WHEN p.category_id = 4 THEN crm.random_decimal(220000, 300000, 2)
        WHEN p.category_id = 5 THEN crm.random_decimal(300000, 450000, 2)
        WHEN p.category_id = 6 THEN crm.random_decimal(380000, 680000, 2)
        WHEN p.category_id = 7 THEN crm.random_decimal(28000, 56000, 2)
        ELSE crm.random_decimal(6000, 32000, 2)
    END,
    crm.random_decimal(15, 30, 2),
    CURRENT_DATE - INTERVAL '6 months',
    TRUE
FROM crm_product p;

-- =====================================================================
-- QUOTATION DATA (Based on MockMailConversations.md Conversations 11-30)
-- =====================================================================

INSERT INTO crm_quotation (quote_number, quote_name, customer_id, contact_id, opportunity_id, status_id, owner_id, quote_date, valid_until, currency_id, subtotal, total_amount, estimated_delivery_days, payment_terms, notes, created_at) VALUES
-- From Conversations 11-20 (No Deal)
('Q-2025-1101', 'CAT 336 Excavator Quote', 11, 11, NULL, 10, 1, '2025-11-26', '2025-12-26', 1, 425000.00, 425000.00, 42, 'Net 30', 'Quote sent - customer went silent', '2025-11-26 10:00:00'),
('Q-2025-1102', 'Wheel Loader Quote', 12, 12, NULL, 9, 4, '2025-11-27', '2025-12-27', 1, 175000.00, 175000.00, 28, 'Net 30', 'Price too high - lost to competitor at $145K', '2025-11-27 10:00:00'),
('Q-2025-1103', 'Bulldozer D6 Quote', 14, 14, NULL, 10, 3, '2025-10-30', '2025-11-30', 1, 380000.00, 380000.00, 35, 'Net 30', 'Quote expired - customer internal delays', '2025-10-30 10:00:00'),
('Q-2025-1104', 'Crane Package Quote Rev.4', 15, 15, NULL, 1, 2, '2025-12-02', '2026-01-02', 1, 485000.00, 485000.00, 56, 'Net 45', 'Multiple revisions - still no decision', '2025-12-02 09:00:00'),
('Q-2025-1105', 'Excavator Fleet Quote', 9, 9, NULL, 9, 1, '2025-12-03', '2026-01-03', 1, 900000.00, 900000.00, 28, 'Financing', 'Financing fell through', '2025-12-03 10:00:00'),
-- From Conversations 21-30 (Successful)
('Q-2025-1201', 'CAT 320 Excavator', 1, 1, 1, 8, 3, '2025-12-10', '2026-01-10', 1, 288000.00, 288000.00, 28, 'Net 30', 'Negotiated from $295K to $288K with free delivery', '2025-12-10 09:00:00'),
('Q-2025-1202', 'Wheel Loader Fleet (3 Units)', 2, 2, 2, 8, 2, '2025-12-11', '2026-01-11', 1, 781000.00, 781000.00, 56, 'Net 45', 'Fleet order with 8% discount', '2025-12-11 11:00:00'),
('Q-2025-1203', 'Mini Excavator - URGENT', 3, 3, 3, 8, 1, '2025-12-14', '2025-12-21', 1, 52000.00, 52000.00, 3, 'Wire Transfer', 'Rush order - IN STOCK', '2025-12-14 08:00:00'),
('Q-2025-1204', 'Bulldozer with Trade-In', 4, 4, 4, 8, 4, '2025-12-15', '2026-01-15', 1, 280000.00, 280000.00, 28, 'Net 30', 'Trade-in value $100K for 2018 D4K2', '2025-12-15 10:30:00'),
('Q-2025-1205', 'Articulated Dump Truck', 5, 5, 5, 8, 3, '2025-12-17', '2026-01-17', 1, 485000.00, 485000.00, 35, 'Financing 60mo', '5.99% APR approved', '2025-12-17 11:00:00'),
('Q-2025-1206', 'Road Maintenance Equipment', 6, 6, 6, 8, 2, '2025-12-20', '2026-01-20', 1, 375500.00, 375500.00, 56, 'Net 60', 'Government contract - GSA pricing', '2025-12-20 09:30:00'),
('Q-2025-1207', 'CAT 320 - Repeat Customer', 7, 7, 7, 8, 1, '2025-12-23', '2026-01-23', 1, 280000.00, 280000.00, 28, 'Net 30', 'Repeat customer discount $15K', '2025-12-23 11:30:00'),
('Q-2025-1208', 'Custom Spec Wheel Loader', 8, 8, 8, 5, 4, '2025-12-26', '2026-01-26', 1, 485000.00, 485000.00, 84, 'Net 30', 'Factory order - custom build', '2025-12-26 09:00:00'),
('Q-2025-1209', 'Emergency Replacement', 9, 9, 9, 8, 3, '2025-12-28', '2025-12-31', 1, 315000.00, 315000.00, 2, 'Insurance', 'Fire damage replacement - $20K emergency discount', '2025-12-28 07:30:00'),
('Q-2025-1210', 'National Fleet Order', 10, 10, 10, 5, 2, '2025-12-29', '2026-01-29', 1, 2369000.00, 2369000.00, 90, 'Net 45', '8 units - 8% fleet discount - multi-location', '2025-12-29 10:00:00');

-- Generate additional quotes
INSERT INTO crm_quotation (quote_number, quote_name, customer_id, status_id, owner_id, quote_date, valid_until, currency_id, subtotal, total_amount, estimated_delivery_days, created_at)
SELECT 
    'Q-2025-' || LPAD((1210 + row_number() OVER ())::TEXT, 4, '0'),
    c.customer_name || ' - Equipment Quote',
    c.customer_id,
    crm.random_between(1, 10),
    crm.random_between(1, 8),
    CURRENT_DATE - (crm.random_between(1, 120) || ' days')::INTERVAL,
    CURRENT_DATE + (crm.random_between(7, 60) || ' days')::INTERVAL,
    1,
    crm.random_decimal(50000, 500000, 2),
    crm.random_decimal(50000, 500000, 2),
    crm.random_between(7, 90),
    CURRENT_TIMESTAMP - (crm.random_between(1, 120) || ' days')::INTERVAL
FROM crm_customer c
WHERE random() < 0.8;

-- Quote Line Items for specific quotes
INSERT INTO crm_quote_line_item (quote_id, line_number, product_id, product_name, quantity, unit_price, line_total) VALUES
(6, 1, 1, 'CAT 320 Next Gen Hydraulic Excavator', 1, 288000.00, 288000.00),
(7, 1, 7, 'Komatsu WA380-8 Wheel Loader', 3, 265000.00, 795000.00),
(7, 2, NULL, 'Extended Warranty (5 years)', 3, 12000.00, 36000.00),
(8, 1, 5, 'Kubota KX040-4 Mini Excavator', 1, 52000.00, 52000.00),
(9, 1, 8, 'CAT D5 LGP Bulldozer', 1, 380000.00, 380000.00),
(10, 1, 11, 'Volvo A30G Articulated Hauler', 1, 485000.00, 485000.00),
(11, 1, 10, 'CAT 140M Motor Grader', 1, 345000.00, 345000.00),
(11, 2, 14, 'Snow Plow Attachment', 1, 18500.00, 18500.00),
(11, 3, 15, 'Wing Kit', 1, 12000.00, 12000.00),
(12, 1, 1, 'CAT 320 Next Gen Hydraulic Excavator', 1, 280000.00, 280000.00),
(13, 1, 6, 'CAT 980M Wheel Loader - Custom', 1, 485000.00, 485000.00),
(14, 1, 2, 'CAT 325 Hydraulic Excavator', 1, 315000.00, 315000.00),
(15, 1, 1, 'CAT 320 Excavator - Dallas', 2, 290000.00, 580000.00),
(15, 2, 1, 'CAT 320 Excavator - Phoenix', 1, 290000.00, 290000.00),
(15, 3, 9, 'CAT D6 Bulldozer - Denver', 2, 365000.00, 730000.00),
(15, 4, 6, 'CAT 980M Wheel Loader - Seattle', 1, 395000.00, 395000.00),
(15, 5, 1, 'CAT 320 Excavator - Atlanta', 2, 290000.00, 580000.00);

-- =====================================================================
-- EMAIL THREAD DATA (Based on MockMailConversations.md)
-- =====================================================================

INSERT INTO crm_email_thread (thread_subject, reference_type, reference_id, customer_id, contact_id, assigned_to_id, status, message_count, first_message_at, last_message_at) VALUES
('Inquiry about CAT 320 Excavator', 'LEAD', 1, 11, 11, 1, 'CLOSED', 1, '2025-11-15 09:30:00', '2025-11-15 09:30:00'),
('Looking for Used Wheel Loaders', 'LEAD', 2, 12, 12, 2, 'CLOSED', 3, '2025-11-16 14:15:00', '2025-11-17 10:00:00'),
('Heavy Equipment Requirements for Mining Project', 'LEAD', 3, 13, 13, 3, 'CLOSED', 1, '2025-11-18 11:20:00', '2025-11-18 11:20:00'),
('Quotation #Q-2025-1201 - CAT 320 Excavator', 'QUOTATION', 6, 1, 1, 3, 'CLOSED', 5, '2025-12-10 09:00:00', '2025-12-11 10:00:00'),
('Quotation #Q-2025-1202 - Wheel Loader Fleet', 'QUOTATION', 7, 2, 2, 2, 'CLOSED', 4, '2025-12-11 11:00:00', '2025-12-13 09:00:00'),
('URGENT: Quotation #Q-2025-1203 - Mini Excavator', 'QUOTATION', 8, 3, 3, 1, 'CLOSED', 2, '2025-12-14 08:00:00', '2025-12-14 08:45:00'),
('Quotation #Q-2025-1210 - National Fleet Order', 'QUOTATION', 15, 10, 10, 2, 'OPEN', 3, '2025-12-29 10:00:00', '2025-12-30 09:00:00');

-- Email Messages
INSERT INTO crm_email_message (thread_id, direction, from_email, from_name, to_emails, subject, body_text, sent_at, is_read) VALUES
(1, 'INBOUND', 'john.martinez@constructionpro.com', 'John Martinez', ARRAY['sarah.johnson@heavyequipdealer.com'], 'Inquiry about CAT 320 Excavator', 'Hi, I saw your advertisement for heavy equipment and I''m interested in learning more about CAT 320 excavators for our upcoming highway project. Could you send me some information? Thanks, John Martinez', '2025-11-15 09:30:00', TRUE),
(2, 'INBOUND', 'maria.garcia@smallcontractors.com', 'Maria Garcia', ARRAY['mike.thompson@heavyequipdealer.com'], 'Looking for Used Wheel Loaders', 'Hello Mike, We''re a small contracting company looking for used wheel loaders. Our budget is around $25,000. Do you have anything in that range?', '2025-11-16 14:15:00', TRUE),
(2, 'OUTBOUND', 'mike.thompson@heavyequipdealer.com', 'Mike Thompson', ARRAY['maria.garcia@smallcontractors.com'], 'RE: Looking for Used Wheel Loaders', 'Hi Maria, Thank you for reaching out! Unfortunately, our used wheel loaders start at $45,000. I''d be happy to discuss financing options if you''re interested.', '2025-11-16 16:45:00', TRUE),
(2, 'INBOUND', 'maria.garcia@smallcontractors.com', 'Maria Garcia', ARRAY['mike.thompson@heavyequipdealer.com'], 'RE: Looking for Used Wheel Loaders', 'Hi Mike, Thanks for the information, but that''s outside our budget at this time. We''ll keep you in mind for future needs.', '2025-11-17 10:00:00', TRUE),
(4, 'OUTBOUND', 'lisa.anderson@heavyequipdealer.com', 'Lisa Anderson', ARRAY['m.thompson@thompsonexcavating.com'], 'Quotation #Q-2025-1201 - CAT 320 Excavator', 'Dear Mr. Thompson, Thank you for your interest in the CAT 320 Excavator. Please find attached Quotation #Q-2025-1201. Price: $295,000. Delivery: 3-4 weeks.', '2025-12-10 09:00:00', TRUE),
(4, 'INBOUND', 'm.thompson@thompsonexcavating.com', 'Mark Thompson', ARRAY['lisa.anderson@heavyequipdealer.com'], 'RE: Quotation #Q-2025-1201', 'Lisa, The quote looks good. Can you do $285,000 with the same terms? If so, we have a deal.', '2025-12-10 14:30:00', TRUE),
(4, 'OUTBOUND', 'lisa.anderson@heavyequipdealer.com', 'Lisa Anderson', ARRAY['m.thompson@thompsonexcavating.com'], 'RE: Quotation #Q-2025-1201', 'Mark, I''ve discussed with my manager and we can offer $288,000 as our best price. This includes free delivery and operator training. Deal?', '2025-12-10 16:00:00', TRUE),
(4, 'INBOUND', 'm.thompson@thompsonexcavating.com', 'Mark Thompson', ARRAY['lisa.anderson@heavyequipdealer.com'], 'RE: Quotation #Q-2025-1201', 'Deal! Please send the purchase agreement. We''ll process the deposit this week.', '2025-12-10 16:30:00', TRUE);

-- =====================================================================
-- ACTIVITY AND TASK DATA
-- =====================================================================

INSERT INTO crm_activity (activity_type, subject, reference_type, reference_id, customer_id, owner_id, activity_date, duration_minutes, outcome, is_completed, completed_at)
SELECT 
    crm.random_element(ARRAY['CALL', 'EMAIL', 'MEETING', 'DEMO', 'SITE_VISIT']),
    'Follow-up with ' || c.customer_name,
    'CUSTOMER',
    c.customer_id,
    c.customer_id,
    crm.random_between(1, 8),
    CURRENT_DATE - (crm.random_between(1, 90) || ' days')::INTERVAL,
    crm.random_between(15, 120),
    crm.random_element(ARRAY['Successful', 'Follow-up needed', 'No answer', 'Scheduled next meeting']),
    (random() < 0.8),
    CASE WHEN random() < 0.8 THEN CURRENT_TIMESTAMP - (crm.random_between(1, 90) || ' days')::INTERVAL ELSE NULL END
FROM crm_customer c
WHERE random() < 0.6;

-- Tasks
INSERT INTO crm_task (task_name, reference_type, reference_id, customer_id, assigned_to_id, priority, status, due_date)
SELECT 
    crm.random_element(ARRAY['Follow up on quote', 'Send product info', 'Schedule demo', 'Prepare proposal', 'Review requirements']),
    'CUSTOMER',
    c.customer_id,
    c.customer_id,
    crm.random_between(1, 8),
    crm.random_element(ARRAY['HIGH', 'NORMAL', 'LOW']),
    crm.random_element(ARRAY['NOT_STARTED', 'IN_PROGRESS', 'COMPLETED', 'DEFERRED']),
    CURRENT_DATE + (crm.random_between(-30, 30) || ' days')::INTERVAL
FROM crm_customer c
WHERE random() < 0.5;

-- =====================================================================
-- AI/ML AND ANALYTICS DATA
-- =====================================================================

-- AI Recommendation Log
INSERT INTO crm_ai_recommendation_log (recommendation_type, reference_type, reference_id, customer_id, confidence_score, was_accepted, model_version, created_at)
SELECT 
    crm.random_element(ARRAY['PRICING', 'PRODUCT', 'DISCOUNT', 'TIMELINE']),
    'QUOTATION',
    q.quote_id,
    q.customer_id,
    crm.random_decimal(0.7, 0.98, 4),
    (random() < 0.75),
    'v1.0',
    q.created_at
FROM crm_quotation q
WHERE random() < 0.6;

-- Quote Analytics (Daily summary for last 90 days)
INSERT INTO crm_quote_analytics (analytics_date, sales_rep_id, quotes_created, quotes_sent, quotes_accepted, quotes_rejected, total_value_quoted, total_value_won, conversion_rate)
SELECT 
    d::DATE,
    sr.sales_rep_id,
    crm.random_between(1, 5),
    crm.random_between(1, 4),
    crm.random_between(0, 3),
    crm.random_between(0, 2),
    crm.random_decimal(100000, 1000000, 2),
    crm.random_decimal(50000, 500000, 2),
    crm.random_decimal(0.15, 0.45, 2)
FROM generate_series(CURRENT_DATE - INTERVAL '90 days', CURRENT_DATE, '1 day') d
CROSS JOIN crm_sales_rep sr
WHERE random() < 0.3
ON CONFLICT DO NOTHING;

-- CRM Users
INSERT INTO crm_user (username, email, first_name, last_name, sales_rep_id, role, is_active)
SELECT 
    LOWER(sr.first_name || '.' || sr.last_name),
    sr.email,
    sr.first_name,
    sr.last_name,
    sr.sales_rep_id,
    CASE WHEN sr.job_title LIKE '%Manager%' THEN 'SALES_MANAGER' ELSE 'SALES_REP' END,
    sr.is_active
FROM crm_sales_rep sr;

-- =====================================================================
-- DATA GENERATION SUMMARY
-- =====================================================================

DO $$
DECLARE
    customer_count INT;
    lead_count INT;
    opportunity_count INT;
    quote_count INT;
    product_count INT;
    email_count INT;
BEGIN
    SELECT COUNT(*) INTO customer_count FROM crm_customer;
    SELECT COUNT(*) INTO lead_count FROM crm_lead;
    SELECT COUNT(*) INTO opportunity_count FROM crm_opportunity;
    SELECT COUNT(*) INTO quote_count FROM crm_quotation;
    SELECT COUNT(*) INTO product_count FROM crm_product;
    SELECT COUNT(*) INTO email_count FROM crm_email_message;
    
    RAISE NOTICE 'CRM Mock Data Generation Complete:';
    RAISE NOTICE '  Customers: %', customer_count;
    RAISE NOTICE '  Leads: %', lead_count;
    RAISE NOTICE '  Opportunities: %', opportunity_count;
    RAISE NOTICE '  Quotations: %', quote_count;
    RAISE NOTICE '  Products: %', product_count;
    RAISE NOTICE '  Email Messages: %', email_count;
END $$;

-- =====================================================================
-- END OF CRM MOCK DATA
-- =====================================================================
