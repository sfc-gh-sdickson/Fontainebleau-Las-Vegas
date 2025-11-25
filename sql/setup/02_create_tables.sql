-- ============================================================================
-- Fontainebleau Las Vegas Intelligence Agent - Table Definitions
-- ============================================================================
-- Purpose: Create all necessary tables for luxury hotel business model
-- All columns verified against Fontainebleau business requirements
-- Syntax: Verified against Snowflake SQL Reference
-- ============================================================================

USE DATABASE FONTAINEBLEAU_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE FONTAINEBLEAU_WH;

-- ============================================================================
-- ROOM_TYPES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE ROOM_TYPES (
    room_type_id VARCHAR(20) PRIMARY KEY,
    room_type_name VARCHAR(100) NOT NULL,
    room_category VARCHAR(50) NOT NULL,
    base_rate NUMBER(10,2) NOT NULL,
    max_occupancy NUMBER(3,0) NOT NULL,
    square_feet NUMBER(6,0),
    view_type VARCHAR(50),
    amenities VARCHAR(1000),
    bed_configuration VARCHAR(100),
    floor_range VARCHAR(50),
    is_suite BOOLEAN DEFAULT FALSE,
    is_accessible BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- ROOMS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE ROOMS (
    room_id VARCHAR(20) PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL,
    room_type_id VARCHAR(20) NOT NULL,
    floor_number NUMBER(3,0) NOT NULL,
    tower VARCHAR(50),
    room_status VARCHAR(30) DEFAULT 'AVAILABLE',
    housekeeping_status VARCHAR(30) DEFAULT 'CLEAN',
    maintenance_status VARCHAR(30) DEFAULT 'OPERATIONAL',
    last_cleaned TIMESTAMP_NTZ,
    last_inspected TIMESTAMP_NTZ,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (room_type_id) REFERENCES ROOM_TYPES(room_type_id)
);

-- ============================================================================
-- GUESTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE GUESTS (
    guest_id VARCHAR(30) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL,
    phone VARCHAR(30),
    date_of_birth DATE,
    address_line1 VARCHAR(200),
    address_line2 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    guest_type VARCHAR(30) DEFAULT 'LEISURE',
    loyalty_tier VARCHAR(30) DEFAULT 'MEMBER',
    loyalty_number VARCHAR(30),
    total_stays NUMBER(8,0) DEFAULT 0,
    total_spend NUMBER(12,2) DEFAULT 0.00,
    lifetime_value NUMBER(12,2) DEFAULT 0.00,
    preferences VARCHAR(2000),
    dietary_restrictions VARCHAR(500),
    special_requests VARCHAR(2000),
    vip_status BOOLEAN DEFAULT FALSE,
    guest_status VARCHAR(30) DEFAULT 'ACTIVE',
    first_visit_date DATE,
    last_visit_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- LOYALTY_PROGRAM TABLE
-- ============================================================================
CREATE OR REPLACE TABLE LOYALTY_PROGRAM (
    loyalty_id VARCHAR(30) PRIMARY KEY,
    guest_id VARCHAR(30) NOT NULL,
    loyalty_number VARCHAR(30) NOT NULL,
    current_tier VARCHAR(30) DEFAULT 'MEMBER',
    points_balance NUMBER(12,0) DEFAULT 0,
    points_earned_ytd NUMBER(12,0) DEFAULT 0,
    points_redeemed_ytd NUMBER(12,0) DEFAULT 0,
    tier_qualification_date DATE,
    tier_expiration_date DATE,
    lifetime_points NUMBER(12,0) DEFAULT 0,
    comp_dollars_balance NUMBER(10,2) DEFAULT 0.00,
    free_night_credits NUMBER(5,0) DEFAULT 0,
    enrollment_date DATE NOT NULL,
    enrollment_channel VARCHAR(50),
    program_status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id)
);

-- ============================================================================
-- RESERVATIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE RESERVATIONS (
    reservation_id VARCHAR(30) PRIMARY KEY,
    guest_id VARCHAR(30) NOT NULL,
    room_id VARCHAR(20),
    room_type_id VARCHAR(20) NOT NULL,
    confirmation_number VARCHAR(20) NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    nights NUMBER(5,0) NOT NULL,
    adults NUMBER(3,0) DEFAULT 1,
    children NUMBER(3,0) DEFAULT 0,
    rate_code VARCHAR(30),
    rate_type VARCHAR(50),
    room_rate NUMBER(10,2) NOT NULL,
    total_room_revenue NUMBER(12,2) NOT NULL,
    reservation_status VARCHAR(30) DEFAULT 'CONFIRMED',
    booking_source VARCHAR(50),
    booking_channel VARCHAR(50),
    booking_date TIMESTAMP_NTZ NOT NULL,
    cancellation_date TIMESTAMP_NTZ,
    cancellation_reason VARCHAR(500),
    special_requests VARCHAR(2000),
    arrival_time TIME,
    departure_time TIME,
    is_group_booking BOOLEAN DEFAULT FALSE,
    group_id VARCHAR(30),
    travel_purpose VARCHAR(50),
    payment_method VARCHAR(50),
    deposit_amount NUMBER(10,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id),
    FOREIGN KEY (room_id) REFERENCES ROOMS(room_id),
    FOREIGN KEY (room_type_id) REFERENCES ROOM_TYPES(room_type_id)
);

-- ============================================================================
-- RESTAURANTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE RESTAURANTS (
    restaurant_id VARCHAR(20) PRIMARY KEY,
    restaurant_name VARCHAR(200) NOT NULL,
    cuisine_type VARCHAR(100),
    meal_period VARCHAR(50),
    seating_capacity NUMBER(5,0),
    location VARCHAR(100),
    floor_number NUMBER(3,0),
    dress_code VARCHAR(50),
    price_range VARCHAR(20),
    avg_check_amount NUMBER(10,2),
    michelin_stars NUMBER(1,0) DEFAULT 0,
    chef_name VARCHAR(200),
    phone VARCHAR(30),
    hours_of_operation VARCHAR(200),
    reservation_required BOOLEAN DEFAULT FALSE,
    restaurant_status VARCHAR(30) DEFAULT 'OPEN',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- MENU_ITEMS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE MENU_ITEMS (
    menu_item_id VARCHAR(30) PRIMARY KEY,
    restaurant_id VARCHAR(20) NOT NULL,
    item_name VARCHAR(200) NOT NULL,
    item_description VARCHAR(1000),
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    price NUMBER(10,2) NOT NULL,
    cost NUMBER(10,2),
    is_signature BOOLEAN DEFAULT FALSE,
    is_seasonal BOOLEAN DEFAULT FALSE,
    is_vegetarian BOOLEAN DEFAULT FALSE,
    is_vegan BOOLEAN DEFAULT FALSE,
    is_gluten_free BOOLEAN DEFAULT FALSE,
    allergens VARCHAR(500),
    calories NUMBER(6,0),
    item_status VARCHAR(30) DEFAULT 'AVAILABLE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (restaurant_id) REFERENCES RESTAURANTS(restaurant_id)
);

-- ============================================================================
-- DINING_RESERVATIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE DINING_RESERVATIONS (
    dining_reservation_id VARCHAR(30) PRIMARY KEY,
    guest_id VARCHAR(30) NOT NULL,
    restaurant_id VARCHAR(20) NOT NULL,
    reservation_id VARCHAR(30),
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size NUMBER(3,0) NOT NULL,
    table_number VARCHAR(20),
    special_occasion VARCHAR(100),
    dietary_notes VARCHAR(500),
    reservation_status VARCHAR(30) DEFAULT 'CONFIRMED',
    actual_arrival_time TIME,
    actual_departure_time TIME,
    cancellation_date TIMESTAMP_NTZ,
    no_show BOOLEAN DEFAULT FALSE,
    booking_source VARCHAR(50),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id),
    FOREIGN KEY (restaurant_id) REFERENCES RESTAURANTS(restaurant_id),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id)
);

