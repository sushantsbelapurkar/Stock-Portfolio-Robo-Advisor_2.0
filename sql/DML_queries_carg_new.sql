SELECT * FROM mysql_portfolio.symbol_list -- where symbol in ('TIDEWATER.NS','MRF.NS','CANFINHOME.NS')
;
SELECT * FROM mysql_portfolio.shares_float;
-- DROP TABLE mysql_portfolio.balance_sheet;
SELECT * FROM mysql_portfolio.balance_sheet;
-- DROP TABLE mysql_portfolio.income_statement;
SELECT * FROM mysql_portfolio.income_statement;
-- DROP TABLE mysql_portfolio.cash_flow_statement;
SELECT * FROM mysql_portfolio.cash_flow_statement;
-- DROP TABLE mysql_portfolio.financial_growth;
SELECT * FROM mysql_portfolio.financial_growth;
-- DROP TABLE mysql_portfolio.financial_ratios;
SELECT * FROM mysql_portfolio.financial_ratios;
-- DROP TABLE mysql_portfolio.key_metrics;
SELECT * FROM mysql_portfolio.key_metrics;
-- DROP TABLE mysql_portfolio.sector_pe;
SELECT * FROM mysql_portfolio.sector_pe;
-- DROP TABLE mysql_portfolio.industry_pe;
SELECT * FROM mysql_portfolio.industry_pe;
-- DROP TABLE mysql_portfolio.stock_screener;
SELECT * FROM mysql_portfolio.stock_screener;
-- DROP TABLE mysql_portfolio.historical_prices;
SELECT * FROM mysql_portfolio.historical_prices;

SHOW COLUMNS FROM mysql_portfolio.key_metrics;
SHOW COLUMNS FROM mysql_portfolio.stock_screener;
SHOW COLUMNS FROM mysql_portfolio.income_statement;
SHOW COLUMNS FROM mysql_portfolio.balance_sheet;
SHOW COLUMNS FROM mysql_portfolio.cash_flow_statement;
SHOW COLUMNS FROM mysql_portfolio.financial_growth;

SELECT * FROM mysql_portfolio.key_metrics WHERE symbol = 'AAPL' AND YEAR(date) = '2017';
SELECT * FROM mysql_portfolio.income_statement WHERE symbol = 'AAPL' AND YEAR(date) = '2017';
SELECT * FROM mysql_portfolio.cash_flow_statement WHERE symbol = 'AAPL';
SELECT * FROM mysql_portfolio.balance_sheet WHERE symbol = 'AAPL' AND YEAR(date) = '2017';


/* QUERIES TO MANIPULATE THE DATA FOR THE FINAL DECISION DATA */

USE mysql_portfolio;

-- eps calculation for last 5 years--------------------

 drop table mysql_portfolio.eps_info;
 create table mysql_portfolio.eps_info as
 WITH eps_growth AS
 (
 SELECT symbol,calendarYear,eps, lag(eps) over (partition by symbol order by calendarYear) as prev_eps,
CASE WHEN eps > lag(eps) over (partition by symbol order by calendarYear) THEN 1 ELSE 0 END AS eps_growth,
round(avg(eps) over(partition by symbol order by calendarYear rows between unbounded preceding and unbounded following),2) as avg_eps,
row_number() over (partition by symbol order by calendarYear) as row_numb, curdate() as created_at
  FROM mysql_portfolio.income_statement
 WHERE calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 4 YEAR)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 order by 1,2 desc
 ),
 eps_details as
 (
 SELECT *,
 CASE WHEN sum(eps_growth) over(partition by symbol order by calendarYear rows between unbounded preceding and unbounded following) >=3
THEN 1 ELSE 0 END AS positive_eps_growth_3yrs FROM eps_growth
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM eps_details GROUP BY 1
 )
 SELECT eps_details.symbol, eps_details.calendarYear, eps_details.eps as ttm_eps,
 eps_details.eps_growth as recent_eps_growth,eps_details.positive_eps_growth_3yrs, eps_details.avg_eps as _5yr_avg_eps
