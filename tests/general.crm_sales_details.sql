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
from bronze.crm_sales_details
-- where sls_prd_num != trim(sls_prd_num)
-- where sls_prd_key not in ( select prd_key from silver.crm_prd_info)
-- where sls_cust_id not in ( select cst_id from silver.crm_cust_info)


-- notes + qc
-- negative or 0 cannot be cast to a date
select 
nullif(sls_order_dt, 0) sls_order_dt
from bronze.crm_sales_details
where sls_order_dt <= 0 
or len(sls_order_dt) != 8
or sls_order_dt > 20500101
or sls_order_dt < 19000101

-- invalid date orders
select
*
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

-- check data consistency between sales, quantity and price
select
sls_sales as old_sls_price,
sls_quantity,
sls_price as old_sls_price,
case when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
		then sls_quantity * abs(sls_price)
	else sls_sales
end as sls_sales,
case when sls_price is null or sls_price <= 0
		then sls_sales / nullif(sls_quantity, 0)
	else sls_price
end as sls_price
from bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price -- if sales is negative or 0, calculate using quantity and price
or sls_sales is null or sls_quantity is null or sls_price is null -- if price is null or 0, calculate using sales and quantity
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0 -- if price is negative, convert to positive 
order by sls_sales, sls_quantity, sls_price

-- qc
select distinct
sls_sales,
sls_quantity,
sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0
order by sls_sales, sls_quantity, sls_price

select count(*) from silver.crm_sales_details