-- ============================================================================
-- DINING_ORDERS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE DINING_ORDERS (
    order_id VARCHAR(30) PRIMARY KEY,
    dining_reservation_id VARCHAR(30),
    guest_id VARCHAR(30) NOT NULL,
    restaurant_id VARCHAR(20) NOT NULL,
    reservation_id VARCHAR(30),
    order_date TIMESTAMP_NTZ NOT NULL,
    order_type VARCHAR(30) NOT NULL,
    table_number VARCHAR(20),
    server_id VARCHAR(20),
    covers NUMBER(3,0) DEFAULT 1,
    subtotal NUMBER(12,2) NOT NULL,
    tax_amount NUMBER(10,2) DEFAULT 0.00,
    tip_amount NUMBER(10,2) DEFAULT 0.00,
    discount_amount NUMBER(10,2) DEFAULT 0.00,
    total_amount NUMBER(12,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(30) DEFAULT 'PAID',
    is_room_charge BOOLEAN DEFAULT FALSE,
    is_comp BOOLEAN DEFAULT FALSE,
    comp_reason VARCHAR(200),
    order_status VARCHAR(30) DEFAULT 'COMPLETED',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (dining_reservation_id) REFERENCES DINING_RESERVATIONS(dining_reservation_id),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id),
    FOREIGN KEY (restaurant_id) REFERENCES RESTAURANTS(restaurant_id),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id)
);

