use Datawarehouse;
Go

create or  alter procedure silver.load_silver as
begin
	
	declare @start as DATETIME, @finish as datetime;
	set @start = getdate();
	print('=========================================');
	print('Loading Silver Layer');
	print('=========================================');

	print('-----------------------------------------');
	print('Loading CRM Tables');
	print('-----------------------------------------');

	truncate table silver.crm_cust_info;
	print('>>Truncated table silver.crm_cust_info');
	print('-----------------------------------------');

	print('>>Inserting data into silver.crm_cust_info');
	insert into silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)


	select cst_id,
	cst_key,
	trim(cst_firstname) as cst_firstname,
	trim(cst_lastname) as cst_lastname,

	case when upper(trim(cst_marital_status)) = 'S' then 'Single'
		when upper(trim(cst_marital_status)) = 'M' then 'Married'
		else 'n/a'
	end as cst_marital_status,

	case when upper(trim(cst_gndr)) = 'F' then 'Female'
		when upper(trim(cst_gndr)) = 'M' then 'Male'
		else 'n/a'
	end as cst_gndr,
	cst_create_date
	from
	(
	select *,
	row_number() over(partition by cst_id order by cst_create_date desc) as rank_bt
	from bronze.crm_cust_info
	)t where rank_bt = 1;
	print('>>Insertion complete');
print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
/* Full load for 2nd table in silver layer*/


	print('-----------------------------------------');
	print('>>Truncating Table');
	print('-----------------------------------------');
	truncate table silver.crm_prd_info;
	print('-----------------------------------------');
	print('>>Inserting Data into silver.crm_prd_info');
	print('-----------------------------------------');
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
	print('-----------------------------------------');
	print('>>Insertion Complete');
print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
-- FUll load in the 3rd table in silver layer

	print('-----------------------------------------');
	print('>>Truncating Table');
	print('-----------------------------------------');
	truncate table silver.crm_sales_details;
	print('>>Inserting data into silver.crm_sales_details');
	print('-----------------------------------------');
	
	insert into silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price)

	select 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		case 
			when sls_order_dt = 0 or sls_order_dt < 0 or len(sls_order_dt) != 8 then NULL
			else cast(cast(sls_order_dt as nvarchar) as date)
		end as sls_order_dt,
		case
			when sls_ship_dt <= 0 or len(sls_ship_dt) != 8 then null
			else cast(cast(sls_ship_dt as nvarchar) as date)
		end as sls_ship_dt,
		case
			when sls_due_dt <= 0 or len(sls_due_dt) != 8 then null
			else cast(cast(sls_due_dt as nvarchar) as date)
		end as sls_due_dt,
		case
			when sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity * abs(sls_price) then abs(sls_price) * sls_quantity
			else sls_sales
		end as sls_sales,
		sls_quantity,
		case
			when sls_price <= 0 or sls_price is null then sls_sales/nullif(sls_quantity, 0)
			else sls_price
		end as sls_price
	from bronze.crm_sales_details;
	print('-----------------------------------------');
	print('>>Insertion complete');
print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');

print('=========================================');
print('Loading ERP Tables');
print('=========================================');
-- Insert data for 4th table in the silver layer

	print('>>Truncating the table');
	print('-----------------------------------------');
	truncate table silver.erp_CUST_AZ12;
	print('>>Inserting data into silver.erp_CUST_AZ12');
	print('-----------------------------------------');

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
	print('>>Insertion complete');
print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
-- Inserting data into the 5th table in silver layer

	print('>>Truncating the table');
	print('-----------------------------------------');
	truncate table silver.erp_LOC_A101;
	print('>>Inserting data into silver.erp_LOC_A101');
	print('-----------------------------------------');

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

	print('>>Insertion Complete');
	print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');

-- inserting data into the 6th table in silver layer

	print('>>Truncating the Table');
	print('-----------------------------------------');
	truncate table silver.erp_PX_CAT_G1V2;
	print('>>Inserting data into silver.erp_PX_CAT_G1V2');
	print('-----------------------------------------');

	insert into silver.erp_PX_CAT_G1V2 (
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	)

	select 
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
	from bronze.erp_PX_CAT_G1V2;

	print('>>Insertion complete');
	print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
	
	print('=========================================');
	print('Ending the Silver Layer');
	print('=========================================');
	set @finish = getdate();
	print('TOTAL SILVER LAYER TIME:' + cast(datediff(second, @start, @finish) as nvarchar) + ' seconds');
END
