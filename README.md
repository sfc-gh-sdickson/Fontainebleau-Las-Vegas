<img src="Snowflake_Logo.svg" width="200">

# Fontainebleau Las Vegas Intelligence Agent Solution

## About Fontainebleau Las Vegas

Fontainebleau Las Vegas is a premier luxury resort and casino destination on the Las Vegas Strip. Their comprehensive hospitality portfolio includes world-class accommodations, fine dining, entertainment, spa services, gaming, nightlife, and convention facilities serving guests from around the world.

### Key Business Areas

- **Accommodations**: Luxury suites, standard rooms, penthouses, villas - over 3,600 rooms
- **Dining**: Fine dining restaurants, casual dining, bars, lounges, room service
- **Entertainment**: Nightclubs, shows, pools, events, concerts
- **Spa & Wellness**: LIV SPA, fitness center, wellness programs
- **Gaming**: Casino floor, VIP gaming, slots, table games
- **Meetings & Events**: Convention center, ballrooms, meeting spaces
- **Amenities**: Pools, retail, concierge services, transportation

### Market Position

- One of the newest and most iconic resorts on the Las Vegas Strip
- Premium luxury positioning with exceptional guest experiences
- Comprehensive ecosystem of hospitality services
- Industry-leading technology integration

## Project Overview

This Snowflake Intelligence solution demonstrates how Fontainebleau Las Vegas can leverage AI agents to analyze:

- **Guest Intelligence**: Guest profiles, preferences, VIP tracking, loyalty status
- **Reservation Analytics**: Booking patterns, occupancy rates, revenue optimization
- **Dining Operations**: Restaurant performance, menu analytics, guest preferences
- **Spa & Wellness**: Service utilization, treatment popularity, revenue trends
- **Gaming Analytics**: Player activity, comp tracking, gaming revenue
- **Event Management**: Venue utilization, event performance, group bookings
- **Guest Satisfaction**: Feedback analysis, satisfaction scores, service quality
- **Revenue Management**: ADR, RevPAR, ancillary revenue, package performance
- **Unstructured Data Search**: Semantic search over guest reviews, policies, and incident reports using Cortex Search

## Database Schema

The solution includes:

1. **RAW Schema**: Core business tables
   - GUESTS: Guest profiles and contact information
   - ROOMS: Room inventory with types and amenities
   - RESERVATIONS: Booking details and status
   - ROOM_TYPES: Room categories and configurations
   - RESTAURANTS: Dining venue information
   - DINING_RESERVATIONS: Restaurant bookings
   - DINING_ORDERS: Food and beverage transactions
   - MENU_ITEMS: Menu offerings and pricing
   - SPA_SERVICES: Spa treatment catalog
   - SPA_APPOINTMENTS: Spa booking details
   - GAMING_PLAYERS: Casino player profiles
   - GAMING_TRANSACTIONS: Gaming activity tracking
   - EVENTS: Meetings and events data
   - EVENT_BOOKINGS: Event reservation details
   - STAFF: Employee information
   - GUEST_FEEDBACK: Satisfaction surveys and ratings
   - LOYALTY_PROGRAM: Rewards and tier tracking
   - AMENITY_USAGE: Pool, gym, and other amenity tracking
   - GUEST_REVIEWS: Unstructured guest review text (10K reviews)
   - HOTEL_POLICIES: Operational policies and procedures (comprehensive documents)
   - INCIDENT_REPORTS: Guest incident and resolution documentation (5K reports)

2. **ANALYTICS Schema**: Curated views and semantic models
   - Guest 360 views
   - Revenue analytics
   - Occupancy metrics
   - Dining performance
   - Spa utilization
   - Gaming analytics
   - Event performance
   - Semantic views for AI agents

3. **Cortex Search Services**: Semantic search over unstructured data
   - GUEST_REVIEWS_SEARCH: Search 10K guest reviews
   - HOTEL_POLICIES_SEARCH: Search operational policies and procedures
   - INCIDENT_REPORTS_SEARCH: Search 5K guest incident reports

## Files

### Core Files
- `README.md`: This comprehensive solution documentation
- `docs/AGENT_SETUP.md`: Complete agent configuration instructions
- `docs/questions.md`: 15 test questions (5 simple, 5 complex, 5 ML)

### SQL Files
- `sql/setup/01_database_and_schema.sql`: Database and schema creation
- `sql/setup/02_create_tables.sql`: Table definitions with proper constraints
- `sql/data/03_generate_synthetic_data.sql`: Realistic hotel sample data
- `sql/views/04_create_views.sql`: Analytical views
- `sql/views/05_create_semantic_views.sql`: Semantic views for AI agents (verified syntax)
- `sql/search/06_create_cortex_search.sql`: Unstructured data tables and Cortex Search services
- `sql/ml/07_create_model_wrapper_functions.sql`: ML model wrapper procedures (optional)
- `sql/agent/08_create_intelligence_agent.sql`: Create Snowflake Intelligence Agent

