# Northwind SQL Skills Demonstration (MySQL)

## Overview
A focused technical project using the Northwind sample database to demonstrate comprehensive SQL proficiency (JOINs, string and datetime functions, CASE logic, window functions, subqueries, and CTEs) using a properly normalized, multi-table relational schema.

## Purpose
Northwind's 19 interconnected tables required genuine relational SQL: JOINs across multiple tables, careful handling of NULLs and duplicate matches, and window functions applied correctly on top of aggregated data. This project exists specifically to demonstrate SQL technique in depth — it complements the business-analysis projects rather than replacing them.

## Skills Demonstrated

**Joins**
- INNER JOIN across 2–4 tables (customers, orders, order_details, products)
- LEFT JOIN with anti-join pattern (`WHERE ... IS NULL`) to find customers with no orders and products never sold
- Distinguished semi-join (EXISTS) behavior from INNER JOIN duplication

**String Functions**
- CONCAT, UPPER/LOWER, SUBSTRING, LEFT/RIGHT, REPLACE
- LENGTH/TRIM comparison to detect hidden whitespace in text fields

**Datetime Functions**
- DATEDIFF for order-to-ship fulfillment time
- CASE-based shipping speed buckets (Fast / Standard / Slow)
- YEAR/MONTH grouping for order volume by period
- DATE_ADD for SLA deadline comparisons

**Window Functions**
- DENSE_RANK() — product revenue ranked within category (aggregated via CTE first, not per line-item)
- ROW_NUMBER() — each customer's most recent order, filtered via a subquery wrapper (window function results can't be filtered in the same SELECT's WHERE clause)
- SUM() OVER() — running revenue total by date, aggregated by day first
- LAG() — month-over-month revenue growth, correctly ordered by year and month together to avoid merging across years
- NTILE(4) — customer spend quartiles, built in two versions (active buyers only, and including zero-spend customers via LEFT JOIN + COALESCE)

**Subqueries & CTEs**
- CTE-based comparison of each customer's spend against the overall average
- Nested subquery identifying orders containing the highest-priced product, using IN rather than = to safely handle ties

## Methodology Notes
- Grouping and partitioning were done on unique ID columns (e.g., `customer_id`) rather than display text (e.g., concatenated names), to avoid incorrect merging if two records shared identical text values.
- "Highest-priced product" was determined using the transaction-level `unit_price` in `order_details`, reflecting actual price paid, rather than the catalog `list_price`, since these can differ.
- Customer spend quartiles were built with two explicit interpretations (buyers only, and all customers including non-buyers) since both are valid depending on the business question being asked.

## Dataset
Northwind (MySQL port): https://github.com/dalers/mywind

## Files
- `northwind_queries.sql` — all queries from this project, organized by skill category, with comments

## Note on Scope
This dataset is intentionally small (48 orders), which limits it as a source of business insight.