-- ============================================================================
-- ORDER_ITEMS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE ORDER_ITEMS (
    order_item_id VARCHAR(30) PRIMARY KEY,
    order_id VARCHAR(30) NOT NULL,
    menu_item_id VARCHAR(30) NOT NULL,
    quantity NUMBER(5,0) DEFAULT 1,
    unit_price NUMBER(10,2) NOT NULL,
    item_total NUMBER(10,2) NOT NULL,
    special_instructions VARCHAR(500),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (order_id) REFERENCES DINING_ORDERS(order_id),
    FOREIGN KEY (menu_item_id) REFERENCES MENU_ITEMS(menu_item_id)
);

-- ============================================================================
-- SPA_SERVICES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SPA_SERVICES (
    service_id VARCHAR(20) PRIMARY KEY,
    service_name VARCHAR(200) NOT NULL,
    service_category VARCHAR(50) NOT NULL,
    service_description VARCHAR(2000),
    duration_minutes NUMBER(4,0) NOT NULL,
    price NUMBER(10,2) NOT NULL,
    therapist_required BOOLEAN DEFAULT TRUE,
    room_type VARCHAR(50),
    max_guests NUMBER(3,0) DEFAULT 1,
    is_signature BOOLEAN DEFAULT FALSE,
    is_package BOOLEAN DEFAULT FALSE,
    service_status VARCHAR(30) DEFAULT 'AVAILABLE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- SPA_THERAPISTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SPA_THERAPISTS (
    therapist_id VARCHAR(20) PRIMARY KEY,
    therapist_name VARCHAR(200) NOT NULL,
    email VARCHAR(200),
    phone VARCHAR(30),
    specializations VARCHAR(500),
    certifications VARCHAR(1000),
    hire_date DATE,
    therapist_status VARCHAR(30) DEFAULT 'ACTIVE',
    avg_rating NUMBER(3,2),
    total_appointments NUMBER(8,0) DEFAULT 0,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- SPA_APPOINTMENTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SPA_APPOINTMENTS (
    appointment_id VARCHAR(30) PRIMARY KEY,
    guest_id VARCHAR(30) NOT NULL,
    reservation_id VARCHAR(30),
    service_id VARCHAR(20) NOT NULL,
    therapist_id VARCHAR(20),
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room_number VARCHAR(20),
    guests_in_party NUMBER(3,0) DEFAULT 1,
    appointment_status VARCHAR(30) DEFAULT 'CONFIRMED',
    cancellation_date TIMESTAMP_NTZ,
    cancellation_reason VARCHAR(500),
    no_show BOOLEAN DEFAULT FALSE,
    check_in_time TIME,
    special_requests VARCHAR(1000),
    health_notes VARCHAR(2000),
    price NUMBER(10,2) NOT NULL,
    discount_amount NUMBER(10,2) DEFAULT 0.00,
    tip_amount NUMBER(10,2) DEFAULT 0.00,
    total_amount NUMBER(10,2) NOT NULL,
    payment_method VARCHAR(50),
    is_room_charge BOOLEAN DEFAULT FALSE,
    is_comp BOOLEAN DEFAULT FALSE,
    rating NUMBER(3,0),
    booking_source VARCHAR(50),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id),
    FOREIGN KEY (service_id) REFERENCES SPA_SERVICES(service_id),
    FOREIGN KEY (therapist_id) REFERENCES SPA_THERAPISTS(therapist_id)
);

