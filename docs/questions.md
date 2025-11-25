<img src="../Snowflake_Logo.svg" width="200">

# Fontainebleau Intelligence Agent - Test Questions

This document provides test questions to validate the Fontainebleau Intelligence Agent's capabilities across all three tool types: Cortex Analyst (structured data), Cortex Search (unstructured data), and ML Models (predictions).

---

## Simple Questions (Cortex Analyst)

These questions test basic structured data queries using the semantic views.

### 1. Total Guests Count
**Question:** How many guests are in the system?

**Expected Behavior:** Agent uses HotelOperationsAnalyst tool to query GUESTS table.

**Expected Answer:** Returns the count of distinct guests (approximately 10,000 based on synthetic data).

---

### 2. Average Daily Room Rate
**Question:** What is the average daily rate for all rooms?

**Expected Behavior:** Agent uses RevenueManagementAnalyst tool to calculate average from ROOMS table.

**Expected Answer:** Returns the average daily_rate across all room types.

---

### 3. Room Types Available
**Question:** List all available room types and their counts.

**Expected Behavior:** Agent queries ROOMS table grouped by room_type.

**Expected Answer:** Returns list including Standard, Deluxe, Suite, Penthouse, etc.

---

### 4. Active Reservations Count
**Question:** How many reservations are currently confirmed?

**Expected Behavior:** Agent filters reservations by status = 'CONFIRMED'.

**Expected Answer:** Returns count of confirmed reservations.

---

### 5. Staff Count by Position
**Question:** Show me the number of staff members in each position.

**Expected Behavior:** Agent queries STAFF table grouped by position.

**Expected Answer:** Returns breakdown of Managers, Receptionists, Housekeeping, etc.

---

## Complex Questions (Cortex Analyst)

These questions test multi-table joins, aggregations, and analytical queries.

### 1. Revenue Analysis by Booking Channel
**Question:** Analyze revenue performance by booking channel. Show me total revenue, average booking value, and cancellation rates for each channel (Online, Direct, Travel Agent).

**Expected Behavior:** Agent uses RevenueManagementAnalyst to join RESERVATIONS data, group by booking_channel, and calculate multiple metrics.

**Expected Answer:** Returns table with booking channels, total revenue, avg booking value, and cancellation percentages.

---

### 2. Guest Experience Analysis
**Question:** Analyze guest feedback trends. Show me the sentiment distribution (positive, neutral, negative) over the past year, common feedback categories, and correlation between feedback and loyalty member status.

**Expected Behavior:** Agent uses GuestExperienceAnalyst to analyze GUEST_FEEDBACK joined with GUESTS.

**Expected Answer:** Returns sentiment breakdown, top feedback categories, and comparison of loyalty vs non-loyalty member feedback.

---

### 3. Room Occupancy Patterns
**Question:** Analyze room occupancy rates by room type for the last quarter. Show me average occupancy, peak occupancy dates, and which room types are most popular.

**Expected Behavior:** Agent joins RESERVATIONS with ROOMS, calculates occupancy metrics by room_type and date.

**Expected Answer:** Returns occupancy percentages by room type and identifies peak dates.

---

### 4. Maintenance Performance Analysis
**Question:** Analyze maintenance request trends. What are the most common issue types, average resolution times, and which floors have the most maintenance requests?

**Expected Behavior:** Agent uses HotelOperationsAnalyst to analyze MAINTENANCE_REQUESTS joined with ROOMS and STAFF.

**Expected Answer:** Returns issue type breakdown, avg resolution time in hours, and requests by floor.

---

### 5. Service Revenue Deep Dive
**Question:** Which services generate the most revenue? Show me total revenue by service type, average price, and peak usage times (day of week and month).

**Expected Behavior:** Agent analyzes SERVICES table with temporal groupings.

**Expected Answer:** Returns service revenue ranking with SPA, ROOM_SERVICE, DINING, etc., and usage patterns.

---

## Unstructured Data Questions (Cortex Search)

These questions test the Cortex Search services for semantic search across text data.

### 1. Guest Feedback Search - Room Quality
**Question:** Search guest feedback for comments about room cleanliness and housekeeping.

**Expected Behavior:** Agent uses GuestFeedbackSearch tool to find relevant feedback entries.

**Expected Answer:** Returns feedback entries mentioning room conditions, cleanliness, housekeeping quality.

---

### 2. Policy Document Search - Safety
**Question:** Find policy documentation about emergency response procedures and fire safety.

**Expected Behavior:** Agent uses PolicyDocumentsSearch tool to locate safety policies.

**Expected Answer:** Returns relevant sections from Emergency Response Procedures document.

---

