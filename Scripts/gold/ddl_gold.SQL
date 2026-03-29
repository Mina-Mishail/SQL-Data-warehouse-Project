/*
======================================================================================
DDL Script : Create Gold Views
======================================================================================
Script Purpose:
    This script creates views for the Gold Layer in the data warehouse.
    The Gold Layer represent the final dimension and fact tables (Start Schema)

    Each view perform transformations and combines data from the silver layer
    to produce a clean, enriched, and business-ready datataset.

Usage:
    - These views can be queried difrectly for analytics and reporting.
======================================================================================
*/

-- ########################################################################
 -- Dimension Table : Customers
-- ########################################################################
create or alter view [gold].[dim_customers] as 
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
GO

-- ########################################################################
 -- Dimension Table : Products
 create or alter view [gold].[dim_products] as 
	select 
		ROW_NUMBER() over(order by pn.prd_start_dt, pn.prd_key) product_key,
		pn.prd_id product_id,
		pn.prd_key product_number,
		pn.prd_nm product_name,
		pn.cat_id category_id,
		pc.cat category,
		pc.subcat subcategory,
		pc.maintenance ,
		pn.prd_cost cost,
		pn.prd_line product_line,
		pn.prd_start_dt start_date
	from silver.crm_prd_info pn
		LEFT JOIN silver.erp_px_cat_g1v2 pc
		ON pn.cat_id = pc.id
	where pn.prd_end_dt is null -- Filter-out all historical data
GO

-- ########################################################################
 -- Fact Table : Sales Transactions
create or alter view gold.fact_sales as 
select 
	sd.sls_ord_num order_number,
	pr.product_key ,
	cu.customer_key ,
	sd.sls_order_dt order_date,	
	sd.sls_ship_dt shipping_date,
	sd.sls_due_dt due_date,
	sd.sls_sales sales_amount,
	sd.sls_quantity quantity,
	sd.sls_price price
from silver.crm_sales_details sd
	LEFT JOIN gold.dim_products pr
		ON sd.sls_prd_key = pr.[product_number]
	LEFT JOIN gold.dim_customers cu
		ON sd.sls_cust_id = cu.customer_id ;
GO
