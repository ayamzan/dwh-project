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
from bronze.crm_prd_info


-- notes
select
prd_id,
prd_key,
replace(SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
from bronze.crm_prd_info
where replace(SUBSTRING(prd_key, 1, 5), '-', '_') not in
(select distinct id from bronze.erp_px_cat_g1v2) -- filters out unmatched data post transformation

select
prd_id,
prd_key,
substring(prd_key, 7, LEN(prd_key)) as prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
from bronze.crm_prd_info
where substring(prd_key, 7, LEN(prd_key)) in (
select sls_prd_key from bronze.crm_sales_details)

-- check for unwanted spaces
select prd_nm 
from bronze.crm_prd_info
where prd_nm != trim(prd_nm)

-- check for nulls or negative numbers
select prd_cost 
from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null

-- data standardisation and consistency
select distinct prd_line
from bronze.crm_prd_info

-- check for invalid date orers
select * 
from bronze.crm_prd_info
where prd_end_dt < prd_start_dt

-- notes

select
prd_id,
COUNT(*)
from bronze.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null

select distinct id from bronze.erp_px_cat_g1v2 -- match with first 5 char of cat_id from crm_prd_info

select sls_prd_key from bronze.crm_sales_details

-- qc
select prd_nm 
from silver.crm_prd_info
where prd_nm != trim(prd_nm)

-- check for nulls or negative numbers
select prd_cost 
from silver.crm_prd_info
where prd_cost < 0 or prd_cost is null

-- data standardisation and consistency
select distinct prd_line
from silver.crm_prd_info

-- check for invalid date orers
select * 
from silver.crm_prd_info
where prd_end_dt < prd_start_dt

select count(*) from silver.crm_prd_info