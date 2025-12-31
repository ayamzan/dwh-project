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
)t where flag_last = 1 -- select the most recent record per customer


-- check for nulls or duplicates in pk
select 
cst_id,
count(*)
from bronze.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null

select
*
from (
	select 
	* ,
	ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
	from bronze.crm_cust_info
	where cst_id is not null
)t where flag_last != 1

-- check for unwanted spaces
select cst_firstname from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname)

select cst_lastname from bronze.crm_cust_info
where cst_lastname != trim(cst_lastname)

-- removing empty spaces from cst_firstname and cst_lastname
-- data standardisation and consistency
select distinct cst_gndr
from bronze.crm_cust_info


-- silver qc
select 
cst_id,
count(*)
from silver.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null

select cst_firstname from silver.crm_cust_info
where cst_firstname != trim(cst_firstname)

select cst_lastname from silver.crm_cust_info
where cst_lastname != trim(cst_lastname)

select distinct cst_gndr
from silver.crm_cust_info

select distinct cst_marital_status
from silver.crm_cust_info

select count(*) from silver.crm_cust_info