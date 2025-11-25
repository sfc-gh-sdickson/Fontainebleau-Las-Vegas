-- ============================================================================
-- Fontainebleau Las Vegas Intelligence Agent - Create Snowflake Intelligence Agent
-- ============================================================================
-- Purpose: Create and configure Snowflake Intelligence Agent with:
--          - Cortex Analyst tools (Semantic Views)
--          - Cortex Search tools (Unstructured Data)
--          - ML Model tools (Predictions)
-- Execution: Run this after completing steps 01-07 and running the notebook
-- 
-- ML MODELS (from notebook):
--   1. GUEST_SATISFACTION_PREDICTOR → PREDICT_GUEST_SATISFACTION(VARCHAR)
--   2. ROOM_OCCUPANCY_FORECASTER → FORECAST_ROOM_OCCUPANCY(INT)
--   3. SPA_DEMAND_PREDICTOR → PREDICT_SPA_DEMAND(INT)
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE FONTAINEBLEAU_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE FONTAINEBLEAU_WH;

-- ============================================================================
-- Step 1: Grant Required Permissions for Cortex Analyst
-- ============================================================================

-- Grant Cortex Analyst user role to your role
-- Replace <your_role> with your actual role name (e.g., SYSADMIN, custom role)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER TO ROLE SYSADMIN;

-- Grant usage on database and schemas
GRANT USAGE ON DATABASE FONTAINEBLEAU_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA FONTAINEBLEAU_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA FONTAINEBLEAU_INTELLIGENCE.RAW TO ROLE SYSADMIN;

-- Grant privileges on semantic views for Cortex Analyst
GRANT REFERENCES, SELECT ON SEMANTIC VIEW FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.SV_GUEST_RESERVATION_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.SV_REVENUE_OPERATIONS_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.SV_GUEST_EXPERIENCE_INTELLIGENCE TO ROLE SYSADMIN;

-- Grant usage on warehouse
GRANT USAGE ON WAREHOUSE FONTAINEBLEAU_WH TO ROLE SYSADMIN;

-- Grant usage on Cortex Search services
GRANT USAGE ON CORTEX SEARCH SERVICE FONTAINEBLEAU_INTELLIGENCE.RAW.GUEST_REVIEWS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE FONTAINEBLEAU_INTELLIGENCE.RAW.HOTEL_POLICIES_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE FONTAINEBLEAU_INTELLIGENCE.RAW.INCIDENT_REPORTS_SEARCH TO ROLE SYSADMIN;

