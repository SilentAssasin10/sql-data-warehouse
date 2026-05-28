/*
=====================================================
CREATE DATABASE AND SCHEMA
=====================================================

Purpose: Writing this script to create a database named DataWarehouse and if it exists, then drop the whole
database and create a new one, and also create three tables or schemas named bronze, silver and gold.

WARNING: If this script is run, the whole database gets deleted and it creates a fresh database.
So all the data will be lost if there is no backup and rollback is possible there.
*/


USE master;
Go

-- Drop and create new database if the database already exists

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
	END;

Go

/* Create the schemas into the database */

CREATE DATABASE Datawarehouse;
Go

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
Go
CREATE SCHEMA gold;
Go

