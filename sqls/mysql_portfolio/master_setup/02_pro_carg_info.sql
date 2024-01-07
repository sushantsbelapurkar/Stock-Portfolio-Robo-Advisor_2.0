-- --------------------------------- ebitda CAGR -----------------------------
DROP PROCEDURE IF EXISTS mysql_portfolio.cagr_info;

CREATE PROCEDURE mysql_portfolio.cagr_info(
IN exchangeName varchar(255)
) 
BEGIN
 DROP TABLE IF EXISTS mysql_portfolio.ebitda_info;
 create table mysql_portfolio.ebitda_info as
 WITH ebitda_growth as
 (
 SELECT inc.symbol,inc.calendarYear, inc.ebitda,
 -- CASE WHEN ebitda > 0 THEN ebitda ELSE 0.1 END AS ebitda, 
 lag(inc.ebitda) over (partition by inc.symbol order by inc.calendarYear) as prev_ebitda, 
CASE WHEN inc.ebitda > lag(inc.ebitda) over (partition by inc.symbol order by inc.calendarYear) THEN 'Y' ELSE 'N' END AS ebitda_growth,
round(avg(inc.ebitda) over(partition by inc.symbol order by inc.calendarYear rows between unbounded preceding and unbounded following),2) as avg_ebitda,
row_number() over (partition by inc.symbol order by inc.calendarYear) as row_numb, 
curdate() as created_at 
  FROM mysql_portfolio.income_statement inc
  INNER JOIN mysql_portfolio.symbol_list
  on symbol_list.symbol = inc.symbol
  and symbol_list.exchangeShortName = exchangeName
 WHERE inc.calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 4 YEAR)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
order by 1,2 desc
),
composite_key AS
 (
	SELECT *,CONCAT(ebitda_growth.symbol,ebitda_growth.row_numb) as comp_key FROM ebitda_growth

),
 row_selection AS 
 ( 
   SELECT CONCAT(symbol,row_num) as comp_key FROM 
   (
   SELECT symbol,MAX(row_numb) as row_num FROM ebitda_growth GROUP BY 1
   UNION ALL 
   SELECT symbol,MIN(row_numb) as row_num FROM ebitda_growth GROUP BY 1
   )a
 ),
 required_data AS 
 (
  SELECT composite_key.* 
  FROM row_selection 
  LEFT JOIN composite_key 
  ON row_selection.comp_key = composite_key.comp_key
  ),
 number_of_years AS 
 (
  SELECT symbol, COUNT(calendarYear) AS yrs_num FROM ebitda_growth GROUP BY 1
  ),
 ebitda_details as
 ( 
 SELECT ebitdag.*,
 CASE 
 WHEN 
 FIRST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear) > 0 
 AND LAST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear) > 0 
 THEN 
 ((power((LAST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear))
 /(FIRST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear)),(1/yrs.yrs_num)))-1)*100 
 WHEN 
 FIRST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear) < 0 
 AND LAST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear) < 0 
 THEN 
 ((power((ABS(LAST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear)))
 /(ABS(FIRST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear))),(1/yrs.yrs_num)))-1)*100 *-1
 WHEN 
 FIRST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear) < 0 
 AND LAST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear) > 0 
THEN 
(POW(((LAST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear) 
+ 2* ABS(FIRST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear)))
/ABS(FIRST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear))),(1/yrs.yrs_num))-1)*100
WHEN 
FIRST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear) > 0 
 AND LAST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear) < 0 
