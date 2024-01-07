DROP PROCEDURE IF EXISTS mysql_portfolio.decision_view_info;

CREATE PROCEDURE mysql_portfolio.decision_view_info()
BEGIN
DROP VIEW IF EXISTS mysql_portfolio.vw_stock_parameter_check;
CREATE VIEW mysql_portfolio.vw_stock_parameter_check AS
WITH key_metrics_rownum as
 (
  SELECT key_metrics.*,year(key_metrics.date) as calendarYear, row_number() over (partition by key_metrics.symbol order by year(key_metrics.date)) as row_numb
  FROM mysql_portfolio.key_metrics
  INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = key_metrics.symbol
-- and symbol_list.exchangeShortName = exchange_name()
and symbol_list.exchangeShortName = 'NSE'
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
    ebitda.recent_ebitda,ebitda.recent_ebitda_growth,ebitda.avg_ebitda,ebitda.ebitda_cagr,
    netincome.recent_netincome,netincome.recent_netincome_growth,netincome.avg_netincome,netincome.netincome_cagr,
    sales.recent_revenue,sales.recent_revenue_growth,sales.avg_revenue,sales.revenue_cagr,
    pcashflow.freeCashFlow,pcashflow.latest_cash_flow_date,pcashflow.operatingCashFlow,
    pcashflow.price_fcf_ratio,pcashflow.price_ocf_ratio,keymetrics.priceToSalesRatio,
    keymetrics.dividendYield, keymetrics.debtToEquity,keymetrics.currentRatio,keymetrics.roe,keymetrics.roic,keymetrics.inventoryTurnover,
    keymetrics.peRatio as live_peratio, keymetrics.pbratio as live_pbratio, keymetrics.grahamNetNet, keymetrics.grahamNumber,
    curdate() as created_at
    FROM mysql_portfolio.stock_screener screener
    INNER JOIN mysql_portfolio.symbol_list
	on symbol_list.symbol = screener.symbol
	-- and symbol_list.exchangeShortName = exchange_name()
    and symbol_list.exchangeShortName = 'NSE'
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
    SELECT count(*) from mysql_portfolio.vw_stock_parameter_check;
    END  ;

