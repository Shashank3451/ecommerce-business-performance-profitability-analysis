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

### 1. Create CSV File Format

```sql
CREATE OR REPLACE FILE FORMAT
    ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.CSV_FORMAT
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', 'null')
    EMPTY_FIELD_AS_NULL = TRUE
    DATE_FORMAT = 'DD-MM-YYYY';
```

### 2. Create Internal Stage

```sql
CREATE STAGE
    ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.ECOM_STAGE
    FILE_FORMAT =
    ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.CSV_FORMAT;
```

### 3. Load Data from Stage into Tables

The following commands load CSV files from the Snowflake internal stage into the dimension and fact tables.

```sql
-- Load data into DIM_DATE
COPY INTO ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.DIM_DATE
FROM @ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.ECOM_STAGE/Dim_Date.csv
FILE_FORMAT = (
    FORMAT_NAME = 'ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.CSV_FORMAT'
);

-- Load data into DIM_CUSTOMER
COPY INTO ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.DIM_CUSTOMER
FROM @ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.ECOM_STAGE/Dim_Customer.csv
FILE_FORMAT = (
    FORMAT_NAME = 'ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.CSV_FORMAT'
);

-- Load data into DIM_PRODUCT
COPY INTO ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.DIM_PRODUCT
FROM @ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.ECOM_STAGE/Dim_Product.csv
FILE_FORMAT = (
    FORMAT_NAME = 'ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.CSV_FORMAT'
);

-- Load data into DIM_ORDER
COPY INTO ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.DIM_ORDER
FROM @ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.ECOM_STAGE/Dim_Order.csv
FILE_FORMAT = (
    FORMAT_NAME = 'ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.CSV_FORMAT'
);

-- Load data into FACT_ORDER_ITEMS
COPY INTO ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.FACT_ORDER_ITEMS
FROM @ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.ECOM_STAGE
FILE_FORMAT = (
    FORMAT_NAME = 'ECOMMERCE_ANALYTICS_DB.PROFITABILITY_ANALYSIS.CSV_FORMAT'
)
FILES = ('Fact_Order_Items.csv')
FORCE = TRUE
ON_ERROR = 'ABORT_STATEMENT';
```
