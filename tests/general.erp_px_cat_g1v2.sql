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
from [bronze].[erp_px_cat_g1v2]


-- notes
select * from [silver].[crm_prd_info];

-- check for spaces
select * from [bronze].[erp_px_cat_g1v2]
where cat != trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance)

-- data standardisation and consistency
select distinct
cat
from [bronze].[erp_px_cat_g1v2]

select distinct
subcat
from [bronze].[erp_px_cat_g1v2]

select distinct
maintenance
from [bronze].[erp_px_cat_g1v2]

-- qc 
select count(*) from [silver].[erp_px_cat_g1v2]