/* 
===========================
create Database and Schemas
===========================
Script Purpose:
  This script create a new database named 'DataWarehouse' after checking if it already exists.
  If the database exists, it is dropped and recreated.
Additionally, the scrip sets up three schemas within the database: 'bronze', 'silver', and 'gold'.

WRITING:
  Running this script will drop te entire 'DataWarehouse' database if it exists.
  All data in the database will be permanently deleted.
Proceed with caution and ensure you have proper backups before running this script.
*/

USE master;

-- Create Database 'Datawarehouse'
if exists (select 1 from sys.databases where name='DataWarehouse')
	Begin
		Alter Database DataWarehouse SET SINGLE_USER With RollBack Immediate;
		DROP Database DataWarehouse;
	End;
Go

-- Create Database
create database DataWareHouse;

use DataWarehouse;

--Create Schemas
create schema bronze;
Go

create schema silver;
Go

create schema gold;
Go

