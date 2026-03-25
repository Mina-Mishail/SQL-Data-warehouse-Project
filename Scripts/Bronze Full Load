create or alter proc bronze.load_bronze
as
	Begin
		Declare @start_time datetime, @end_time datetime, @batch_start_Time datetime, @batch_end_time datetime;

		Begin TRY
			print '====================================================================';
			print'Loading Bronze Layer';
			print '====================================================================';

			print '--------------------------------------------------------------';
			print 'Loading CRM Tables';
			print '--------------------------------------------------------------';

			set @batch_start_Time = GETDATE();
			set @start_time = GETDATE();
			print' >> Truncate Bronze Layer - crm_cust_info Table';

				truncate table [bronze].[crm_cust_info];

					
			print '---------------------------------';
			print'Insert Bronze Layer - crm_cust_info Table';

				bulk insert [bronze].[crm_cust_info]
				from 'H:\Move\Test\Data with Baraa\SQL full Course - Materials\2. SQL Data warehouse Project\datasets\source_crm\cust_info.csv'
				with (
				firstrow = 2,
				fieldTerminator =',',
				Tablock
				);
				set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';
				print ' >> ------------------------------------';

			set @start_time = GETDATE();
			print '---------------------------------';
			print' >> Truncate Bronze Layer - [crm_prd_info] Table';

				truncate table [bronze].[crm_prd_info];

			print '---------------------------------';
			print'Insert Bronze Layer - [crm_prd_info] Table';

				bulk insert [bronze].[crm_prd_info]
				from 'H:\Move\Test\Data with Baraa\SQL full Course - Materials\2. SQL Data warehouse Project\datasets\source_crm\prd_info.csv'
				with (
				firstrow = 2,
				fieldTerminator =',',
				Tablock
				);
				set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';
				print ' >> ------------------------------------';

			
			set @start_time = GETDATE();
			print '---------------------------------';
			print' >> Truncate Bronze Layer - [crm_sales_details] Table';
		
				truncate table [bronze].[crm_sales_details] ;

			print '---------------------------------';
			print'Insert Bronze Layer - [crm_sales_details] Table';

				bulk insert [bronze].[crm_sales_details] 
				from 'H:\Move\Test\Data with Baraa\SQL full Course - Materials\2. SQL Data warehouse Project\datasets\source_crm\sales_details.csv'
				with (
				firstrow = 2,
				fieldTerminator =',',
				Tablock
				);
				set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';
				print ' >> ------------------------------------';


			print '--------------------------------------------------------------';
			print 'Loading ERP Tables';
			print '--------------------------------------------------------------';

			set @start_time= GETDATE();
			print '---------------------------------';
			print' >> Truncate Bronze Layer - [erp_cust_az12] Table';
	
				truncate table [bronze].[erp_cust_az12] ;

			print '---------------------------------';
			print'Insert Bronze Layer - [erp_cust_az12] Table';
		
				bulk insert [bronze].[erp_cust_az12]
				from 'H:\Move\Test\Data with Baraa\SQL full Course - Materials\2. SQL Data warehouse Project\datasets\source_erp\CUST_AZ12.csv'
				with (
				firstrow = 2,
				fieldTerminator =',',
				Tablock
				);
				set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';
				print ' >> ------------------------------------';

			
			set @start_time = GETDATE();
			print '---------------------------------';
			print' >> Truncate Bronze Layer - [erp_loc_a101]Table';
	
				truncate table [bronze].[erp_loc_a101] ;

			print '---------------------------------';
			print'Insert Bronze Layer - [erp_loc_a101] Table';

				bulk insert [bronze].[erp_loc_a101]
				from 'H:\Move\Test\Data with Baraa\SQL full Course - Materials\2. SQL Data warehouse Project\datasets\source_erp\LOC_A101.csv'
				with (
				firstrow = 2,
				fieldTerminator =',',
				Tablock
				);
				set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';
				print ' >> ------------------------------------';


			set @start_time = GETDATE();
			print '---------------------------------';
			print' >> Truncate Bronze Layer - [erp_px_cat_g1v2] Table';
	
				truncate table [bronze].[erp_px_cat_g1v2] ;

			print '---------------------------------';
			print'Insert Bronze Layer - [erp_px_cat_g1v2] Table';

				bulk insert  [bronze].[erp_px_cat_g1v2]
				from 'H:\Move\Test\Data with Baraa\SQL full Course - Materials\2. SQL Data warehouse Project\datasets\source_erp\PX_CAT_G1V2.csv'
				with (
				firstrow = 2,
				fieldTerminator =',',
				Tablock
				);
				set @end_time = GETDATE();
				print ' >> Load duration: ' + cast(datediff(MILLISECOND, @start_time, @end_time) as nvarchar) + ' MILLISECONDs';
				print ' >> ------------------------------------';

				print ' >> -------------- Total Project Loading Data Time ----------------------';

				set @batch_end_Time = GETDATE();
				print ' >> Total load duration: ' + cast(datediff(MILLISECOND, @batch_start_Time, @batch_end_Time) as nvarchar) + ' MILLISECONDs';

		End Try
		Begin Catch
			Print 'Error occured during Bronze Layer';
			Print 'Error Message' + Error_message();
			print 'Error NUmber' + Cast(Error_number() as nvarchar);
			print 'Error Message' + Cast(Error_State() as nvarchar);
		End Catch
	End