-- Grant execute on ML model wrapper procedures
-- These MUST match the procedure signatures in 07_create_model_wrapper_functions.sql
GRANT USAGE ON PROCEDURE FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.PREDICT_GUEST_SATISFACTION(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.FORECAST_ROOM_OCCUPANCY(INT) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.PREDICT_SPA_DEMAND(INT) TO ROLE SYSADMIN;

-- ============================================================================
-- Step 2: Create Snowflake Intelligence Agent
-- ============================================================================

CREATE OR REPLACE AGENT FONTAINEBLEAU_INTELLIGENCE_AGENT
  COMMENT = 'Fontainebleau Las Vegas Intelligence Agent for luxury hotel business intelligence'
  PROFILE = '{"display_name": "Fontainebleau Las Vegas Intelligence Agent", "avatar": "hotel-icon.png", "color": "blue"}'
  FROM SPECIFICATION
  $$
models:
  orchestration: auto

orchestration:
  budget:
    seconds: 60
    tokens: 32000

instructions:
  response: 'You are a specialized analytics assistant for Fontainebleau Las Vegas, a premier luxury resort and casino. For structured data queries use Cortex Analyst semantic views. For unstructured content use Cortex Search services. For predictions use ML model procedures. Keep responses concise and data-driven.'
  orchestration: 'For metrics and KPIs use Cortex Analyst tools. For guest reviews, policies, and incident reports use Cortex Search tools. For forecasting use ML function tools.'
  system: 'You help analyze luxury hotel data including guest profiles, reservations, dining, spa, gaming, events, and guest satisfaction using structured and unstructured data sources.'
  sample_questions:
    # ========== 5 SIMPLE QUESTIONS (Cortex Analyst) ==========
    - question: 'How many guests are in the system?'
      answer: 'I will query the GUESTS table to count total distinct guests.'
    - question: 'What is the average daily rate for all rooms?'
      answer: 'I will calculate the average room_rate from the RESERVATIONS table.'
    - question: 'List all available room types and their counts.'
      answer: 'I will query the ROOM_TYPES table to show room categories and inventory.'
    - question: 'How many reservations are currently confirmed?'
      answer: 'I will filter reservations by status CONFIRMED to get the count.'
    - question: 'Show me the number of staff members in each department.'
      answer: 'I will query the STAFF table grouped by department.'
    # ========== 5 COMPLEX QUESTIONS (Cortex Analyst) ==========
    - question: 'Analyze revenue performance by booking channel. Show total revenue, average booking value, and cancellation rates.'
      answer: 'I will join RESERVATIONS data, group by booking_channel, and calculate multiple metrics including cancellation percentages.'
    - question: 'Which loyalty tier has the highest average spend and how does their feedback compare?'
      answer: 'I will join GUESTS with GUEST_FEEDBACK to analyze spend and satisfaction by loyalty_tier.'
    - question: 'Show me room occupancy rates by room category for the last quarter with peak dates.'
      answer: 'I will join RESERVATIONS with ROOM_TYPES and calculate occupancy metrics by room_category and date.'
    - question: 'What are the top 5 restaurants by revenue and their average check amounts?'
      answer: 'I will aggregate DINING_ORDERS by restaurant_id to rank by total_amount and calculate averages.'
    - question: 'Analyze spa appointment trends by day of week and identify peak times.'
      answer: 'I will query SPA_APPOINTMENTS grouped by day of week and time to find usage patterns.'
    # ========== 5 ML MODEL QUESTIONS (Predictions) ==========
    - question: 'Predict guest satisfaction patterns for all loyalty tiers.'
      answer: 'I will call PREDICT_GUEST_SATISFACTION with no filter to analyze sentiment distribution across all guests.'
    - question: 'Analyze guest satisfaction predictions for our PLATINUM tier members.'
      answer: 'I will call PREDICT_GUEST_SATISFACTION with loyalty_tier_filter=PLATINUM.'
    - question: 'Forecast room occupancy for the next 3 months.'
      answer: 'I will call FORECAST_ROOM_OCCUPANCY with months_ahead=3 to predict future occupancy rates.'
    - question: 'Predict spa appointment demand for this weekend.'
      answer: 'I will call PREDICT_SPA_DEMAND with days_ahead=2 to forecast weekend spa bookings.'
    - question: 'What is the predicted spa demand for next week?'
      answer: 'I will call PREDICT_SPA_DEMAND with days_ahead=7 to forecast spa appointments.'

tools:
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'GuestReservationAnalyst'
      description: 'Analyzes guest profiles, reservations, room types, loyalty program, and guest feedback'
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'RevenueOperationsAnalyst'
      description: 'Analyzes dining orders, spa appointments, gaming activity, and event bookings'
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'GuestExperienceAnalyst'
      description: 'Analyzes guest satisfaction, staff performance, amenity usage, and marketing campaigns'
  - tool_spec:
      type: 'cortex_search'
      name: 'GuestReviewsSearch'
      description: 'Searches 10,000+ guest reviews for feedback patterns, complaints, and praise'
  - tool_spec:
      type: 'cortex_search'
      name: 'HotelPoliciesSearch'
      description: 'Searches operational policies including check-in, cancellation, dining, spa, and gaming guidelines'
  - tool_spec:
      type: 'cortex_search'
      name: 'IncidentReportsSearch'
      description: 'Searches 5,000+ incident reports covering guest issues, resolutions, and recommendations'
  - tool_spec:
      type: 'generic'
      name: 'PredictGuestSatisfaction'
      description: 'Predicts guest satisfaction sentiment (Positive/Neutral/Negative) based on recent feedback'
      input_schema:
        type: 'object'
        properties:
          loyalty_tier_filter:
            type: 'string'
            description: 'Loyalty tier to filter (MEMBER, SILVER, GOLD, PLATINUM) or null for all tiers'
        required: []
  - tool_spec:
      type: 'generic'
      name: 'ForecastRoomOccupancy'
      description: 'Forecasts room occupancy rates for future months'
      input_schema:
        type: 'object'
        properties:
          months_ahead:
            type: 'integer'
            description: 'Number of months ahead to forecast (1-12)'
        required: ['months_ahead']
  - tool_spec:
      type: 'generic'
      name: 'PredictSpaDemand'
      description: 'Predicts spa appointment demand for future days'
      input_schema:
        type: 'object'
        properties:
          days_ahead:
            type: 'integer'
            description: 'Number of days ahead to forecast (1-30)'
        required: ['days_ahead']

tool_resources:
  GuestReservationAnalyst:
    semantic_view: 'FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.SV_GUEST_RESERVATION_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'FONTAINEBLEAU_WH'
      query_timeout: 60
  RevenueOperationsAnalyst:
    semantic_view: 'FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.SV_REVENUE_OPERATIONS_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'FONTAINEBLEAU_WH'
      query_timeout: 60
  GuestExperienceAnalyst:
    semantic_view: 'FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.SV_GUEST_EXPERIENCE_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'FONTAINEBLEAU_WH'
      query_timeout: 60
  GuestReviewsSearch:
    search_service: 'FONTAINEBLEAU_INTELLIGENCE.RAW.GUEST_REVIEWS_SEARCH'
    max_results: 10
    title_column: 'review_title'
    id_column: 'review_id'
  HotelPoliciesSearch:
    search_service: 'FONTAINEBLEAU_INTELLIGENCE.RAW.HOTEL_POLICIES_SEARCH'
    max_results: 5
    title_column: 'title'
    id_column: 'policy_id'
  IncidentReportsSearch:
    search_service: 'FONTAINEBLEAU_INTELLIGENCE.RAW.INCIDENT_REPORTS_SEARCH'
    max_results: 10
    title_column: 'incident_type'
    id_column: 'incident_id'
  PredictGuestSatisfaction:
    type: 'procedure'
    identifier: 'FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.PREDICT_GUEST_SATISFACTION'
    execution_environment:
      type: 'warehouse'
      warehouse: 'FONTAINEBLEAU_WH'
      query_timeout: 60
  ForecastRoomOccupancy:
    type: 'procedure'
    identifier: 'FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.FORECAST_ROOM_OCCUPANCY'
    execution_environment:
      type: 'warehouse'
      warehouse: 'FONTAINEBLEAU_WH'
      query_timeout: 60
  PredictSpaDemand:
    type: 'procedure'
    identifier: 'FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.PREDICT_SPA_DEMAND'
    execution_environment:
      type: 'warehouse'
      warehouse: 'FONTAINEBLEAU_WH'
      query_timeout: 60
  $$;

-- ============================================================================
-- Step 3: Verify Agent Creation
-- ============================================================================

-- Show created agent
SHOW AGENTS LIKE 'FONTAINEBLEAU_INTELLIGENCE_AGENT';

-- Describe agent configuration
DESCRIBE AGENT FONTAINEBLEAU_INTELLIGENCE_AGENT;

-- Grant usage
GRANT USAGE ON AGENT FONTAINEBLEAU_INTELLIGENCE_AGENT TO ROLE SYSADMIN;

-- ============================================================================
-- Step 4: Test Agent (Examples)
-- ============================================================================

-- Note: After agent creation, you can test it in Snowsight:
-- 1. Go to AI & ML > Agents
-- 2. Select FONTAINEBLEAU_INTELLIGENCE_AGENT
-- 3. Click "Chat" to interact with the agent

-- Example test queries:
/*
1. Structured queries (Cortex Analyst):
   - "What is our average daily rate by room type?"
   - "Which loyalty tier has the highest total spend?"
   - "Show me total dining revenue by restaurant"
   - "What is the average guest satisfaction score?"

2. Unstructured queries (Cortex Search):
   - "Search guest reviews for complaints about check-in wait times"
   - "Find policy documentation about cancellation refunds"
   - "Search incident reports for pool safety issues"

3. Predictive queries (ML Models):
   - "Predict guest satisfaction for Platinum members"
   - "Forecast room occupancy for the next 3 months"
   - "Predict spa demand for next week"
*/

-- ============================================================================
-- Success Message
-- ============================================================================

SELECT 'Fontainebleau Intelligence Agent created successfully! Access it in Snowsight under AI & ML > Agents' AS status;

-- ============================================================================
-- TROUBLESHOOTING
-- ============================================================================

/*
If agent creation fails, verify:

1. Permissions are granted:
   - CORTEX_ANALYST_USER database role
   - REFERENCES and SELECT on all semantic views
   - USAGE on Cortex Search services
   - USAGE on ML procedures

2. All semantic views exist:
   SHOW SEMANTIC VIEWS IN SCHEMA FONTAINEBLEAU_INTELLIGENCE.ANALYTICS;

3. All Cortex Search services exist and are ready:
   SHOW CORTEX SEARCH SERVICES IN SCHEMA FONTAINEBLEAU_INTELLIGENCE.RAW;

4. ML wrapper procedures exist:
   SHOW PROCEDURES IN SCHEMA FONTAINEBLEAU_INTELLIGENCE.ANALYTICS;
   -- Should show:
   -- PREDICT_GUEST_SATISFACTION(VARCHAR)
   -- FORECAST_ROOM_OCCUPANCY(NUMBER)
   -- PREDICT_SPA_DEMAND(NUMBER)

5. Warehouse is running:
   SHOW WAREHOUSES LIKE 'FONTAINEBLEAU_WH';

6. Models are registered in Model Registry (run notebook first):
   SHOW MODELS IN SCHEMA FONTAINEBLEAU_INTELLIGENCE.ANALYTICS;
   -- Should show:
   -- GUEST_SATISFACTION_PREDICTOR
   -- ROOM_OCCUPANCY_FORECASTER
   -- SPA_DEMAND_PREDICTOR
*/
