-- ============================================================================
-- Fontainebleau Las Vegas Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic sample data for luxury hotel operations
-- Volume: ~50K guests, 100K reservations, 200K dining orders, 50K spa appointments
-- Syntax: Verified against Snowflake SQL Reference
-- ============================================================================

USE DATABASE FONTAINEBLEAU_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE FONTAINEBLEAU_WH;

-- ============================================================================
-- Step 1: Generate Room Types
-- ============================================================================
INSERT INTO ROOM_TYPES VALUES
('RT001', 'Deluxe King', 'STANDARD', 399.00, 2, 450, 'CITY', 'King bed, marble bathroom, 55" TV, minibar', 'KING', '5-20', FALSE, FALSE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('RT002', 'Deluxe Double Queen', 'STANDARD', 399.00, 4, 475, 'CITY', 'Two queen beds, marble bathroom, 55" TV, minibar', 'DOUBLE_QUEEN', '5-20', FALSE, FALSE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('RT003', 'Premium King', 'PREMIUM', 499.00, 2, 500, 'STRIP', 'King bed, Strip view, marble bathroom, 65" TV', 'KING', '21-40', FALSE, FALSE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('RT004', 'Premium Double Queen', 'PREMIUM', 499.00, 4, 525, 'STRIP', 'Two queen beds, Strip view, marble bathroom', 'DOUBLE_QUEEN', '21-40', FALSE, FALSE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('RT005', 'Junior Suite', 'SUITE', 699.00, 3, 750, 'STRIP', 'Living area, king bed, Strip view, wet bar', 'KING', '25-40', TRUE, FALSE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('RT006', 'Executive Suite', 'SUITE', 999.00, 4, 1100, 'STRIP', 'Separate living room, dining area, king bed, panoramic Strip view', 'KING', '30-50', TRUE, FALSE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('RT007', 'Penthouse Suite', 'LUXURY', 2499.00, 4, 2200, 'PANORAMIC', 'Two-story, private terrace, butler service, premium amenities', 'KING', '60-67', TRUE, FALSE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('RT008', 'Villa', 'LUXURY', 4999.00, 6, 4500, 'PANORAMIC', 'Private pool, multiple bedrooms, full kitchen, 24-hour butler', 'MULTIPLE', '65-67', TRUE, FALSE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('RT009', 'Accessible King', 'ACCESSIBLE', 399.00, 2, 500, 'CITY', 'ADA compliant, roll-in shower, accessible features', 'KING', '5-10', FALSE, TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('RT010', 'Accessible Double Queen', 'ACCESSIBLE', 399.00, 4, 525, 'CITY', 'ADA compliant, roll-in shower, two queen beds', 'DOUBLE_QUEEN', '5-10', FALSE, TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('RT011', 'Fountain View King', 'PREMIUM', 549.00, 2, 500, 'FOUNTAIN', 'King bed, fountain view, upgraded amenities', 'KING', '10-25', FALSE, FALSE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('RT012', 'Pool Cabana Suite', 'SUITE', 899.00, 4, 900, 'POOL', 'Direct pool access, private cabana, living area', 'KING', '3-5', TRUE, FALSE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 2: Generate Rooms
-- ============================================================================
INSERT INTO ROOMS
SELECT
    'ROOM' || LPAD(SEQ4(), 6, '0') AS room_id,
    LPAD(FLOOR(SEQ4() / 50) + 5, 2, '0') || LPAD(MOD(SEQ4(), 50) + 1, 2, '0') AS room_number,
    rt.room_type_id,
    FLOOR(SEQ4() / 50) + 5 AS floor_number,
    CASE WHEN FLOOR(SEQ4() / 50) + 5 <= 35 THEN 'BLEU TOWER' ELSE 'BLANC TOWER' END AS tower,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'AVAILABLE' 
         WHEN UNIFORM(0, 100, RANDOM()) < 3 THEN 'MAINTENANCE'
         ELSE 'OUT_OF_ORDER' END AS room_status,
    ARRAY_CONSTRUCT('CLEAN', 'DIRTY', 'INSPECTED', 'IN_PROGRESS')[UNIFORM(0, 3, RANDOM())] AS housekeeping_status,
    'OPERATIONAL' AS maintenance_status,
    DATEADD('hour', -1 * UNIFORM(1, 48, RANDOM()), CURRENT_TIMESTAMP()) AS last_cleaned,
    DATEADD('hour', -1 * UNIFORM(1, 24, RANDOM()), CURRENT_TIMESTAMP()) AS last_inspected,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 3600))
CROSS JOIN (SELECT room_type_id FROM ROOM_TYPES ORDER BY RANDOM() LIMIT 1) rt;

-- Fix room type distribution to be realistic
UPDATE ROOMS
SET room_type_id = CASE 
    WHEN UNIFORM(0, 100, RANDOM()) < 35 THEN 'RT001'  -- 35% Deluxe King
    WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'RT002'  -- 30% Deluxe Double Queen
    WHEN UNIFORM(0, 100, RANDOM()) < 12 THEN 'RT003'  -- 12% Premium King
    WHEN UNIFORM(0, 100, RANDOM()) < 8 THEN 'RT004'   -- 8% Premium Double Queen
    WHEN UNIFORM(0, 100, RANDOM()) < 6 THEN 'RT005'   -- 6% Junior Suite
    WHEN UNIFORM(0, 100, RANDOM()) < 4 THEN 'RT006'   -- 4% Executive Suite
    WHEN UNIFORM(0, 100, RANDOM()) < 2 THEN 'RT007'   -- 2% Penthouse
    WHEN UNIFORM(0, 100, RANDOM()) < 1 THEN 'RT008'   -- 1% Villa
    WHEN UNIFORM(0, 100, RANDOM()) < 1 THEN 'RT009'   -- 1% Accessible
    ELSE 'RT011' END;                                  -- Remaining: Fountain View

-- ============================================================================
-- Step 3: Generate Guests
-- ============================================================================
INSERT INTO GUESTS
SELECT
    'GUEST' || LPAD(SEQ4(), 8, '0') AS guest_id,
    ARRAY_CONSTRUCT('James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Charles',
                    'Mary', 'Patricia', 'Jennifer', 'Linda', 'Barbara', 'Elizabeth', 'Susan', 'Jessica', 'Sarah', 'Karen',
                    'Christopher', 'Daniel', 'Matthew', 'Anthony', 'Mark', 'Donald', 'Steven', 'Paul', 'Andrew', 'Joshua',
                    'Nancy', 'Betty', 'Margaret', 'Sandra', 'Ashley', 'Kimberly', 'Emily', 'Donna', 'Michelle', 'Dorothy',
                    'Alexander', 'Benjamin', 'Nicholas', 'Tyler', 'Brandon', 'Jacob', 'Ethan', 'Noah', 'Mason', 'Lucas',
                    'Sophia', 'Isabella', 'Olivia', 'Ava', 'Mia', 'Emma', 'Charlotte', 'Amelia', 'Harper', 'Evelyn')[UNIFORM(0, 59, RANDOM())] AS first_name,
    ARRAY_CONSTRUCT('Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
                    'Wilson', 'Anderson', 'Taylor', 'Thomas', 'Moore', 'Jackson', 'Martin', 'Lee', 'Thompson', 'White',
                    'Harris', 'Clark', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Lopez',
                    'Hill', 'Scott', 'Green', 'Adams', 'Baker', 'Gonzalez', 'Nelson', 'Carter', 'Mitchell', 'Perez',
                    'Chen', 'Wang', 'Kim', 'Patel', 'Singh', 'Cohen', 'Nakamura', 'Santos', 'Nguyen', 'OBrien')[UNIFORM(0, 49, RANDOM())] AS last_name,
    'guest' || SEQ4() || '@' || ARRAY_CONSTRUCT('gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'icloud.com', 'aol.com')[UNIFORM(0, 5, RANDOM())] AS email,
    CONCAT('+1-', LPAD(UNIFORM(200, 999, RANDOM()), 3, '0'), '-', LPAD(UNIFORM(100, 999, RANDOM()), 3, '0'), '-', LPAD(UNIFORM(1000, 9999, RANDOM()), 4, '0')) AS phone,
    DATEADD('year', -1 * UNIFORM(21, 80, RANDOM()), CURRENT_DATE()) AS date_of_birth,
    UNIFORM(100, 9999, RANDOM()) || ' ' || ARRAY_CONSTRUCT('Main St', 'Oak Ave', 'Park Blvd', 'Cedar Ln', 'Maple Dr', 'Elm St', 'Pine Rd', 'Lake Dr')[UNIFORM(0, 7, RANDOM())] AS address_line1,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'Apt ' || UNIFORM(1, 500, RANDOM()) ELSE NULL END AS address_line2,
    ARRAY_CONSTRUCT('Los Angeles', 'New York', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego',
                    'Dallas', 'San Jose', 'Austin', 'Seattle', 'Denver', 'Boston', 'Miami', 'San Francisco',
                    'Atlanta', 'Las Vegas', 'Portland', 'Detroit', 'Minneapolis', 'Tampa', 'Orlando', 'Charlotte',
                    'Toronto', 'Vancouver', 'London', 'Paris', 'Tokyo', 'Sydney', 'Dubai', 'Singapore')[UNIFORM(0, 31, RANDOM())] AS city,
    ARRAY_CONSTRUCT('CA', 'NY', 'TX', 'FL', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI', 'NJ', 'VA', 'WA', 'AZ', 'MA', 
                    'TN', 'IN', 'MO', 'MD', 'WI', 'CO', 'MN', 'SC', 'AL', 'LA', 'NV', 'OR', 'OK', 'CT', 'UT')[UNIFORM(0, 29, RANDOM())] AS state,
    LPAD(UNIFORM(10001, 99999, RANDOM()), 5, '0') AS postal_code,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'USA'
         WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN 'CANADA'
         WHEN UNIFORM(0, 100, RANDOM()) < 3 THEN 'UK'
         WHEN UNIFORM(0, 100, RANDOM()) < 2 THEN 'JAPAN'
         WHEN UNIFORM(0, 100, RANDOM()) < 2 THEN 'AUSTRALIA'
         ELSE ARRAY_CONSTRUCT('GERMANY', 'FRANCE', 'CHINA', 'UAE', 'SINGAPORE', 'MEXICO')[UNIFORM(0, 5, RANDOM())] END AS country,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'LEISURE'
         WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN 'BUSINESS'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'GAMING'
         ELSE 'GROUP' END AS guest_type,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 50 THEN 'MEMBER'
         WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'SILVER'
         WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN 'GOLD'
         ELSE 'PLATINUM' END AS loyalty_tier,
    'FBL' || LPAD(SEQ4(), 10, '0') AS loyalty_number,
    UNIFORM(1, 50, RANDOM()) AS total_stays,
    (UNIFORM(500, 50000, RANDOM()) * 1.0)::NUMBER(12,2) AS total_spend,
    (UNIFORM(1000, 100000, RANDOM()) * 1.0)::NUMBER(12,2) AS lifetime_value,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN
        ARRAY_CONSTRUCT('High floor', 'Pool view', 'Quiet room', 'Late checkout', 'Early checkin', 'Pillow menu', 'Hypoallergenic')[UNIFORM(0, 6, RANDOM())]
    ELSE NULL END AS preferences,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN
        ARRAY_CONSTRUCT('Vegetarian', 'Vegan', 'Gluten-free', 'Nut allergy', 'Shellfish allergy', 'Kosher', 'Halal')[UNIFORM(0, 6, RANDOM())]
    ELSE NULL END AS dietary_restrictions,
    NULL AS special_requests,
    UNIFORM(0, 100, RANDOM()) < 5 AS vip_status,
    'ACTIVE' AS guest_status,
    DATEADD('day', -1 * UNIFORM(30, 1825, RANDOM()), CURRENT_DATE()) AS first_visit_date,
    DATEADD('day', -1 * UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS last_visit_date,
    DATEADD('day', -1 * UNIFORM(30, 1825, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 50000));

-- ============================================================================
-- Step 4: Generate Loyalty Program Records
-- ============================================================================
INSERT INTO LOYALTY_PROGRAM
SELECT
    'LOY' || LPAD(ROW_NUMBER() OVER (ORDER BY g.guest_id), 10, '0') AS loyalty_id,
    g.guest_id,
    g.loyalty_number,
    g.loyalty_tier AS current_tier,
    UNIFORM(0, 500000, RANDOM()) AS points_balance,
    UNIFORM(0, 100000, RANDOM()) AS points_earned_ytd,
    UNIFORM(0, 50000, RANDOM()) AS points_redeemed_ytd,
    DATEADD('day', -1 * UNIFORM(30, 730, RANDOM()), CURRENT_DATE()) AS tier_qualification_date,
    DATEADD('month', 12, DATEADD('day', -1 * UNIFORM(30, 730, RANDOM()), CURRENT_DATE())) AS tier_expiration_date,
    UNIFORM(0, 1000000, RANDOM()) AS lifetime_points,
    (UNIFORM(0, 5000, RANDOM()) * 1.0)::NUMBER(10,2) AS comp_dollars_balance,
    UNIFORM(0, 10, RANDOM()) AS free_night_credits,
    g.first_visit_date AS enrollment_date,
    ARRAY_CONSTRUCT('WEBSITE', 'FRONT_DESK', 'MOBILE_APP', 'GAMING_FLOOR')[UNIFORM(0, 3, RANDOM())] AS enrollment_channel,
    'ACTIVE' AS program_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM GUESTS g
WHERE UNIFORM(0, 100, RANDOM()) < 80;

-- ============================================================================
-- Step 5: Generate Reservations
-- ============================================================================
INSERT INTO RESERVATIONS
SELECT
    'RES' || LPAD(ROW_NUMBER() OVER (ORDER BY g.guest_id, dates.check_in), 10, '0') AS reservation_id,
    g.guest_id,
    r.room_id,
    rt.room_type_id,
    'FB' || LPAD(UNIFORM(100000, 999999, RANDOM()), 6, '0') || UPPER(SUBSTR(MD5(RANDOM()), 1, 3)) AS confirmation_number,
    check_in AS check_in_date,
    DATEADD('day', nights_val, check_in) AS check_out_date,
    nights_val AS nights,
    UNIFORM(1, 4, RANDOM()) AS adults,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN UNIFORM(1, 3, RANDOM()) ELSE 0 END AS children,
    ARRAY_CONSTRUCT('RACK', 'AAA', 'CORP', 'PROMO', 'PKG', 'COMP', 'LOYALTY')[UNIFORM(0, 6, RANDOM())] AS rate_code,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'BAR'
         WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'ADVANCE_PURCHASE'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'PACKAGE'
         ELSE 'NEGOTIATED' END AS rate_type,
    (rt.base_rate * (1 + (UNIFORM(-20, 50, RANDOM()) / 100.0)))::NUMBER(10,2) AS room_rate,
    (rt.base_rate * nights_val * (1 + (UNIFORM(-20, 50, RANDOM()) / 100.0)))::NUMBER(12,2) AS total_room_revenue,
    CASE WHEN check_in > CURRENT_DATE() THEN 'CONFIRMED'
         WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'CHECKED_OUT'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'CANCELLED'
         ELSE 'NO_SHOW' END AS reservation_status,
    ARRAY_CONSTRUCT('WEBSITE', 'OTA', 'PHONE', 'MOBILE_APP', 'WALK_IN', 'GROUP', 'TRAVEL_AGENT')[UNIFORM(0, 6, RANDOM())] AS booking_source,
    ARRAY_CONSTRUCT('DIRECT', 'EXPEDIA', 'BOOKING.COM', 'HOTELS.COM', 'KAYAK', 'PRICELINE')[UNIFORM(0, 5, RANDOM())] AS booking_channel,
    DATEADD('day', -1 * UNIFORM(1, 180, RANDOM()), check_in) AS booking_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN DATEADD('day', -1 * UNIFORM(1, 30, RANDOM()), check_in) ELSE NULL END AS cancellation_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN ARRAY_CONSTRUCT('Change of plans', 'Found better rate', 'Travel restrictions', 'Health reasons', 'Work conflict')[UNIFORM(0, 4, RANDOM())] ELSE NULL END AS cancellation_reason,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN ARRAY_CONSTRUCT('Late checkout', 'High floor', 'Quiet room', 'Crib needed', 'Rollaway bed')[UNIFORM(0, 4, RANDOM())] ELSE NULL END AS special_requests,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN TO_TIME(LPAD(UNIFORM(14, 22, RANDOM()), 2, '0') || ':' || LPAD(UNIFORM(0, 59, RANDOM()), 2, '0') || ':00') ELSE NULL END AS arrival_time,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN TO_TIME(LPAD(UNIFORM(6, 12, RANDOM()), 2, '0') || ':' || LPAD(UNIFORM(0, 59, RANDOM()), 2, '0') || ':00') ELSE NULL END AS departure_time,
    UNIFORM(0, 100, RANDOM()) < 15 AS is_group_booking,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN 'GRP' || LPAD(UNIFORM(1, 1000, RANDOM()), 5, '0') ELSE NULL END AS group_id,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'LEISURE'
         WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN 'BUSINESS'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'GAMING'
         ELSE 'EVENT' END AS travel_purpose,
    ARRAY_CONSTRUCT('CREDIT_CARD', 'DEBIT_CARD', 'CASH', 'COMP', 'DIRECT_BILL')[UNIFORM(0, 4, RANDOM())] AS payment_method,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN (rt.base_rate * 1.0)::NUMBER(10,2) ELSE 0.00 END AS deposit_amount,
    DATEADD('day', -1 * UNIFORM(1, 180, RANDOM()), check_in) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM GUESTS g
CROSS JOIN (
    SELECT 
        DATEADD('day', -1 * UNIFORM(0, 730, RANDOM()), CURRENT_DATE()) AS check_in,
        UNIFORM(1, 7, RANDOM()) AS nights_val
    FROM TABLE(GENERATOR(ROWCOUNT => 2))
) dates
CROSS JOIN ROOM_TYPES rt
CROSS JOIN ROOMS r
WHERE g.guest_id IS NOT NULL
  AND UNIFORM(0, 100, RANDOM()) < 0.2
LIMIT 100000;

-- ============================================================================
-- Step 6: Generate Restaurants
-- ============================================================================
INSERT INTO RESTAURANTS VALUES
('REST001', 'Papi Steak', 'STEAKHOUSE', 'DINNER', 200, 'CASINO_FLOOR', 1, 'FORMAL', '$$$$$', 250.00, 0, 'David Grutman', '+1-702-555-0101', '5:00 PM - 11:00 PM', TRUE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST002', 'LIV Restaurant & Terrace', 'MEDITERRANEAN', 'ALL_DAY', 180, 'LOBBY', 1, 'SMART_CASUAL', '$$$$', 120.00, 0, 'Executive Chef Team', '+1-702-555-0102', '7:00 AM - 11:00 PM', TRUE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST003', 'Komodo Las Vegas', 'SOUTHEAST_ASIAN', 'DINNER', 300, 'CASINO_FLOOR', 1, 'SMART_CASUAL', '$$$$$', 180.00, 0, 'Chef de Cuisine', '+1-702-555-0103', '5:00 PM - 12:00 AM', TRUE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST004', 'La Petite Maison', 'FRENCH', 'LUNCH_DINNER', 120, 'PROMENADE', 2, 'FORMAL', '$$$$$', 200.00, 0, 'French Culinary Team', '+1-702-555-0104', '11:30 AM - 10:00 PM', TRUE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST005', 'Hakkasan', 'CANTONESE', 'DINNER', 250, 'CASINO_FLOOR', 1, 'SMART_CASUAL', '$$$$$', 175.00, 1, 'Michelin Chef', '+1-702-555-0105', '5:00 PM - 11:00 PM', TRUE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST006', 'Stripsteak', 'AMERICAN_STEAKHOUSE', 'DINNER', 180, 'POOL_LEVEL', 3, 'SMART_CASUAL', '$$$$', 150.00, 0, 'Michael Mina', '+1-702-555-0106', '5:00 PM - 10:00 PM', TRUE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST007', 'BLVD & Main Deli', 'DELI', 'ALL_DAY', 100, 'LOBBY', 1, 'CASUAL', '$$', 35.00, 0, 'Deli Team', '+1-702-555-0107', '6:00 AM - 2:00 AM', FALSE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST008', 'Oasis Pool & Dayclub', 'AMERICAN', 'DAY', 500, 'POOL', 3, 'RESORT_CASUAL', '$$$', 75.00, 0, 'Pool Dining Team', '+1-702-555-0108', '10:00 AM - 6:00 PM', FALSE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST009', 'Don''s Prime', 'STEAKHOUSE', 'DINNER', 150, 'CASINO_FLOOR', 1, 'FORMAL', '$$$$$', 275.00, 0, 'Prime Team', '+1-702-555-0109', '5:30 PM - 10:30 PM', TRUE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST010', 'Vida', 'MEXICAN', 'DINNER', 140, 'PROMENADE', 2, 'SMART_CASUAL', '$$$$', 95.00, 0, 'Mexican Cuisine Team', '+1-702-555-0110', '5:00 PM - 11:00 PM', TRUE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST011', 'Cafe Fontainebleau', 'CAFE', 'BREAKFAST_LUNCH', 80, 'LOBBY', 1, 'CASUAL', '$$', 25.00, 0, 'Cafe Team', '+1-702-555-0111', '6:00 AM - 4:00 PM', FALSE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST012', 'High Roller Lounge', 'BAR_LOUNGE', 'EVENING', 60, 'GAMING_FLOOR', 1, 'SMART_CASUAL', '$$$', 50.00, 0, 'Bar Team', '+1-702-555-0112', '4:00 PM - 2:00 AM', FALSE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST013', 'In-Room Dining', 'ROOM_SERVICE', 'ALL_DAY', 0, 'IN_ROOM', 0, 'NONE', '$$$', 65.00, 0, 'Room Service Team', '+1-702-555-0113', '24 Hours', FALSE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST014', 'LIV Nightclub', 'NIGHTCLUB', 'NIGHT', 1000, 'NIGHTLIFE', 1, 'UPSCALE', '$$$$', 100.00, 0, 'Nightlife Team', '+1-702-555-0114', '10:30 PM - 4:00 AM', TRUE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REST015', 'Bleau Bar', 'COCKTAIL_BAR', 'EVENING', 100, 'LOBBY', 1, 'SMART_CASUAL', '$$$', 45.00, 0, 'Bar Team', '+1-702-555-0115', '4:00 PM - 2:00 AM', FALSE, 'OPEN', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 7: Generate Menu Items
-- ============================================================================
INSERT INTO MENU_ITEMS
SELECT
    'MENU' || LPAD(ROW_NUMBER() OVER (ORDER BY r.restaurant_id), 8, '0') AS menu_item_id,
    r.restaurant_id,
    CASE 
        WHEN r.cuisine_type = 'STEAKHOUSE' THEN ARRAY_CONSTRUCT('Filet Mignon', 'NY Strip', 'Ribeye', 'Porterhouse', 'Wagyu A5', 'Bone-in Ribeye', 'Tomahawk', 'Surf and Turf')[UNIFORM(0, 7, RANDOM())]
        WHEN r.cuisine_type = 'FRENCH' THEN ARRAY_CONSTRUCT('Bouillabaisse', 'Coq au Vin', 'Duck Confit', 'Beef Bourguignon', 'Nicoise Salad', 'Escargot', 'Foie Gras', 'Creme Brulee')[UNIFORM(0, 7, RANDOM())]
        WHEN r.cuisine_type = 'CANTONESE' THEN ARRAY_CONSTRUCT('Peking Duck', 'Dim Sum Platter', 'Crispy Aromatic Duck', 'Lobster Noodles', 'Sweet and Sour Pork', 'Har Gow', 'Char Siu', 'Jasmine Tea Smoked Chicken')[UNIFORM(0, 7, RANDOM())]
        WHEN r.cuisine_type = 'SOUTHEAST_ASIAN' THEN ARRAY_CONSTRUCT('Pad Thai', 'Lemongrass Chicken', 'Miso Black Cod', 'Wagyu Tacos', 'Tuna Tartare', 'Crispy Rock Shrimp', 'Vietnamese Spring Rolls', 'Thai Basil Chicken')[UNIFORM(0, 7, RANDOM())]
        WHEN r.cuisine_type = 'MEXICAN' THEN ARRAY_CONSTRUCT('Carnitas Tacos', 'Carne Asada', 'Guacamole Tableside', 'Enchiladas', 'Birria Tacos', 'Elote', 'Churros', 'Margarita Flight')[UNIFORM(0, 7, RANDOM())]
        ELSE ARRAY_CONSTRUCT('Caesar Salad', 'Grilled Salmon', 'Chicken Sandwich', 'Burger', 'Pasta Primavera', 'Fish Tacos', 'Club Sandwich', 'French Fries')[UNIFORM(0, 7, RANDOM())]
    END AS item_name,
    'A delicious ' || LOWER(r.cuisine_type) || ' dish prepared with the finest ingredients' AS item_description,
    ARRAY_CONSTRUCT('APPETIZER', 'SALAD', 'ENTREE', 'SIDE', 'DESSERT', 'BEVERAGE')[UNIFORM(0, 5, RANDOM())] AS category,
    ARRAY_CONSTRUCT('HOT', 'COLD', 'SIGNATURE', 'SEASONAL')[UNIFORM(0, 3, RANDOM())] AS subcategory,
    (r.avg_check_amount * UNIFORM(20, 80, RANDOM()) / 100.0)::NUMBER(10,2) AS price,
    (r.avg_check_amount * UNIFORM(5, 25, RANDOM()) / 100.0)::NUMBER(10,2) AS cost,
    UNIFORM(0, 100, RANDOM()) < 15 AS is_signature,
    UNIFORM(0, 100, RANDOM()) < 10 AS is_seasonal,
    UNIFORM(0, 100, RANDOM()) < 20 AS is_vegetarian,
    UNIFORM(0, 100, RANDOM()) < 8 AS is_vegan,
    UNIFORM(0, 100, RANDOM()) < 15 AS is_gluten_free,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN ARRAY_CONSTRUCT('Nuts', 'Dairy', 'Shellfish', 'Gluten', 'Soy')[UNIFORM(0, 4, RANDOM())] ELSE NULL END AS allergens,
    UNIFORM(200, 1500, RANDOM()) AS calories,
    'AVAILABLE' AS item_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM RESTAURANTS r
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 40))
WHERE r.restaurant_id IS NOT NULL;

-- ============================================================================
-- Step 8: Generate Dining Orders
-- ============================================================================
INSERT INTO DINING_ORDERS
SELECT
    'ORD' || LPAD(ROW_NUMBER() OVER (ORDER BY g.guest_id, r.restaurant_id), 10, '0') AS order_id,
    NULL AS dining_reservation_id,
    g.guest_id,
    r.restaurant_id,
    res.reservation_id,
    DATEADD('hour', UNIFORM(0, 23, RANDOM()), DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP())) AS order_date,
    CASE WHEN r.meal_period = 'ALL_DAY' THEN ARRAY_CONSTRUCT('DINE_IN', 'TAKEOUT', 'DELIVERY')[UNIFORM(0, 2, RANDOM())]
         ELSE 'DINE_IN' END AS order_type,
    'T' || UNIFORM(1, 50, RANDOM()) AS table_number,
    'STAFF' || LPAD(UNIFORM(1, 500, RANDOM()), 5, '0') AS server_id,
    UNIFORM(1, 6, RANDOM()) AS covers,
    (r.avg_check_amount * UNIFORM(50, 200, RANDOM()) / 100.0)::NUMBER(12,2) AS subtotal,
    ((r.avg_check_amount * UNIFORM(50, 200, RANDOM()) / 100.0) * 0.0825)::NUMBER(10,2) AS tax_amount,
    ((r.avg_check_amount * UNIFORM(50, 200, RANDOM()) / 100.0) * UNIFORM(15, 25, RANDOM()) / 100.0)::NUMBER(10,2) AS tip_amount,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN (r.avg_check_amount * UNIFORM(5, 20, RANDOM()) / 100.0)::NUMBER(10,2) ELSE 0.00 END AS discount_amount,
    0.00 AS total_amount,  -- Will be calculated
    ARRAY_CONSTRUCT('CREDIT_CARD', 'ROOM_CHARGE', 'CASH', 'COMP', 'LOYALTY_POINTS')[UNIFORM(0, 4, RANDOM())] AS payment_method,
    'PAID' AS payment_status,
    UNIFORM(0, 100, RANDOM()) < 30 AS is_room_charge,
    UNIFORM(0, 100, RANDOM()) < 5 AS is_comp,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN ARRAY_CONSTRUCT('VIP Guest', 'Manager Comp', 'Loyalty Reward', 'Service Recovery')[UNIFORM(0, 3, RANDOM())] ELSE NULL END AS comp_reason,
    'COMPLETED' AS order_status,
    DATEADD('hour', UNIFORM(0, 23, RANDOM()), DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP())) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM GUESTS g
CROSS JOIN RESTAURANTS r
LEFT JOIN RESERVATIONS res ON g.guest_id = res.guest_id AND UNIFORM(0, 100, RANDOM()) < 30
WHERE UNIFORM(0, 100, RANDOM()) < 0.3
LIMIT 200000;

-- Update total amounts
UPDATE DINING_ORDERS
SET total_amount = subtotal + tax_amount + tip_amount - discount_amount;

-- ============================================================================
-- Step 9: Generate Spa Services
-- ============================================================================
INSERT INTO SPA_SERVICES VALUES
('SPA001', 'Classic Swedish Massage', 'MASSAGE', 'Full-body relaxation massage with Swedish techniques', 60, 195.00, TRUE, 'TREATMENT_ROOM', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA002', 'Deep Tissue Massage', 'MASSAGE', 'Intensive massage targeting deep muscle layers', 90, 295.00, TRUE, 'TREATMENT_ROOM', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA003', 'Hot Stone Therapy', 'MASSAGE', 'Heated volcanic stones combined with massage', 90, 325.00, TRUE, 'TREATMENT_ROOM', 1, TRUE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA004', 'Couples Massage', 'MASSAGE', 'Side-by-side massage for two guests', 60, 450.00, TRUE, 'COUPLES_SUITE', 2, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA005', 'CBD Recovery Massage', 'MASSAGE', 'Therapeutic massage with CBD-infused oils', 75, 285.00, TRUE, 'TREATMENT_ROOM', 1, TRUE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA006', 'Signature Facial', 'FACIAL', 'Customized facial treatment for all skin types', 60, 225.00, TRUE, 'TREATMENT_ROOM', 1, TRUE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA007', 'Hydrating Facial', 'FACIAL', 'Intensive hydration treatment for dry skin', 75, 275.00, TRUE, 'TREATMENT_ROOM', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA008', 'Anti-Aging Facial', 'FACIAL', 'Advanced treatment to reduce fine lines', 90, 350.00, TRUE, 'TREATMENT_ROOM', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA009', 'Gentleman''s Facial', 'FACIAL', 'Facial designed for men''s skincare needs', 60, 195.00, TRUE, 'TREATMENT_ROOM', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA010', 'Full Body Scrub', 'BODY_TREATMENT', 'Exfoliating body treatment with salt or sugar', 45, 175.00, TRUE, 'WET_ROOM', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA011', 'Body Wrap', 'BODY_TREATMENT', 'Detoxifying body wrap with mineral-rich ingredients', 60, 225.00, TRUE, 'WET_ROOM', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA012', 'Manicure', 'NAIL', 'Classic manicure with polish', 30, 65.00, TRUE, 'NAIL_SALON', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA013', 'Pedicure', 'NAIL', 'Classic pedicure with polish', 45, 85.00, TRUE, 'NAIL_SALON', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA014', 'Gel Manicure', 'NAIL', 'Long-lasting gel polish manicure', 45, 85.00, TRUE, 'NAIL_SALON', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA015', 'LIV Spa Journey', 'PACKAGE', 'Half-day spa experience with multiple treatments', 240, 750.00, TRUE, 'MULTIPLE', 1, TRUE, TRUE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA016', 'Couples Retreat', 'PACKAGE', 'Romantic spa package for two', 180, 950.00, TRUE, 'COUPLES_SUITE', 2, TRUE, TRUE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA017', 'Fitness Session', 'FITNESS', 'Personal training session', 60, 150.00, TRUE, 'FITNESS_CENTER', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA018', 'Yoga Class', 'FITNESS', 'Group or private yoga instruction', 60, 50.00, TRUE, 'YOGA_STUDIO', 10, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA019', 'Hair Styling', 'SALON', 'Blowout and styling', 45, 95.00, TRUE, 'HAIR_SALON', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('SPA020', 'Makeup Application', 'SALON', 'Professional makeup application', 60, 150.00, TRUE, 'HAIR_SALON', 1, FALSE, FALSE, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 10: Generate Spa Therapists
-- ============================================================================
INSERT INTO SPA_THERAPISTS
SELECT
    'THER' || LPAD(SEQ4(), 5, '0') AS therapist_id,
    ARRAY_CONSTRUCT('Emma', 'Olivia', 'Ava', 'Isabella', 'Sophia', 'Mia', 'Charlotte', 'Amelia', 'Harper', 'Evelyn',
                    'James', 'William', 'Benjamin', 'Lucas', 'Henry', 'Alexander', 'Sebastian', 'Jack', 'Aiden', 'Owen')[UNIFORM(0, 19, RANDOM())]
        || ' ' ||
    ARRAY_CONSTRUCT('Martinez', 'Anderson', 'Taylor', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Garcia', 'Thompson')[UNIFORM(0, 9, RANDOM())] AS therapist_name,
    'therapist' || SEQ4() || '@fontainebleaulsv.com' AS email,
    CONCAT('+1-702-555-', LPAD(UNIFORM(1000, 9999, RANDOM()), 4, '0')) AS phone,
    ARRAY_CONSTRUCT('Swedish Massage', 'Deep Tissue', 'Hot Stone', 'Facials', 'Body Treatments', 'Reflexology', 'Thai Massage', 'Aromatherapy')[UNIFORM(0, 7, RANDOM())] AS specializations,
    ARRAY_CONSTRUCT('Licensed Massage Therapist', 'Esthetician', 'Certified Yoga Instructor', 'Personal Trainer')[UNIFORM(0, 3, RANDOM())] AS certifications,
    DATEADD('day', -1 * UNIFORM(30, 2555, RANDOM()), CURRENT_DATE()) AS hire_date,
    'ACTIVE' AS therapist_status,
    (UNIFORM(40, 50, RANDOM()) / 10.0)::NUMBER(3,2) AS avg_rating,
    UNIFORM(100, 5000, RANDOM()) AS total_appointments,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 100));

-- ============================================================================
-- Step 11: Generate Spa Appointments
-- ============================================================================
INSERT INTO SPA_APPOINTMENTS
SELECT
    'SPAAPPT' || LPAD(ROW_NUMBER() OVER (ORDER BY g.guest_id, s.service_id), 10, '0') AS appointment_id,
    g.guest_id,
    res.reservation_id,
    s.service_id,
    t.therapist_id,
    DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_DATE()) AS appointment_date,
    TO_TIME(LPAD(UNIFORM(9, 19, RANDOM()), 2, '0') || ':' || ARRAY_CONSTRUCT('00', '30')[UNIFORM(0, 1, RANDOM())] || ':00') AS start_time,
    TIMEADD('minute', s.duration_minutes, TO_TIME(LPAD(UNIFORM(9, 19, RANDOM()), 2, '0') || ':' || ARRAY_CONSTRUCT('00', '30')[UNIFORM(0, 1, RANDOM())] || ':00')) AS end_time,
    'SPA' || LPAD(UNIFORM(1, 20, RANDOM()), 2, '0') AS room_number,
    CASE WHEN s.service_name LIKE '%Couple%' THEN 2 ELSE 1 END AS guests_in_party,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'COMPLETED'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'CANCELLED'
         ELSE 'NO_SHOW' END AS appointment_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN DATEADD('day', -1 * UNIFORM(1, 7, RANDOM()), DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_DATE())) ELSE NULL END AS cancellation_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN ARRAY_CONSTRUCT('Schedule conflict', 'Not feeling well', 'Changed plans')[UNIFORM(0, 2, RANDOM())] ELSE NULL END AS cancellation_reason,
    UNIFORM(0, 100, RANDOM()) < 5 AS no_show,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN TIMEADD('minute', -1 * UNIFORM(5, 30, RANDOM()), TO_TIME(LPAD(UNIFORM(9, 19, RANDOM()), 2, '0') || ':00:00')) ELSE NULL END AS check_in_time,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN ARRAY_CONSTRUCT('Light pressure', 'Extra time on back', 'Pregnancy-safe products', 'No fragrance')[UNIFORM(0, 3, RANDOM())] ELSE NULL END AS special_requests,
    NULL AS health_notes,
    s.price,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN (s.price * UNIFORM(10, 25, RANDOM()) / 100.0)::NUMBER(10,2) ELSE 0.00 END AS discount_amount,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN (s.price * UNIFORM(15, 25, RANDOM()) / 100.0)::NUMBER(10,2) ELSE 0.00 END AS tip_amount,
    s.price AS total_amount,
    ARRAY_CONSTRUCT('CREDIT_CARD', 'ROOM_CHARGE', 'CASH', 'COMP')[UNIFORM(0, 3, RANDOM())] AS payment_method,
    UNIFORM(0, 100, RANDOM()) < 40 AS is_room_charge,
    UNIFORM(0, 100, RANDOM()) < 5 AS is_comp,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN UNIFORM(3, 5, RANDOM()) ELSE NULL END AS rating,
    ARRAY_CONSTRUCT('CONCIERGE', 'WEBSITE', 'MOBILE_APP', 'PHONE', 'WALK_IN')[UNIFORM(0, 4, RANDOM())] AS booking_source,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM GUESTS g
CROSS JOIN SPA_SERVICES s
CROSS JOIN SPA_THERAPISTS t
LEFT JOIN RESERVATIONS res ON g.guest_id = res.guest_id AND UNIFORM(0, 100, RANDOM()) < 50
WHERE UNIFORM(0, 100, RANDOM()) < 0.05
LIMIT 50000;

-- Update spa appointment totals
UPDATE SPA_APPOINTMENTS
SET total_amount = price - discount_amount + tip_amount;

-- ============================================================================
-- Step 12: Generate Gaming Players
-- ============================================================================
INSERT INTO GAMING_PLAYERS
SELECT
    'PLAYER' || LPAD(ROW_NUMBER() OVER (ORDER BY g.guest_id), 8, '0') AS player_id,
    g.guest_id,
    'FBLV' || LPAD(ROW_NUMBER() OVER (ORDER BY g.guest_id), 10, '0') AS player_card_number,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 50 THEN 'MEMBER'
         WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'SILVER'
         WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN 'GOLD'
         ELSE 'PLATINUM' END AS player_tier,
    (UNIFORM(50, 5000, RANDOM()) * 1.0)::NUMBER(10,2) AS theoretical_daily_value,
    (UNIFORM(25, 4000, RANDOM()) * 1.0)::NUMBER(10,2) AS actual_daily_value,
    (UNIFORM(1000, 500000, RANDOM()) * 1.0)::NUMBER(15,2) AS total_coin_in,
    (UNIFORM(500, 450000, RANDOM()) * 1.0)::NUMBER(15,2) AS total_coin_out,
    (UNIFORM(500, 50000, RANDOM()) * 1.0)::NUMBER(15,2) AS total_table_buy_in,
    (UNIFORM(-20000, 20000, RANDOM()) * 1.0)::NUMBER(15,2) AS total_table_win_loss,
    (UNIFORM(0, 5000, RANDOM()) * 1.0)::NUMBER(10,2) AS comp_balance,
    (UNIFORM(0, 25000, RANDOM()) * 1.0)::NUMBER(12,2) AS comp_earned_ytd,
    (UNIFORM(0, 20000, RANDOM()) * 1.0)::NUMBER(12,2) AS comp_redeemed_ytd,
    ARRAY_CONSTRUCT('SLOTS', 'BLACKJACK', 'POKER', 'BACCARAT', 'CRAPS', 'ROULETTE')[UNIFORM(0, 5, RANDOM())] AS primary_game_type,
    (UNIFORM(10, 1000, RANDOM()) * 1.0)::NUMBER(10,2) AS average_bet,
    UNIFORM(1, 50, RANDOM()) AS visit_frequency,
    DATEADD('day', -1 * UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) AS last_play_date,
    DATEADD('day', -1 * UNIFORM(30, 730, RANDOM()), CURRENT_DATE()) AS enrollment_date,
    'ACTIVE' AS player_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'HOST' || LPAD(UNIFORM(1, 50, RANDOM()), 4, '0') ELSE NULL END AS host_id,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM GUESTS g
WHERE g.guest_type = 'GAMING' OR UNIFORM(0, 100, RANDOM()) < 30
LIMIT 30000;

-- ============================================================================
-- Step 13: Generate Gaming Transactions
-- ============================================================================
INSERT INTO GAMING_TRANSACTIONS
SELECT
    'GTRANS' || LPAD(ROW_NUMBER() OVER (ORDER BY p.player_id), 12, '0') AS transaction_id,
    p.player_id,
    p.guest_id,
    res.reservation_id,
    DATEADD('minute', UNIFORM(0, 1440, RANDOM()), DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP())) AS transaction_date,
    ARRAY_CONSTRUCT('SLOTS_PLAY', 'TABLE_PLAY', 'BUY_IN', 'CASH_OUT', 'MARKER', 'COMP_REDEMPTION')[UNIFORM(0, 5, RANDOM())] AS transaction_type,
    p.primary_game_type AS game_type,
    CASE WHEN p.primary_game_type = 'SLOTS' THEN 'SLOT' || LPAD(UNIFORM(1, 500, RANDOM()), 4, '0')
         ELSE 'TABLE' || LPAD(UNIFORM(1, 100, RANDOM()), 3, '0') END AS table_or_machine_id,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN (UNIFORM(100, 10000, RANDOM()) * 1.0)::NUMBER(12,2) ELSE 0.00 END AS buy_in_amount,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 35 THEN (UNIFORM(50, 15000, RANDOM()) * 1.0)::NUMBER(12,2) ELSE 0.00 END AS cash_out_amount,
    CASE WHEN p.primary_game_type = 'SLOTS' THEN (UNIFORM(100, 5000, RANDOM()) * 1.0)::NUMBER(12,2) ELSE 0.00 END AS coin_in,
    CASE WHEN p.primary_game_type = 'SLOTS' THEN (UNIFORM(50, 4500, RANDOM()) * 1.0)::NUMBER(12,2) ELSE 0.00 END AS coin_out,
    (p.theoretical_daily_value * UNIFORM(5, 50, RANDOM()) / 100.0)::NUMBER(10,2) AS theoretical_win,
    (UNIFORM(-5000, 5000, RANDOM()) * 1.0)::NUMBER(12,2) AS actual_win_loss,
    (UNIFORM(5, 100, RANDOM()) * 1.0)::NUMBER(10,2) AS comp_earned,
    UNIFORM(15, 480, RANDOM()) AS session_duration_minutes,
    p.average_bet,
    CASE WHEN p.primary_game_type != 'SLOTS' THEN UNIFORM(10, 200, RANDOM()) ELSE NULL END AS hands_played,
    CURRENT_TIMESTAMP() AS created_at
FROM GAMING_PLAYERS p
LEFT JOIN RESERVATIONS res ON p.guest_id = res.guest_id AND UNIFORM(0, 100, RANDOM()) < 40
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 5))
WHERE UNIFORM(0, 100, RANDOM()) < 70
LIMIT 100000;

-- ============================================================================
-- Step 14: Generate Event Venues
-- ============================================================================
INSERT INTO EVENT_VENUES VALUES
('VEN001', 'Grand Ballroom', 'BALLROOM', 'CONVENTION_CENTER', 2, 2500, 1500, 1800, 3000, 45000, 30.0, FALSE, TRUE, 5000.00, 35000.00, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('VEN002', 'Crystal Ballroom', 'BALLROOM', 'CONVENTION_CENTER', 2, 1200, 800, 900, 1500, 25000, 25.0, FALSE, TRUE, 3500.00, 25000.00, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('VEN003', 'Executive Boardroom', 'MEETING_ROOM', 'CONVENTION_CENTER', 2, 30, 25, 20, 35, 1200, 12.0, TRUE, TRUE, 500.00, 3500.00, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('VEN004', 'Sunrise Room', 'MEETING_ROOM', 'CONVENTION_CENTER', 2, 150, 100, 120, 200, 5000, 15.0, TRUE, TRUE, 1000.00, 7000.00, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('VEN005', 'Sunset Room', 'MEETING_ROOM', 'CONVENTION_CENTER', 2, 150, 100, 120, 200, 5000, 15.0, TRUE, TRUE, 1000.00, 7000.00, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('VEN006', 'Pool Terrace', 'OUTDOOR', 'POOL_LEVEL', 3, 500, NULL, 400, 600, 15000, NULL, TRUE, TRUE, 3000.00, 20000.00, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('VEN007', 'Rooftop Venue', 'OUTDOOR', 'ROOFTOP', 67, 300, NULL, 250, 400, 10000, NULL, TRUE, TRUE, 4000.00, 28000.00, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('VEN008', 'LIV Nightclub', 'NIGHTCLUB', 'ENTERTAINMENT', 1, 1000, NULL, NULL, 1500, 20000, 25.0, FALSE, TRUE, 10000.00, 75000.00, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('VEN009', 'Bleau Suite', 'HOSPITALITY_SUITE', 'TOWER', 60, 50, NULL, 40, 75, 2500, 12.0, TRUE, TRUE, 1500.00, 10000.00, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('VEN010', 'Garden Terrace', 'OUTDOOR', 'GROUND_FLOOR', 1, 200, NULL, 150, 250, 8000, NULL, TRUE, TRUE, 2000.00, 15000.00, 'AVAILABLE', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 15: Generate Events
-- ============================================================================
INSERT INTO EVENTS
SELECT
    'EVT' || LPAD(ROW_NUMBER() OVER (ORDER BY v.venue_id), 8, '0') AS event_id,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN ARRAY_CONSTRUCT('Annual Sales Conference', 'Leadership Summit', 'Product Launch', 'Investor Meeting', 'Board Retreat')[UNIFORM(0, 4, RANDOM())]
        WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN ARRAY_CONSTRUCT('Wedding Reception', 'Anniversary Celebration', 'Birthday Gala', 'Quinceañera', 'Bar Mitzvah')[UNIFORM(0, 4, RANDOM())]
        WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN ARRAY_CONSTRUCT('Medical Conference', 'Tech Summit', 'Legal Symposium', 'Financial Forum', 'Industry Expo')[UNIFORM(0, 4, RANDOM())]
        ELSE ARRAY_CONSTRUCT('Charity Gala', 'Award Ceremony', 'VIP Reception', 'Private Concert', 'Corporate Dinner')[UNIFORM(0, 4, RANDOM())]
    END AS event_name,
    ARRAY_CONSTRUCT('CORPORATE', 'WEDDING', 'SOCIAL', 'CONFERENCE', 'MEETING', 'GALA', 'RECEPTION')[UNIFORM(0, 6, RANDOM())] AS event_type,
    v.venue_id,
    ARRAY_CONSTRUCT('Smith Event Planning', 'Corporate Events Inc', 'Luxury Weddings', 'Las Vegas Meetings', 'Private Client')[UNIFORM(0, 4, RANDOM())] AS organizer_name,
    ARRAY_CONSTRUCT('ABC Corporation', 'Tech Solutions Inc', 'Smith Family', 'Johnson Industries', 'Medical Association')[UNIFORM(0, 4, RANDOM())] AS organizer_company,
    'events' || ROW_NUMBER() OVER (ORDER BY v.venue_id) || '@' || ARRAY_CONSTRUCT('company.com', 'gmail.com', 'planners.com')[UNIFORM(0, 2, RANDOM())] AS organizer_email,
    CONCAT('+1-', LPAD(UNIFORM(200, 999, RANDOM()), 3, '0'), '-555-', LPAD(UNIFORM(1000, 9999, RANDOM()), 4, '0')) AS organizer_phone,
    DATEADD('day', UNIFORM(-365, 365, RANDOM()), CURRENT_DATE()) AS event_date,
    TO_TIME(LPAD(UNIFORM(8, 20, RANDOM()), 2, '0') || ':00:00') AS start_time,
    TO_TIME(LPAD(UNIFORM(12, 23, RANDOM()), 2, '0') || ':00:00') AS end_time,
    TIMEADD('hour', -2, TO_TIME(LPAD(UNIFORM(8, 20, RANDOM()), 2, '0') || ':00:00')) AS setup_time,
    TIMEADD('hour', 2, TO_TIME(LPAD(UNIFORM(12, 23, RANDOM()), 2, '0') || ':00:00')) AS teardown_time,
    LEAST(UNIFORM(50, 500, RANDOM()), COALESCE(v.capacity_reception, 500)) AS expected_attendance,
    LEAST(UNIFORM(40, 500, RANDOM()), COALESCE(v.capacity_reception, 500)) AS actual_attendance,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'COMPLETED'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'CONFIRMED'
         ELSE 'CANCELLED' END AS event_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN DATEADD('day', -1 * UNIFORM(1, 60, RANDOM()), DATEADD('day', UNIFORM(-365, 365, RANDOM()), CURRENT_DATE())) ELSE NULL END AS cancellation_date,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM EVENT_VENUES v
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 1000))
WHERE UNIFORM(0, 100, RANDOM()) < 100
LIMIT 10000;

-- ============================================================================
-- Step 16: Generate Event Bookings
-- ============================================================================
INSERT INTO EVENT_BOOKINGS
SELECT
    'EVTBK' || LPAD(ROW_NUMBER() OVER (ORDER BY e.event_id), 10, '0') AS booking_id,
    e.event_id,
    g.guest_id,
    e.event_type AS booking_type,
    (UNIFORM(5000, 150000, RANDOM()) * 1.0)::NUMBER(15,2) AS contract_amount,
    (UNIFORM(1000, 30000, RANDOM()) * 1.0)::NUMBER(12,2) AS deposit_amount,
    (UNIFORM(2000, 50000, RANDOM()) * 1.0)::NUMBER(12,2) AS catering_revenue,
    (UNIFORM(500, 5000, RANDOM()) * 1.0)::NUMBER(10,2) AS av_revenue,
    (UNIFORM(1000, 10000, RANDOM()) * 1.0)::NUMBER(10,2) AS room_rental_revenue,
    (UNIFORM(0, 3000, RANDOM()) * 1.0)::NUMBER(10,2) AS other_revenue,
    0.00 AS total_revenue,
    CASE WHEN e.event_status = 'COMPLETED' THEN 'PAID'
         WHEN e.event_status = 'CONFIRMED' THEN 'DEPOSIT_RECEIVED'
         ELSE 'CANCELLED' END AS payment_status,
    DATEADD('day', -1 * UNIFORM(30, 180, RANDOM()), e.event_date) AS contract_signed_date,
    ARRAY_CONSTRUCT('DIRECT', 'TRAVEL_AGENT', 'WEBSITE', 'REFERRAL', 'CVB')[UNIFORM(0, 4, RANDOM())] AS booking_source,
    e.event_status AS booking_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM EVENTS e
LEFT JOIN GUESTS g ON UNIFORM(0, 100, RANDOM()) < 50;

-- Update total revenue
UPDATE EVENT_BOOKINGS
SET total_revenue = contract_amount + catering_revenue + av_revenue + room_rental_revenue + other_revenue;

-- ============================================================================
-- Step 17: Generate Staff
-- ============================================================================
INSERT INTO STAFF
SELECT
    'STAFF' || LPAD(SEQ4(), 6, '0') AS staff_id,
    ARRAY_CONSTRUCT('Michael', 'Jennifer', 'David', 'Jessica', 'Christopher', 'Ashley', 'Matthew', 'Amanda', 'Daniel', 'Sarah',
                    'Andrew', 'Stephanie', 'Joshua', 'Nicole', 'James', 'Emily', 'Ryan', 'Megan', 'Brandon', 'Lauren')[UNIFORM(0, 19, RANDOM())] AS first_name,
    ARRAY_CONSTRUCT('Johnson', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas',
                    'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson', 'Clark', 'Lewis')[UNIFORM(0, 19, RANDOM())] AS last_name,
    'staff' || SEQ4() || '@fontainebleaulsv.com' AS email,
    CONCAT('+1-702-555-', LPAD(UNIFORM(1000, 9999, RANDOM()), 4, '0')) AS phone,
    ARRAY_CONSTRUCT('FRONT_OFFICE', 'HOUSEKEEPING', 'FOOD_BEVERAGE', 'SPA', 'GAMING', 'SECURITY', 'ENGINEERING', 'CONCIERGE', 'VALET', 'SALES')[UNIFORM(0, 9, RANDOM())] AS department,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN ARRAY_CONSTRUCT('Associate', 'Agent', 'Server', 'Attendant', 'Technician')[UNIFORM(0, 4, RANDOM())]
        WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN ARRAY_CONSTRUCT('Supervisor', 'Lead', 'Senior Associate')[UNIFORM(0, 2, RANDOM())]
        WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN ARRAY_CONSTRUCT('Manager', 'Assistant Manager')[UNIFORM(0, 1, RANDOM())]
        ELSE ARRAY_CONSTRUCT('Director', 'Executive')[UNIFORM(0, 1, RANDOM())]
    END AS position,
    DATEADD('day', -1 * UNIFORM(30, 1825, RANDOM()), CURRENT_DATE()) AS hire_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN 'STAFF' || LPAD(UNIFORM(1, 500, RANDOM()), 6, '0') ELSE NULL END AS manager_id,
    (UNIFORM(15, 75, RANDOM()) * 1.0)::NUMBER(8,2) AS hourly_rate,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'FULL_TIME' ELSE 'PART_TIME' END AS employee_type,
    ARRAY_CONSTRUCT('DAY', 'SWING', 'NIGHT', 'ROTATING')[UNIFORM(0, 3, RANDOM())] AS shift,
    (UNIFORM(30, 50, RANDOM()) / 10.0)::NUMBER(3,2) AS performance_rating,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'ACTIVE' ELSE 'INACTIVE' END AS staff_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 3000));

-- ============================================================================
-- Step 18: Generate Guest Feedback
-- ============================================================================
INSERT INTO GUEST_FEEDBACK
SELECT
    'FDBK' || LPAD(ROW_NUMBER() OVER (ORDER BY res.reservation_id), 10, '0') AS feedback_id,
    g.guest_id,
    res.reservation_id,
    DATEADD('day', UNIFORM(0, 7, RANDOM()), res.check_out_date) AS feedback_date,
    ARRAY_CONSTRUCT('SURVEY', 'EMAIL', 'PHONE', 'IN_PERSON', 'SOCIAL_MEDIA')[UNIFORM(0, 4, RANDOM())] AS feedback_type,
    ARRAY_CONSTRUCT('FRONT_OFFICE', 'HOUSEKEEPING', 'DINING', 'SPA', 'POOL', 'GAMING', 'GENERAL')[UNIFORM(0, 6, RANDOM())] AS department,
    UNIFORM(1, 5, RANDOM()) AS overall_rating,
    UNIFORM(1, 5, RANDOM()) AS room_rating,
    UNIFORM(1, 5, RANDOM()) AS cleanliness_rating,
    UNIFORM(1, 5, RANDOM()) AS service_rating,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN UNIFORM(1, 5, RANDOM()) ELSE NULL END AS dining_rating,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN UNIFORM(1, 5, RANDOM()) ELSE NULL END AS spa_rating,
    UNIFORM(1, 5, RANDOM()) AS value_rating,
    UNIFORM(1, 10, RANDOM()) AS likelihood_to_recommend,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN ARRAY_CONSTRUCT('Excellent stay, highly recommend!', 'Beautiful property, great service', 'Will definitely return', 'Amazing experience from start to finish', 'Best hotel in Vegas!')[UNIFORM(0, 4, RANDOM())]
        WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN ARRAY_CONSTRUCT('Good overall, some minor issues', 'Nice hotel but pricey', 'Enjoyed our stay with a few exceptions', 'Room was nice but service could improve', 'Good location, average experience')[UNIFORM(0, 4, RANDOM())]
        ELSE ARRAY_CONSTRUCT('Disappointed with the experience', 'Expected more for the price', 'Several issues during our stay', 'Would not recommend', 'Needs improvement')[UNIFORM(0, 4, RANDOM())]
    END AS feedback_comments,
    s.staff_id,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN DATEADD('day', UNIFORM(1, 7, RANDOM()), DATEADD('day', UNIFORM(0, 7, RANDOM()), res.check_out_date)) ELSE NULL END AS response_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'Thank you for your feedback. We appreciate you choosing Fontainebleau Las Vegas.' ELSE NULL END AS response_text,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN TRUE ELSE FALSE END AS issue_resolved,
    UNIFORM(0, 100, RANDOM()) < 15 AS follow_up_required,
    ARRAY_CONSTRUCT('EMAIL', 'POST_STAY_SURVEY', 'REVIEW_SITE', 'SOCIAL_MEDIA')[UNIFORM(0, 3, RANDOM())] AS feedback_source,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'CLOSED' ELSE 'NEW' END AS feedback_status,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM RESERVATIONS res
JOIN GUESTS g ON res.guest_id = g.guest_id
LEFT JOIN STAFF s ON UNIFORM(0, 100, RANDOM()) < 50
WHERE res.reservation_status = 'CHECKED_OUT'
  AND UNIFORM(0, 100, RANDOM()) < 30
LIMIT 25000;

-- ============================================================================
-- Step 19: Generate Amenity Usage
-- ============================================================================
INSERT INTO AMENITY_USAGE
SELECT
    'AMEN' || LPAD(ROW_NUMBER() OVER (ORDER BY res.reservation_id), 10, '0') AS usage_id,
    g.guest_id,
    res.reservation_id,
    ARRAY_CONSTRUCT('POOL', 'FITNESS_CENTER', 'BUSINESS_CENTER', 'CABANA', 'BEACH_CLUB')[UNIFORM(0, 4, RANDOM())] AS amenity_type,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'Oasis Pool'
        WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 'Fitness Center'
        WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN 'Cabana ' || UNIFORM(1, 50, RANDOM())
        WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'Business Center'
        ELSE 'Beach Club'
    END AS amenity_name,
    DATEADD('day', MOD(ABS(RANDOM()), GREATEST(res.nights, 1)), res.check_in_date) AS usage_date,
    TO_TIME(LPAD(UNIFORM(6, 20, RANDOM()), 2, '0') || ':' || LPAD(UNIFORM(0, 59, RANDOM()), 2, '0') || ':00') AS start_time,
    TIMEADD('minute', UNIFORM(30, 240, RANDOM()), TO_TIME(LPAD(UNIFORM(6, 20, RANDOM()), 2, '0') || ':' || LPAD(UNIFORM(0, 59, RANDOM()), 2, '0') || ':00')) AS end_time,
    UNIFORM(30, 240, RANDOM()) AS duration_minutes,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN (UNIFORM(50, 500, RANDOM()) * 1.0)::NUMBER(10,2) ELSE 0.00 END AS usage_fee,
    UNIFORM(0, 100, RANDOM()) < 20 AS is_comp,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN ARRAY_CONSTRUCT('Lounge chair', 'Towel', 'Umbrella', 'Treadmill', 'Weights')[UNIFORM(0, 4, RANDOM())] ELSE NULL END AS equipment_used,
    CURRENT_TIMESTAMP() AS created_at
FROM RESERVATIONS res
JOIN GUESTS g ON res.guest_id = g.guest_id
WHERE res.reservation_status IN ('CHECKED_OUT', 'CONFIRMED')
  AND UNIFORM(0, 100, RANDOM()) < 40
LIMIT 50000;

-- ============================================================================
-- Step 20: Generate Marketing Campaigns
-- ============================================================================
INSERT INTO MARKETING_CAMPAIGNS
SELECT
    'CAMP' || LPAD(SEQ4(), 6, '0') AS campaign_id,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN ARRAY_CONSTRUCT('Summer Escape Package', 'Fall Savings Event', 'Holiday Getaway', 'New Year Celebration', 'Valentine''s Romance')[UNIFORM(0, 4, RANDOM())]
        WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN ARRAY_CONSTRUCT('Loyalty Member Exclusive', 'VIP Gaming Weekend', 'Platinum Rewards', 'Welcome Back Offer', 'Anniversary Special')[UNIFORM(0, 4, RANDOM())]
        WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN ARRAY_CONSTRUCT('Spa & Wellness Retreat', 'Dine & Stay Package', 'Golf & Resort', 'Entertainment Package', 'Convention Special')[UNIFORM(0, 4, RANDOM())]
        ELSE ARRAY_CONSTRUCT('Flash Sale', 'Limited Time Offer', 'Early Bird Discount', 'Last Minute Deal', 'Midweek Madness')[UNIFORM(0, 4, RANDOM())]
    END AS campaign_name,
    ARRAY_CONSTRUCT('SEASONAL', 'LOYALTY', 'PACKAGE', 'PROMOTIONAL', 'FLASH_SALE', 'EMAIL', 'SOCIAL')[UNIFORM(0, 6, RANDOM())] AS campaign_type,
    ARRAY_CONSTRUCT('ALL', 'LEISURE', 'BUSINESS', 'GAMING', 'VIP', 'LOYALTY_MEMBERS')[UNIFORM(0, 5, RANDOM())] AS target_segment,
    DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_DATE()) AS start_date,
    DATEADD('day', UNIFORM(7, 90, RANDOM()), DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_DATE())) AS end_date,
    (UNIFORM(10000, 500000, RANDOM()) * 1.0)::NUMBER(12,2) AS budget,
    ARRAY_CONSTRUCT('EMAIL', 'SOCIAL_MEDIA', 'DISPLAY_ADS', 'DIRECT_MAIL', 'SMS', 'WEBSITE')[UNIFORM(0, 5, RANDOM())] AS channel,
    'Special offer for our valued guests' AS offer_description,
    (UNIFORM(10, 40, RANDOM()) * 1.0)::NUMBER(5,2) AS discount_percentage,
    UPPER(SUBSTR(MD5(RANDOM()), 1, 8)) AS promo_code,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'COMPLETED' ELSE 'ACTIVE' END AS campaign_status,
    UNIFORM(10000, 1000000, RANDOM()) AS impressions,
    UNIFORM(500, 50000, RANDOM()) AS clicks,
    UNIFORM(50, 5000, RANDOM()) AS conversions,
    (UNIFORM(50000, 2000000, RANDOM()) * 1.0)::NUMBER(15,2) AS revenue_generated,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 200));

-- ============================================================================
-- Display data generation completion summary
-- ============================================================================
SELECT 'Data generation completed successfully' AS status,
       (SELECT COUNT(*) FROM ROOM_TYPES) AS room_types,
       (SELECT COUNT(*) FROM ROOMS) AS rooms,
       (SELECT COUNT(*) FROM GUESTS) AS guests,
       (SELECT COUNT(*) FROM RESERVATIONS) AS reservations,
       (SELECT COUNT(*) FROM RESTAURANTS) AS restaurants,
       (SELECT COUNT(*) FROM MENU_ITEMS) AS menu_items,
       (SELECT COUNT(*) FROM DINING_ORDERS) AS dining_orders,
       (SELECT COUNT(*) FROM SPA_SERVICES) AS spa_services,
       (SELECT COUNT(*) FROM SPA_APPOINTMENTS) AS spa_appointments,
       (SELECT COUNT(*) FROM GAMING_PLAYERS) AS gaming_players,
       (SELECT COUNT(*) FROM GAMING_TRANSACTIONS) AS gaming_transactions,
       (SELECT COUNT(*) FROM EVENTS) AS events,
       (SELECT COUNT(*) FROM STAFF) AS staff,
       (SELECT COUNT(*) FROM GUEST_FEEDBACK) AS guest_feedback;

