-- Sample Product Data for Testing
-- This script inserts sample heavy equipment products into the database

-- Insert sample product categories
INSERT INTO erp.erp_product_category (category_code, category_name, description) VALUES
('EXCAVATORS', 'Excavators', 'Hydraulic excavators and mini excavators'),
('LOADERS', 'Wheel Loaders', 'Wheel loaders and front loaders'),
('BULLDOZERS', 'Bulldozers', 'Track-type tractors and bulldozers'),
('CRANES', 'Cranes', 'Mobile and tower cranes')
ON CONFLICT (category_code) DO NOTHING;

-- Insert sample products
INSERT INTO erp.erp_product (product_code, product_name, description, category_id, brand, model_number, manufacturer, uom_id, lead_time_days) VALUES
(
    'CAT320-NG',
    'CAT 320 Next Gen Hydraulic Excavator',
    'CAT 320 Next Generation hydraulic excavator with advanced features',
    (SELECT category_id FROM erp.erp_product_category WHERE category_code = 'EXCAVATORS'),
    'Caterpillar',
    '320',
    'Caterpillar Inc.',
    (SELECT uom_id FROM erp.erp_unit_of_measure WHERE uom_code = 'EA'),
    30
),
(
    'KOM-WA380',
    'Komatsu WA380-8 Wheel Loader',
    'Komatsu WA380-8 wheel loader for quarry and construction operations',
    (SELECT category_id FROM erp.erp_product_category WHERE category_code = 'LOADERS'),
    'Komatsu',
    'WA380-8',
    'Komatsu Ltd.',
    (SELECT uom_id FROM erp.erp_unit_of_measure WHERE uom_code = 'EA'),
    45
),
(
    'KUB-KX040',
    'Kubota KX040-4 Mini Excavator',
    'Kubota KX040-4 compact mini excavator for landscaping and small projects',
    (SELECT category_id FROM erp.erp_product_category WHERE category_code = 'EXCAVATORS'),
    'Kubota',
    'KX040-4',
    'Kubota Corporation',
    (SELECT uom_id FROM erp.erp_unit_of_measure WHERE uom_code = 'EA'),
    15
),
(
    'CAT-D6',
    'CAT D6 LGP Bulldozer',
    'CAT D6 Low Ground Pressure bulldozer for grading and earthmoving',
    (SELECT category_id FROM erp.erp_product_category WHERE category_code = 'BULLDOZERS'),
    'Caterpillar',
    'D6 LGP',
    'Caterpillar Inc.',
    (SELECT uom_id FROM erp.erp_unit_of_measure WHERE uom_code = 'EA'),
    60
),
(
    'GENERIC-EQUIP',
    'Generic Heavy Equipment',
    'Generic equipment for fallback pricing',
    (SELECT category_id FROM erp.erp_product_category WHERE category_code = 'EXCAVATORS'),
    'Generic',
    'GEN-001',
    'Generic Manufacturer',
    (SELECT uom_id FROM erp.erp_unit_of_measure WHERE uom_code = 'EA'),
    30
)
ON CONFLICT (product_code) DO NOTHING;

-- Insert sample pricing
INSERT INTO erp.erp_product_pricing (product_id, currency_id, unit_cost, list_price, effective_from, effective_to, is_active) VALUES
(
    (SELECT product_id FROM erp.erp_product WHERE product_code = 'CAT320-NG'),
    (SELECT currency_id FROM erp.erp_currency WHERE currency_code = 'USD'),
    280000.00,
    295000.00,
    '2024-01-01',
    '2025-12-31',
    true
),
(
    (SELECT product_id FROM erp.erp_product WHERE product_code = 'KOM-WA380'),
    (SELECT currency_id FROM erp.erp_currency WHERE currency_code = 'USD'),
    255000.00,
    265000.00,
    '2024-01-01',
    '2025-12-31',
    true
),
(
    (SELECT product_id FROM erp.erp_product WHERE product_code = 'KUB-KX040'),
    (SELECT currency_id FROM erp.erp_currency WHERE currency_code = 'USD'),
    50000.00,
    52000.00,
    '2024-01-01',
    '2025-12-31',
    true
),
(
    (SELECT product_id FROM erp.erp_product WHERE product_code = 'CAT-D6'),
    (SELECT currency_id FROM erp.erp_currency WHERE currency_code = 'USD'),
    365000.00,
    380000.00,
    '2024-01-01',
    '2025-12-31',
    true
),
(
    (SELECT product_id FROM erp.erp_product WHERE product_code = 'GENERIC-EQUIP'),
    (SELECT currency_id FROM erp.erp_currency WHERE currency_code = 'USD'),
    100000.00,
    110000.00,
    '2024-01-01',
    '2025-12-31',
    true
)
ON CONFLICT DO NOTHING;

-- Verify data
SELECT 
    p.product_code,
    p.product_name,
    pp.unit_cost,
    pp.list_price,
    c.currency_code
FROM erp.erp_product p
JOIN erp.erp_product_pricing pp ON p.product_id = pp.product_id
JOIN erp.erp_currency c ON pp.currency_id = c.currency_id
WHERE p.product_code IN ('CAT320-NG', 'KOM-WA380', 'KUB-KX040', 'CAT-D6', 'GENERIC-EQUIP')
AND pp.is_active = true;
