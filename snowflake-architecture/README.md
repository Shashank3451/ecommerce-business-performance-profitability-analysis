# Snowflake Data Warehousing & Architecture
This folder contains the documentation and details of the data warehousing setup in
Snowflake for the E-commerce Analytics Project.

## Architecture Components

### 1. Storage & Ingestion (Staging)- Data Source: Raw E-commerce datasets (Customers, Orders, Products, Date, Payments) in CSV
format.- Stage Type: Internal Named Stage (@ECOM_STAGE) used to upload files safely before
loading into tables.- File Format: CSV format with SKIP_HEADER = 1, FIELD_OPTIONALLY_ENCLOSED_BY = '"', and
ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE.

### 2. Database Schema Design
We implemented a multi-layer schema approach to maintain data quality:- RAW_STAGE_DB: Holds the raw, untouched data directly from CSV files.- ANALYTICS_DB: Contains the cleaned, transformed, and final structured tables (Fact and
Dimension tables) optimized for Power BI.

### 3. Virtual Warehouse Configuration- Warehouse Name: COMPUTE_WH- Size: X-Small (Sufficient for handling millions of rows for this analysis while
keeping cloud costs low).- Scaling Policy: Standard, with Auto-Suspend set to 5 minutes to save credits when
idle.

## Key Snowflake Commands Used (Examples)```

-- 1. Create Internal Stage
CREATE OR REPLACE STAGE ECOM_STAGE;

-- 2. Create File Format
CREATE OR REPLACE FILE FORMAT csv_format
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- 3. Copy Data from Stage to Table
COPY INTO RAW_STAGE_DB.PUBLIC.CUSTOMERS
FROM @ECOM_STAGE/customers.csv
FILE_FORMAT = (FORMAT_NAME = csv_format)
ON_ERROR = 'CONTINUE';
```