--  max_row.max_row_numb
 FROM eps_details
 LEFT JOIN max_row
 ON max_row.symbol = eps_details.symbol
 WHERE eps_details.row_numb = max_row.max_row_numb order by 1,2
 ;

 select * from mysql_portfolio.eps_info order by symbol;

 -- ---------------------------------- CAGR DATA -------------------------------
 -- REFERENCE : https://www.linkedin.com/pulse/reply-how-handle-percent-change-cagr-negative-numbers-timo-krall/
 -- Select Case True

--     Case (begin > 0 And final > 0)
--         CAGR_flexible = (final / begin) ^ (1 / years) - 1
--     Case (begin < 0 And final < 0)
--         CAGR_flexible = (-1) * ((Abs(final) / Abs(begin)) ^ (1 / years) - 1)
--     Case (begin < 0 And final > 0)
--        CAGR_flexible = ((final + 2 * Abs(begin)) / Abs(begin)) ^ (1 / years) - 1
--     Case (begin > 0 And final < 0)
--         CAGR_flexible = (-1) * (((Abs(final) + 2 * begin) / begin) ^ (1 / years) - 1)
--     Case Else
--         CAGR_flexible = 0
 -- --------------------------------- ebitda CAGR -----------------------------
 drop table mysql_portfolio.ebitda_info;
 create table mysql_portfolio.ebitda_info as
 WITH ebitda_growth as
 (
 SELECT symbol,calendarYear,
 CASE WHEN ebitda > 0 THEN ebitda ELSE 0.1 END AS ebitda,
 lag(ebitda) over (partition by symbol order by calendarYear) as prev_ebitda,
CASE WHEN ebitda > lag(ebitda) over (partition by symbol order by calendarYear) THEN 'Y' ELSE 'N' END AS ebitda_growth,
round(avg(ebitda) over(partition by symbol order by calendarYear rows between unbounded preceding and unbounded following),2) as avg_ebitda,
row_number() over (partition by symbol order by calendarYear) as row_numb,
curdate() as created_at
  FROM mysql_portfolio.income_statement
 WHERE calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 4 YEAR)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