-- ============================================================================
-- GAMING_PLAYERS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE GAMING_PLAYERS (
    player_id VARCHAR(30) PRIMARY KEY,
    guest_id VARCHAR(30) NOT NULL,
    player_card_number VARCHAR(30) NOT NULL,
    player_tier VARCHAR(30) DEFAULT 'MEMBER',
    theoretical_daily_value NUMBER(10,2) DEFAULT 0.00,
    actual_daily_value NUMBER(10,2) DEFAULT 0.00,
    total_coin_in NUMBER(15,2) DEFAULT 0.00,
    total_coin_out NUMBER(15,2) DEFAULT 0.00,
    total_table_buy_in NUMBER(15,2) DEFAULT 0.00,
    total_table_win_loss NUMBER(15,2) DEFAULT 0.00,
    comp_balance NUMBER(10,2) DEFAULT 0.00,
    comp_earned_ytd NUMBER(12,2) DEFAULT 0.00,
    comp_redeemed_ytd NUMBER(12,2) DEFAULT 0.00,
    primary_game_type VARCHAR(50),
    average_bet NUMBER(10,2),
    visit_frequency NUMBER(5,0),
    last_play_date DATE,
    enrollment_date DATE NOT NULL,
    player_status VARCHAR(30) DEFAULT 'ACTIVE',
    host_id VARCHAR(20),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id)
);

-- ============================================================================
-- GAMING_TRANSACTIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE GAMING_TRANSACTIONS (
    transaction_id VARCHAR(30) PRIMARY KEY,
    player_id VARCHAR(30) NOT NULL,
    guest_id VARCHAR(30) NOT NULL,
    reservation_id VARCHAR(30),
    transaction_date TIMESTAMP_NTZ NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    game_type VARCHAR(50),
    table_or_machine_id VARCHAR(30),
    buy_in_amount NUMBER(12,2) DEFAULT 0.00,
    cash_out_amount NUMBER(12,2) DEFAULT 0.00,
    coin_in NUMBER(12,2) DEFAULT 0.00,
    coin_out NUMBER(12,2) DEFAULT 0.00,
    theoretical_win NUMBER(10,2) DEFAULT 0.00,
    actual_win_loss NUMBER(12,2) DEFAULT 0.00,
    comp_earned NUMBER(10,2) DEFAULT 0.00,
    session_duration_minutes NUMBER(6,0),
    average_bet NUMBER(10,2),
    hands_played NUMBER(8,0),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (player_id) REFERENCES GAMING_PLAYERS(player_id),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id)
);

