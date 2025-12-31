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
from [bronze].[erp_loc_a101]


-- notes
select cst_key from [silver].[crm_cust_info];

-- data standardisation and consistency
select distinct cntry as old_cntry,
case when trim(cntry) = 'DE' then 'Germany'
	 when trim(cntry) in ('US', 'USA') then 'United States'
	 when trim(cntry) = '' or cntry is null then 'n/a'
	 else trim(cntry)
end as cntry
from [bronze].[erp_loc_a101]
order by cntry

select distinct cntry
from [silver].[erp_loc_a101]
order by cntry

select * from [silver].[erp_loc_a101]