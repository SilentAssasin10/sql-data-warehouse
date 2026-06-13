/*==============================================================
This is the script for the gold layer
I have created the view for 3 different tables which are dim_customers, dim_products and fact_sales.
These 3 represent the cleaned and formatted data from the silver layer and connects fact_sales with 
those 2 dimension views. 

The structure uses star schema for better understanding and easy uses.
The script runs the whole query and creates the schema if not already present. If it exists, the ddl
only alters those views and recreates.
================================================================*/

use Datawarehouse;
Go

-- Gold layer dimension table for silver layer customer information tables

create or alter view gold.dim_customers as
select 
	row_number() over(order by cst_id) as customer_key,
	ca.cst_id as customer_id,
	ca.cst_key as customer_number,
	ca.cst_firstname as first_name,
	ca.cst_lastname as last_name,
	la.CNTRY as country,
	ca.cst_marital_status as marital_status,
	case
		when cst_gndr != 'n/a' then cst_gndr
		else coalesce(GEN, 'n/a')
	end as gender,
	co.BDATE as birthdate,
	ca.cst_create_date as create_date
	
from silver.crm_cust_info ca
left join silver.erp_CUST_AZ12 co
on		  ca.cst_key = co.CID
left join silver.erp_LOC_A101 la
on		  ca.cst_key = la.CID;
Go

-- Gold layer dimension table on silver layer tables containing product info 
create or alter view gold.dim_products as
select
	ROW_NUMBER() over(order by prd_start_dt) as product_key,
	pd.prd_id as product_id,
	pd.prd_key as product_number,
	pd.cat_id as category_id,
	pd.sales_prd_key as sales_product_key,
	pd.prd_nm as product_name,
	pa.CAT as product_category,
	pa.SUBCAT as product_subcategory,
	pa.MAINTENANCE as maintenance,
	pd.prd_cost as product_cost,
	pd.prd_line as product_line,
	pd.prd_start_dt as product_start_date	
from silver.crm_prd_info pd
left join silver.erp_PX_CAT_G1V2 pa
on pd.cat_id = pa.ID
where pd.prd_end_dt is null;
Go

-- Gold layer fact table for sales details

create or alter view gold.fact_sales as
select 
	sa.sls_ord_num as order_number,
	pd.product_key as product_key,
	cu.customer_key,
	sa.sls_order_dt as order_date,
	sa.sls_ship_dt as shipping_date,
	sa.sls_due_dt as due_date,
	sa.sls_sales as sales_amount,
	sa.sls_quantity as quantity,
	sa.sls_price as unit_price
from silver.crm_sales_details sa
left join gold.dim_customers cu
on sa.sls_cust_id = cu.customer_id
left join gold.dim_products pd
on sa.sls_prd_key = pd.sales_product_key;
Go