THEN 
(POW(((ABS(LAST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear))
+ 2*FIRST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear))
/ FIRST_VALUE(ebitdag.ebitda) over(partition by ebitdag.symbol order by ebitdag.calendarYear)),(1/yrs.yrs_num))-1)*100*-1

 END as carg
 FROM required_data ebitdag
 LEFT JOIN number_of_years yrs 
 ON yrs.symbol = ebitdag.symbol 
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM ebitda_details GROUP BY 1
 )
 SELECT ebitda_details.symbol, ebitda_details.calendarYear, ebitda_details.ebitda as recent_ebitda,
 ebitda_details.ebitda_growth as recent_ebitda_growth, ebitda_details.avg_ebitda, yrs.yrs_num as number_of_yrs,
 round(ebitda_details.carg,2) as ebitda_cagr, CURDATE() as created_at
 FROM ebitda_details
 LEFT JOIN
 max_row ON ebitda_details.symbol = max_row.symbol
 LEFT JOIN number_of_years yrs 
 ON yrs.symbol = ebitda_details.symbol
 WHERE ebitda_details.row_numb = max_row.max_row_numb order by 1,2
 ;

 select count(*) from mysql_portfolio.ebitda_info;


 -- --------------------------------- netincome CAGR ----------------------------------------
 DROP TABLE IF EXISTS mysql_portfolio.netincome_info;
 create table mysql_portfolio.netincome_info as
 WITH netincome_growth as
 (
 SELECT cf.symbol,cf.calendarYear, cf.netincome,
 lag(cf.netincome) over (partition by cf.symbol order by cf.calendarYear) as prev_netincome,
CASE WHEN cf.netincome > lag(cf.netincome) over (partition by cf.symbol order by cf.calendarYear) THEN 'Y' ELSE 'N' END AS netincome_growth,
round(avg(cf.freeCashFlow) over(partition by cf.symbol order by cf.calendarYear rows between unbounded preceding and unbounded following),2) as avg_netincome,
row_number() over (partition by cf.symbol order by cf.calendarYear) as row_numb,
curdate() as created_at
  FROM mysql_portfolio.cash_flow_statement cf
  INNER JOIN mysql_portfolio.symbol_list
  on symbol_list.symbol = cf.symbol
  and symbol_list.exchangeShortName = exchangeName

 WHERE cf.calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 4 YEAR)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 -- order by 1,2 desc

 ),
 composite_key AS
 (
	SELECT *,CONCAT(netincome_growth.symbol,netincome_growth.row_numb) as comp_key FROM netincome_growth

),
 row_selection AS
 (
   SELECT CONCAT(symbol,row_num) as comp_key FROM
   (
   SELECT symbol,MAX(row_numb) as row_num FROM netincome_growth GROUP BY 1
   UNION ALL
   SELECT symbol,MIN(row_numb) as row_num FROM netincome_growth GROUP BY 1
   )a
 ),
 required_data AS
 (
  SELECT composite_key.*
  FROM row_selection
  LEFT JOIN composite_key
  ON row_selection.comp_key = composite_key.comp_key
  ),
 number_of_years AS
 (
  SELECT symbol, COUNT(calendarYear) AS yrs_num FROM netincome_growth GROUP BY 1
  ),
 netincome_details as
 (
 SELECT nig.*,
 CASE
 WHEN
 FIRST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear) > 0
 AND LAST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear) > 0
 THEN
 ((power((LAST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear))
 /(FIRST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear)),(1/yrs.yrs_num)))-1)*100
 WHEN
 FIRST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear) < 0
 AND LAST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear) < 0
 THEN
 ((power((ABS(LAST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear)))
 /(ABS(FIRST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear))),(1/yrs.yrs_num)))-1)*100 *-1
 WHEN
 FIRST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear) < 0
 AND LAST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear) > 0
THEN
(POW(((LAST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear)
+ 2* ABS(FIRST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear)))
/ABS(FIRST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear))),(1/yrs.yrs_num))-1)*100
WHEN
FIRST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear) > 0
 AND LAST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear) < 0
