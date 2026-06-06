use Datawarehouse;
Go

insert into silver.crm_prd_info (
	prd_id,
	prd_key,
	cat_id,
	sales_prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt)

select prd_id,
prd_key,
replace(substring(prd_key, 1, 5), '-', '_') as cat_id,
substring(prd_key, 7, len(prd_key)) as sales_prd_key,
trim(prd_nm) as prd_nm,
isnull(prd_cost, 0) as prd_cost,
case when upper(trim(prd_line)) = 'R' then 'Road'
	when upper(trim(prd_line)) = 'T' then 'Touring'
	when upper(trim(prd_line)) = 'M' then 'Mountain'
	when upper(trim(prd_line)) = 'S' then 'Other Sales'
	else 'n/a'
end as prd_line,
prd_start_dt,
dateadd(day, -1, lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)) as prd_end_dt
from bronze.crm_prd_info;