-- ============================================================================
-- EVENT_VENUES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE EVENT_VENUES (
    venue_id VARCHAR(20) PRIMARY KEY,
    venue_name VARCHAR(200) NOT NULL,
    venue_type VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    floor_number NUMBER(3,0),
    capacity_theater NUMBER(6,0),
    capacity_classroom NUMBER(6,0),
    capacity_banquet NUMBER(6,0),
    capacity_reception NUMBER(6,0),
    square_feet NUMBER(8,0),
    ceiling_height NUMBER(4,1),
    has_natural_light BOOLEAN DEFAULT FALSE,
    has_av_equipment BOOLEAN DEFAULT TRUE,
    hourly_rate NUMBER(10,2),
    daily_rate NUMBER(12,2),
    venue_status VARCHAR(30) DEFAULT 'AVAILABLE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- EVENTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE EVENTS (
    event_id VARCHAR(30) PRIMARY KEY,
    event_name VARCHAR(500) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    venue_id VARCHAR(20) NOT NULL,
    organizer_name VARCHAR(200),
    organizer_company VARCHAR(200),
    organizer_email VARCHAR(200),
    organizer_phone VARCHAR(30),
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    setup_time TIME,
    teardown_time TIME,
    expected_attendance NUMBER(6,0),
    actual_attendance NUMBER(6,0),
    event_status VARCHAR(30) DEFAULT 'CONFIRMED',
    cancellation_date TIMESTAMP_NTZ,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (venue_id) REFERENCES EVENT_VENUES(venue_id)
);

-- ============================================================================
-- EVENT_BOOKINGS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE EVENT_BOOKINGS (
    booking_id VARCHAR(30) PRIMARY KEY,
    event_id VARCHAR(30) NOT NULL,
    guest_id VARCHAR(30),
    booking_type VARCHAR(50) NOT NULL,
    contract_amount NUMBER(15,2) NOT NULL,
    deposit_amount NUMBER(12,2) DEFAULT 0.00,
    catering_revenue NUMBER(12,2) DEFAULT 0.00,
    av_revenue NUMBER(10,2) DEFAULT 0.00,
    room_rental_revenue NUMBER(10,2) DEFAULT 0.00,
    other_revenue NUMBER(10,2) DEFAULT 0.00,
    total_revenue NUMBER(15,2) NOT NULL,
    payment_status VARCHAR(30) DEFAULT 'PENDING',
    contract_signed_date DATE,
    booking_source VARCHAR(50),
    booking_status VARCHAR(30) DEFAULT 'CONFIRMED',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (event_id) REFERENCES EVENTS(event_id),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id)
);

-- ============================================================================
-- STAFF TABLE
-- ============================================================================
CREATE OR REPLACE TABLE STAFF (
    staff_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL,
    phone VARCHAR(30),
    department VARCHAR(50) NOT NULL,
    position VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,
    manager_id VARCHAR(20),
    hourly_rate NUMBER(8,2),
    employee_type VARCHAR(30) DEFAULT 'FULL_TIME',
    shift VARCHAR(30),
    performance_rating NUMBER(3,2),
    staff_status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- GUEST_FEEDBACK TABLE
-- ============================================================================
CREATE OR REPLACE TABLE GUEST_FEEDBACK (
    feedback_id VARCHAR(30) PRIMARY KEY,
    guest_id VARCHAR(30) NOT NULL,
    reservation_id VARCHAR(30),
    feedback_date TIMESTAMP_NTZ NOT NULL,
    feedback_type VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    overall_rating NUMBER(3,0),
    room_rating NUMBER(3,0),
    cleanliness_rating NUMBER(3,0),
    service_rating NUMBER(3,0),
    dining_rating NUMBER(3,0),
    spa_rating NUMBER(3,0),
    value_rating NUMBER(3,0),
    likelihood_to_recommend NUMBER(3,0),
    feedback_comments VARCHAR(5000),
    staff_id VARCHAR(20),
    response_date TIMESTAMP_NTZ,
    response_text VARCHAR(2000),
    issue_resolved BOOLEAN,
    follow_up_required BOOLEAN DEFAULT FALSE,
    feedback_source VARCHAR(50),
    feedback_status VARCHAR(30) DEFAULT 'NEW',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id),
    FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id)
);

