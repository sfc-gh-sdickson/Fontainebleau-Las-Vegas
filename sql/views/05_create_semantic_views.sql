-- ============================================================================
-- Fontainebleau Las Vegas Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Create semantic views for Snowflake Intelligence agents
-- All syntax VERIFIED against official documentation:
-- https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
-- 
-- CRITICAL SYNTAX RULE:
-- Dimensions/Metrics: <table_alias>.<semantic_name> AS <sql_expression>
--   - semantic_name = the NAME you want for the dimension/metric
--   - sql_expression = the SQL to compute it (column name or expression)
-- 
-- Clause order is MANDATORY: TABLES → RELATIONSHIPS → FACTS → DIMENSIONS → METRICS → COMMENT
-- All synonyms are GLOBALLY UNIQUE across all semantic views
-- ============================================================================

USE DATABASE FONTAINEBLEAU_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE FONTAINEBLEAU_WH;

-- ============================================================================
-- Semantic View 1: Guest & Reservation Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_GUEST_RESERVATION_INTELLIGENCE
  TABLES (
    guests AS RAW.GUESTS
      PRIMARY KEY (guest_id)
      WITH SYNONYMS ('hotel guests', 'customers', 'patrons')
      COMMENT = 'Guest profiles and contact information',
    reservations AS RAW.RESERVATIONS
      PRIMARY KEY (reservation_id)
      WITH SYNONYMS ('bookings', 'room reservations', 'stays')
      COMMENT = 'Room reservation details',
    room_types AS RAW.ROOM_TYPES
      PRIMARY KEY (room_type_id)
      WITH SYNONYMS ('room categories', 'accommodation types', 'room configurations')
      COMMENT = 'Room type catalog and pricing',
    rooms AS RAW.ROOMS
      PRIMARY KEY (room_id)
      WITH SYNONYMS ('hotel rooms', 'accommodations', 'room inventory')
      COMMENT = 'Physical room inventory',
    loyalty AS RAW.LOYALTY_PROGRAM
      PRIMARY KEY (loyalty_id)
      WITH SYNONYMS ('rewards program', 'loyalty members', 'member benefits')
      COMMENT = 'Loyalty program membership and points',
    feedback AS RAW.GUEST_FEEDBACK
      PRIMARY KEY (feedback_id)
      WITH SYNONYMS ('guest reviews', 'satisfaction surveys', 'guest ratings')
      COMMENT = 'Guest satisfaction feedback and ratings'
  )
  RELATIONSHIPS (
    reservations(guest_id) REFERENCES guests(guest_id),
    reservations(room_type_id) REFERENCES room_types(room_type_id),
    reservations(room_id) REFERENCES rooms(room_id),
    rooms(room_type_id) REFERENCES room_types(room_type_id),
    loyalty(guest_id) REFERENCES guests(guest_id),
    feedback(guest_id) REFERENCES guests(guest_id),
    feedback(reservation_id) REFERENCES reservations(reservation_id)
  )
  DIMENSIONS (
    -- Guest dimensions (semantic_name AS sql_expression)
    guests.guest_id AS guest_id
      WITH SYNONYMS ('customer id', 'patron id')
      COMMENT = 'Unique guest identifier',
    guests.guest_first_name AS first_name
      WITH SYNONYMS ('given name', 'customer first name')
      COMMENT = 'Guest first name',
    guests.guest_last_name AS last_name
      WITH SYNONYMS ('surname', 'family name', 'customer last name')
      COMMENT = 'Guest last name',
    guests.guest_city AS city
      WITH SYNONYMS ('home city', 'origin city')
      COMMENT = 'Guest home city',
    guests.guest_state AS state
      WITH SYNONYMS ('home state', 'origin state')
      COMMENT = 'Guest home state',
    guests.guest_country AS country
      WITH SYNONYMS ('home country', 'nationality')
      COMMENT = 'Guest home country',
    guests.guest_type AS guest_type
      WITH SYNONYMS ('traveler type', 'customer segment')
      COMMENT = 'Guest type: LEISURE, BUSINESS, GAMING, GROUP',
    guests.loyalty_tier AS loyalty_tier
      WITH SYNONYMS ('member tier', 'rewards level', 'membership status')
      COMMENT = 'Loyalty tier: MEMBER, SILVER, GOLD, PLATINUM',
    guests.vip_status AS vip_status
      WITH SYNONYMS ('vip guest', 'special status', 'priority guest')
      COMMENT = 'Whether guest has VIP status',
    guests.guest_status AS guest_status
      WITH SYNONYMS ('account status', 'profile status')
      COMMENT = 'Guest account status: ACTIVE, INACTIVE',
    -- Reservation dimensions
    reservations.confirmation_number AS confirmation_number
      WITH SYNONYMS ('booking number', 'reservation code', 'conf number')
      COMMENT = 'Reservation confirmation number',
    reservations.check_in_date AS check_in_date
      WITH SYNONYMS ('arrival date', 'start date')
      COMMENT = 'Reservation check-in date',
    reservations.check_out_date AS check_out_date
      WITH SYNONYMS ('departure date', 'end date')
      COMMENT = 'Reservation check-out date',
    reservations.reservation_status AS reservation_status
      WITH SYNONYMS ('booking status', 'stay status')
      COMMENT = 'Status: CONFIRMED, CHECKED_OUT, CANCELLED, NO_SHOW',
    reservations.booking_source AS booking_source
      WITH SYNONYMS ('reservation source', 'channel source')
      COMMENT = 'Source: WEBSITE, OTA, PHONE, MOBILE_APP, WALK_IN',
    reservations.booking_channel AS booking_channel
      WITH SYNONYMS ('distribution channel', 'sales channel')
      COMMENT = 'Channel: DIRECT, EXPEDIA, BOOKING.COM, etc.',
    reservations.rate_code AS rate_code
      WITH SYNONYMS ('pricing code', 'rate plan code')
      COMMENT = 'Rate code applied to reservation',
    reservations.rate_type AS rate_type
      WITH SYNONYMS ('pricing type', 'rate category')
      COMMENT = 'Rate type: BAR, ADVANCE_PURCHASE, PACKAGE',
    reservations.travel_purpose AS travel_purpose
      WITH SYNONYMS ('trip purpose', 'reason for stay')
      COMMENT = 'Purpose: LEISURE, BUSINESS, GAMING, EVENT',
    reservations.is_group_booking AS is_group_booking
      WITH SYNONYMS ('group reservation', 'block booking')
      COMMENT = 'Whether reservation is part of a group',
    -- Room type dimensions
    room_types.room_type_name AS room_type_name
      WITH SYNONYMS ('room category name', 'accommodation name')
      COMMENT = 'Name of the room type',
    room_types.room_category AS room_category
      WITH SYNONYMS ('tier', 'room tier', 'accommodation tier')
      COMMENT = 'Category: STANDARD, PREMIUM, SUITE, LUXURY, ACCESSIBLE',
    room_types.view_type AS view_type
      WITH SYNONYMS ('room view', 'window view')
      COMMENT = 'View: CITY, STRIP, PANORAMIC, FOUNTAIN, POOL',
    room_types.is_suite AS is_suite
      WITH SYNONYMS ('suite room', 'suite accommodation')
      COMMENT = 'Whether room type is a suite',
    -- Room dimensions
    rooms.room_number AS room_number
      WITH SYNONYMS ('room no', 'unit number')
      COMMENT = 'Physical room number',
    rooms.floor_number AS floor_number
      WITH SYNONYMS ('room floor', 'level')
      COMMENT = 'Floor the room is on',
    rooms.tower AS tower
      WITH SYNONYMS ('building', 'hotel tower')
      COMMENT = 'Tower: BLEU TOWER, BLANC TOWER',
    -- Loyalty dimensions
    loyalty.loyalty_current_tier AS current_tier
      WITH SYNONYMS ('rewards tier', 'program tier')
      COMMENT = 'Current loyalty program tier',
    -- Feedback dimensions
    feedback.feedback_type AS feedback_type
      WITH SYNONYMS ('survey type', 'review type')
      COMMENT = 'Feedback type: SURVEY, EMAIL, PHONE, SOCIAL_MEDIA',
    feedback.feedback_department AS department
      WITH SYNONYMS ('service area', 'department reviewed')
      COMMENT = 'Department the feedback relates to',
    feedback.feedback_status AS feedback_status
      WITH SYNONYMS ('review status', 'resolution status')
      COMMENT = 'Feedback status: NEW, CLOSED'
  )
  METRICS (
    -- Guest metrics (semantic_name AS aggregation_expression)
    guests.total_guests AS COUNT(DISTINCT guest_id)
      WITH SYNONYMS ('guest count', 'customer count', 'patron count')
      COMMENT = 'Total number of guests',
    guests.total_stays AS SUM(total_stays)
      WITH SYNONYMS ('cumulative stays', 'visit count')
      COMMENT = 'Total number of stays across guests',
    guests.avg_total_spend AS AVG(total_spend)
      WITH SYNONYMS ('average guest spend', 'mean customer spend')
      COMMENT = 'Average total spend per guest',
    guests.total_lifetime_value AS SUM(lifetime_value)
      WITH SYNONYMS ('cumulative ltv', 'total customer value')
      COMMENT = 'Sum of guest lifetime values',
    -- Reservation metrics
    reservations.total_reservations AS COUNT(DISTINCT reservation_id)
      WITH SYNONYMS ('booking count', 'reservation count')
      COMMENT = 'Total number of reservations',
    reservations.total_room_nights AS SUM(nights)
      WITH SYNONYMS ('room nights sold', 'nights booked')
      COMMENT = 'Total room nights',
    reservations.total_room_revenue AS SUM(total_room_revenue)
      WITH SYNONYMS ('room revenue', 'accommodation revenue')
      COMMENT = 'Total room revenue',
    reservations.avg_room_rate AS AVG(room_rate)
      WITH SYNONYMS ('average daily rate', 'mean room rate', 'adr')
      COMMENT = 'Average room rate',
    reservations.avg_nights AS AVG(nights)
      WITH SYNONYMS ('average length of stay', 'mean stay duration', 'alos')
      COMMENT = 'Average number of nights per stay',
    reservations.avg_adults AS AVG(adults)
      WITH SYNONYMS ('average adults per booking', 'mean adult count')
      COMMENT = 'Average number of adults per reservation',
    -- Room type metrics
    room_types.total_room_types AS COUNT(DISTINCT room_type_id)
      WITH SYNONYMS ('room type count', 'category count')
      COMMENT = 'Total number of room types',
    room_types.avg_base_rate AS AVG(base_rate)
      WITH SYNONYMS ('average list price', 'mean base rate')
      COMMENT = 'Average base rate across room types',
    -- Room metrics
    rooms.total_rooms AS COUNT(DISTINCT room_id)
      WITH SYNONYMS ('room inventory', 'room count')
      COMMENT = 'Total number of rooms',
    -- Loyalty metrics
    loyalty.avg_points_balance AS AVG(points_balance)
      WITH SYNONYMS ('average points', 'mean point balance')
      COMMENT = 'Average loyalty points balance',
    loyalty.total_points_earned_ytd AS SUM(points_earned_ytd)
      WITH SYNONYMS ('points earned this year', 'ytd points')
      COMMENT = 'Total points earned year to date',
    -- Feedback metrics
    feedback.total_feedback AS COUNT(DISTINCT feedback_id)
      WITH SYNONYMS ('feedback count', 'survey count')
      COMMENT = 'Total number of feedback submissions',
    feedback.avg_overall_rating AS AVG(overall_rating)
      WITH SYNONYMS ('average satisfaction', 'mean rating')
      COMMENT = 'Average overall rating (1-5)',
    feedback.avg_nps AS AVG(likelihood_to_recommend)
      WITH SYNONYMS ('average nps score', 'net promoter score')
      COMMENT = 'Average likelihood to recommend (1-10)'
  )
  COMMENT = 'Guest & Reservation Intelligence - comprehensive view of guests, reservations, rooms, loyalty, and feedback';

