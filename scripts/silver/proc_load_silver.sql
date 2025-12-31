/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '============================================='
        PRINT 'Loading Silver Table'
        PRINT '============================================='

		PRINT '---------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------------';

        SET @start_time = GETDATE();
        print '>> Truncating table: silver.crm_cust_info';
        truncate table [silver].[crm_cust_info];
        print 'Inserting data into: silver.crm_cust_info';
        -- QC names, gndr, marital status and date
        -- load to silver table
        insert into silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date)
        select
        cst_id,
        cst_key,
        trim(cst_firstname) as cst_firstname,
        trim(cst_lastname) as cst_lastname,
        case when upper(trim(cst_marital_status)) = 'M' then 'Married'
            when upper(trim(cst_marital_status)) = 'S' then 'Single'
            else 'n/a'
        end cst_marital_status, -- normalise marital status to readable format
        case when upper(trim(cst_gndr)) = 'F' then 'Female'
            when upper(trim(cst_gndr)) = 'M' then 'Male'
            else 'n/a'
        end cst_gndr, -- normalise gender values to readable format
        cst_create_date
        from (
            select
            *,
            ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
            from bronze.crm_cust_info
            where cst_id is not null
        )t where flag_last = 1;
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------';

        SET @start_time = GETDATE();
        print '>> Truncating table: silver.crm_prd_info';
        truncate table silver.crm_prd_info;
        print 'Inserting data into: silver.crm_prd_info';
        -- check for nulls or duplicates in PK
        -- insert into silver table 
        insert into silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        select
        prd_id,
        replace(SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id,
        substring(prd_key, 7, LEN(prd_key)) as prd_key,
        prd_nm,
        isnull(prd_cost, 0) as prd_cost,
        case upper(trim(prd_line))
            when 'M' then 'Mountain'
            when 'R' then 'Road'
            when 'S' then 'Other Sales'
            when 'T' then 'Touring'
            else 'n/a'
        end as prd_line,
        cast (prd_start_dt as date) as prd_start_dt,
        cast (lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
        from bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------'

        SET @start_time = GETDATE();
        print '>> Truncating table: silver.crm_sales_details';
        truncate table silver.crm_sales_details;
        print 'Inserting data into: silver.crm_sales_details';
        insert into silver.crm_sales_details (
        sls_prd_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
        )
        select
        sls_prd_num,
        sls_prd_key,
        sls_cust_id,
        case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null
            else CAST(cast(sls_order_dt as varchar) as date)
        end as sls_order_dt,
        case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null
            else CAST(cast(sls_ship_dt as varchar) as date)
        end as sls_ship_dt,
        case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null
            else CAST(cast(sls_due_dt as varchar) as date)
        end as sls_due_dt,
        case when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
                then sls_quantity * abs(sls_price)
            else sls_sales
        end as sls_sales,
        sls_quantity,
        case when sls_price is null or sls_price <= 0
                then sls_sales / nullif(sls_quantity, 0)
            else sls_price
        end as sls_price
        from bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------';


        PRINT '---------------------------------------------';
		PRINT 'Loading ERP Tables'
		PRINT '---------------------------------------------';

        SET @start_time = GETDATE();
        print '>> Truncating table: [silver].[erp_cust_az12]';
        truncate table [silver].[erp_cust_az12];
        print 'Inserting data into: [silver].[erp_cust_az12]';
        insert into [silver].[erp_cust_az12] (
            cid,
            bdate,
            gen
        )
        select 
        case when cid like 'NAS%' then substring(cid, 4, len(cid))
            else cid
        end as cid,
        case when bdate > getdate() then null
            else bdate
        end as bdate,
        case when upper(trim(gen)) in ('F', 'Female') then 'Female'
            when upper(trim(gen)) in ('M', 'Male') then 'Male'
            else 'n/a'
        end as gen
        from [bronze].[erp_cust_az12];
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------';

        SET @start_time = GETDATE();
        print '>> Truncating table: [silver].[erp_loc_a101]';
        truncate table [silver].[erp_loc_a101];
        print 'Inserting data into: [silver].[erp_loc_a101]';
        insert into [silver].[erp_loc_a101] (
            cid,
            cntry
        )
        select 
        replace(cid, '-', '') cid,
        case when trim(cntry) = 'DE' then 'Germany'
            when trim(cntry) in ('US', 'USA') then 'United States'
            when trim(cntry) = '' or cntry is null then 'n/a'
            else trim(cntry)
        end as cntry
        from [bronze].[erp_loc_a101];
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------';

        SET @start_time = GETDATE();
        print '>> Truncating table: [silver].[erp_px_cat_g1v2]';
        truncate table [silver].[erp_px_cat_g1v2];
        print 'Inserting data into: [silver].[erp_px_cat_g1v2]';
        insert into [silver].[erp_px_cat_g1v2] (
            id,
            cat,
            subcat,
            maintenance
        )
        select
        id,
        cat,
        subcat,
        maintenance
        from [bronze].[erp_px_cat_g1v2];
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------';

        SET @batch_end_time = GETDATE();
        PRINT '============================================='
        PRINT 'Loading silver layer completed';
        PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) as NVARCHAR) + ' seconds';
        PRINT '============================================='
    END TRY
    BEGIN CATCH
        PRINT '============================================='
        PRINT 'Error occured during loading silver layer'
        PRINT 'Error:' + ERROR_MESSAGE();
        PRINT 'Error:' + CAST (ERROR_MESSAGE() as NVARCHAR);
        PRINT 'Error:' + CAST (ERROR_STATE() as NVARCHAR);
        PRINT '============================================='
    END CATCH
END