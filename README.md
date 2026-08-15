# Northwind SQL Skills Demonstration (MySQL)

## Overview
A focused technical project using the Northwind sample database to demonstrate SQL proficiency (JOINs, string and datetime functions, CASE logic, window functions, subqueries, and CTEs) using a properly normalized, multi-table relational schema.

## Purpose
Northwind's 19 interconnected tables required relational SQL: JOINs across multiple tables, handling of NULLs and duplicate matches, and window functions applied correctly on top of aggregated data. This project exists specifically to demonstrate SQL technique.

## Skills Demonstrated

**Joins**
- INNER JOIN across 2–4 tables (customers, orders, order_details, products)
- LEFT JOIN with anti-join pattern to find customers with no orders and products never sold
- Distinguished semi-join (EXISTS) behavior from INNER JOIN duplication

**String Functions**
- CONCAT, UPPER/LOWER, SUBSTRING, LEFT/RIGHT, REPLACE
- LENGTH/TRIM comparison to detect hidden whitespace in text fields

**Datetime Functions**
- DATEDIFF for order-to-ship fulfillment time
- CASE-based shipping speed buckets (Fast / Standard / Slow)
- YEAR/MONTH grouping for order volume by period
- DATE_ADD for shipping deadline comparisons

**Window Functions**
- DENSE_RANK() - product revenue ranked within category 
- ROW_NUMBER() - each customer's most recent order, filtered via a subquery wrapper 
- SUM() OVER() - running revenue total by date, aggregated by day first
- LAG() - month-over-month revenue growth
- NTILE(4) - customer spend quartiles

**Subqueries & CTEs**
- CTE-based comparison of each customer's spend against the overall average
- Nested subquery identifying orders containing the highest-priced product

## Dataset
Northwind (MySQL port): https://github.com/dalers/mywind

## Files
- `northwind sql queries.sql` - all queries from this project

## Note on Scope
This dataset is intentionally small (48 orders), which limits it as a source of business insight.