### 3. Maintenance Reports Search - HVAC
**Question:** Search maintenance reports for HVAC system failures and air conditioning issues.

**Expected Behavior:** Agent uses MaintenanceReportsSearch tool to find relevant reports.

**Expected Answer:** Returns maintenance reports discussing HVAC diagnosis, repair, and recommendations.

---

### 4. Guest Feedback Search - Dining
**Question:** Find guest comments about the restaurant and dining experiences.

**Expected Behavior:** Agent searches feedback for dining-related mentions.

**Expected Answer:** Returns feedback about food quality, service, restaurant atmosphere.

---

### 5. Policy Search - Guest Privacy
**Question:** What does the hotel policy say about guest data privacy and information handling?

**Expected Behavior:** Agent searches policy documents for privacy-related content.

**Expected Answer:** Returns sections from Guest Privacy Policy about data collection, use, and rights.

---

## ML Model Questions (Predictions)

These questions test the ML model wrapper functions for predictive capabilities.

### 1. Guest Satisfaction Prediction - All Tiers
**Question:** Predict guest satisfaction patterns across all loyalty tiers.

**Expected Behavior:** Agent calls PREDICT_GUEST_SATISFACTION procedure with NULL for all tiers.

**Expected Answer:** Returns sentiment distribution (POSITIVE/NEUTRAL/NEGATIVE counts) and accuracy based on recent feedback.

---

### 2. Guest Satisfaction Prediction - Platinum Members
**Question:** Analyze guest satisfaction predictions for our PLATINUM tier members.

**Expected Behavior:** Agent calls PREDICT_GUEST_SATISFACTION with loyalty_tier_filter='PLATINUM'.

**Expected Answer:** Returns sentiment predictions and accuracy for Platinum loyalty members.

---

### 3. Room Occupancy Forecast - 3 Months
**Question:** Forecast room occupancy for the next 3 months.

**Expected Behavior:** Agent calls FORECAST_ROOM_OCCUPANCY procedure with months_ahead=3.

**Expected Answer:** Returns predicted occupancy rate percentage compared to historical averages.

---

### 4. Spa Demand - This Weekend
**Question:** Predict spa appointment demand for the upcoming weekend (2 days ahead).

**Expected Behavior:** Agent calls PREDICT_SPA_DEMAND with days_ahead=2.

**Expected Answer:** Returns predicted spa appointment count based on historical patterns.

---

### 5. Spa Demand - Next Week
**Question:** What's the predicted spa demand for next week?

**Expected Behavior:** Agent calls PREDICT_SPA_DEMAND with days_ahead=7.

**Expected Answer:** Returns forecasted spa appointment demand for 7 days ahead.

---

## Multi-Tool Questions (Combined Capabilities)

These questions may require the agent to use multiple tools to provide a comprehensive answer.

### 1. Comprehensive Guest Analysis
**Question:** For our high-value loyalty members, analyze their feedback sentiment, booking patterns, and predict their satisfaction for an upcoming stay.

**Expected Behavior:** 
1. Uses Cortex Analyst to query loyalty member data and booking patterns
2. Uses Cortex Search to find their feedback
3. Uses ML model to predict satisfaction

---

### 2. Operational Insights with Search
**Question:** What are the most common maintenance issues for Penthouse suites, and are there any policy documents about preventive maintenance?

**Expected Behavior:**
1. Uses Cortex Analyst to query maintenance requests for Penthouse rooms
2. Uses Cortex Search to find maintenance policies

---

### 3. Revenue Forecast with Context
**Question:** Based on current booking trends, forecast next month's revenue and show me any guest feedback that might impact future bookings.

**Expected Behavior:**
1. Uses Cortex Analyst for current revenue trends
2. Uses ML model for forecasting
3. Uses Cortex Search for relevant feedback

---

## Validation Checklist

Use this checklist to verify the agent is working correctly:

| Test Category | Questions Tested | Pass/Fail |
|--------------|------------------|-----------|
| Simple Structured (5) | 1-5 | [ ] |
| Complex Structured (5) | 1-5 | [ ] |
| Unstructured Search (5) | 1-5 | [ ] |
| ML Predictions (5) | 1-5 | [ ] |
| Multi-Tool (3) | 1-3 | [ ] |

**Total: 23 test questions**

---

## Notes for Testing

1. **Response Time**: Simple queries should return in seconds; complex analytics may take 10-30 seconds.

2. **Data Freshness**: If you modified the synthetic data, results will differ from examples.

3. **ML Model Accuracy**: Predictions are based on synthetic data; real-world accuracy would require production data training.

4. **Search Relevance**: Cortex Search uses semantic matching; results may include conceptually similar content.

5. **Error Handling**: The agent should gracefully handle questions outside its capability and explain limitations.

