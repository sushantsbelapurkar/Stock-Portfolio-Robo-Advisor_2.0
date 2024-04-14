-- --------------------------------- ebitda CAGR -----------------------------
DROP PROCEDURE IF EXISTS mysql_portfolio.cagr_info;

CREATE PROCEDURE mysql_portfolio.cagr_info(
IN exchangeName varchar(255)
) 
BEGIN
-- DROP TABLE IF EXISTS mysql_portfolio.ebitda_info;
-- create table mysql_portfolio.ebitda_info as
INSERT INTO mysql_portfolio.ebitda_info
 WITH ebitda_growth as
 (
 SELECT inc.symbol,inc.calendarYear, inc.ebitda,
 -- CASE WHEN ebitda > 0 THEN ebitda ELSE 0.1 END AS ebitda, 
 lag(inc.ebitda) over (partition by inc.symbol order by inc.calendarYear) as prev_ebitda, 
CASE WHEN inc.ebitda > lag(inc.ebitda) over (partition by inc.symbol order by inc.calendarYear) THEN 'Y' ELSE 'N' END AS ebitda_growth,
round(avg(inc.ebitda) over(partition by inc.symbol order by inc.calendarYear rows between unbounded preceding and unbounded following),2) as avg_ebitda,
row_number() over (partition by inc.symbol order by inc.calendarYear) as row_numb, 
curdate() as created_at 
  FROM


  -- ###################### Placeholder for sensitive code #############################



),
composite_key AS
 (


	-- ###################### Placeholder for sensitive code #############################

),
 required_data AS 
 (


  -- ###################### Placeholder for sensitive code #############################


 )
 SELECT -- Placeholder for sensitive code
 FROM ebitda_details
 LEFT JOIN
 max_row ON ebitda_details.symbol = max_row.symbol
 LEFT JOIN number_of_years yrs 
 ON yrs.symbol = ebitda_details.symbol
 WHERE ebitda_details.row_numb = max_row.max_row_numb order by 1,2
 ;

 select count(*) from mysql_portfolio.ebitda_info;


 -- --------------------------------- netincome CAGR ----------------------------------------
-- DROP TABLE IF EXISTS mysql_portfolio.netincome_info;
-- create table mysql_portfolio.netincome_info as
INSERT INTO mysql_portfolio.netincome_info
 WITH netincome_growth as
 (


  -- ###################### Placeholder for sensitive code #############################



 -- --------------------------------- sales/revenue CAGR ----------------------------------------
-- DROP TABLE IF EXISTS mysql_portfolio.sales_info;
-- create table mysql_portfolio.sales_info as
INSERT INTO mysql_portfolio.sales_info
 WITH sales_growth as
 (


 -- ###################### Placeholder for sensitive code #############################



 -- --------------------------------- free cash flow CAGR ----------------------------------------
-- DROP TABLE IF EXISTS mysql_portfolio.free_cash_flow_info;
-- create table mysql_portfolio.free_cash_flow_info as
INSERT INTO mysql_portfolio.free_cash_flow_info
 WITH free_cashflow_growth as
 (


 -- ###################### Placeholder for sensitive code #############################


 SELECT composite_key.*