-- ============================================================================
-- Semantic View 2: Revenue & Operations Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_REVENUE_OPERATIONS_INTELLIGENCE
  TABLES (
    guests AS RAW.GUESTS
      PRIMARY KEY (guest_id)
      WITH SYNONYMS ('dining guests', 'spa guests', 'gaming guests')
      COMMENT = 'Guests using hotel services',
    restaurants AS RAW.RESTAURANTS
      PRIMARY KEY (restaurant_id)
      WITH SYNONYMS ('dining venues', 'food outlets', 'restaurant outlets')
      COMMENT = 'Restaurant and bar venues',
    dining_orders AS RAW.DINING_ORDERS
      PRIMARY KEY (order_id)
      WITH SYNONYMS ('food orders', 'restaurant checks', 'dining transactions')
      COMMENT = 'Dining order transactions',
    spa_services AS RAW.SPA_SERVICES
      PRIMARY KEY (service_id)
      WITH SYNONYMS ('spa treatments', 'wellness services', 'spa offerings')
      COMMENT = 'Spa service catalog',
    spa_appointments AS RAW.SPA_APPOINTMENTS
      PRIMARY KEY (appointment_id)
      WITH SYNONYMS ('spa bookings', 'treatment appointments', 'spa reservations')
      COMMENT = 'Spa appointment bookings',
    gaming_players AS RAW.GAMING_PLAYERS
      PRIMARY KEY (player_id)
      WITH SYNONYMS ('casino players', 'gaming members', 'player club members')
      COMMENT = 'Gaming player profiles',
    gaming_transactions AS RAW.GAMING_TRANSACTIONS
      PRIMARY KEY (transaction_id)
      WITH SYNONYMS ('gaming activity', 'casino transactions', 'player activity')
      COMMENT = 'Gaming transaction records',
    events AS RAW.EVENTS
      PRIMARY KEY (event_id)
      WITH SYNONYMS ('meetings and events', 'conferences', 'banquets')
      COMMENT = 'Event and meeting bookings',
    event_bookings AS RAW.EVENT_BOOKINGS
      PRIMARY KEY (booking_id)
      WITH SYNONYMS ('event contracts', 'catering bookings', 'group bookings')
      COMMENT = 'Event booking and revenue details'
  )
  RELATIONSHIPS (
    dining_orders(guest_id) REFERENCES guests(guest_id),
    dining_orders(restaurant_id) REFERENCES restaurants(restaurant_id),
    spa_appointments(guest_id) REFERENCES guests(guest_id),
    spa_appointments(service_id) REFERENCES spa_services(service_id),
    gaming_players(guest_id) REFERENCES guests(guest_id),
    gaming_transactions(player_id) REFERENCES gaming_players(player_id),
    gaming_transactions(guest_id) REFERENCES guests(guest_id),
    event_bookings(event_id) REFERENCES events(event_id),
    event_bookings(guest_id) REFERENCES guests(guest_id)
  )
  DIMENSIONS (
    -- Guest dimensions for revenue context
    guests.revenue_guest_type AS guest_type
      WITH SYNONYMS ('revenue customer type', 'spending segment')
      COMMENT = 'Guest type for revenue analysis',
    guests.revenue_loyalty_tier AS loyalty_tier
      WITH SYNONYMS ('spending tier', 'revenue member level')
      COMMENT = 'Loyalty tier for revenue analysis',
    -- Restaurant dimensions
    restaurants.restaurant_name AS restaurant_name
      WITH SYNONYMS ('venue name', 'outlet name', 'dining venue')
      COMMENT = 'Name of the restaurant',
    restaurants.cuisine_type AS cuisine_type
      WITH SYNONYMS ('food type', 'restaurant style')
      COMMENT = 'Type of cuisine served',
    restaurants.meal_period AS meal_period
      WITH SYNONYMS ('service period', 'dining time')
      COMMENT = 'Meal period: BREAKFAST, LUNCH, DINNER, ALL_DAY',
    restaurants.price_range AS price_range
      WITH SYNONYMS ('pricing level', 'cost tier')
      COMMENT = 'Price range: $, $$, $$$, $$$$, $$$$$',
    -- Dining order dimensions
    dining_orders.order_type AS order_type
      WITH SYNONYMS ('dining type', 'service type')
      COMMENT = 'Order type: DINE_IN, TAKEOUT, DELIVERY',
    dining_orders.dining_payment_method AS payment_method
      WITH SYNONYMS ('payment type', 'transaction method')
      COMMENT = 'Payment method used',
    dining_orders.is_room_charge AS is_room_charge
      WITH SYNONYMS ('charged to room', 'room folio charge')
      COMMENT = 'Whether order was charged to room',
    dining_orders.is_dining_comp AS is_comp
      WITH SYNONYMS ('complimentary dining', 'comped meal')
      COMMENT = 'Whether order was complimentary',
    -- Spa dimensions
    spa_services.spa_service_name AS service_name
      WITH SYNONYMS ('treatment name', 'wellness service')
      COMMENT = 'Name of the spa service',
    spa_services.spa_category AS service_category
      WITH SYNONYMS ('treatment category', 'service type spa')
      COMMENT = 'Category: MASSAGE, FACIAL, BODY_TREATMENT, NAIL, PACKAGE',
    spa_appointments.spa_appointment_status AS appointment_status
      WITH SYNONYMS ('treatment status', 'spa booking status')
      COMMENT = 'Status: CONFIRMED, COMPLETED, CANCELLED, NO_SHOW',
    spa_appointments.spa_booking_source AS booking_source
      WITH SYNONYMS ('spa reservation source', 'how booked spa')
      COMMENT = 'How spa appointment was booked',
    -- Gaming dimensions
    gaming_players.player_tier AS player_tier
      WITH SYNONYMS ('casino tier', 'gaming level')
      COMMENT = 'Gaming player tier: MEMBER, SILVER, GOLD, PLATINUM',
    gaming_players.primary_game_type AS primary_game_type
      WITH SYNONYMS ('favorite game', 'preferred game')
      COMMENT = 'Primary game: SLOTS, BLACKJACK, POKER, BACCARAT, CRAPS',
    gaming_transactions.gaming_transaction_type AS transaction_type
      WITH SYNONYMS ('activity type', 'gaming action')
      COMMENT = 'Transaction type: SLOTS_PLAY, TABLE_PLAY, BUY_IN, CASH_OUT',
    gaming_transactions.game_type AS game_type
      WITH SYNONYMS ('game played', 'casino game')
      COMMENT = 'Type of game played',
    -- Event dimensions
    events.event_name AS event_name
      WITH SYNONYMS ('function name', 'meeting name')
      COMMENT = 'Name of the event',
    events.event_type AS event_type
      WITH SYNONYMS ('function type', 'meeting type')
      COMMENT = 'Type: CORPORATE, WEDDING, SOCIAL, CONFERENCE, GALA',
    events.event_status AS event_status
      WITH SYNONYMS ('function status', 'booking status')
      COMMENT = 'Event status: CONFIRMED, COMPLETED, CANCELLED',
    event_bookings.event_booking_type AS booking_type
      WITH SYNONYMS ('contract type', 'event classification')
      COMMENT = 'Type of event booking',
    event_bookings.event_payment_status AS payment_status
      WITH SYNONYMS ('payment state', 'invoice status')
      COMMENT = 'Payment status: PENDING, DEPOSIT_RECEIVED, PAID'
  )
  METRICS (
    -- Dining metrics
    dining_orders.total_orders AS COUNT(DISTINCT order_id)
      WITH SYNONYMS ('order count', 'transaction count')
      COMMENT = 'Total number of dining orders',
    dining_orders.total_covers AS SUM(covers)
      WITH SYNONYMS ('guest covers', 'diners served')
      COMMENT = 'Total number of covers (diners)',
    dining_orders.total_dining_revenue AS SUM(total_amount)
      WITH SYNONYMS ('food and beverage revenue', 'fb revenue')
      COMMENT = 'Total dining revenue',
    dining_orders.avg_check AS AVG(total_amount)
      WITH SYNONYMS ('average check amount', 'mean order value')
      COMMENT = 'Average dining order amount',
    dining_orders.total_tips AS SUM(tip_amount)
      WITH SYNONYMS ('gratuities', 'tip revenue')
      COMMENT = 'Total tip amount',
    -- Spa metrics
    spa_services.total_services AS COUNT(DISTINCT service_id)
      WITH SYNONYMS ('service count', 'treatment count')
      COMMENT = 'Total number of spa services offered',
    spa_appointments.total_spa_appointments AS COUNT(DISTINCT appointment_id)
      WITH SYNONYMS ('treatment count appointments', 'spa booking count')
      COMMENT = 'Total number of spa appointments',
    spa_appointments.total_spa_revenue AS SUM(total_amount)
      WITH SYNONYMS ('wellness revenue', 'spa sales')
      COMMENT = 'Total spa revenue',
    spa_appointments.avg_spa_transaction AS AVG(total_amount)
      WITH SYNONYMS ('average spa sale', 'mean treatment value')
      COMMENT = 'Average spa transaction amount',
    spa_appointments.avg_spa_rating AS AVG(rating)
      WITH SYNONYMS ('spa service rating', 'treatment rating')
      COMMENT = 'Average spa service rating',
    -- Gaming metrics
    gaming_players.total_players AS COUNT(DISTINCT player_id)
      WITH SYNONYMS ('player count', 'casino member count')
      COMMENT = 'Total number of gaming players',
    gaming_players.avg_theoretical_value AS AVG(theoretical_daily_value)
      WITH SYNONYMS ('average theo', 'mean theoretical win')
      COMMENT = 'Average theoretical daily value',
    gaming_players.total_coin_in_all AS SUM(total_coin_in)
      WITH SYNONYMS ('total handle', 'cumulative coin in')
      COMMENT = 'Total coin in across all players',
    gaming_transactions.total_gaming_transactions AS COUNT(DISTINCT transaction_id)
      WITH SYNONYMS ('gaming session count', 'play count')
      COMMENT = 'Total number of gaming transactions',
    gaming_transactions.total_buy_ins AS SUM(buy_in_amount)
      WITH SYNONYMS ('total markers', 'cumulative buy ins')
      COMMENT = 'Total buy-in amounts',
    gaming_transactions.total_win_loss AS SUM(actual_win_loss)
      WITH SYNONYMS ('net gaming revenue', 'house hold')
      COMMENT = 'Total actual win/loss',
    -- Event metrics
    events.total_events AS COUNT(DISTINCT event_id)
      WITH SYNONYMS ('event count', 'function count')
      COMMENT = 'Total number of events',
    events.total_attendance AS SUM(actual_attendance)
      WITH SYNONYMS ('total attendees', 'cumulative attendance')
      COMMENT = 'Total event attendance',
    event_bookings.total_event_revenue AS SUM(total_revenue)
      WITH SYNONYMS ('function revenue', 'catering revenue')
      COMMENT = 'Total event revenue',
    event_bookings.avg_event_revenue AS AVG(total_revenue)
      WITH SYNONYMS ('average event value', 'mean function revenue')
      COMMENT = 'Average revenue per event'
  )
  COMMENT = 'Revenue & Operations Intelligence - comprehensive view of dining, spa, gaming, and events revenue';