THEN
(POW(((ABS(LAST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear))
+ 2*FIRST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear))
/ FIRST_VALUE(nig.netincome) over(partition by nig.symbol order by nig.calendarYear)),(1/yrs.yrs_num))-1)*100*-1

 END as carg
 FROM required_data nig
 LEFT JOIN number_of_years yrs
 ON yrs.symbol = nig.symbol
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM netincome_details GROUP BY 1
 )
 SELECT netincome_details.symbol, netincome_details.calendarYear, netincome_details.netincome as recent_netincome,
 netincome_details.netincome_growth as recent_netincome_growth, netincome_details.avg_netincome, yrs.yrs_num as number_of_yrs,
 round(netincome_details.carg,2) as netincome_cagr, CURDATE() as created_at
 FROM netincome_details
 LEFT JOIN
 max_row ON netincome_details.symbol = max_row.symbol
 LEFT JOIN number_of_years yrs
 ON yrs.symbol = netincome_details.symbol
 WHERE netincome_details.row_numb = max_row.max_row_numb
 -- order by 1,2
 ;

 SELECT count(*) FROM mysql_portfolio.netincome_info;


 -- --------------------------------- sales/revenue CAGR ----------------------------------------
 DROP TABLE IF EXISTS mysql_portfolio.sales_info;
 create table mysql_portfolio.sales_info as
 WITH sales_growth as
 (
 SELECT inc.symbol,inc.calendarYear,inc.revenue,
 -- CASE WHEN revenue > 0 THEN revenue ELSE 0.1 END AS revenue,
 lag(inc.revenue) over (partition by inc.symbol order by inc.calendarYear) as prev_revenue,
CASE WHEN inc.revenue > lag(inc.revenue) over (partition by inc.symbol order by inc.calendarYear) THEN 'Y' ELSE 'N' END AS revenue_growth,
round(avg(inc.revenue) over(partition by inc.symbol order by inc.calendarYear rows between unbounded preceding and unbounded following),2) as avg_revenue,
row_number() over (partition by inc.symbol order by inc.calendarYear) as row_numb,
curdate() as created_at
  FROM mysql_portfolio.income_statement inc
  INNER JOIN mysql_portfolio.symbol_list
  on symbol_list.symbol = inc.symbol
 and symbol_list.exchangeShortName = exchangeName
 WHERE inc.calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 4 YEAR))
 ),
 composite_key AS
 (
	SELECT *,CONCAT(sales_growth.symbol,sales_growth.row_numb) as comp_key FROM sales_growth

),
 row_selection AS
 (
   SELECT CONCAT(symbol,row_num) as comp_key FROM
   (
   SELECT symbol,MAX(row_numb) as row_num FROM sales_growth GROUP BY 1
   UNION ALL
   SELECT symbol,MIN(row_numb) as row_num FROM sales_growth GROUP BY 1
   )a
 ),
 required_data AS
 (
  SELECT composite_key.*
  FROM row_selection
  LEFT JOIN composite_key
  ON row_selection.comp_key = composite_key.comp_key
  ),
 number_of_years AS
 (
  SELECT symbol, COUNT(calendarYear) AS yrs_num FROM sales_growth GROUP BY 1
  ),
 sales_details as
 (
 SELECT sg.*,
 CASE
 WHEN
 FIRST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear) > 0
 AND LAST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear) > 0
 THEN
 ((power((LAST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear))
 /(FIRST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear)),(1/yrs.yrs_num)))-1)*100
 WHEN
 FIRST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear) < 0
 AND LAST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear) < 0
 THEN
 ((power((ABS(LAST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear)))
 /(ABS(FIRST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear))),(1/yrs.yrs_num)))-1)*100 *-1
 WHEN
 FIRST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear) < 0
 AND LAST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear) > 0
THEN
(POW(((LAST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear)
+ 2* ABS(FIRST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear)))
/ABS(FIRST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear))),(1/yrs.yrs_num))-1)*100
WHEN
FIRST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear) > 0
 AND LAST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear) < 0