-- ============================================================================
-- AMENITY_USAGE TABLE
-- ============================================================================
CREATE OR REPLACE TABLE AMENITY_USAGE (
    usage_id VARCHAR(30) PRIMARY KEY,
    guest_id VARCHAR(30) NOT NULL,
    reservation_id VARCHAR(30),
    amenity_type VARCHAR(50) NOT NULL,
    amenity_name VARCHAR(100) NOT NULL,
    usage_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    duration_minutes NUMBER(5,0),
    usage_fee NUMBER(10,2) DEFAULT 0.00,
    is_comp BOOLEAN DEFAULT FALSE,
    equipment_used VARCHAR(500),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id)
);

-- ============================================================================
-- ROOM_SERVICE_ORDERS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE ROOM_SERVICE_ORDERS (
    order_id VARCHAR(30) PRIMARY KEY,
    guest_id VARCHAR(30) NOT NULL,
    reservation_id VARCHAR(30) NOT NULL,
    room_id VARCHAR(20) NOT NULL,
    order_date TIMESTAMP_NTZ NOT NULL,
    order_time TIME NOT NULL,
    delivery_time TIME,
    items_ordered VARCHAR(2000),
    subtotal NUMBER(10,2) NOT NULL,
    delivery_fee NUMBER(8,2) DEFAULT 0.00,
    tax_amount NUMBER(8,2) DEFAULT 0.00,
    tip_amount NUMBER(8,2) DEFAULT 0.00,
    total_amount NUMBER(10,2) NOT NULL,
    special_instructions VARCHAR(1000),
    order_status VARCHAR(30) DEFAULT 'DELIVERED',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id),
    FOREIGN KEY (room_id) REFERENCES ROOMS(room_id)
);

-- ============================================================================
-- HOUSEKEEPING_LOGS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE HOUSEKEEPING_LOGS (
    log_id VARCHAR(30) PRIMARY KEY,
    room_id VARCHAR(20) NOT NULL,
    staff_id VARCHAR(20) NOT NULL,
    service_date DATE NOT NULL,
    service_type VARCHAR(50) NOT NULL,
    start_time TIME,
    end_time TIME,
    duration_minutes NUMBER(5,0),
    inspection_passed BOOLEAN DEFAULT TRUE,
    inspector_id VARCHAR(20),
    notes VARCHAR(1000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (room_id) REFERENCES ROOMS(room_id),
    FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id)
);

-- ============================================================================
-- MARKETING_CAMPAIGNS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE MARKETING_CAMPAIGNS (
    campaign_id VARCHAR(30) PRIMARY KEY,
    campaign_name VARCHAR(200) NOT NULL,
    campaign_type VARCHAR(50) NOT NULL,
    target_segment VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE,
    budget NUMBER(12,2),
    channel VARCHAR(50),
    offer_description VARCHAR(1000),
    discount_percentage NUMBER(5,2),
    promo_code VARCHAR(30),
    campaign_status VARCHAR(30) DEFAULT 'ACTIVE',
    impressions NUMBER(12,0) DEFAULT 0,
    clicks NUMBER(10,0) DEFAULT 0,
    conversions NUMBER(8,0) DEFAULT 0,
    revenue_generated NUMBER(15,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- GUEST_CAMPAIGN_INTERACTIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE GUEST_CAMPAIGN_INTERACTIONS (
    interaction_id VARCHAR(30) PRIMARY KEY,
    guest_id VARCHAR(30) NOT NULL,
    campaign_id VARCHAR(30) NOT NULL,
    interaction_date TIMESTAMP_NTZ NOT NULL,
    interaction_type VARCHAR(50) NOT NULL,
    channel VARCHAR(50),
    converted BOOLEAN DEFAULT FALSE,
    reservation_id VARCHAR(30),
    revenue_attributed NUMBER(12,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (guest_id) REFERENCES GUESTS(guest_id),
    FOREIGN KEY (campaign_id) REFERENCES MARKETING_CAMPAIGNS(campaign_id),
    FOREIGN KEY (reservation_id) REFERENCES RESERVATIONS(reservation_id)
);

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All tables created successfully' AS status;

