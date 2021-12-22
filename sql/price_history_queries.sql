drop table mysql_portfolio._50_day_avg_price_info;
create table mysql_portfolio._50_day_avg_price_info as
 WITH fifty_days AS
 (
 SELECT symbol,date,close,
round(avg(close) over(partition by symbol order by date rows between unbounded preceding and unbounded following),2) as avg_price,
row_number() over (partition by symbol order by date) as row_numb, curdate() as created_at
  FROM mysql_portfolio.historical_prices
 WHERE date >= (DATE_SUB((SELECT MAX(date)FROM mysql_portfolio.historical_prices), INTERVAL 70 DAY)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 -- AND symbol IN ('AAPL','MSFT') order by 1,2 desc
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM fifty_days GROUP BY 1
 )
  SELECT fifty_days.symbol, fifty_days.date as latest_price_date, fifty_days.close as latest_close_price, fifty_days.avg_price as _50day_avg_price,
  max_row_numb as days_considered
  FROM fifty_days
  LEFT JOIN max_row ON max_row.symbol = fifty_days.symbol
  WHERE fifty_days.row_numb = max_row.max_row_numb
 -- WE TOOK approx 70 calendar days in DATE_SUB() AS 70 calendar days = 50 working days
;
 SELECT * FROM mysql_portfolio._50_day_avg_price_info;

 drop table mysql_portfolio._200_day_avg_price_info;
 create table mysql_portfolio._200_day_avg_price_info as
 WITH twohundred_days AS
 (
 SELECT symbol,date,close,
round(avg(close) over(partition by symbol order by date rows between unbounded preceding and unbounded following),2) as avg_price,
row_number() over (partition by symbol order by date) as row_numb, curdate() as created_at
  FROM mysql_portfolio.historical_prices
 WHERE date >= (DATE_SUB((SELECT MAX(date)FROM mysql_portfolio.historical_prices), INTERVAL 300 DAY)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 -- AND symbol IN ('AAPL','MSFT') order by 1,2 desc
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM twohundred_days GROUP BY 1
 )
  SELECT twohundred_days.symbol, twohundred_days.date as latest_price_date, twohundred_days.close as latest_close_price, twohundred_days.avg_price as _200day_avg_price,
  max_row_numb as days_considered
  FROM twohundred_days
  LEFT JOIN max_row ON max_row.symbol = twohundred_days.symbol
  WHERE twohundred_days.row_numb = max_row.max_row_numb
  ;
 -- WE TOOK approx 300 calendar days in DATE_SUB() AS 300 calendar days = 200 working days
 SELECT * FROM mysql_portfolio._200_day_avg_price_info;

 drop table mysql_portfolio._5_year_avg_price_info;
 create table mysql_portfolio._5_year_avg_price_info as
 WITH five_yr_days AS
 (
 SELECT symbol,date,close,
round(avg(close) over(partition by symbol order by date rows between unbounded preceding and unbounded following),2) as avg_price,
row_number() over (partition by symbol order by date) as row_numb, curdate() as created_at
  FROM mysql_portfolio.historical_prices
 WHERE date >= (DATE_SUB((SELECT MAX(date)FROM mysql_portfolio.historical_prices), INTERVAL 1827 DAY)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 -- AND symbol IN ('AAPL','MSFT') order by 1,2 desc
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM five_yr_days GROUP BY 1
 )
  SELECT five_yr_days.symbol, five_yr_days.date as latest_price_date,five_yr_days.close as latest_close_price, five_yr_days.avg_price as _5yr_avg_price,
  max_row_numb as days_considered
  FROM five_yr_days
  LEFT JOIN max_row ON max_row.symbol = five_yr_days.symbol
  WHERE five_yr_days.row_numb = max_row.max_row_numb
  ;
 -- WE TOOK approx 1827 calendar days in DATE_SUB() AS 300 calendar days = 1238 working days/5 working years
 SELECT * FROM mysql_portfolio._5_year_avg_price_info;

 ------------------ GOLDEN/DEATH CROSS ANALYSIS-----------------------------
 DROP TABLE mysql_portfolio.golden_death_cross;
 CREATE TABLE mysql_portfolio.golden_death_cross AS
 WITH _50_200_days AS
 (
SELECT _50day.symbol, _50day.latest_price_date,_50day.days_considered as days_consider_50,_50day._50day_avg_price,
_200day.days_considered as days_consider_200,_200day._200day_avg_price,
round(_200day._200day_avg_price-(_200day._200day_avg_price*0.1),2) as _10percentDownOf_200day,
round(_200day._200day_avg_price+(_200day._200day_avg_price*0.1),2) as _10percentUpOf_200day
FROM mysql_portfolio._200_day_avg_price_info _200day
LEFT JOIN mysql_portfolio._50_day_avg_price_info _50day
ON _50day.symbol = _200day.symbol
)
SELECT _50_200_days.*,
CASE
WHEN (_50day_avg_price BETWEEN _10percentDownOf_200day AND _10percentUpOf_200day) THEN 'Y' ELSE 'N' END AS near_to_golden_death_cross,
round((_200day_avg_price - _50day_avg_price),2) as price_difference,
round(100-((_50day_avg_price*100)/_200day_avg_price),2) as percent_diff_in_50_200_price,
'Check trading volume' as note
FROM _50_200_days
;

SELECT * FROM mysql_portfolio.golden_death_cross;

 drop table mysql_portfolio.pe_pb_ratio_info;
 create table mysql_portfolio.pe_pb_ratio_info
 WITH key_metrics_rownum as
 (
  SELECT *,year(date) as calendarYear, row_number() over (partition by symbol order by year(date)) as row_numb
  FROM mysql_portfolio.key_metrics
  ),
  key_metrics_max as
  (
  SELECT symbol, max(row_numb) as max_row_numb FROM key_metrics_rownum group by 1
  ),
  key_metrics_maxyr as
  (
  SELECT key_metrics_max.symbol,key_metrics_max.max_row_numb, key_metrics_rownum.bookValuePerShare
  FROM key_metrics_max LEFT JOIN key_metrics_rownum ON key_metrics_rownum.symbol = key_metrics_max.symbol
  WHERE key_metrics_rownum.row_numb = key_metrics_max.max_row_numb
  )
 SELECT
 eps.*,_50day.latest_price_date,_50day.latest_close_price,_50day._50day_avg_price, _200day._200day_avg_price,_5year._5yr_avg_price,
 round(_50day_avg_price/ttm_eps,2) as current_pe_ratio,round(_200day_avg_price/ttm_eps,2) as _200day_pe_ratio,
 round(_5yr_avg_price/_5yr_avg_eps,2) as _5year_pe_ratio,
 round((round(_50day_avg_price/ttm_eps,2)+round(_200day_avg_price/ttm_eps,2)+round(_5yr_avg_price/_5yr_avg_eps,2))/3,2) as final_pe_ratio,
 key_metrics_maxyr.bookValuePerShare,
 round(_50day_avg_price/key_metrics_maxyr.bookValuePerShare,2) as pbratio,
 round((_50day_avg_price/key_metrics_maxyr.bookValuePerShare)
 *(round((round(_50day_avg_price/ttm_eps,2)+round(_200day_avg_price/ttm_eps,2)+round(_5yr_avg_price/_5yr_avg_eps,2))/3,2)),2) as ratio_pe_into_pb
 -- (pe_ratio1+pe_ratio2+pe_ratio3+pe_ratio4)/4 as avg_pe_ratio
 FROM
 mysql_portfolio.eps_info eps
 LEFT JOIN mysql_portfolio._50_day_avg_price_info _50day
 ON _50day.symbol = eps.symbol
 LEFT JOIN mysql_portfolio._200_day_avg_price_info _200day
 ON _200day.symbol = eps.symbol
 LEFT JOIN mysql_portfolio._5_year_avg_price_info _5year
 ON _5year.symbol = eps.symbol
 LEFT JOIN key_metrics_maxyr
 ON eps.symbol = key_metrics_maxyr.symbol
 ;
 SELECT * FROM mysql_portfolio.pe_pb_ratio_info;

 SELECT * FROM mysql_portfolio.key_metrics WHERE symbol = 'AAPL' AND YEAR(date) = '2021';

 SELECT * FROM mysql_portfolio.historical_prices LIMIT 200;

 ------------ price to cashflow analysis --------------------------------
drop table mysql_portfolio.price_cashflow_info;
create table  mysql_portfolio.price_cashflow_info as
WITH cash_flow_rownum as
 (
  SELECT *,row_number() over (partition by symbol order by calendarYear) as row_numb
  FROM mysql_portfolio.cash_flow_statement
  ),
  cash_flow_statement_max as
  (
  SELECT symbol, max(row_numb) as max_row_numb FROM cash_flow_rownum group by 1
  )
SELECT cash_flow.symbol,cash_flow.date as latest_cash_flow_date, cash_flow.calendarYear, cash_flow.freeCashFlow,cash_flow.operatingCashFlow,
 _50day._50day_avg_price, _50day.latest_price_date, shares_float.outstandingShares,
 (_50day._50day_avg_price*shares_float.outstandingShares) as outstanding_share_total_price,
 ((_50day._50day_avg_price*shares_float.outstandingShares)/cash_flow.freeCashFlow) as price_fcf_ratio,
 ((_50day._50day_avg_price*shares_float.outstandingShares)/cash_flow.operatingCashFlow) as price_ocf_ratio
 FROM cash_flow_rownum cash_flow
 LEFT JOIN cash_flow_statement_max
 ON cash_flow.symbol = cash_flow_statement_max.symbol
 LEFT JOIN mysql_portfolio._50_day_avg_price_info _50day
 ON cash_flow.symbol = _50day.symbol
 LEFT JOIN mysql_portfolio.shares_float
 ON shares_float.symbol = cash_flow.symbol
 WHERE cash_flow.row_numb = cash_flow_statement_max.max_row_numb
 ;

 SELECT * FROM mysql_portfolio.price_cashflow_info;
