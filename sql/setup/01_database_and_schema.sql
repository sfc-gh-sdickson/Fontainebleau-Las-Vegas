-- ============================================================================
-- Fontainebleau Las Vegas Intelligence Agent - Database and Schema Setup
-- ============================================================================
-- Purpose: Initialize the database, schema, and warehouse for the Fontainebleau
--          Intelligence Agent solution
-- Syntax: Verified against Snowflake SQL Reference
-- ============================================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS FONTAINEBLEAU_INTELLIGENCE;

-- Use the database
USE DATABASE FONTAINEBLEAU_INTELLIGENCE;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;

-- Create a virtual warehouse for query processing
CREATE OR REPLACE WAREHOUSE FONTAINEBLEAU_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for Fontainebleau Intelligence Agent queries';

-- Set the warehouse as active
USE WAREHOUSE FONTAINEBLEAU_WH;

-- Display confirmation
SELECT 'Database, schema, and warehouse setup completed successfully' AS STATUS;

