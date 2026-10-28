# Snowflake Data Warehousing & Architecture
This folder contains the documentation and details of the Snowflake data warehousing setup for the E-commerce Analytics Project, covering data ingestion, database design, and compute resource configuration.

## Architecture Components

### 1. Storage & Ingestion (Staging)

- **Data Source:** Raw e-commerce datasets (Customers, Orders, Products, Date, and Payments) in CSV format.
- **Stage Type:** Internal named stage (`@ECOM_STAGE`) used to upload files before loading them into tables.
- **File Format:** CSV format with `SKIP_HEADER = 1`, `FIELD_OPTIONALLY_ENCLOSED_BY = '"'`, and `ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE`.

### 2. Database Schema Design

A multi-layer schema approach was implemented to organize raw data and analytical tables.

- **RAW_STAGE_DB:** Stores raw, unmodified data loaded from CSV files.
- **ANALYTICS_DB:** Contains cleaned, transformed, and structured fact and dimension tables optimized for Power BI reporting.

### 3. Virtual Warehouse Configuration

- **Warehouse Name:** `COMPUTE_WH`
- **Size:** `X-Small`, configured to support the analytical workload while controlling compute costs.
- **Scaling Policy:** Standard, with auto-suspend set to 5 minutes to reduce credit consumption during idle periods.

## Key Snowflake Commands Used
The following commands illustrate the core steps involved in setting up the staging environment and defining the CSV file format.

### 1. Create Internal Stage

```sql
CREATE OR REPLACE STAGE ECOM_STAGE;
```

### 2. Create CSV File Format

```sql
CREATE OR REPLACE FILE FORMAT csv_format
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';
```

### 3. Copy Data from Stage to Table

```sql
COPY INTO RAW_STAGE_DB.PUBLIC.CUSTOMERS
FROM @ECOM_STAGE/customers.csv
FILE_FORMAT = (FORMAT_NAME = csv_format)
ON_ERROR = 'CONTINUE';
```