order by 1,2 desc
),
ebitda_details as
(
SELECT *,
  ((power((LAST_VALUE(ebitda) over(partition by symbol order by calendarYear))
  /(FIRST_VALUE(ebitda) over(partition by symbol order by calendarYear)),(1/5)))-1)*100  as carg FROM ebitda_growth
  ),
  max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM ebitda_details GROUP BY 1
 )
 SELECT ebitda_details.symbol, ebitda_details.calendarYear, ebitda_details.ebitda as recent_ebitda,
 ebitda_details.ebitda_growth as recent_ebitda_growth, ebitda_details.avg_ebitda as _5yr_avg_ebitda,round(ebitda_details.carg,2)
 as _5yr_ebitda_cagr
 FROM ebitda_details
 LEFT JOIN
 max_row ON ebitda_details.symbol = max_row.symbol
 WHERE ebitda_details.row_numb = max_row.max_row_numb order by 1,2
 ;
 select * from mysql_portfolio.ebitda_info;

 -- --------------------------------- netincome CAGR ----------------------------------------
 drop table mysql_portfolio.netincome_info;
 create table mysql_portfolio.netincome_info as
 WITH netincome_growth as
 (
 SELECT symbol,calendarYear,
CASE WHEN netincome > 0 THEN netincome ELSE 0.1 END AS netincome,
 lag(netincome) over (partition by symbol order by calendarYear) as prev_netincome,
CASE WHEN netincome > lag(netincome) over (partition by symbol order by calendarYear) THEN 'Y' ELSE 'N' END AS netincome_growth,
round(avg(netincome) over(partition by symbol order by calendarYear rows between unbounded preceding and unbounded following),2) as avg_netincome,
row_number() over (partition by symbol order by calendarYear) as row_numb, curdate() as created_at
  FROM mysql_portfolio.income_statement
 WHERE calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 4 YEAR))
 ),
 netincome_details as
 (
 SELECT  *,
 ((power((LAST_VALUE(netincome) over(partition by symbol order by calendarYear))/(FIRST_VALUE(netincome) over(partition by symbol order by calendarYear)),(1/5)))-1)*100 as carg
 FROM netincome_growth
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM netincome_details GROUP BY 1
 )
 SELECT netincome_details.symbol, netincome_details.calendarYear, netincome_details.netincome as recent_netincome,
 netincome_details.netincome_growth as recent_netincome_growth, netincome_details.avg_netincome as _5yr_avg_netincome,round(netincome_details.carg,2)
 as _5yr_netincome_cagr
 FROM netincome_details
 LEFT JOIN
 max_row ON netincome_details.symbol = max_row.symbol
 WHERE netincome_details.row_numb = max_row.max_row_numb order by 1,2
 ;
 SELECT * FROM mysql_portfolio.netincome_info;


 -- --------------------------------- sales/revenue CAGR ----------------------------------------
 drop table mysql_portfolio.sales_info;
 create table mysql_portfolio.sales_info as
 WITH sales_growth as
 (
 SELECT symbol,calendarYear,
 CASE WHEN revenue > 0 THEN revenue ELSE 0.1 END AS revenue,
 lag(revenue) over (partition by symbol order by calendarYear) as prev_revenue,
CASE WHEN revenue > lag(revenue) over (partition by symbol order by calendarYear) THEN 'Y' ELSE 'N' END AS revenue_growth,
round(avg(revenue) over(partition by symbol order by calendarYear rows between unbounded preceding and unbounded following),2) as avg_revenue,
row_number() over (partition by symbol order by calendarYear) as row_numb,
curdate() as created_at
  FROM mysql_portfolio.income_statement
 WHERE calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 4 YEAR))
 ),
 sales_details as
 (
 SELECT *,
 ((power((LAST_VALUE(revenue) over(partition by symbol order by calendarYear))/(FIRST_VALUE(revenue) over(partition by symbol order by calendarYear)),(1/5)))-1)*100 as carg
 FROM sales_growth
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM sales_details GROUP BY 1
 )
 SELECT sales_details.symbol, sales_details.calendarYear, sales_details.revenue as recent_revenue,
 sales_details.revenue_growth as recent_revenue_growth, sales_details.avg_revenue as _5yr_avg_revenue,round(sales_details.carg,2)
 as _5yr_revenue_cagr
 FROM sales_details
 LEFT JOIN
 max_row ON sales_details.symbol = max_row.symbol
 WHERE sales_details.row_numb = max_row.max_row_numb order by 1,2
 ;
 select * from mysql_portfolio.sales_info;


 -- --------------------------------- free cash flow CAGR ----------------------------------------
 drop table mysql_portfolio.free_cash_flow_info;
 -- create table mysql_portfolio.free_cash_flow_info as
 WITH free_cashflow_growth as
 (
 SELECT symbol,calendarYear,  freeCashFlow,
 -- CASE WHEN freeCashFlow > 0 THEN freeCashFlow ELSE 0.1 END AS freeCashFlow,
 lag(freeCashFlow) over (partition by symbol order by calendarYear) as prev_fcf,
CASE WHEN freeCashFlow > lag(freeCashFlow) over (partition by symbol order by calendarYear) THEN 'Y' ELSE 'N' END AS fcf_growth,
round(avg(freeCashFlow) over(partition by symbol order by calendarYear rows between unbounded preceding and unbounded following),2) as avg_fcf,
row_number() over (partition by symbol order by calendarYear) as row_numb,
curdate() as created_at
  FROM mysql_portfolio.cash_flow_statement
 WHERE calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 4 YEAR))
 order by 1,2 desc -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
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
 free_cashflow_details.fcf_growth as recent_fcf_growth, free_cashflow_details.avg_fcf as _5yr_avg_fcf, yrs.yrs_num as number_of_yrs,
 round(free_cashflow_details.carg,2) as fcf_cagr
 FROM free_cashflow_details
 LEFT JOIN
 max_row ON free_cashflow_details.symbol = max_row.symbol
 LEFT JOIN number_of_years yrs ON yrs.symbol = free_cashflow_details.symbol
 WHERE free_cashflow_details.row_numb = max_row.max_row_numb order by 1,2
 ;
 SELECT * FROM mysql_portfolio.free_cash_flow_info;
