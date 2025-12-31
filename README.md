# dwh-project
Modern DWH with SQL server with ETL, data modeling and analytics

|                | Bronze Layer            | Silver Layer               | Gold Layer               |
|----------------|-------------------------|----------------------------|--------------------------|
| Definitiion    | Raw unprocessed data    | Cleaned and processed data | Business ready           |
| Objective      | Tracebility & debugging | Prepare for analysis       | Analysis & Reporting     |
| Object Type    | Tables                  | Tables                     | Tables                   |
| Load Method    | Full Load               | Full Load                  | None                     |
| Transformation | None                    | Full transformation        | Aggregations, biz logics |
| Modelling      | As is                   | As is                      | Which Schema             |
| RBAC           | Data Engineers          | Data Engineers, Analysts   | Business Users           |

The data architecture of this project would is done with medallion architecture using bronze, silver and gold layers.
ETL from source to warehouse.
Creating fact and dimension tables for analytical queries.

# methods used
Extraction method - pull
Extraction type - Full
Extraction Technique - File Parsing

Transformation - whatever is required

Processing Types - Batch
Load Method - Full Load
SCD Type - Type 1

***
For this project, star schema is adopted because the dataset is fixed and not expected to grow. This approach offers simplicity, faster query performance and easier maintenance which is ideal for static or moderately sized datasets.

If the dataset were expected to grow significantly over time, a snowflake schema might be more appropriate. Snowflake schemas normalize dimension tables to reduce redundancy and storage footprint, which can help manage large or evolving datasets. However, this comes with increased complexity in query design and performance trade-offs due to additional joins

In both schemas, the relationship between dimension and fact are typically 1:N
***

# requirements
Modern DWH using SQL server

# specs:
- 2 csv files
- cleanse and resolve data quality issues
- combining both data sources 
- documentation

Tools: 
SSMS - https://learn.microsoft.com/en-us/ssms/install/install?view=sql-server-ver16
SQL exzpress - https://www.microsoft.com/en-us/sql-server/sql-server-downloads

naming conventions:
Bronze and Silver <sourcesystem>_<entity> e.g. crm_customer_info
Gold Layer integrates multiple sources together hence names should be meaningful
<category>_<entity> e.g dim_customers, fact_sales, agg_customers

Columns Naming Conventions:
surrogate keys: <table_name>_<key>

technical columns: <dwh>_<column_name> e.g. dwh_created_date

stored procedure: load_<layer> e.g. load_bronze, load_silver

