-- check for duplicates in prd_id
-- required results: 0 resutls
select prd_id, count(prd_id) as number
from bronze.crm_prd_info
group by prd_id
having count(prd_id) > 1 or prd_id is null;
-- condition satisfied


-- check for category id
select replace(substring(prd_key, 1, 5),'-','_') as cat_id from bronze.crm_prd_info
where substring(prd_key, 1, 5) not in (
	select id from bronze.erp_PX_CAT_G1V2
)

-- check for sales_prd_key
select substring(prd_key, 7, len(prd_key)) as gotcha from bronze.crm_prd_info
where substring(prd_key, 7, len(prd_key)) not in (
select sls_prd_key from bronze.crm_sales_details);

-- check if prd_nm has spaces
-- expectations: 0 results
select prd_nm from bronze.crm_prd_info
where prd_nm != trim(prd_nm);
-- satisfied

--check for negative values in prd_cost
-- expectations: 0 results
select prd_id from bronze.crm_prd_info
where prd_cost < 0 or prd_cost is null;
-- 2 missing values handled properly

--data standardization and normalization
select distinct prd_line from bronze.crm_prd_info;

-- date checking for null values
 select * from bronze.crm_prd_info
 where prd_start_dt > prd_end_dt;

 select * from silver.crm_prd_info
 where prd_start_dt > prd_end_dt;

 select * from silver.crm_prd_info;

 -- for sales_table
 select sls_ord_num from bronze.crm_sales_details
 where sls_ord_num != trim(sls_ord_num);

 select sls_prd_key from bronze.crm_sales_details
 where sls_prd_key not in (
	select sales_prd_key from silver.crm_prd_info);

select * from bronze.crm_sales_details
where sls_cust_id in (
	select cst_id from silver.crm_cust_info);

select * from bronze.crm_sales_details
where len(sls_due_dt) != 8 or sls_due_dt <= 0;

select * from bronze.crm_sales_details
where sls_sales <= 0;

select * from bronze.crm_sales_details
where sls_price <= 0 or sls_price is null or sls_price != sls_sales / sls_quantity;

select * from bronze.crm_sales_details
where sls_quantity <= 0; -- it is fine

select * from silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;

-- for erp_CUST_AZ12 table
select * from bronze.erp_CUST_AZ12;
select * from bronze.crm_cust_info;

select 
	case when CID like 'NAS%' then substring(CID, 4, len(CID))
		else CID
	end as CID
	from bronze.erp_CUST_AZ12
	where case when CID like 'NAS%' then substring(CID, 4, len(CID))
		else CID
	end not in (select cst_key from silver.crm_cust_info);

select BDATE from bronze.erp_CUST_AZ12
where BDATE < '1920-01-01' or BDATE > GETDATE();

-- data cleaning for erp_loc table
