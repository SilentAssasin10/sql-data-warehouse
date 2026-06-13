use Datawarehouse;
Go
select distinct
	ca.cst_gndr,
	co.GEN,
	case
		when cst_gndr != 'n/a' then cst_gndr
		else coalesce(GEN, 'n/a')
	end as new_cst_gndr
from silver.crm_cust_info ca
left join silver.erp_CUST_AZ12 co
on		  ca.cst_key = co.CID
left join silver.erp_LOC_A101 la
on		  ca.cst_key = la.CID
order by 1,2

select * from silver.erp_PX_CAT_G1V2;