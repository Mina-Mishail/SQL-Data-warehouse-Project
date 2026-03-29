/*
  Create view to select main Data of Customer in one place, integrate data
*/

create view gold.dim_customers as 
select 
	ROW_NUMBER() over (order by ci.cst_id ) as customer_key,
	ci.cst_id customer_id ,
	ci.cst_key cusotomer_number,
	ci.cst_firstname first_name,
	ci.cst_lastname last_name,	
	cl.cntry country,
	ci.cst_material_status marital_status,
	case
		when ci.cst_gndr != 'n/a' then ci.cst_gndr -- CRM is the master of Gender info
		Else isnull(ca.gen,'n/a')
	end as gender,
	ca.bdate birth_date,
	ci.cst_create_date create_date

from silver.crm_cust_info ci
	left join silver.erp_cust_az12 ca 
		ON ci.cst_key = ca.cid
	left join silver.erp_loc_a101 cl
		ON ci.cst_key = cl.cid ;

