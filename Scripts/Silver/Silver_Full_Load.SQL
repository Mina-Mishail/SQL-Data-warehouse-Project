/* 

=========================================================================================================
Stored procedure : Load and Clean Silver Layer (bronze -> Silver) 
=========================================================================================================
Script purpose:
	This stored procedure loads data into the 'silver' schema from external CSV files.
  It Performs the following actions:
  - Truncate the silver tables before loading data.
  - uses the 'BULK INSERT' command to load data from bronze table  to silver tables.

  parameters:
    None.
    This stored procedure doesn't accept any parameters or return any values.

    Usage Example:
      Exec bronze.load_bronze;
=========================================================================================================
*/


create or alter proc silver.load_silver as 
	Begin
			Declare @start_time datetime, @end_time datetime, @batch_start_Time datetime, @batch_end_time datetime;
		 Begin Try
				-- 1. Clean and Insert into 'silver.crm_cust_info'
				set @batch_start_Time = GETDATE()
				set @start_time = GETDATE();

				Print '>> Truncate Table: silver.crm_cust_info';
				Truncate Table silver.crm_cust_info;
				Print '>> Inserting DAta into : silver.crm_cust_info';

				with CTE as (
					select 
						* ,
						ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as 'flag_last'
					from bronze.[crm_cust_info] c 
						where c.cst_id IS NOT NULL) 

				insert into silver.crm_cust_info  (
					cst_id,
					cst_key,
					cst_firstname,
					cst_lastname,
					cst_gndr,
					cst_material_status
				)
				select 
					ct.cst_id,
					ct.cst_key,
					trim(ct.cst_firstname) as cst_firstname ,
					trim(ct.cst_lastname) as cst_lastname,
					case
						when UPPER(TRIM(ct.cst_gndr)) = 'F' then 'Female'
						when UPPER(trim(ct.cst_gndr)) =  'M' then 'Male'
						else 'n/a' 
					End cst_gndr,
					case 
						when UPPER(TRIM(ct.cst_material_status)) = 'S' then 'Single'
						when UPPER(TRIM(ct.cst_material_status)) = 'M' then 'Married'
						else 'n/a' 
					End 'cst_material_status'
				from CTE ct
				where   ct.flag_last = 1
				
				set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';

				-- ########################################################################

				-- 2.Clean and Insert into 'silver.crm_prd_info'
				set @start_time = GETDATE();

				Print '>> Truncate Table: silver.crm_prd_info';
				Truncate Table silver.crm_prd_info;
				Print '>> Inserting DAta into : silver.crm_prd_info';

				insert INTO SILVER.crm_prd_info (
					prd_id,		
					cat_id,		
					prd_key,		
					prd_nm,		
					prd_cost,	
					prd_line,	
					prd_start_dt,
					prd_end_dt
				)
				select 
					i.prd_id,
					REPLACE(SUBSTRING(i.prd_key, 1,5),'-','_') cat_id,
					SUBSTRING(i.prd_key,7,len(i.prd_key)) prd_key,
					i.prd_nm,
					ISNULL(i.prd_cost ,0) prd_cost,
					case UPPER(trim(i.prd_line)) 
						when 'M' then 'Mountain'
						when 'R' then 'Road'
						when 'S' then 'Other Sales'
						when 'T' then 'Tourism'
						else 'n/a'
					end prd_line,
					cast(i.prd_start_dt as date) prd_start_dt,
					cast(lead(i.prd_start_dt) over (partition by i.prd_key order by i.prd_start_dt ) -1 as date) prd_end_dt
				from [bronze].[crm_prd_info] i;

				set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';

				-- ########################################################################

				-- 3. Clean and Insert into 'silver.crm_sales_details'
				set @start_time = GETDATE();

				Print '>> Truncate Table: silver.crm_sales_details';
				Truncate Table silver.crm_sales_details;
				Print '>> Inserting DAta into : silver.crm_sales_details';

				Insert into silver.crm_sales_details (
					sls_ord_num ,
					sls_prd_key ,
					sls_cust_id, 
					sls_order_dt, 
					sls_ship_dt, 
					sls_due_dt, 
					sls_sales, 
					sls_quantity, 
					sls_price 
				)
				select 
					sd.sls_ord_num,
					sd.sls_prd_key,
					sd.sls_cust_id,
					case 
						when sd.sls_order_dt = 0 or Len(sd.sls_order_dt) != 8 then NULL
						else cast(cast(sd.sls_order_dt as varchar) as date) 
					end sls_order_dt,
					case
						when sd.sls_ship_dt = 0 or Len(sd.sls_ship_dt) != 8 then NULL
						else cast(cast(sd.sls_ship_dt as varchar) as date) 
					end sls_ship_dt,
					case 
						when sd.sls_due_dt = 0 or Len(sd.sls_due_dt) != 8 then NULL
						else cast(cast(sd.sls_due_dt as varchar) as date) 
					end sls_due_dt,
					case 
						when ISNULL(sd.sls_sales ,0)<= 0 or sd.sls_sales != ABS(sd.sls_price) * sd.sls_quantity 
						then ABS(sd.sls_price) * sd.sls_quantity
						else sd.sls_sales
					End sls_sales,
					sd.sls_quantity,
					case
						when ISNULL(sd.sls_price,0) <= 0
							Then sd.sls_sales / NULLIF(sd.sls_Quantity,0)
						Else sd.sls_price
					End sls_price
				from [bronze].[crm_sales_details] sd;

				set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';

				-- ########################################################################

				-- 4. Clean and Insert into [silver].[erp_cust_az12]
				set @start_time = GETDATE();

				Print '>> Truncate Table: silver.erp_cust_az12';
				Truncate Table silver.erp_cust_az12;
				Print '>> Inserting DAta into : silver.erp_cust_az12';

				Insert into Silver.erp_cust_az12(
					cid,
					bdate,
					gen
				)
				select 
					CASE
						When b.cid like 'NAS%' then substring(b.cid,4, len(b.cid))
						Else b.cid
					END cid,
					Case
						When b.bdate > GETDATE() then NULL
						Else b.bdate
					End bdate,
					Case 
						When UPPER(TRIM(b.gen)) in ('F', 'FEMALE') then 'Female'
						when UPPER(TRIM(b.gen)) in('M','Male') then 'Male'
						Else 'n/a' 
					End  bdate
				from [bronze].[erp_cust_az12] b;

				set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';

				-- ########################################################################

				-- 5. Clean and Insert into [silver].[erp_loc_a101]
				set @start_time = GETDATE();

				Print '>> Truncate Table: silver.erp_loc_a101';
				Truncate Table silver.erp_loc_a101;
				Print '>> Inserting DAta into : silver.erp_loc_a101';

				INsert into silver.erp_loc_a101(
					cid,
					cntry
				)
				select 
					REPLACE(cid,'-','') cid,
					case when TRIM(cntry) = 'DE' then 'Germany'
						WHen TRIM(cntry) in ('US','USA') then 'United States'
						when TRIM(cntry) ='' OR cntry IS NULL then 'n/a'
						else TRIM(cntry) 
					End cntry
				from [bronze].[erp_loc_a101];

				set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';

				-- ########################################################################

				-- 6. Clean and Insert into [silver].[erp_px_cat_g1v2]
				set @start_time = GETDATE();

				Print '>> Truncate Table: silver.[erp_px_cat_g1v2]';
				Truncate Table silver.erp_px_cat_g1v2;
				Print '>> Inserting DAta into : silver.[erp_px_cat_g1v2]';

				INsert into [silver].[erp_px_cat_g1v2](
					id,
					cat,
					subcat,
					maintenance
				)
				select 
					id,
					cat,
					subcat,
					maintenance
				from [bronze].[erp_px_cat_g1v2];

					set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';
				print ' >> ------------------------------------';

				print ' >> -------------- Total Project Loading Data Time ----------------------';

				set @batch_end_time = GETDATE()
				print ' >> Total load duration: ' + cast(datediff(MILLISECOND, @batch_start_Time, @batch_end_Time) as nvarchar) + ' MILLISECONDs';

		 End Try
		 Begin Catch
			Print 'Error occured during Bronze Layer';
			Print 'Error Message' + Error_message();
			print 'Error NUmber' + Cast(Error_number() as nvarchar);
			print 'Error Message' + Cast(Error_State() as nvarchar);
		 End Catch
End
	
