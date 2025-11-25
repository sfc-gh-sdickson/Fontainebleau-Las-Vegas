-- ============================================================================
-- Fontainebleau Las Vegas Intelligence Agent - Analytical Views
-- ============================================================================
-- Purpose: Create curated analytical views for reporting and analysis
-- Syntax: Verified against Snowflake SQL Reference
-- ============================================================================

USE DATABASE FONTAINEBLEAU_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE FONTAINEBLEAU_WH;

-- ============================================================================
-- View 1: Guest 360 View
-- ============================================================================
CREATE OR REPLACE VIEW V_GUEST_360 AS
SELECT
    g.guest_id,
    g.first_name,
    g.last_name,
    g.first_name || ' ' || g.last_name AS full_name,
    g.email,
    g.phone,
    g.city,
    g.state,
    g.country,
    g.guest_type,
    g.loyalty_tier,
    g.loyalty_number,
    g.vip_status,
    g.total_stays,
    g.total_spend,
    g.lifetime_value,
    g.first_visit_date,
    g.last_visit_date,
    DATEDIFF('day', g.last_visit_date, CURRENT_DATE()) AS days_since_last_visit,
    lp.points_balance,
    lp.comp_dollars_balance,
    lp.free_night_credits,
    COUNT(DISTINCT r.reservation_id) AS total_reservations,
    SUM(r.total_room_revenue) AS total_room_revenue,
    AVG(r.room_rate) AS avg_room_rate,
    AVG(r.nights) AS avg_length_of_stay,
    COUNT(DISTINCT CASE WHEN r.reservation_status = 'CANCELLED' THEN r.reservation_id END) AS cancelled_reservations,
    COUNT(DISTINCT do.order_id) AS total_dining_orders,
    SUM(do.total_amount) AS total_dining_spend,
    COUNT(DISTINCT sa.appointment_id) AS total_spa_appointments,
    SUM(sa.total_amount) AS total_spa_spend,
    AVG(gf.overall_rating) AS avg_overall_rating,
    AVG(gf.likelihood_to_recommend) AS avg_nps_score
FROM RAW.GUESTS g
LEFT JOIN RAW.LOYALTY_PROGRAM lp ON g.guest_id = lp.guest_id
LEFT JOIN RAW.RESERVATIONS r ON g.guest_id = r.guest_id
LEFT JOIN RAW.DINING_ORDERS do ON g.guest_id = do.guest_id
LEFT JOIN RAW.SPA_APPOINTMENTS sa ON g.guest_id = sa.guest_id
LEFT JOIN RAW.GUEST_FEEDBACK gf ON g.guest_id = gf.guest_id
GROUP BY 
    g.guest_id, g.first_name, g.last_name, g.email, g.phone, g.city, g.state, g.country,
    g.guest_type, g.loyalty_tier, g.loyalty_number, g.vip_status, g.total_stays, 
    g.total_spend, g.lifetime_value, g.first_visit_date, g.last_visit_date,
    lp.points_balance, lp.comp_dollars_balance, lp.free_night_credits;

-- ============================================================================
-- View 2: Reservation Analytics
-- ============================================================================
CREATE OR REPLACE VIEW V_RESERVATION_ANALYTICS AS
SELECT
    r.reservation_id,
    r.confirmation_number,
    r.guest_id,
    g.first_name || ' ' || g.last_name AS guest_name,
    g.loyalty_tier,
    g.vip_status,
    r.room_id,
    rm.room_number,
    rt.room_type_name,
    rt.room_category,
    r.check_in_date,
    r.check_out_date,
    r.nights,
    r.adults,
    r.children,
    r.adults + r.children AS total_guests,
    r.rate_code,
    r.rate_type,
    r.room_rate,
    r.total_room_revenue,
    r.total_room_revenue / NULLIF(r.nights, 0) AS adr,
    r.reservation_status,
    r.booking_source,
    r.booking_channel,
    r.booking_date,
    DATEDIFF('day', r.booking_date, r.check_in_date) AS lead_time_days,
    r.is_group_booking,
    r.travel_purpose,
    r.payment_method,
    DATE_TRUNC('month', r.check_in_date) AS stay_month,
    DAYNAME(r.check_in_date) AS arrival_day,
    CASE WHEN DAYOFWEEK(r.check_in_date) IN (0, 6) THEN 'WEEKEND' ELSE 'WEEKDAY' END AS arrival_type
FROM RAW.RESERVATIONS r
JOIN RAW.GUESTS g ON r.guest_id = g.guest_id
LEFT JOIN RAW.ROOMS rm ON r.room_id = rm.room_id
JOIN RAW.ROOM_TYPES rt ON r.room_type_id = rt.room_type_id;

