use Datawarehouse;
Go
insert into silver.erp_CUST_AZ12 (
	CID,
	BDATE,
	gen)
select 
	case when CID like 'NAS%' then substring(CID, 4, len(CID))
		else CID
	end as CID,
	case when BDATE > GETDATE() then null
		else BDATE
	end as BDATE,
	case when upper(trim(gen)) in ('F','FEMALE') then 'Female'
		when upper(trim(gen)) in ('M', 'MALE') then 'Male'
		else 'n/a'
	end as gen
	from bronze.erp_CUST_AZ12;
