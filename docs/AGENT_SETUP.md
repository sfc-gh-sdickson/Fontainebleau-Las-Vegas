<img src="../Snowflake_Logo.svg" width="200">

# Fontainebleau Intelligence Agent - Setup Guide

This document provides step-by-step instructions to set up and configure the Fontainebleau Intelligence Agent in Snowflake.

## Prerequisites

Before starting, ensure you have:

1. **Snowflake Account** with appropriate permissions:
   - ACCOUNTADMIN role (or equivalent for creating databases, warehouses, agents)
   - Access to Snowflake Cortex features (Cortex Analyst, Cortex Search)
   
2. **Snowflake Features Enabled**:
   - Snowflake Intelligence Agents (Private Preview or GA)
   - Cortex Analyst
   - Cortex Search
   - Model Registry

3. **Snowsight Access** for agent configuration and testing

---

## Step 1: Create Database and Warehouse

Run the database setup script to create the foundation:

```sql
-- Execute the setup script
-- File: sql/setup/01_database_and_schema.sql

CREATE DATABASE IF NOT EXISTS FONTAINEBLEAU_INTELLIGENCE;
USE DATABASE FONTAINEBLEAU_INTELLIGENCE;

CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;

CREATE OR REPLACE WAREHOUSE FONTAINEBLEAU_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE FONTAINEBLEAU_WH;
```

**Expected Result:** Database, schemas, and warehouse created successfully.

---

## Step 2: Create Tables

Run the table creation script:

```sql
-- File: sql/setup/02_create_tables.sql

-- This creates all 14 tables:
-- GUESTS, ROOMS, RESERVATIONS, SERVICES, STAFF, GUEST_FEEDBACK,
-- EVENTS, EVENT_ATTENDEES, MARKETING_CAMPAIGNS, GUEST_CAMPAIGN_INTERACTIONS,
-- MAINTENANCE_REQUESTS, SUPPLIERS, INVENTORY, PURCHASE_ORDERS
```

**Expected Result:** All tables created with proper primary/foreign key relationships.

---

## Step 3: Generate Synthetic Data

Run the data generation script:

```sql
-- File: sql/data/03_generate_synthetic_data.sql

-- This generates realistic hotel data including:
-- - 10,000 guests
-- - 500 rooms
-- - 20,000+ reservations
-- - 50,000+ services
-- - 100+ staff members
-- - And more...
```

**Expected Result:** All tables populated with synthetic data.

---

## Step 4: Create Analytical Views

Run the views creation script:

```sql
-- File: sql/views/04_create_views.sql

-- Creates views for common analytics:
-- V_GUEST_360, V_ROOM_OCCUPANCY, V_RESERVATION_ANALYTICS, etc.
```

**Expected Result:** 10 analytical views created in the ANALYTICS schema.

---

## Step 5: Create Semantic Views

Run the semantic views script (critical for Cortex Analyst):

```sql
-- File: sql/views/05_create_semantic_views.sql

-- Creates 3 semantic views:
-- 1. SV_HOTEL_OPERATIONS_INTELLIGENCE
-- 2. SV_GUEST_EXPERIENCE_INTELLIGENCE
-- 3. SV_REVENUE_MANAGEMENT_INTELLIGENCE
```

**Syntax Verification Notes:**
- Clause order: TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT
- All synonyms are globally unique across semantic views
- Verified against: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view

**Expected Result:** 3 semantic views created and ready for Cortex Analyst.

---

## Step 6: Set Up Cortex Search Services

Run the Cortex Search setup script:

```sql
-- File: sql/search/06_create_cortex_search.sql

-- Creates 3 tables for unstructured data:
-- GUEST_FEEDBACK_UNSTRUCTURED, POLICY_DOCUMENTS, MAINTENANCE_REPORTS

-- Creates 3 Cortex Search services:
-- GUEST_FEEDBACK_SEARCH, POLICY_DOCUMENTS_SEARCH, MAINTENANCE_REPORTS_SEARCH
```

**Syntax Verification Notes:**
- Change tracking enabled on all source tables
- Verified against: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search

**Expected Result:** Unstructured data tables and Cortex Search services created.

---

## Step 7: Train and Register ML Models

Open the Snowflake Notebook and run all cells:

```
File: notebooks/fontainebleau_ml_models.ipynb
```

This notebook trains and registers 3 ML models:

| Model Name | Type | Purpose |
|------------|------|---------|
| GUEST_SATISFACTION_PREDICTOR | Random Forest Classifier | Predict guest sentiment |
| ROOM_OCCUPANCY_FORECASTER | Linear Regression | Forecast room occupancy |
| SPA_DEMAND_PREDICTOR | Linear Regression | Predict spa appointment demand |

**Expected Result:** 3 models registered in the Model Registry.

---

## Step 8: Create Model Wrapper Functions

