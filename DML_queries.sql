SELECT * FROM mysql_portfolio.symbol_list;
SELECT * FROM mysql_portfolio.balance_sheet;
SELECT * FROM mysql_portfolio.income_statement;
SELECT * FROM mysql_portfolio.cash_flow_statement;
SELECT * FROM mysql_portfolio.financial_growth;
SELECT * FROM mysql_portfolio.financial_ratios;
SELECT * FROM mysql_portfolio.historical_prices;
SELECT * FROM mysql_portfolio.key_metrics;
SELECT * FROM mysql_portfolio.sector_pe;
SELECT * FROM mysql_portfolio.industry_pe;
SELECT * FROM mysql_portfolio.stock_screener;

SHOW COLUMNS FROM mysql_portfolio.key_metrics;
SHOW COLUMNS FROM mysql_portfolio.stock_screener;
SHOW COLUMNS FROM mysql_portfolio.income_statement;
SHOW COLUMNS FROM mysql_portfolio.balance_sheet;
SHOW COLUMNS FROM mysql_portfolio.cash_flow_statement;
SHOW COLUMNS FROM mysql_portfolio.financial_growth;

/* QUERIES TO MANIPULATE THE DATA FOR THE FINAL DECISION DATA */

USE mysql_portfolio;
 
 -- eps calculation for last 5 years
 drop table mysql_portfolio.eps_info;
 create table mysql_portfolio.eps_info as 
 SELECT symbol, calendarYear, eps as ttm_eps, eps_growth as recent_eps_growth,positive_eps_growth_3yrs, avg_eps as _5yr_avg_eps FROM 
 (
 SELECT *, 
 CASE WHEN sum(eps_growth) over(partition by symbol order by calendarYear rows between unbounded preceding and unbounded following) >=3
THEN 1 ELSE 0 END AS positive_eps_growth_3yrs FROM 
 (
 SELECT symbol,calendarYear,eps, lag(eps) over (partition by symbol order by calendarYear) as prev_eps, 
CASE WHEN eps > lag(eps) over (partition by symbol order by calendarYear) THEN 1 ELSE 0 END AS eps_growth,
round(avg(eps) over(partition by symbol order by calendarYear rows between unbounded preceding and unbounded following),2) as avg_eps,
row_number() over (partition by symbol order by calendarYear) as row_numb, curdate() as created_at 
  FROM mysql_portfolio.income_statement 
 WHERE calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 5 YEAR)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 AND symbol IN ('AAPL','MSFT') order by 1,2 desc
 )eps_growth order by 1,2 desc
 )eps_details WHERE row_numb = 6;
 
 select * from mysql_portfolio.eps_info; 
 
 drop table mysql_portfolio.ebitda_info;
 create table mysql_portfolio.ebitda_info as 
 SELECT symbol, calendarYear, ebitda as recent_ebitda, ebitda_growth as recent_ebitda_growth, avg_ebitda as _5yr_avg_ebitda,carg as _5yr_ebitda_cagr
 FROM
 (
 SELECT *,
 ((power((LAST_VALUE(ebitda) over(partition by symbol order by calendarYear))/(FIRST_VALUE(ebitda) over(partition by symbol order by calendarYear)),(1/5)))-1)*100 as carg
 FROM
 (
 SELECT symbol,calendarYear,ebitda, lag(ebitda) over (partition by symbol order by calendarYear) as prev_ebitda, 
CASE WHEN ebitda > lag(ebitda) over (partition by symbol order by calendarYear) THEN 'Y' ELSE 'N' END AS ebitda_growth,
round(avg(ebitda) over(partition by symbol order by calendarYear rows between unbounded preceding and unbounded following),2) as avg_ebitda,
row_number() over (partition by symbol order by calendarYear) as row_numb, 
curdate() as created_at 
  FROM mysql_portfolio.income_statement 
 WHERE calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 5 YEAR)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 AND symbol IN ('AAPL','MSFT') order by 1,2 desc
 )ebitda_growth order by symbol,calendarYear desc
 )ebitda_details WHERE row_numb = 6;
 
 select * from mysql_portfolio.ebitda_info; 
 
 drop table mysql_portfolio.netincome_info;
 create table mysql_portfolio.netincome_info as 
 SELECT symbol, calendarYear, netincome as recent_netincome, netincome_growth as recent_netincome_growth, avg_netincome as _5yr_avg_netincome, carg as _5yr_netincome_cagr
 FROM(
 SELECT  *,
 ((power((LAST_VALUE(netincome) over(partition by symbol order by calendarYear))/(FIRST_VALUE(netincome) over(partition by symbol order by calendarYear)),(1/5)))-1)*100 as carg
 FROM
 (
 SELECT symbol,calendarYear,netincome, lag(netincome) over (partition by symbol order by calendarYear) as prev_netincome, 
CASE WHEN netincome > lag(netincome) over (partition by symbol order by calendarYear) THEN 'Y' ELSE 'N' END AS netincome_growth,
round(avg(netincome) over(partition by symbol order by calendarYear rows between unbounded preceding and unbounded following),2) as avg_netincome,
row_number() over (partition by symbol order by calendarYear) as row_numb, curdate() as created_at 
  FROM mysql_portfolio.income_statement 
 WHERE calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 5 YEAR)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 AND symbol IN ('AAPL','MSFT') order by 1,2 desc 
 )netincome_growth order by symbol,calendarYear desc
 )netincome_details WHERE row_numb = 6;
 
 SELECT * FROM mysql_portfolio.netincome_info;
 
 drop table mysql_portfolio.sales_info;
 create table mysql_portfolio.sales_info as 
 SELECT symbol, calendarYear, revenue as recent_revenue, revenue_growth as recent_revenue_growth, avg_revenue as _5yr_avg_revenue,carg as _5yr_revenue_cagr
 FROM
 (
 SELECT *,
 ((power((LAST_VALUE(revenue) over(partition by symbol order by calendarYear))/(FIRST_VALUE(revenue) over(partition by symbol order by calendarYear)),(1/5)))-1)*100 as carg
 FROM
 (
 SELECT symbol,calendarYear,revenue, lag(revenue) over (partition by symbol order by calendarYear) as prev_revenue, 
CASE WHEN revenue > lag(revenue) over (partition by symbol order by calendarYear) THEN 'Y' ELSE 'N' END AS revenue_growth,
round(avg(revenue) over(partition by symbol order by calendarYear rows between unbounded preceding and unbounded following),2) as avg_revenue,
row_number() over (partition by symbol order by calendarYear) as row_numb, 
curdate() as created_at 
  FROM mysql_portfolio.income_statement 
 WHERE calendarYear >= YEAR(DATE_SUB(CURDATE(), INTERVAL 5 YEAR)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 AND symbol IN ('AAPL','MSFT') order by 1,2 desc
 )revenue_growth order by symbol,calendarYear desc
 )revenue_details WHERE row_numb = 6;
 
 select * from mysql_portfolio.sales_info; 
 
 
 drop table mysql_portfolio._50_day_avg_price_info;
 create table mysql_portfolio._50_day_avg_price_info as 
 SELECT symbol, date as latest_price_date, close as latest_close_price, avg_price as _50day_avg_price FROM
 (
 SELECT symbol,date,close,
round(avg(close) over(partition by symbol order by date rows between unbounded preceding and unbounded following),2) as avg_price,
row_number() over (partition by symbol order by date) as row_numb, curdate() as created_at 
  FROM mysql_portfolio.historical_prices 
 WHERE date >= (DATE_SUB((SELECT MAX(date)FROM mysql_portfolio.historical_prices), INTERVAL 70 DAY)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 AND symbol IN ('AAPL','MSFT') order by 1,2 desc 
 )50day_avg WHERE row_numb = 50
 -- WE TOOK approx 70 calendar days in DATE_SUB() AS 70 calendar days = 50 working days

;
 SELECT * FROM mysql_portfolio._50_day_avg_price_info;
 
 drop table mysql_portfolio._200_day_avg_price_info;
 create table mysql_portfolio._200_day_avg_price_info as 
 SELECT symbol, date as latest_price_date, close as latest_close_price, avg_price as _200day_avg_price FROM
 (
 SELECT symbol,date,close,
round(avg(close) over(partition by symbol order by date rows between unbounded preceding and unbounded following),2) as avg_price,
row_number() over (partition by symbol order by date) as row_numb, curdate() as created_at 
  FROM mysql_portfolio.historical_prices 
 WHERE date >= (DATE_SUB((SELECT MAX(date)FROM mysql_portfolio.historical_prices), INTERVAL 284 DAY)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 AND symbol IN ('AAPL','MSFT') order by 1,2 desc 
 )200day_avg WHERE row_numb = 200
 -- WE TOOK approx 284 calendar days in DATE_SUB() AS 70 calendar days = 200 working days

 ;
 SELECT * FROM mysql_portfolio._200_day_avg_price_info;
 
 drop table mysql_portfolio._5_year_avg_price_info;
create table mysql_portfolio._5_year_avg_price_info as 
 SELECT symbol, date as latest_price_date, close as latest_close_price, avg_price as _5year_avg_price 
 FROM
 (
 SELECT symbol,date,close,
round(avg(close) over(partition by symbol order by date rows between unbounded preceding and unbounded following),2) as avg_price,
row_number() over (partition by symbol order by date) as row_numb, curdate() as created_at 
  FROM mysql_portfolio.historical_prices 
 WHERE date >= (DATE_SUB((SELECT MAX(date)FROM mysql_portfolio.historical_prices), INTERVAL 1825 DAY)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 AND symbol IN ('AAPL','MSFT') order by 1,2 desc 
 )200day_avg WHERE row_numb = 1258;
 -- ACTUALLY WE SHOULD USE row_numb = 1305 TO confirm we calculate correct data; 1825 calender days = 5 working years
 SELECT * FROM mysql_portfolio._5_year_avg_price_info;
 
 
 drop table mysql_portfolio.pe_pb_ratio_info;
 create table mysql_portfolio.pe_pb_ratio_info
 SELECT 
 eps.*,_50day.latest_price_date,_50day.latest_close_price,_50day._50day_avg_price, _200day._200day_avg_price,_5year._5year_avg_price,
 round(_50day_avg_price/ttm_eps,2) as current_pe_ratio,round(_200day_avg_price/ttm_eps,2) as _200day_pe_ratio,
 round(_5year_avg_price/_5yr_avg_eps,2) as _5year_pe_ratio,
 round((round(_50day_avg_price/ttm_eps,2)+round(_200day_avg_price/ttm_eps,2)+round(_5year_avg_price/_5yr_avg_eps,2))/3,2) as final_pe_ratio,
 key_metrics.bookValuePerShare,
 round(_50day_avg_price/key_metrics.bookValuePerShare,2) as pbratio,
 round((_50day_avg_price/key_metrics.bookValuePerShare)
 *(round((round(_50day_avg_price/ttm_eps,2)+round(_200day_avg_price/ttm_eps,2)+round(_5year_avg_price/_5yr_avg_eps,2))/3,2)),2) as ratio_pe_into_pb
 -- (pe_ratio1+pe_ratio2+pe_ratio3+pe_ratio4)/4 as avg_pe_ratio
 FROM 
 mysql_portfolio.eps_info eps 
 LEFT JOIN mysql_portfolio._50_day_avg_price_info _50day 
 ON _50day.symbol = eps.symbol 
 LEFT JOIN mysql_portfolio._200_day_avg_price_info _200day 
 ON _200day.symbol = eps.symbol
 LEFT JOIN mysql_portfolio._5_year_avg_price_info _5year 
 ON _5year.symbol = eps.symbol
 INNER JOIN mysql_portfolio.key_metrics
 ON eps.symbol = key_metrics.symbol
 AND YEAR(key_metrics.date)= (SELECT MAX(YEAR(date)) FROM mysql_portfolio.key_metrics)
 ;
 SELECT * FROM mysql_portfolio.pe_pb_ratio_info;
 
 SELECT * FROM mysql_portfolio.key_metrics WHERE symbol = 'AAPL' AND YEAR(date) = '2021';
 
 SELECT * FROM mysql_portfolio.historical_prices LIMIT 200;

 
drop table mysql_portfolio.price_cashflow_info;
create table  mysql_portfolio.price_cashflow_info as
SELECT cash_flow.symbol,cash_flow.date as latest_cash_flow_date, cash_flow.freeCashFlow,cash_flow.operatingCashFlow,
 _50day._50day_avg_price, _50day.latest_price_date, (_50day._50day_avg_price/cash_flow.freeCashFlow) as price_fcf_ratio,  
 (_50day._50day_avg_price/cash_flow.operatingCashFlow) as price_ocf_ratio
 FROM mysql_portfolio.cash_flow_statement cash_flow
 LEFT JOIN mysql_portfolio._50_day_avg_price_info _50day
 ON cash_flow.symbol = _50day.symbol
 WHERE YEAR(cash_flow.date) = (SELECT MAX(YEAR(date)) FROM mysql_portfolio.cash_flow_statement);

 SELECT * FROM mysql_portfolio.price_cashflow_info;
 
 