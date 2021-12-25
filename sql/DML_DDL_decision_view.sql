SHOW COLUMNS FROM mysql_portfolio.key_metrics;
SHOW COLUMNS FROM mysql_portfolio.stock_screener;
SHOW COLUMNS FROM mysql_portfolio.income_statement;
SHOW COLUMNS FROM mysql_portfolio.balance_sheet;
SHOW COLUMNS FROM mysql_portfolio.cash_flow_statement;
SHOW COLUMNS FROM mysql_portfolio.financial_growth;
SHOW COLUMNS FROM mysql_portfolio.eps_info;
SHOW COLUMNS FROM mysql_portfolio.pe_pb_ratio_info;
SHOW COLUMNS FROM mysql_portfolio.ebitda_info;
SHOW COLUMNS FROM mysql_portfolio.netincome_info;
SHOW COLUMNS FROM mysql_portfolio._50_day_avg_price_info;
SHOW COLUMNS FROM mysql_portfolio._200_day_avg_price_info;
SHOW COLUMNS FROM mysql_portfolio._5_year_avg_price_info;
SHOW COLUMNS FROM mysql_portfolio.price_cashflow_info;


-- ------------------------------ PRICE TO CASH FLOW ANALYSIS ----------------------------------------------
drop table mysql_portfolio.price_cashflow_info;
-- create table  mysql_portfolio.price_cashflow_info as
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

 -- --------------------------- DECISION PARAMETER GATHERING view FILE ----------------------------
DROP VIEW mysql_portfolio.vw_stock_parameter_check;
CREATE VIEW mysql_portfolio.vw_stock_parameter_check AS
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
  SELECT key_metrics_max.symbol,key_metrics_max.max_row_numb, key_metrics_rownum.dividendYield,key_metrics_rownum.debtToEquity,
  key_metrics_rownum.currentRatio,key_metrics_rownum.roe,key_metrics_rownum.roic,key_metrics_rownum.inventoryTurnover,
  key_metrics_rownum.peRatio,key_metrics_rownum.pbratio,key_metrics_rownum.priceToSalesRatio,key_metrics_rownum.grahamNetNet,
  key_metrics_rownum.grahamNumber
  FROM key_metrics_max
  LEFT JOIN key_metrics_rownum
  ON key_metrics_rownum.symbol = key_metrics_max.symbol
  WHERE key_metrics_rownum.row_numb = key_metrics_max.max_row_numb
  )
SELECT DISTINCT
    screener.companyName,screener.exchangeShortName,screener.industry,screener.sector,sector.pe as sector_pe_ratio,
    screener.marketCap,
    CASE
    WHEN screener.marketCap >= 10000000000 THEN 'large_cap'
    WHEN screener.marketCap >= 2000000000 AND screener.marketCap < 10000000000 THEN 'mid_cap'
    WHEN screener.marketCap >= 300000000 AND screener.marketCap < 2000000000 THEN 'small_cap'
    ELSE 'very_small_cap'
    END AS company_cap,
    screener.beta,
    pepb.*,
    ebitda.recent_ebitda,ebitda.recent_ebitda_growth,ebitda._5yr_avg_ebitda,ebitda._5yr_ebitda_cagr,
    netincome.recent_netincome,netincome.recent_netincome_growth,netincome._5yr_avg_netincome,netincome._5yr_netincome_cagr,
    sales.recent_revenue,sales.recent_revenue_growth,sales._5yr_avg_revenue,sales._5yr_revenue_cagr,
    pcashflow.freeCashFlow,pcashflow.latest_cash_flow_date,pcashflow.operatingCashFlow,
    pcashflow.price_fcf_ratio,pcashflow.price_ocf_ratio,keymetrics.priceToSalesRatio,
    keymetrics.dividendYield, keymetrics.debtToEquity,keymetrics.currentRatio,keymetrics.roe,keymetrics.roic,keymetrics.inventoryTurnover,
    keymetrics.peRatio as live_peratio, keymetrics.pbratio as live_pbratio, keymetrics.grahamNetNet, keymetrics.grahamNumber
    FROM mysql_portfolio.stock_screener screener
    LEFT JOIN mysql_portfolio.pe_pb_ratio_info pepb
    ON pepb.symbol = screener.symbol
    LEFT JOIN mysql_portfolio.ebitda_info ebitda
    ON screener.symbol = ebitda.symbol
    LEFT JOIN mysql_portfolio.netincome_info netincome
	ON screener.symbol = netincome.symbol
	LEFT JOIN mysql_portfolio.sales_info sales
	ON screener.symbol = sales.symbol
    LEFT JOIN mysql_portfolio.price_cashflow_info pcashflow
    ON pcashflow.symbol = screener.symbol
    LEFT JOIN key_metrics_maxyr keymetrics
    ON screener.symbol = keymetrics.symbol
    LEFT JOIN mysql_portfolio.sector_pe sector
    ON sector.sector = screener.sector
    AND sector.exchange = screener.exchangeShortName
    WHERE screener.isEtf = 0
    AND pepb.symbol is not null order by symbol
  --   AND screener.symbol in ('AAPL','MSFT')
    ;

    SELECT * FROM mysql_portfolio.vw_stock_parameter_check;
