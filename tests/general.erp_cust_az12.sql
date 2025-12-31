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
from [bronze].[erp_cust_az12]



-- notes
select cst_key from [silver].[crm_cust_info]

select distinct
bdate
from [bronze].[erp_cust_az12]
where bdate < '1925-01-01' or bdate > getdate()

select distinct gen
from [bronze].[erp_cust_az12]

-- qc
select distinct
bdate
from silver.[erp_cust_az12]
where bdate < '1925-01-01' or bdate > getdate()

select distinct gen
from silver.[erp_cust_az12]

select count(*) from silver.[erp_cust_az12]