-- ============================================================================
-- View 3: Revenue Analytics
-- ============================================================================
CREATE OR REPLACE VIEW V_REVENUE_ANALYTICS AS
SELECT
    DATE_TRUNC('day', r.check_in_date) AS business_date,
    DATE_TRUNC('week', r.check_in_date) AS business_week,
    DATE_TRUNC('month', r.check_in_date) AS business_month,
    rt.room_category,
    rt.room_type_name,
    g.loyalty_tier,
    g.guest_type,
    r.booking_source,
    r.booking_channel,
    r.travel_purpose,
    COUNT(DISTINCT r.reservation_id) AS reservations,
    SUM(r.nights) AS room_nights_sold,
    SUM(r.total_room_revenue) AS room_revenue,
    AVG(r.room_rate) AS avg_daily_rate,
    SUM(r.total_room_revenue) / NULLIF(SUM(r.nights), 0) AS revpar,
    COUNT(DISTINCT r.guest_id) AS unique_guests,
    SUM(CASE WHEN r.is_group_booking THEN 1 ELSE 0 END) AS group_bookings,
    SUM(CASE WHEN r.reservation_status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancellations,
    SUM(CASE WHEN r.reservation_status = 'NO_SHOW' THEN 1 ELSE 0 END) AS no_shows
FROM RAW.RESERVATIONS r
JOIN RAW.GUESTS g ON r.guest_id = g.guest_id
JOIN RAW.ROOM_TYPES rt ON r.room_type_id = rt.room_type_id
WHERE r.reservation_status NOT IN ('CANCELLED', 'NO_SHOW')
GROUP BY 
    DATE_TRUNC('day', r.check_in_date),
    DATE_TRUNC('week', r.check_in_date),
    DATE_TRUNC('month', r.check_in_date),
    rt.room_category, rt.room_type_name,
    g.loyalty_tier, g.guest_type,
    r.booking_source, r.booking_channel, r.travel_purpose;

-- ============================================================================
-- View 4: Dining Performance
-- ============================================================================
CREATE OR REPLACE VIEW V_DINING_PERFORMANCE AS
SELECT
    rest.restaurant_id,
    rest.restaurant_name,
    rest.cuisine_type,
    rest.meal_period,
    rest.price_range,
    DATE_TRUNC('day', do.order_date) AS business_date,
    DATE_TRUNC('month', do.order_date) AS business_month,
    do.order_type,
    COUNT(DISTINCT do.order_id) AS total_orders,
    SUM(do.covers) AS total_covers,
    SUM(do.subtotal) AS gross_revenue,
    SUM(do.discount_amount) AS total_discounts,
    SUM(do.total_amount) AS net_revenue,
    AVG(do.total_amount) AS avg_check,
    SUM(do.total_amount) / NULLIF(SUM(do.covers), 0) AS revenue_per_cover,
    AVG(do.tip_amount / NULLIF(do.subtotal, 0)) * 100 AS avg_tip_percentage,
    SUM(CASE WHEN do.is_comp THEN 1 ELSE 0 END) AS comped_orders,
    SUM(CASE WHEN do.is_room_charge THEN 1 ELSE 0 END) AS room_charge_orders
FROM RAW.DINING_ORDERS do
JOIN RAW.RESTAURANTS rest ON do.restaurant_id = rest.restaurant_id
WHERE do.order_status = 'COMPLETED'
GROUP BY 
    rest.restaurant_id, rest.restaurant_name, rest.cuisine_type, rest.meal_period, rest.price_range,
    DATE_TRUNC('day', do.order_date), DATE_TRUNC('month', do.order_date), do.order_type;

-- ============================================================================
-- View 5: Spa Utilization
-- ============================================================================
CREATE OR REPLACE VIEW V_SPA_UTILIZATION AS
SELECT
    ss.service_id,
    ss.service_name,
    ss.service_category,
    ss.duration_minutes,
    ss.price AS list_price,
    DATE_TRUNC('day', sa.appointment_date) AS business_date,
    DATE_TRUNC('month', sa.appointment_date) AS business_month,
    COUNT(DISTINCT sa.appointment_id) AS total_appointments,
    SUM(sa.guests_in_party) AS total_guests,
    COUNT(DISTINCT CASE WHEN sa.appointment_status = 'COMPLETED' THEN sa.appointment_id END) AS completed_appointments,
    COUNT(DISTINCT CASE WHEN sa.appointment_status = 'CANCELLED' THEN sa.appointment_id END) AS cancelled_appointments,
    COUNT(DISTINCT CASE WHEN sa.no_show = TRUE THEN sa.appointment_id END) AS no_shows,
    SUM(sa.total_amount) AS total_revenue,
    AVG(sa.total_amount) AS avg_transaction,
    SUM(sa.tip_amount) AS total_tips,
    AVG(sa.rating) AS avg_service_rating,
    SUM(CASE WHEN sa.is_comp THEN 1 ELSE 0 END) AS comped_services
FROM RAW.SPA_APPOINTMENTS sa
JOIN RAW.SPA_SERVICES ss ON sa.service_id = ss.service_id
GROUP BY 
    ss.service_id, ss.service_name, ss.service_category, ss.duration_minutes, ss.price,
    DATE_TRUNC('day', sa.appointment_date), DATE_TRUNC('month', sa.appointment_date);

-- ============================================================================
-- View 6: Gaming Analytics
-- ============================================================================
CREATE OR REPLACE VIEW V_GAMING_ANALYTICS AS
SELECT
    gp.player_id,
    gp.player_card_number,
    gp.player_tier,
    gp.primary_game_type,
    g.first_name || ' ' || g.last_name AS player_name,
    g.loyalty_tier AS guest_loyalty_tier,
    g.vip_status,
    gp.theoretical_daily_value,
    gp.actual_daily_value,
    gp.total_coin_in,
    gp.total_coin_out,
    gp.total_table_buy_in,
    gp.total_table_win_loss,
    gp.comp_balance,
    gp.comp_earned_ytd,
    gp.comp_redeemed_ytd,
    gp.average_bet,
    gp.visit_frequency,
    gp.last_play_date,
    DATEDIFF('day', gp.last_play_date, CURRENT_DATE()) AS days_since_last_play,
    COUNT(DISTINCT gt.transaction_id) AS total_transactions,
    SUM(gt.buy_in_amount) AS total_buy_ins,
    SUM(gt.cash_out_amount) AS total_cash_outs,
    SUM(gt.actual_win_loss) AS total_win_loss,
    SUM(gt.comp_earned) AS total_comps_earned,
    AVG(gt.session_duration_minutes) AS avg_session_minutes
FROM RAW.GAMING_PLAYERS gp
JOIN RAW.GUESTS g ON gp.guest_id = g.guest_id
LEFT JOIN RAW.GAMING_TRANSACTIONS gt ON gp.player_id = gt.player_id
GROUP BY 
    gp.player_id, gp.player_card_number, gp.player_tier, gp.primary_game_type,
    g.first_name, g.last_name, g.loyalty_tier, g.vip_status,
    gp.theoretical_daily_value, gp.actual_daily_value, gp.total_coin_in, gp.total_coin_out,
    gp.total_table_buy_in, gp.total_table_win_loss, gp.comp_balance, gp.comp_earned_ytd,
    gp.comp_redeemed_ytd, gp.average_bet, gp.visit_frequency, gp.last_play_date;

-- ============================================================================
-- View 7: Event Performance
-- ============================================================================
CREATE OR REPLACE VIEW V_EVENT_PERFORMANCE AS
SELECT
    e.event_id,
    e.event_name,
    e.event_type,
    v.venue_name,
    v.venue_type,
    v.capacity_reception AS venue_capacity,
    e.event_date,
    DATE_TRUNC('month', e.event_date) AS event_month,
    e.expected_attendance,
    e.actual_attendance,
    CASE WHEN e.expected_attendance > 0 
         THEN (e.actual_attendance * 100.0 / e.expected_attendance)::NUMBER(5,2) 
         ELSE NULL END AS attendance_rate,
    e.event_status,
    eb.contract_amount,
    eb.catering_revenue,
    eb.av_revenue,
    eb.room_rental_revenue,
    eb.total_revenue,
    eb.total_revenue / NULLIF(e.actual_attendance, 0) AS revenue_per_attendee,
    eb.booking_source,
    eb.payment_status
FROM RAW.EVENTS e
JOIN RAW.EVENT_VENUES v ON e.venue_id = v.venue_id
LEFT JOIN RAW.EVENT_BOOKINGS eb ON e.event_id = eb.event_id;

-- ============================================================================
-- View 8: Guest Satisfaction Analytics
-- ============================================================================
CREATE OR REPLACE VIEW V_GUEST_SATISFACTION AS
SELECT
    gf.feedback_id,
    gf.guest_id,
    g.first_name || ' ' || g.last_name AS guest_name,
    g.loyalty_tier,
    g.vip_status,
    r.confirmation_number,
    rt.room_type_name,
    gf.feedback_date,
    DATE_TRUNC('month', gf.feedback_date) AS feedback_month,
    gf.feedback_type,
    gf.department,
    gf.overall_rating,
    gf.room_rating,
    gf.cleanliness_rating,
    gf.service_rating,
    gf.dining_rating,
    gf.spa_rating,
    gf.value_rating,
    gf.likelihood_to_recommend,
    CASE 
        WHEN gf.likelihood_to_recommend >= 9 THEN 'PROMOTER'
        WHEN gf.likelihood_to_recommend >= 7 THEN 'PASSIVE'
        ELSE 'DETRACTOR'
    END AS nps_category,
    gf.feedback_comments,
    gf.feedback_source,
    gf.feedback_status,
    gf.follow_up_required,
    gf.issue_resolved
FROM RAW.GUEST_FEEDBACK gf
JOIN RAW.GUESTS g ON gf.guest_id = g.guest_id
LEFT JOIN RAW.RESERVATIONS r ON gf.reservation_id = r.reservation_id
LEFT JOIN RAW.ROOM_TYPES rt ON r.room_type_id = rt.room_type_id;

-- ============================================================================
-- View 9: Daily Occupancy Report
-- ============================================================================
CREATE OR REPLACE VIEW V_DAILY_OCCUPANCY AS
SELECT
    d.calendar_date,
    DAYNAME(d.calendar_date) AS day_of_week,
    CASE WHEN DAYOFWEEK(d.calendar_date) IN (0, 6) THEN 'WEEKEND' ELSE 'WEEKDAY' END AS day_type,
    DATE_TRUNC('week', d.calendar_date) AS week_start,
    DATE_TRUNC('month', d.calendar_date) AS month_start,
    total_rooms.room_count AS total_rooms,
    COALESCE(occ.occupied_rooms, 0) AS occupied_rooms,
    total_rooms.room_count - COALESCE(occ.occupied_rooms, 0) AS available_rooms,
    (COALESCE(occ.occupied_rooms, 0) * 100.0 / total_rooms.room_count)::NUMBER(5,2) AS occupancy_rate,
    COALESCE(occ.room_revenue, 0) AS room_revenue,
    COALESCE(occ.room_revenue, 0) / NULLIF(occ.occupied_rooms, 0) AS adr,
    COALESCE(occ.room_revenue, 0) / total_rooms.room_count AS revpar
FROM (
    SELECT DATEADD('day', SEQ4(), '2023-01-01')::DATE AS calendar_date
    FROM TABLE(GENERATOR(ROWCOUNT => 1095))
) d
CROSS JOIN (
    SELECT COUNT(*) AS room_count FROM RAW.ROOMS WHERE room_status != 'OUT_OF_ORDER'
) total_rooms
LEFT JOIN (
    SELECT
        r.check_in_date AS stay_date,
        COUNT(DISTINCT r.reservation_id) AS occupied_rooms,
        SUM(r.room_rate) AS room_revenue
    FROM RAW.RESERVATIONS r
    WHERE r.reservation_status NOT IN ('CANCELLED', 'NO_SHOW')
    GROUP BY r.check_in_date
) occ ON d.calendar_date = occ.stay_date
WHERE d.calendar_date <= CURRENT_DATE();

-- ============================================================================
-- View 10: Campaign Performance
-- ============================================================================
CREATE OR REPLACE VIEW V_CAMPAIGN_PERFORMANCE AS
SELECT
    mc.campaign_id,
    mc.campaign_name,
    mc.campaign_type,
    mc.target_segment,
    mc.start_date,
    mc.end_date,
    DATEDIFF('day', mc.start_date, COALESCE(mc.end_date, CURRENT_DATE())) AS campaign_duration_days,
    mc.budget,
    mc.channel,
    mc.discount_percentage,
    mc.promo_code,
    mc.campaign_status,
    mc.impressions,
    mc.clicks,
    mc.conversions,
    mc.revenue_generated,
    CASE WHEN mc.impressions > 0 
         THEN (mc.clicks * 100.0 / mc.impressions)::NUMBER(5,2) 
         ELSE 0 END AS click_through_rate,
    CASE WHEN mc.clicks > 0 
         THEN (mc.conversions * 100.0 / mc.clicks)::NUMBER(5,2) 
         ELSE 0 END AS conversion_rate,
    CASE WHEN mc.budget > 0 
         THEN (mc.revenue_generated / mc.budget)::NUMBER(10,2) 
         ELSE 0 END AS roi,
    CASE WHEN mc.conversions > 0 
         THEN (mc.budget / mc.conversions)::NUMBER(10,2) 
         ELSE 0 END AS cost_per_acquisition
FROM RAW.MARKETING_CAMPAIGNS mc;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All analytical views created successfully' AS status;

