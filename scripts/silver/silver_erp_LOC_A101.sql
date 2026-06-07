use Datawarehouse;
Go

insert into silver.erp_LOC_A101 (
	CID,
	CNTRY)

select
	replace(CID, '-', '') as CID,
	case when upper(trim(CNTRY)) in ('US', 'USA') then 'United States'
		when trim(CNTRY) = 'DE' then 'Germany'
		when trim(CNTRY) is null or trim(CNTRY) = '' then 'n/a'
		else trim(CNTRY)
	end as CNTRY
	from bronze.erp_LOC_A101;
