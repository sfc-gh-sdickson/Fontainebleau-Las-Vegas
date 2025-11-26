# AI Generation Failures and Lessons Learned

## Project: Fontainebleau Las Vegas Intelligence Agent
## Date: November 26, 2025

This document catalogs all AI generation failures during this project to prevent repeating them in future sessions.

---

## CRITICAL RULE: Snowflake SQL is NOT Generic SQL

**NEVER assume syntax from other databases works in Snowflake. ALWAYS verify against Snowflake SQL Reference.**

---

## Failure Category 1: Snowflake Function Constraints

### 1.1 UNIFORM() Function - Arguments Must Be Constants

**What I did wrong:**
```sql
-- WRONG: Column values as arguments
UNIFORM(0, res.nights, RANDOM())
UNIFORM(0, res.nights - 1, RANDOM())
UNIFORM(1, s.max_guests, RANDOM())
```

**What I should have done:**
```sql
-- CORRECT: Use MOD with RANDOM or LEAST with constant UNIFORM
MOD(ABS(RANDOM()), GREATEST(res.nights, 1))
LEAST(UNIFORM(1, 10, RANDOM()), s.max_guests)
```

**Rule:** `UNIFORM(min, max, generator)` - min and max MUST be constant literal values, not column references.

---

### 1.2 SEQ4() Function - Only Valid in GENERATOR Context

**What I did wrong:**
```sql
-- WRONG: SEQ4() in regular SELECT without GENERATOR
SELECT
    'LOY' || LPAD(SEQ4(), 10, '0') AS loyalty_id,
    ...
FROM GUESTS g
```

**What I should have done:**
```sql
-- CORRECT: Use ROW_NUMBER() for non-GENERATOR contexts
SELECT
    'LOY' || LPAD(ROW_NUMBER() OVER (ORDER BY g.guest_id), 10, '0') AS loyalty_id,
    ...
FROM GUESTS g

-- OR use SEQ4() only with GENERATOR
SELECT SEQ4() FROM TABLE(GENERATOR(ROWCOUNT => 100))
```

**Rule:** `SEQ4()` is ONLY valid when selecting from `TABLE(GENERATOR(...))`. For all other contexts, use `ROW_NUMBER() OVER (ORDER BY ...)`.

---

### 1.3 GENERATOR() Function - ROWCOUNT Must Be Constant

**What I did wrong (potential):**
```sql
-- WRONG: Variable rowcount
TABLE(GENERATOR(ROWCOUNT => some_variable))
```

**What I should have done:**
```sql
-- CORRECT: Constant rowcount
TABLE(GENERATOR(ROWCOUNT => 1000))
```

**Rule:** `GENERATOR(ROWCOUNT => n)` - n MUST be a constant integer literal.

---

## Failure Category 2: ML Model Wrapper Procedures

### 2.1 Changing Working Code When Not Asked

**What I did wrong:**
- User asked me to fix ONLY procedure 2 (FORECAST_ROOM_OCCUPANCY)
- I changed ALL THREE procedures, breaking procedures 1 and 3 that were working

**What I should have done:**
- Touch ONLY the code the user asked me to fix
- Leave working code completely untouched
- If I think other code needs changes, ASK first

**Rule:** Never modify working code unless explicitly asked. If you think something else needs fixing, ask the user first.

---

### 2.2 Data Type Mismatches with ML Models

**What I did wrong:**
```sql
-- WRONG: Cast to FLOAT when model expects INTEGER
MONTH(...)::FLOAT AS MONTH_NUM
```

**Error received:**
```
Data Validation Error in feature MONTH_NUM: Feature type DataType.INT8 is not met by column MONTH_NUM because of its original type DoubleType()
```

**What I should have done:**
1. Look at the EXACT training data query in the notebook
2. Match data types EXACTLY - if notebook uses `MONTH(x) AS month_num` (no cast), don't add a cast
3. Only cast columns that were cast in training