-- ============================================================================
-- Semantic View 3: Guest Experience Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_GUEST_EXPERIENCE_INTELLIGENCE
  TABLES (
    guests AS RAW.GUESTS
      PRIMARY KEY (guest_id)
      WITH SYNONYMS ('experience guests', 'service guests', 'satisfaction guests')
      COMMENT = 'Guests for experience analysis',
    feedback AS RAW.GUEST_FEEDBACK
      PRIMARY KEY (feedback_id)
      WITH SYNONYMS ('experience feedback', 'service reviews', 'guest comments')
      COMMENT = 'Guest satisfaction and feedback',
    staff AS RAW.STAFF
      PRIMARY KEY (staff_id)
      WITH SYNONYMS ('employees', 'team members', 'associates')
      COMMENT = 'Hotel staff members',
    amenity_usage AS RAW.AMENITY_USAGE
      PRIMARY KEY (usage_id)
      WITH SYNONYMS ('facility usage', 'amenity visits', 'facility activity')
      COMMENT = 'Amenity usage tracking',
    reservations AS RAW.RESERVATIONS
      PRIMARY KEY (reservation_id)
      WITH SYNONYMS ('experience reservations', 'guest stays', 'service bookings')
      COMMENT = 'Reservation context for experience',
    campaigns AS RAW.MARKETING_CAMPAIGNS
      PRIMARY KEY (campaign_id)
      WITH SYNONYMS ('promotions', 'marketing offers', 'special offers')
      COMMENT = 'Marketing campaigns and promotions'
  )
  RELATIONSHIPS (
    feedback(guest_id) REFERENCES guests(guest_id),
    feedback(reservation_id) REFERENCES reservations(reservation_id),
    feedback(staff_id) REFERENCES staff(staff_id),
    amenity_usage(guest_id) REFERENCES guests(guest_id),
    amenity_usage(reservation_id) REFERENCES reservations(reservation_id),
    reservations(guest_id) REFERENCES guests(guest_id)
  )
  DIMENSIONS (
    -- Guest experience dimensions
    guests.experience_guest_type AS guest_type
      WITH SYNONYMS ('service guest type', 'satisfaction segment')
      COMMENT = 'Guest type for experience analysis',
    guests.experience_loyalty_tier AS loyalty_tier
      WITH SYNONYMS ('experience member tier', 'satisfaction tier')
      COMMENT = 'Loyalty tier for experience analysis',
    guests.experience_vip_status AS vip_status
      WITH SYNONYMS ('priority guest', 'special guest')
      COMMENT = 'VIP status for experience analysis',
    -- Feedback dimensions
    feedback.experience_feedback_type AS feedback_type
      WITH SYNONYMS ('review type experience', 'survey method')
      COMMENT = 'Type of feedback collected',
    feedback.department AS department
      WITH SYNONYMS ('service department', 'hotel department')
      COMMENT = 'Department the feedback relates to',
    feedback.feedback_source AS feedback_source
      WITH SYNONYMS ('review source', 'survey source')
      COMMENT = 'Source: EMAIL, POST_STAY_SURVEY, REVIEW_SITE, SOCIAL_MEDIA',
    feedback.follow_up_required AS follow_up_required
      WITH SYNONYMS ('needs follow up', 'action required')
      COMMENT = 'Whether feedback requires follow-up',
    feedback.issue_resolved AS issue_resolved
      WITH SYNONYMS ('problem fixed', 'complaint resolved')
      COMMENT = 'Whether any issues were resolved',
    -- Staff dimensions (VERIFIED: STAFF.department is the column name)
    staff.staff_department AS department
      WITH SYNONYMS ('employee department', 'team department')
      COMMENT = 'Staff department',
    staff.position AS position
      WITH SYNONYMS ('job title', 'role')
      COMMENT = 'Staff position/title',
    staff.employee_type AS employee_type
      WITH SYNONYMS ('employment type', 'work status')
      COMMENT = 'Employee type: FULL_TIME, PART_TIME',
    staff.shift AS shift
      WITH SYNONYMS ('work shift', 'schedule')
      COMMENT = 'Shift: DAY, SWING, NIGHT, ROTATING',
    staff.staff_status AS staff_status
      WITH SYNONYMS ('employee status', 'active status')
      COMMENT = 'Staff status: ACTIVE, INACTIVE',
    -- Amenity dimensions
    amenity_usage.amenity_type AS amenity_type
      WITH SYNONYMS ('facility type', 'amenity category')
      COMMENT = 'Type: POOL, FITNESS_CENTER, BUSINESS_CENTER, CABANA',
    amenity_usage.amenity_name AS amenity_name
      WITH SYNONYMS ('facility name', 'specific amenity')
      COMMENT = 'Name of the specific amenity',
    -- Campaign dimensions
    campaigns.campaign_name AS campaign_name
      WITH SYNONYMS ('offer name', 'promotion name')
      COMMENT = 'Marketing campaign name',
    campaigns.campaign_type AS campaign_type
      WITH SYNONYMS ('promotion type', 'offer type')
      COMMENT = 'Campaign type: SEASONAL, LOYALTY, PACKAGE, PROMOTIONAL',
    campaigns.target_segment AS target_segment
      WITH SYNONYMS ('audience', 'target audience')
      COMMENT = 'Target guest segment',
    campaigns.marketing_channel AS channel
      WITH SYNONYMS ('marketing channel', 'distribution method')
      COMMENT = 'Marketing channel used',
    campaigns.campaign_status AS campaign_status
      WITH SYNONYMS ('offer status', 'promotion status')
      COMMENT = 'Campaign status: ACTIVE, COMPLETED'
  )
  METRICS (
    -- Feedback metrics
    feedback.total_feedback_records AS COUNT(DISTINCT feedback_id)
      WITH SYNONYMS ('review count', 'survey responses')
      COMMENT = 'Total number of feedback records',
    feedback.avg_overall_satisfaction AS AVG(overall_rating)
      WITH SYNONYMS ('average overall score', 'mean satisfaction')
      COMMENT = 'Average overall satisfaction rating',
    feedback.avg_room_satisfaction AS AVG(room_rating)
      WITH SYNONYMS ('room rating average', 'accommodation score')
      COMMENT = 'Average room rating',
    feedback.avg_cleanliness_rating AS AVG(cleanliness_rating)
      WITH SYNONYMS ('cleanliness score', 'housekeeping rating')
      COMMENT = 'Average cleanliness rating',
    feedback.avg_service_satisfaction AS AVG(service_rating)
      WITH SYNONYMS ('service score', 'staff rating')
      COMMENT = 'Average service rating',
    feedback.avg_dining_satisfaction AS AVG(dining_rating)
      WITH SYNONYMS ('food rating', 'restaurant score')
      COMMENT = 'Average dining rating',
    feedback.avg_value_rating AS AVG(value_rating)
      WITH SYNONYMS ('value score', 'price satisfaction')
      COMMENT = 'Average value for money rating',
    feedback.avg_likelihood_recommend AS AVG(likelihood_to_recommend)
      WITH SYNONYMS ('nps average', 'recommendation score')
      COMMENT = 'Average NPS score (1-10)',
    -- Staff metrics
    staff.total_staff AS COUNT(DISTINCT staff_id)
      WITH SYNONYMS ('employee count', 'headcount')
      COMMENT = 'Total number of staff members',
    staff.avg_performance_rating AS AVG(performance_rating)
      WITH SYNONYMS ('staff performance', 'employee rating')
      COMMENT = 'Average staff performance rating',
    -- Amenity metrics
    amenity_usage.total_amenity_visits AS COUNT(DISTINCT usage_id)
      WITH SYNONYMS ('facility visits', 'amenity usage count')
      COMMENT = 'Total amenity usage records',
    amenity_usage.avg_usage_duration AS AVG(duration_minutes)
      WITH SYNONYMS ('average visit time', 'mean usage time')
      COMMENT = 'Average amenity usage duration in minutes',
    amenity_usage.total_amenity_fees AS SUM(usage_fee)
      WITH SYNONYMS ('facility fees', 'amenity revenue')
      COMMENT = 'Total amenity usage fees',
    -- Campaign metrics
    campaigns.total_campaigns AS COUNT(DISTINCT campaign_id)
      WITH SYNONYMS ('promotion count', 'offer count')
      COMMENT = 'Total number of marketing campaigns',
    campaigns.total_impressions AS SUM(impressions)
      WITH SYNONYMS ('ad views', 'reach')
      COMMENT = 'Total campaign impressions',
    campaigns.total_conversions AS SUM(conversions)
      WITH SYNONYMS ('bookings from campaigns', 'campaign bookings')
      COMMENT = 'Total campaign conversions',
    campaigns.total_campaign_revenue AS SUM(revenue_generated)
      WITH SYNONYMS ('marketing revenue', 'promotion revenue')
      COMMENT = 'Total revenue from campaigns'
  )
  COMMENT = 'Guest Experience Intelligence - comprehensive view of satisfaction, staff, amenities, and marketing effectiveness';

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All semantic views created successfully' AS status;
