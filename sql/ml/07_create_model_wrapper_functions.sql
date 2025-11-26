-- ============================================================================
-- Fontainebleau Las Vegas Intelligence Agent - Model Registry Wrapper Functions
-- ============================================================================
-- Purpose: Create SQL procedures that wrap Model Registry models
--          so they can be added as tools to the Intelligence Agent
-- 
-- IMPORTANT: These wrapper functions MUST match the models created in:
--            notebooks/fontainebleau_ml_models.ipynb
--
-- COLUMN VERIFICATION: All column names verified against 02_create_tables.sql
--
-- Models registered by notebook:
--   1. GUEST_SATISFACTION_PREDICTOR - Output: PREDICTED_SENTIMENT (0, 1, 2)
--   2. ROOM_OCCUPANCY_FORECASTER - Output: PREDICTED_OCCUPANCY_RATE (float)
--   3. SPA_DEMAND_PREDICTOR - Output: PREDICTED_DEMAND (float)
-- ============================================================================

USE DATABASE FONTAINEBLEAU_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE FONTAINEBLEAU_WH;

-- ============================================================================
-- Procedure 1: Guest Satisfaction Prediction Wrapper
-- Matches: GUEST_SATISFACTION_PREDICTOR model from notebook
-- 
-- VERIFIED COLUMNS:
--   GUESTS: loyalty_tier, total_spend, vip_status
--   RESERVATIONS: adults, children, total_room_revenue, booking_channel, check_in_date, check_out_date
--   ROOM_TYPES: room_category
--   GUEST_FEEDBACK: overall_rating, feedback_id
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_GUEST_SATISFACTION(
    LOYALTY_TIER_FILTER VARCHAR
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_satisfaction'
COMMENT = 'Calls GUEST_SATISFACTION_PREDICTOR model from Model Registry to predict guest sentiment'
AS
$$
def predict_satisfaction(session, loyalty_tier_filter):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("GUEST_SATISFACTION_PREDICTOR").default
    
    # Build query with optional filter (sanitize input)
    tier_filter = ""
    if loyalty_tier_filter and loyalty_tier_filter.upper() in ('MEMBER', 'SILVER', 'GOLD', 'PLATINUM'):
        tier_filter = f"AND g.loyalty_tier = '{loyalty_tier_filter.upper()}'"
    
    # Query structured EXACTLY like notebook training data (Cell 7)
    # Column names must be UPPERCASE to match model expectations
    query = f"""
    SELECT
        CASE WHEN g.loyalty_tier IN ('GOLD', 'PLATINUM') THEN TRUE ELSE FALSE END AS IS_LOYALTY_MEMBER,
        COALESCE(g.total_spend, 0)::FLOAT AS GUEST_TOTAL_SPEND,
        COALESCE(r.adults + r.children, 1)::FLOAT AS NUM_GUESTS,
        COALESCE(r.total_room_revenue, 0)::FLOAT AS RESERVATION_PRICE,
        COALESCE(r.nights, 1)::FLOAT AS STAY_DURATION_DAYS,
        rt.room_category AS ROOM_CATEGORY,
        r.booking_channel AS BOOKING_SOURCE,
        COALESCE(gf.overall_rating, 3)::FLOAT AS SATISFACTION_RATING,
        -- Derive sentiment from overall_rating (1-5 scale)
        CASE 
            WHEN gf.overall_rating >= 4 THEN 2  -- POSITIVE
            WHEN gf.overall_rating = 3 THEN 1   -- NEUTRAL
            ELSE 0                               -- NEGATIVE
        END AS SENTIMENT_LABEL
    FROM RAW.GUEST_FEEDBACK gf
    JOIN RAW.GUESTS g ON gf.guest_id = g.guest_id
    JOIN RAW.RESERVATIONS r ON gf.reservation_id = r.reservation_id
    JOIN RAW.ROOM_TYPES rt ON r.room_type_id = rt.room_type_id
    WHERE gf.feedback_date >= DATEADD('month', -6, CURRENT_DATE())
      AND gf.overall_rating IS NOT NULL
      AND r.booking_channel IS NOT NULL
      AND rt.room_category IS NOT NULL
      {tier_filter}
    LIMIT 20
    """
    
    input_df = session.sql(query)
    
    # Check if we have data
    row_count = input_df.count()
    if row_count == 0:
        return json.dumps({
            "error": "No feedback data available for the specified criteria",
            "loyalty_tier_filter": loyalty_tier_filter or "ALL"
        })
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Analyze predictions
    result = predictions.select("SENTIMENT_LABEL", "PREDICTED_SENTIMENT").to_pandas()
    
    # Count by predicted sentiment
    positive_count = int((result['PREDICTED_SENTIMENT'] == 2).sum())
    neutral_count = int((result['PREDICTED_SENTIMENT'] == 1).sum())
    negative_count = int((result['PREDICTED_SENTIMENT'] == 0).sum())
    total_count = len(result)
    
    # Calculate accuracy on this sample
    correct = int((result['SENTIMENT_LABEL'] == result['PREDICTED_SENTIMENT']).sum())
    accuracy = round(correct / total_count * 100, 2) if total_count > 0 else 0
    
    return json.dumps({
        "loyalty_tier_filter": loyalty_tier_filter or "ALL",
        "total_feedback_analyzed": total_count,
        "predicted_positive": positive_count,
        "predicted_neutral": neutral_count,
        "predicted_negative": negative_count,
        "sample_accuracy_pct": accuracy
    })
$$;

-- ============================================================================
-- Procedure 2: Room Occupancy Forecast Wrapper
-- Matches: ROOM_OCCUPANCY_FORECASTER model from notebook
-- 
-- VERIFIED COLUMNS:
--   RESERVATIONS: reservation_id, guest_id, room_id, check_in_date, check_out_date, 
--                 total_room_revenue, reservation_status, nights
--   ROOMS: room_id
--
-- MODEL INPUT COLUMNS (from notebook training):
--   MONTH_NUM, YEAR_NUM, TOTAL_RESERVATIONS, UNIQUE_GUESTS, ROOMS_BOOKED,
--   AVG_STAY_DURATION, AVG_BOOKING_VALUE, OCCUPANCY_RATE (target)
-- ============================================================================

CREATE OR REPLACE PROCEDURE FORECAST_ROOM_OCCUPANCY(
    MONTHS_AHEAD INT
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'forecast_occupancy'
COMMENT = 'Calls ROOM_OCCUPANCY_FORECASTER model from Model Registry to predict future room occupancy rates'
AS
$$
def forecast_occupancy(session, months_ahead):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("ROOM_OCCUPANCY_FORECASTER").default
    
    # Query structured EXACTLY like notebook training data (Cell 14)
    # Uses COALESCE to handle NULL values and ensure numeric types
    query = f"""
    WITH historical_data AS (
        SELECT
            DATE_TRUNC('month', r.check_in_date)::DATE AS occupancy_month,
            MONTH(r.check_in_date) AS month_num,
            YEAR(r.check_in_date) AS year_num,
            COUNT(DISTINCT r.reservation_id)::FLOAT AS total_reservations,
            COUNT(DISTINCT r.guest_id)::FLOAT AS unique_guests,
            COUNT(DISTINCT r.room_id)::FLOAT AS rooms_booked,
            AVG(r.nights)::FLOAT AS avg_stay_duration,
            AVG(r.total_room_revenue)::FLOAT AS avg_booking_value,
            (COUNT(DISTINCT r.room_id)::FLOAT / NULLIF((SELECT COUNT(*) FROM RAW.ROOMS), 0)::FLOAT * 100)::FLOAT AS occupancy_rate
        FROM RAW.RESERVATIONS r
        WHERE r.check_in_date >= DATEADD('month', -24, CURRENT_DATE())
          AND r.reservation_status IN ('CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT')
        GROUP BY DATE_TRUNC('month', r.check_in_date), MONTH(r.check_in_date), YEAR(r.check_in_date)
    ),
    target_month_avg AS (
        SELECT
            AVG(total_reservations) AS avg_reservations,
            AVG(unique_guests) AS avg_guests,
            AVG(rooms_booked) AS avg_rooms,
            AVG(avg_stay_duration) AS avg_duration,
            AVG(avg_booking_value) AS avg_value,
            AVG(occupancy_rate) AS avg_occupancy
        FROM historical_data
        WHERE month_num = MONTH(DATEADD('month', {months_ahead}, CURRENT_DATE()))
    )
    SELECT
        MONTH(DATEADD('month', {months_ahead}, CURRENT_DATE()))::FLOAT AS MONTH_NUM,
        YEAR(DATEADD('month', {months_ahead}, CURRENT_DATE()))::FLOAT AS YEAR_NUM,
        COALESCE(tma.avg_reservations, 500.0)::FLOAT AS TOTAL_RESERVATIONS,
        COALESCE(tma.avg_guests, 400.0)::FLOAT AS UNIQUE_GUESTS,
        COALESCE(tma.avg_rooms, 300.0)::FLOAT AS ROOMS_BOOKED,
        COALESCE(tma.avg_duration, 3.0)::FLOAT AS AVG_STAY_DURATION,
        COALESCE(tma.avg_value, 500.0)::FLOAT AS AVG_BOOKING_VALUE,
        COALESCE(tma.avg_occupancy, 70.0)::FLOAT AS OCCUPANCY_RATE
    FROM target_month_avg tma
    """
    
    input_df = session.sql(query)
    
    # Check if we have data
    row_count = input_df.count()
    if row_count == 0:
        return json.dumps({
            "error": "No historical data available for prediction",
            "months_ahead": months_ahead
        })
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Get prediction result
    result = predictions.select("OCCUPANCY_RATE", "PREDICTED_OCCUPANCY_RATE").to_pandas()
    
    if len(result) > 0:
        predicted_rate = round(float(result['PREDICTED_OCCUPANCY_RATE'].iloc[0]), 2)
        historical_rate = round(float(result['OCCUPANCY_RATE'].iloc[0]), 2)
    else:
        predicted_rate = 0.0
        historical_rate = 0.0
    
    return json.dumps({
        "months_ahead": months_ahead,
        "target_month": f"{months_ahead} months from now",
        "predicted_occupancy_rate_pct": predicted_rate,
        "historical_avg_for_same_month_pct": historical_rate
    })
$$;

-- ============================================================================
-- Procedure 3: Spa Demand Prediction Wrapper
-- Matches: SPA_DEMAND_PREDICTOR model from notebook
-- 
-- VERIFIED COLUMNS:
--   SPA_APPOINTMENTS: appointment_id, appointment_date, total_amount, appointment_status
--
-- MODEL INPUT COLUMNS (from notebook training - Cell 21):
--   DAY_OF_WEEK, MONTH_NUM, APPOINTMENT_COUNT, AVG_APPOINTMENT_AMOUNT,
--   TOTAL_DAILY_REVENUE, HIGH_DEMAND
-- ============================================================================

CREATE OR REPLACE PROCEDURE PREDICT_SPA_DEMAND(
    DAYS_AHEAD INT
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_demand'
COMMENT = 'Calls SPA_DEMAND_PREDICTOR model from Model Registry to predict spa appointment demand'
AS
$$
def predict_demand(session, days_ahead):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("SPA_DEMAND_PREDICTOR").default
    
    # Query structured EXACTLY like notebook training data (Cell 21)
    # Column names must match exactly (uppercase)
    query = f"""
    WITH daily_data AS (
        SELECT
            sa.appointment_date,
            DAYOFWEEK(sa.appointment_date)::FLOAT AS DAY_OF_WEEK,
            MONTH(sa.appointment_date) AS MONTH_NUM,
            COUNT(DISTINCT sa.appointment_id)::FLOAT AS APPOINTMENT_COUNT,
            AVG(sa.total_amount)::FLOAT AS AVG_APPOINTMENT_AMOUNT,
            SUM(sa.total_amount)::FLOAT AS TOTAL_DAILY_REVENUE,
            CASE WHEN COUNT(DISTINCT sa.appointment_id) > 20 THEN 1 ELSE 0 END AS HIGH_DEMAND
        FROM RAW.SPA_APPOINTMENTS sa
        WHERE sa.appointment_date >= DATEADD('year', -1, CURRENT_DATE())
          AND sa.appointment_status IN ('CONFIRMED', 'COMPLETED')
        GROUP BY sa.appointment_date, DAYOFWEEK(sa.appointment_date), MONTH(sa.appointment_date)
    ),
    day_averages AS (
        SELECT
            AVG(APPOINTMENT_COUNT) AS avg_count,
            AVG(AVG_APPOINTMENT_AMOUNT) AS avg_amount,
            AVG(TOTAL_DAILY_REVENUE) AS avg_revenue
        FROM daily_data
        WHERE DAY_OF_WEEK = DAYOFWEEK(DATEADD('day', {days_ahead}, CURRENT_DATE()))
    )
    SELECT
        DAYOFWEEK(DATEADD('day', {days_ahead}, CURRENT_DATE()))::FLOAT AS DAY_OF_WEEK,
        MONTH(DATEADD('day', {days_ahead}, CURRENT_DATE()))::FLOAT AS MONTH_NUM,
        COALESCE(da.avg_count, 15.0)::FLOAT AS APPOINTMENT_COUNT,
        COALESCE(da.avg_amount, 250.0)::FLOAT AS AVG_APPOINTMENT_AMOUNT,
        COALESCE(da.avg_revenue, 3000.0)::FLOAT AS TOTAL_DAILY_REVENUE,
        CASE WHEN COALESCE(da.avg_count, 15.0) > 20 THEN 1 ELSE 0 END AS HIGH_DEMAND
    FROM day_averages da
    """
    
    input_df = session.sql(query)
    
    # Check if we have data
    row_count = input_df.count()
    if row_count == 0:
        return json.dumps({
            "error": "No historical data available for prediction",
            "days_ahead": days_ahead
        })
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Get prediction result
    result = predictions.select("APPOINTMENT_COUNT", "PREDICTED_DEMAND").to_pandas()
    
    if len(result) > 0:
        predicted_demand = round(float(result['PREDICTED_DEMAND'].iloc[0]), 0)
        historical_avg = round(float(result['APPOINTMENT_COUNT'].iloc[0]), 0)
    else:
        predicted_demand = 0
        historical_avg = 0
    
    return json.dumps({
        "days_ahead": days_ahead,
        "predicted_spa_appointments": int(predicted_demand),
        "historical_avg_for_same_day_of_week": int(historical_avg)
    })
$$;

-- ============================================================================
-- Display confirmation
-- ============================================================================

SELECT 'ML model wrapper functions created successfully' AS status;

-- ============================================================================
-- Test the wrapper procedures (uncomment after models are registered via notebook)
-- ============================================================================
/*
CALL PREDICT_GUEST_SATISFACTION('PLATINUM');
CALL PREDICT_GUEST_SATISFACTION(NULL);

CALL FORECAST_ROOM_OCCUPANCY(1);
CALL FORECAST_ROOM_OCCUPANCY(3);

CALL PREDICT_SPA_DEMAND(7);
CALL PREDICT_SPA_DEMAND(1);
*/

SELECT 'Execute notebook first to register models, then uncomment tests above' AS instruction;
