/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY
		DECLARE @first DATETIME, @last DATETIME;
		SET @first = GETDATE();
		Print '======================================';
		Print 'Loading Bronze Layer';
		Print '======================================';

		Print '--------------------------------------';
		Print 'Loading CRM Tables';
		Print '--------------------------------------';

		DECLARE @start_time DATETIME, @end_time DATETIME;


		Print '>> Truncating Table: bronze.crm_cust_info';
		SET @start_time = GETDATE();

		TRUNCATE TABLE bronze.crm_cust_info;

		Print '>> Inserting Data Into: bronze.crm_cust_info';

		BULK INSERT bronze.crm_cust_info
		FROM 'D:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		Print 'Time required:' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR)  + 'seconds';
		Print '---------------------------';

		Print '>> Truncating Table: bronze.crm_prd_info';
		SET @start_time = GETDATE();

		TRUNCATE TABLE bronze.crm_prd_info;

		Print '>> Inserting Data Into: bronze.crm_prd_info';

		BULK INSERT bronze.crm_prd_info
		FROM 'D:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		Print 'Time required:' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR)  + 'seconds';
		Print '---------------------------';

		Print '>> Truncating Table: bronze.crm_sales_details';
		SET @start_time = GETDATE();

		TRUNCATE TABLE bronze.crm_sales_details;

		Print '>> Inserting Data Into: bronze.crm_sales_details';

		BULK INSERT bronze.crm_sales_details
		FROM 'D:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		Print 'Time required:' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR)  + 'seconds';
		Print '---------------------------';

		Print '--------------------------------------';
		Print 'Loading ERP Tables';
		Print '--------------------------------------';

		Print '>> Truncating Table: bronze.erp_CUST_AZ12';

		TRUNCATE TABLE bronze.erp_CUST_AZ12;
		SET @start_time = GETDATE();

		Print '>> Inserting Data Into: bronze.erp_CUST_AZ12';

		BULK INSERT bronze.erp_CUST_AZ12
		FROM 'D:\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		Print 'Time required:' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR)  + 'seconds';
		Print '---------------------------';

		Print '>> Truncating Table: bronze.erp_PX_CAT_G1V2';

		TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;
		SET @start_time = GETDATE();

		Print '>> Inserting Data Into: bronze.erp_PX_CAT_G1V2';

		BULK INSERT bronze.erp_PX_CAT_G1V2
		FROM 'D:\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		Print 'Time required:' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR)  + 'seconds';
		Print '---------------------------';

		Print '>> Truncating Table: bronze.erp_LOC_A101';
		SET @start_time = GETDATE();

		TRUNCATE TABLE bronze.erp_LOC_A101;

		Print '>> Inserting Data Into: bronze.erp_LOC_A101';

		BULK INSERT bronze.erp_LOC_A101
		FROM 'D:\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		Print 'Time required:' + CAST (DATEDIFF (second, @start_time, @end_time) AS NVARCHAR)  + 'seconds';
		Print '---------------------------';
		SET @last = GETDATE();
		Print '>> BRONZE LAYER LOAD DURATION: ' + CAST (DATEDIFF(second, @first, @last) AS NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		Print '===================================';
		Print 'Error Occured during loading bronze layer';
		Print 'ERROR MESSAGE :' + ERROR_MESSAGE();
		Print 'ERROR MESSAGE:' + CAST (ERROR_MESSAGE() AS NVARCHAR);
		Print 'ERROR MESSAGE:' + CAST (ERROR_STATE() AS NVARCHAR);
		Print '===================================';
	END CATCH
END
Go
