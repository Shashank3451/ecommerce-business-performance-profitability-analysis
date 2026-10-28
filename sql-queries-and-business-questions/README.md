# Advanced SQL Analytics & Database Design
This directory contains the core analytical engine of the project. The scripts are
divided into database schema setup and business-oriented complex logic queries.

## Files Included- table_creation.sql: Contains the DDL code to build the relational tables (Customers,
Orders, Products, Payments) with proper primary and foreign key constraints.
- business_questions.sql: Hosts the advanced queries engineered to solve the 5-8
foundational business questions.

## Advanced SQL Concepts Applied- CTEs (Common Table Expressions): Implemented for high query readability and
multi-stage logic isolation.- Window Functions: Applied ROW_NUMBER(), RANK(), and SUM() OVER() for dynamic customer
ranking and cumulative revenue analysis.- Aggregations & Joins: Utilized complex Inner/Left joins alongside strategic grouping
to aggregate millions of data rows seamlessly.

# Advanced SQL Analytics & Database Design
This directory contains the core analytical engine of the project. The scripts are divided into database schema setup and business-oriented analytical queries.

## Files Included
- `table_creation.sql`: Contains the DDL code to build the relational tables (Customers, Orders, Products, Payments) with proper primary and foreign key constraints.
- `business_questions.sql`: Contains SQL queries organized into six analytical sections to answer business questions and derive meaningful business insights.

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
