# SQL Data Warehouse Project Catalog

## Project Overview

This project implements a modern Data Warehouse using SQL Server following the Medallion Architecture pattern.

The warehouse integrates CRM and ERP source systems and transforms raw operational data into business-ready analytical datasets.

---

# Architecture

Source Systems
↓
Bronze Layer
↓
Silver Layer
↓
Gold Layer
↓
Analytics & Reporting

---

# Source Systems

The warehouse consumes data from two operational systems.

## CRM System

Contains customer, product, and sales information.

### Files

* cust_info.csv
* prd_info.csv
* sales_details.csv

---

## ERP System

Contains customer demographic and product category information.

### Files

* CUST_AZ12.csv
* LOC_A101.csv
* PX_CAT_G1V2.csv

---

# Bronze Layer

## Purpose

Stores raw source data exactly as received.

No business transformations are performed.

Acts as the landing zone for source system data.

---

## Loading Method

Stored Procedure:

```sql
bronze.load_bronze
```

### Operations

* Truncate existing Bronze tables
* Bulk load source CSV files
* Preserve source structure

---

## Bronze Tables

### CRM

| Table                    |
| ------------------------ |
| bronze.crm_cust_info     |
| bronze.crm_prd_info      |
| bronze.crm_sales_details |

### ERP

| Table                  |
| ---------------------- |
| bronze.erp_CUST_AZ12   |
| bronze.erp_LOC_A101    |
| bronze.erp_PX_CAT_G1V2 |

---

# Silver Layer

## Purpose

Stores cleansed and standardized data.

This layer applies business rules and data quality checks.

---

## Loading Method

Stored Procedure:

```sql
silver.load_silver
```

---

## Key Transformations

### Customer Data

* Remove duplicate customers
* Standardize gender values
* Standardize marital status
* Trim unnecessary spaces

### Product Data

* Create category identifiers
* Generate product keys
* Standardize product line values
* Calculate product end dates

### Sales Data

* Validate order dates
* Validate shipping dates
* Validate due dates
* Correct sales calculations
* Handle missing values

### ERP Customer Data

* Standardize gender values
* Clean customer identifiers
* Validate birth dates

### ERP Location Data

* Standardize country names
* Handle missing values

---

## Silver Tables

| Table                    |
| ------------------------ |
| silver.crm_cust_info     |
| silver.crm_prd_info      |
| silver.crm_sales_details |
| silver.erp_CUST_AZ12     |
| silver.erp_LOC_A101      |
| silver.erp_PX_CAT_G1V2   |

---

# Gold Layer

## Purpose

Provides business-ready datasets for analytics and reporting.

Implements dimensional modeling principles.

---

# Data Model

The Gold Layer follows a Star Schema design.

---

## Dimension Tables

### gold.dim_customers

Customer master information.

#### Attributes

* customer_key (Surrogate Key)
* customer_id
* customer_number
* first_name
* last_name
* country
* gender
* birthdate
* marital_status

---

### gold.dim_products

Product master information.

#### Attributes

* product_key (Surrogate Key)
* product_id
* product_number
* product_name
* category
* subcategory
* maintenance_type
* product_line
* cost

---

## Fact Table

### gold.fact_sales

Stores business transactions.

#### Measures

* sales_amount
* quantity
* price

#### Foreign Keys

* customer_key
* product_key

#### Dates

* order_date
* shipping_date
* due_date

---

# Business Rules

## Customer Gender

Priority:

1. CRM Gender
2. ERP Gender
3. n/a

---

## Customer Country

Priority:

1. ERP Country
2. n/a

---

## Product End Date

Calculated as:

Next Product Start Date - 1 Day

Implemented using:

* LEAD()
* DATEADD()

---

## Sales Validation

Sales Amount:

Sales = Quantity × Price

Invalid values are corrected during Silver Layer processing.

---

# Pipeline Execution

Execute the warehouse in the following order.

## Step 1

```sql
EXEC bronze.load_bronze;
```

Loads raw source data.

---

## Step 2

```sql
EXEC silver.load_silver;
```

Performs data cleansing and transformation.

---

## Step 3

Execute Gold Layer scripts.

Creates:

* Customer Dimension
* Product Dimension
* Sales Fact Table

---

# Technologies Used

* SQL Server
* SQL Server Management Studio (SSMS)
* T-SQL
* Stored Procedures
* Window Functions
* Dimensional Modeling

---

# Concepts Demonstrated

* Data Warehousing
* Medallion Architecture
* ELT Pipelines
* Data Quality Management
* Data Cleansing
* Star Schema Design
* Surrogate Keys
* Fact Tables
* Dimension Tables
* Window Functions
* Business Rule Implementation