**Rule:** ML model input columns must have the EXACT same data types as the training data. Check the notebook training query and match it precisely.

---

### 2.3 Not Handling NULL Values

**What I did wrong:**
- Queries could return NULL values when no historical data matched
- Model cannot handle NULL inputs

**What I should have done:**
```sql
-- Use COALESCE with sensible defaults
COALESCE(AVG(column), default_value)::FLOAT AS column_name
```

**Rule:** Always use COALESCE to handle potential NULL values in ML model input queries.

---

## Failure Category 3: Process Failures

### 3.1 Not Verifying Before Committing

**What I did wrong:**
- Made changes and committed without verifying they would work
- Had to make multiple commits to fix errors

**What I should have done:**
1. Read the source data (notebook training code) carefully
2. Match column names, data types, and query structure exactly
3. Consider edge cases (NULL values, empty results)
4. Only then write the code

**Rule:** Verify correctness BEFORE making changes, not after.

---

### 3.2 Making Assumptions About Snowflake Syntax

**What I did wrong:**
- Assumed UNIFORM() worked like random functions in other databases
- Assumed SEQ4() was a general sequence generator

**What I should have done:**
- Look up every Snowflake-specific function in the documentation
- Verify syntax before using it
- Test understanding against official docs

**Rule:** Never assume. Always verify Snowflake syntax against official documentation.

---

## Verification Checklist for Future Sessions

Before declaring any Snowflake SQL ready:

### Data Generation Scripts
- [ ] All UNIFORM() calls use constant min/max values only
- [ ] All SEQ4() calls are within GENERATOR context only
- [ ] All GENERATOR() calls use constant ROWCOUNT only
- [ ] ARRAY_CONSTRUCT indices are within bounds
- [ ] All date functions use correct Snowflake syntax

### ML Model Wrappers
- [ ] Input column names match notebook training EXACTLY (case-sensitive)
- [ ] Input column data types match notebook training EXACTLY
- [ ] NULL values are handled with COALESCE
- [ ] Empty result sets are handled gracefully
- [ ] Only the requested procedure is modified

### Semantic Views
- [ ] Clause order is correct: TABLES → RELATIONSHIPS → FACTS → DIMENSIONS → METRICS
- [ ] All synonyms are globally unique
- [ ] Column references match actual table columns

### Cortex Search
- [ ] Change tracking is enabled on source tables
- [ ] ON clause specifies the searchable text column
- [ ] ATTRIBUTES lists metadata columns correctly

---

## Summary of Key Lessons

1. **Snowflake SQL ≠ Generic SQL** - Always verify syntax
2. **Don't touch working code** - Only fix what you're asked to fix
3. **Match ML training data exactly** - Column names, types, structure
4. **Handle edge cases** - NULLs, empty results, missing data
5. **Verify before committing** - Don't iterate with broken code
6. **Read the error messages** - They tell you exactly what's wrong

---

## Files Affected by These Failures

| File | Issues |
|------|--------|
| `sql/data/03_generate_synthetic_data.sql` | UNIFORM with column args, SEQ4 without GENERATOR |
| `sql/search/06_create_cortex_search.sql` | SEQ4 without GENERATOR |
| `sql/ml/07_create_model_wrapper_functions.sql` | Data type mismatches, NULL handling, modifying working code |

---

## Reference Links

- [Snowflake UNIFORM Function](https://docs.snowflake.com/en/sql-reference/functions/uniform)
- [Snowflake GENERATOR Function](https://docs.snowflake.com/en/sql-reference/functions/generator)
- [Snowflake SEQ Functions](https://docs.snowflake.com/en/sql-reference/functions/seq1)
- [Snowflake Model Registry](https://docs.snowflake.com/en/developer-guide/snowpark-ml/model-registry/overview)
- [CREATE SEMANTIC VIEW](https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view)
- [CREATE CORTEX SEARCH SERVICE](https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search)