### ML Models (Optional)
- `notebooks/fontainebleau_ml_models.ipynb`: Snowflake Notebook for training ML models

## Setup Instructions

### Quick Start (Simplified Agent - No ML)
```sql
-- Execute in order:
-- 1. Run sql/setup/01_database_and_schema.sql
-- 2. Run sql/setup/02_create_tables.sql
-- 3. Run sql/data/03_generate_synthetic_data.sql (10-20 min)
-- 4. Run sql/views/04_create_views.sql
-- 5. Run sql/views/05_create_semantic_views.sql
-- 6. Run sql/search/06_create_cortex_search.sql (5-10 min)
-- 7. Run sql/agent/08_create_intelligence_agent.sql
-- 8. Access agent in Snowsight: AI & ML > Agents > FONTAINEBLEAU_INTELLIGENCE_AGENT
```

### Complete Setup (Full Agent with ML)
```sql
-- Execute quick start steps 1-6, then:
-- 7. Upload and run notebooks/fontainebleau_ml_models.ipynb in Snowflake
-- 8. Run sql/ml/07_create_model_wrapper_functions.sql
-- 9. Run sql/agent/08_create_intelligence_agent.sql
-- 10. Access agent in Snowsight: AI & ML > Agents > FONTAINEBLEAU_INTELLIGENCE_AGENT
```

### Detailed Instructions
- See **docs/AGENT_SETUP.md** for step-by-step configuration guide
- Test with questions from **docs/questions.md**

## Data Model Highlights

### Structured Data
- Realistic luxury hotel business scenarios
- 50K guests with detailed profiles
- 100K reservations with booking patterns
- 3,600+ rooms across multiple room types
- 200K dining orders with menu items
- 50K spa appointments
- 30K gaming player profiles
- 10K events and meetings
- 100K loyalty transactions
- 25K guest feedback records

### Unstructured Data
- 10,000 guest reviews with sentiment variations
- Comprehensive hotel policy documents (check-in, cancellation, dining, spa, gaming)
- 5,000 incident investigation reports
- Semantic search powered by Snowflake Cortex Search
- RAG (Retrieval Augmented Generation) ready for AI agents

## Key Features

✅ **Hybrid Data Architecture**: Combines structured tables with unstructured guest content  
✅ **Semantic Search**: Find similar guest issues and solutions by meaning, not keywords  
✅ **RAG-Ready**: Agent can retrieve context from reviews and policy documents  
✅ **Production-Ready Syntax**: All SQL verified against Snowflake documentation  
✅ **Comprehensive Demo**: 100K reservations, 200K dining orders, 10K reviews  
✅ **Verified Syntax**: CREATE SEMANTIC VIEW and CREATE CORTEX SEARCH SERVICE syntax verified against official Snowflake documentation  
✅ **No Duplicate Synonyms**: All semantic view synonyms globally unique across all three views

## Sample Questions

The agent can answer sophisticated questions like:

### Structured Data Analysis (Semantic Views)
1. **Occupancy Analysis**: Room occupancy rates by room type and season
2. **Revenue Trends**: ADR and RevPAR analysis over time
3. **Guest Segmentation**: VIP versus regular guest patterns
4. **Dining Performance**: Restaurant revenue and cover counts
5. **Spa Utilization**: Service popularity and booking patterns
6. **Gaming Analytics**: Player value and comp efficiency
7. **Event Performance**: Venue utilization and group revenue
8. **Loyalty Impact**: Tier distribution and redemption patterns

### Unstructured Data Search (Cortex Search)
9. **Guest Reviews**: Common complaints and praise patterns
10. **Policy Guidance**: Check-in procedures, cancellation terms
11. **Incident Resolution**: Guest issue patterns and resolutions

### ML Model Predictions
12. **Booking Cancellation**: Predict likelihood of reservation cancellation
13. **Guest Lifetime Value**: Predict high-value guest potential
14. **Service Demand**: Forecast spa and dining demand

## Semantic Views

The solution includes three verified semantic views:

1. **SV_GUEST_RESERVATION_INTELLIGENCE**: Comprehensive view of guests, reservations, rooms, loyalty, and feedback
2. **SV_REVENUE_OPERATIONS_INTELLIGENCE**: Dining, spa, gaming, events, and revenue metrics
3. **SV_GUEST_EXPERIENCE_INTELLIGENCE**: Guest satisfaction, service quality, and staff performance

All semantic views follow the verified syntax structure:
- TABLES clause with PRIMARY KEY definitions
- RELATIONSHIPS clause defining foreign keys
- DIMENSIONS clause with synonyms and comments
- METRICS clause with aggregations and calculations
- Proper clause ordering (TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT)
- **NO DUPLICATE SYNONYMS** - All synonyms globally unique

## Cortex Search Services

Three Cortex Search services enable semantic search over unstructured data:

1. **GUEST_REVIEWS_SEARCH**: Search 10,000 guest reviews
   - Find similar guest complaints and praise
   - Identify service quality patterns
   - Analyze sentiment trends
   - Searchable attributes: guest_id, room_type, rating, review_date

