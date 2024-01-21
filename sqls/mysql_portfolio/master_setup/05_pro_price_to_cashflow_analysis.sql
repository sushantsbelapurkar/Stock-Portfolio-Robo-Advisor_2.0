DROP PROCEDURE IF EXISTS mysql_portfolio.price_cah_flow_info;

CREATE PROCEDURE mysql_portfolio.price_cah_flow_info(
IN exchangeName varchar(255)
)
BEGIN
-- drop table IF EXISTS mysql_portfolio.price_cashflow_info;
-- create table  mysql_portfolio.price_cashflow_info as
INSERT INTO mysql_portfolio.price_cashflow_info
WITH cash_flow_rownum as
 (
  SELECT cf.*,row_number() over (partition by cf.symbol order by cf.calendarYear) as row_numb
  FROM mysql_portfolio.cash_flow_statement cf
  INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = cf.symbol
and symbol_list.exchangeShortName = exchangeName
  ),
  cash_flow_statement_max as
  (
  SELECT symbol, max(row_numb) as max_row_numb FROM cash_flow_rownum group by 1
  )
SELECT cash_flow.symbol,cash_flow.date as latest_cash_flow_date, cash_flow.calendarYear, cash_flow.freeCashFlow,cash_flow.operatingCashFlow,
 _50day._50day_avg_price, _50day.latest_price_date, shares_float.outstandingShares,
 (_50day._50day_avg_price*shares_float.outstandingShares) as outstanding_share_total_price,
 ((_50day._50day_avg_price*shares_float.outstandingShares)/NULLIF(cash_flow.freeCashFlow,0)) as price_fcf_ratio,
 ((_50day._50day_avg_price*shares_float.outstandingShares)/NULLIF(cash_flow.operatingCashFlow,0)) as price_ocf_ratio,
 curdate() as created_at
 FROM cash_flow_rownum cash_flow
 LEFT JOIN cash_flow_statement_max
 ON cash_flow.symbol = cash_flow_statement_max.symbol
 LEFT JOIN mysql_portfolio._50_day_avg_price_info _50day
 ON cash_flow.symbol = _50day.symbol
 LEFT JOIN mysql_portfolio.shares_float
 ON shares_float.symbol = cash_flow.symbol
 INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = cash_flow.symbol
and symbol_list.exchangeShortName = exchangeName
 WHERE cash_flow.row_numb = cash_flow_statement_max.max_row_numb
 ;
 SELECT count(*), 'records inserted in price_cashflow_info table' from mysql_portfolio.price_cashflow_info;
 END ;