Run the wrapper functions script:

```sql
-- File: sql/ml/07_create_model_wrapper_functions.sql

-- Creates 3 stored procedures:
-- PREDICT_GUEST_SATISFACTION(STRING)
-- FORECAST_ROOM_OCCUPANCY(INT, INT)
-- PREDICT_SPA_DEMAND(INT)
```

**Expected Result:** 3 stored procedures created to wrap ML models.

---

## Step 9: Create the Intelligence Agent

Run the agent creation script:

```sql
-- File: sql/agent/08_create_intelligence_agent.sql

-- This script:
-- 1. Grants required permissions
-- 2. Creates FONTAINEBLEAU_INTELLIGENCE_AGENT
-- 3. Configures all tools (Cortex Analyst, Cortex Search, ML Models)
```

**Expected Result:** Intelligence Agent created and configured.

---

## Step 10: Test the Agent

### Option A: Test in Snowsight

1. Navigate to **AI & ML → Agents**
2. Select **FONTAINEBLEAU_INTELLIGENCE_AGENT**
3. Click **Chat** to open the conversation interface
4. Try these sample questions:

**Structured Data (Cortex Analyst):**
```
What is the total number of reservations for next month?
Show me the average guest satisfaction rating.
List all available room types and their daily rates.
```

**Unstructured Data (Cortex Search):**
```
Search guest feedback for comments about room cleanliness.
Find policy documentation about emergency response procedures.
Search maintenance reports for HVAC system failures.
```

**Predictive (ML Models):**
```
Predict guest satisfaction for: "The room was clean but the service was slow."
Forecast room occupancy for next 3 months.
Predict demand for spa services for the upcoming weekend.
```

### Option B: Test via SQL

```sql
-- Test agent invocation
SELECT SNOWFLAKE.CORTEX.AGENT(
    'FONTAINEBLEAU_INTELLIGENCE_AGENT',
    'What is the average daily room rate?'
);
```

---

## Troubleshooting

### Common Issues

1. **"Semantic view not found" error**
   - Ensure semantic views are created in ANALYTICS schema
   - Verify REFERENCES and SELECT grants on semantic views

2. **"Cortex Search service not responding"**
   - Check that change tracking is enabled on source tables
   - Verify the search service is in the RAW schema

3. **"ML model not found" error**
   - Run the notebook to register models
   - Verify models are visible in Model Registry

4. **Permission errors**
   - Ensure ACCOUNTADMIN role or equivalent
   - Run the GRANT statements in 08_create_intelligence_agent.sql

### Useful Diagnostic Commands

```sql
-- Check semantic views
SHOW SEMANTIC VIEWS IN SCHEMA FONTAINEBLEAU_INTELLIGENCE.ANALYTICS;

-- Check Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA FONTAINEBLEAU_INTELLIGENCE.RAW;

-- Check ML models
SHOW MODELS IN SCHEMA FONTAINEBLEAU_INTELLIGENCE.ANALYTICS;

-- Check agent status
SHOW AGENTS LIKE 'FONTAINEBLEAU_INTELLIGENCE_AGENT';
DESCRIBE AGENT FONTAINEBLEAU_INTELLIGENCE_AGENT;
```

---

## Granting Access to Other Users

To allow other users to interact with the agent:

```sql
-- Grant usage on the agent
GRANT USAGE ON AGENT FONTAINEBLEAU_INTELLIGENCE.ANALYTICS.FONTAINEBLEAU_INTELLIGENCE_AGENT 
TO ROLE <role_name>;

-- Grant usage on required objects
GRANT USAGE ON DATABASE FONTAINEBLEAU_INTELLIGENCE TO ROLE <role_name>;
GRANT USAGE ON SCHEMA FONTAINEBLEAU_INTELLIGENCE.ANALYTICS TO ROLE <role_name>;
GRANT USAGE ON SCHEMA FONTAINEBLEAU_INTELLIGENCE.RAW TO ROLE <role_name>;
GRANT USAGE ON WAREHOUSE FONTAINEBLEAU_WH TO ROLE <role_name>;
```

---

## Next Steps

1. **Customize the Agent**: Modify the agent specification in `08_create_intelligence_agent.sql` to add custom instructions or tools.

2. **Add More Data Sources**: Extend semantic views with additional tables or metrics.

3. **Enhance ML Models**: Retrain models with production data for better accuracy.

4. **Monitor Usage**: Track agent usage and performance through Snowflake Query History.

---

## Support

For issues with:
- **Snowflake Intelligence Agents**: Consult Snowflake documentation or support
- **This Demo Solution**: Review the files in the repository for additional context

**Documentation Links:**
- [Snowflake Intelligence Agents](https://docs.snowflake.com/en/user-guide/snowflake-intelligence-agents)
- [Cortex Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Cortex Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [Model Registry](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/overview)

