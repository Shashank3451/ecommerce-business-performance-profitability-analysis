# Advanced SQL Analytics & Database Design
This directory contains the core analytical engine of the project. The scripts are divided into database schema setup and business-oriented analytical queries.

 ## Files Included
- [`Create_Ecommerce_Analytics_DB.sql`](../snowflake-architecture/Create_Ecommerce_Analytics_DB.sql) — Contains SQL statements for creating the Snowflake database and setting up the analytics environment.
- [`Insert_Data_from_Stage.sql`](../snowflake-architecture/Insert_Data_from_Stage.sql) — Contains SQL statements for loading data from a Snowflake stage into the target tables.
- [`SQL_Queries_Analysis.sql`](SQL_Queries_Analysis.sql) — Contains SQL queries organized into six analytical sections to analyze business performance, profitability, and customer segmentation.

## SQL Analysis Framework
The SQL analysis is organized into six key business domains, with dedicated queries developed to investigate business questions, analyze performance, and derive actionable insights.

1. **Data Quality and Validation** — Evaluating data completeness, consistency, and reliability to establish a foundation for accurate analysis.
2. **Overall Business Performance** — Analyzing key business metrics and performance trends to assess overall business performance.
3. **Product and Category Performance** — Evaluating product and category-level performance to identify key contributors to business results.
4. **Discount and Profitability Analysis** — Examining discount patterns and their relationship with sales and profitability.
5. **Customer Demographics and Segmentation** — Analyzing customer characteristics and segment-level behavior to understand customer contributions and patterns.
6. **Advanced Business Analysis** — Investigating broader business trends and patterns to generate deeper insights and support data-driven decision-making.

## Advanced SQL Concepts Applied

- **CTEs (Common Table Expressions):** Used to improve query readability and organize multi-stage logic.
- **Window Functions:** Applied `ROW_NUMBER()`, `RANK()`, and `SUM() OVER()` for customer ranking and cumulative revenue analysis.
- **Aggregations & Joins:** Used Inner and Left Joins with strategic grouping to analyze and summarize business data.
