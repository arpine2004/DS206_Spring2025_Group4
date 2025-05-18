# Dimensional Data Warehouse ETL Pipeline

## Project Description
This project implements a dimensional data warehouse ETL pipeline for a sales/orders database. It includes the creation of staging tables, dimension tables, fact tables, and incremental data loading scripts using SQL Server. The pipeline supports Slowly Changing Dimensions (SCD) types 1, 2, 3, and 4, maintains data history, and tracks the source of records using a surrogate key (Dim_SOR).

## Features
- Staging area with raw source data tables
- Dimension tables with surrogate keys and SCD handling
- Fact tables for order details and transactions
- FactError table to capture rows failing foreign key constraints
- Parametrized SQL scripts for incremental data loading by date range
- Surrogate key tracking with Dim_SOR table
- Referential integrity with foreign key constraints

## Prerequisites
- Microsoft SQL Server 2019 or later
- Python 3.8+
- `pyodbc` Python package
- SQL Server ODBC Driver 18
- Proper database access permissions

## Setup Instructions
1. Create the `ORDER_DDS` database on your SQL Server instance.
2. Run all SQL scripts inside the `infrastructure_initiation/` folder to create staging, dimension, fact tables, and the `Dim_SOR` table.
3. Configure database connection details in your Python config file.
4. Run the ETL pipeline using the Python script `flow.py`.


### Note on Database Connection Configuration
- **For Windows users with integrated authentication:**  
 You can omit `UID` and `PWD` from your config file and use `Trusted_Connection=yes` to connect via Windows authentication.
- **For Mac users or others requiring SQL Server authentication:**  
 Specify both `UID` (username) and `PWD` (password) in the config file for explicit SQL Server login.
Configuration
The database connection parameters are stored in a config file (e.g., `sql_server_config.cfg`) that the pipeline scripts read to connect to your SQL Server instance.

Example config file section for the `ORDER_DDS` database:

```ini
[ORDER_DDS]
Driver={ODBC Driver 18 for SQL Server}
Server= yourservername
Database= ORDER_DDS
UID= exmapleuid
PWD= examplepwd
Encrypt=no
TrustServerCertificate=yes
Trusted_Connection=yes
```

You will be prompted to enter start and end dates for incremental loading (format: YYYY-MM-DD).


### Usage
- Load raw data into staging tables.
- Run the ETL pipeline specifying the ingestion window.
- Dimension tables are updated or inserted with SCD logic.
- Fact tables are loaded with transactional data referencing dimension surrogate keys.
- Invalid or missing references are logged in the `FactError` table.

### Final Notes (Important)

After downloading the file, please unzip it
to a folder with the same name, then proceed with 
working with the project. 