THEN
(POW(((ABS(LAST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear))
+ 2*FIRST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear))
/ FIRST_VALUE(sg.revenue) over(partition by sg.symbol order by sg.calendarYear)),(1/yrs.yrs_num))-1)*100*-1

 END as carg
 FROM required_data sg
 LEFT JOIN number_of_years yrs
 ON yrs.symbol = sg.symbol
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM sales_details GROUP BY 1
 )
 SELECT sales_details.symbol, sales_details.calendarYear, sales_details.revenue as recent_revenue,
 sales_details.revenue_growth as recent_revenue_growth, sales_details.avg_revenue, yrs.yrs_num as number_of_yrs,
 round(sales_details.carg,2) as revenue_cagr, CURDATE() as created_at
 FROM sales_details
 LEFT JOIN
 max_row ON sales_details.symbol = max_row.symbol
 LEFT JOIN number_of_years yrs
 ON yrs.symbol = sales_details.symbol
 WHERE sales_details.row_numb = max_row.max_row_numb
 -- order by 1,2
 ;

  select count(*) from mysql_portfolio.sales_info;


 -- --------------------------------- free cash flow CAGR ----------------------------------------
 DROP TABLE IF EXISTS mysql_portfolio.free_cash_flow_info;
 create table mysql_portfolio.free_cash_flow_info as
 WITH free_cashflow_growth as
 (
 SELECT cf.symbol,cf.calendarYear, cf.freeCashFlow,
 lag(cf.freeCashFlow) over (partition by cf.symbol order by cf.calendarYear) as prev_fcf,
CASE WHEN cf.freeCashFlow > lag(cf.freeCashFlow) over (partition by cf.symbol order by cf.calendarYear) THEN 'Y' ELSE 'N' END AS fcf_growth,
round(avg(cf.freeCashFlow) over(partition by cf.symbol order by cf.calendarYear rows between unbounded preceding and unbounded following),2) as avg_fcf,
row_number() over (partition by cf.symbol order by cf.calendarYear) as row_numb,
curdate() as created_at
  FROM mysql_portfolio.cash_flow_statement cf
  INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = cf.symbol
and symbol_list.exchangeShortName = exchangeName
 WHERE cf.calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 4 YEAR))
 -- order by 1,2 desc -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 ),
 composite_key AS
 (
	SELECT *,CONCAT(free_cashflow_growth.symbol,free_cashflow_growth.row_numb) as comp_key FROM free_cashflow_growth

),
 row_selection AS
 (
   SELECT CONCAT(symbol,row_num) as comp_key FROM
   (
   SELECT symbol,MAX(row_numb) as row_num FROM free_cashflow_growth GROUP BY 1
   UNION ALL
   SELECT symbol,MIN(row_numb) as row_num FROM free_cashflow_growth GROUP BY 1
   )a
 ),
 required_data AS
 (
  SELECT composite_key.*
  FROM row_selection
  LEFT JOIN composite_key
  ON row_selection.comp_key = composite_key.comp_key
  ),
 number_of_years AS
 (
  SELECT symbol, COUNT(calendarYear) AS yrs_num FROM free_cashflow_growth GROUP BY 1
  ),
 free_cashflow_details as
 (
 SELECT fcfg.*,
 CASE
 WHEN
 FIRST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear) > 0
 AND LAST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear) > 0
 THEN
 ((power((LAST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear))
 /(FIRST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear)),(1/yrs.yrs_num)))-1)*100
 WHEN
 FIRST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear) < 0
 AND LAST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear) < 0
 THEN
 ((power((ABS(LAST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear)))
 /(ABS(FIRST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear))),(1/yrs.yrs_num)))-1)*100 *-1
 WHEN
 FIRST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear) < 0
 AND LAST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear) > 0
THEN
(POW(((LAST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear)
+ 2* ABS(FIRST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear)))
/ABS(FIRST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear))),(1/yrs.yrs_num))-1)*100
WHEN
FIRST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear) > 0
 AND LAST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear) < 0
THEN
(POW(((ABS(LAST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear))
+ 2*FIRST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear))
/ FIRST_VALUE(fcfg.freeCashFlow) over(partition by fcfg.symbol order by fcfg.calendarYear)),(1/yrs.yrs_num))-1)*100*-1

 END as carg
 FROM required_data fcfg
 LEFT JOIN number_of_years yrs
 ON yrs.symbol = fcfg.symbol
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM free_cashflow_details GROUP BY 1
 )
 SELECT free_cashflow_details.symbol, free_cashflow_details.calendarYear, free_cashflow_details.freeCashFlow as recent_free_cash_flow,
 free_cashflow_details.fcf_growth as recent_fcf_growth, free_cashflow_details.avg_fcf, yrs.yrs_num as number_of_yrs,
 round(free_cashflow_details.carg,2) as fcf_cagr, CURDATE() as created_at
 FROM free_cashflow_details
 LEFT JOIN
 max_row ON free_cashflow_details.symbol = max_row.symbol
 LEFT JOIN number_of_years yrs
 ON yrs.symbol = free_cashflow_details.symbol
 WHERE free_cashflow_details.row_numb = max_row.max_row_numb order by 1,2
 ;

 SELECT count(*) FROM mysql_portfolio.free_cash_flow_info;
END ;