2. **HOTEL_POLICIES_SEARCH**: Search operational policies
   - Retrieve policy requirements and procedures
   - Find cancellation and refund guidelines
   - Access service standards and protocols
   - Searchable attributes: policy_category, department, effective_date

3. **INCIDENT_REPORTS_SEARCH**: Search 5,000 incident reports
   - Find similar guest issues and resolutions
   - Identify service failure patterns
   - Retrieve successful resolution procedures
   - Searchable attributes: incident_type, severity, department, resolution_status

## Syntax Verification

All SQL syntax has been verified against official Snowflake documentation:

- **CREATE SEMANTIC VIEW**: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
- **CREATE CORTEX SEARCH SERVICE**: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search
- **Cortex Search Overview**: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview

Key verification points:
- ✅ Clause order is mandatory (TABLES → RELATIONSHIPS → DIMENSIONS → METRICS)
- ✅ PRIMARY KEY columns verified to exist in source tables
- ✅ No self-referencing or cyclic relationships
- ✅ Semantic expression format: `name AS expression`
- ✅ Change tracking enabled for Cortex Search tables
- ✅ Correct ATTRIBUTES syntax for filterable columns
- ✅ All column references verified against table definitions
- ✅ No duplicate synonyms across all three semantic views

## Getting Started

### Prerequisites
- Snowflake account with Cortex Intelligence enabled
- ACCOUNTADMIN or equivalent privileges
- X-SMALL or larger warehouse

### Quick Start
```sql
-- 1. Create database and schemas
@sql/setup/01_database_and_schema.sql

-- 2. Create tables
@sql/setup/02_create_tables.sql

-- 3. Generate sample data (10-20 minutes)
@sql/data/03_generate_synthetic_data.sql

-- 4. Create analytical views
@sql/views/04_create_views.sql

-- 5. Create semantic views
@sql/views/05_create_semantic_views.sql

-- 6. Create Cortex Search services (5-10 minutes)
@sql/search/06_create_cortex_search.sql
```

### Configure Agent
Follow the detailed instructions in `docs/AGENT_SETUP.md` to:
1. Create the Snowflake Intelligence Agent
2. Add semantic views as data sources (Cortex Analyst)
3. Configure Cortex Search services
4. Set up system prompts and instructions
5. Test with sample questions

## Testing

### Verify Installation
```sql
-- Check semantic views
SHOW SEMANTIC VIEWS IN SCHEMA FONTAINEBLEAU_INTELLIGENCE.ANALYTICS;

-- Check Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA FONTAINEBLEAU_INTELLIGENCE.RAW;

-- Test Cortex Search
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'FONTAINEBLEAU_INTELLIGENCE.RAW.GUEST_REVIEWS_SEARCH',
      '{"query": "room service slow", "limit":5}'
  )
)['results'] as results;
```

### Sample Test Questions
1. "What is our average daily rate by room type for the past quarter?"
2. "Which restaurants have the highest revenue per cover?"
3. "Show me guests at risk of not returning based on satisfaction scores."
4. "Search guest reviews for complaints about check-in wait times."

## Data Volumes

- **Guests**: 50,000
- **Rooms**: 3,600
- **Room Types**: 12 categories
- **Reservations**: 100,000
- **Restaurants**: 15 venues
- **Menu Items**: 500+ items
- **Dining Orders**: 200,000
- **Spa Services**: 50 treatments
- **Spa Appointments**: 50,000
- **Gaming Players**: 30,000
- **Gaming Transactions**: 100,000
- **Events**: 10,000
- **Staff**: 3,000
- **Guest Feedback**: 25,000
- **Loyalty Transactions**: 100,000
- **Guest Reviews**: 10,000 (unstructured)
- **Policy Documents**: 5 comprehensive guides
- **Incident Reports**: 5,000 (unstructured)

## Support

For questions or issues:
- Review `docs/AGENT_SETUP.md` for detailed setup instructions
- Check `docs/questions.md` for example questions
- Refer to Snowflake documentation for syntax verification
- Contact your Snowflake account team for assistance

## Version History

- **v1.0** (November 2025): Initial release
  - Verified semantic view syntax
  - Verified Cortex Search syntax
  - 50K guests, 100K reservations, 200K dining orders
  - 10K guest reviews with semantic search
  - 5 policy documents with operational guidance
  - 5K incident investigation reports
  - 15 test questions (5 simple + 5 complex + 5 ML)
  - Comprehensive documentation

## License

This solution is provided as a template for building Snowflake Intelligence agents. Adapt as needed for your specific use case.

---

**Created**: November 2025  
**Snowflake Documentation**: Syntax verified against official documentation  
**Target Use Case**: Fontainebleau Las Vegas luxury hotel business intelligence

**NO GUESSING - ALL SYNTAX VERIFIED** ✅  
**NO DUPLICATE SYNONYMS - ALL GLOBALLY UNIQUE** ✅

