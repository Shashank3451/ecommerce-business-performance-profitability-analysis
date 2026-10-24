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