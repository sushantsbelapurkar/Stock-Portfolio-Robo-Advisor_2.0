
 SELECT fundamental.symbol,fundamental.calendarYear,fundamental.eps_growth_analysis,fundamental.debt_to_equity_analysis,
 fundamental.current_ratio_analysis,fundamental.inventory_analysis,fundamental.roe_analysis,fundamental.roic_analysis,
 value.pe_ratio_analysis,value.pe_and_sector_pe_analysis,value.pb_ratio_analysis,value.pepb_ratio_analysis,
 value.price_to_sales_analysis,value.price_ocf_analysis,
 growth.ebitda_growth, growth.netincome_growth,growth.sales_growth,growth.roe_growth,growth.shareholder_equity_growth,
 growth.operating_cash_flow_growth,growth.divident_growth,growth.rdexpense_growth,growth.capex_growth_ofc,growth.capex_growth_revenue,
 growth.is_roic_greater_wacc
 FROM mysql_portfolio.fundamental_analysis fundamental
 LEFT JOIN mysql_portfolio.value_analysis value
 ON value.symbol = fundamental.symbol
 LEFT JOIN mysql_portfolio.growth_analysis growth
 ON growth.symbol = fundamental.symbol;

 DROP TABLE mysql_portfolio.fair_price_analysis;
CREATE TABLE mysql_portfolio.fair_price_analysis AS
WITH fair_price AS
(
SELECT eps_info.symbol,eps_info.calendarYear,
round(15*eps_info._5yr_avg_eps,2) as eps_fair_value,round(key_metrics.grahamNumber,2) as graham_number,
round(dcf_data.dcf_fair_value,2) as dcf_fair_value,
price.latest_price_date,price.latest_close_price, price._50day_avg_price
 FROM mysql_portfolio.eps_info
 LEFT JOIN mysql_portfolio.key_metrics
 ON key_metrics.symbol = eps_info.symbol
 AND year(key_metrics.date) = eps_info.calendarYear
 LEFT JOIN mysql_portfolio.dcf_data
 ON dcf_data.symbol = eps_info.symbol
 AND dcf_data.calendarYear = eps_info.calendarYear
 LEFT JOIN mysql_portfolio._50_day_avg_price_info price
 ON price.symbol = eps_info.symbol
 )
 SELECT * ,
 CASE
WHEN (latest_close_price <= eps_fair_value OR latest_close_price <= graham_number) THEN 'undervalued'
WHEN (latest_close_price > eps_fair_value AND latest_close_price <= eps_fair_value+eps_fair_value*0.2)
	OR (latest_close_price > graham_number AND latest_close_price <= eps_fair_value+eps_fair_value*0.2)
THEN 'border_level'
ELSE 'overvalued' END AS latest_price_compared_to_eps_graham,
CASE
WHEN latest_close_price <= dcf_fair_value THEN 'undervalued'
ELSE 'overvalued' END AS latest_price_compared_to_dcf
FROM fair_price
 ;

 SELECT * FROM mysql_portfolio.fair_price_analysis;
SELECT * FROM mysql_portfolio._50_day_avg_price_info;
 SELECT * FROM mysql_portfolio.eps_info;
  SELECT * FROM mysql_portfolio.dcf_data;
SELECT * FROM mysql_portfolio.key_metrics;
 SELECT * FROM mysql_portfolio.pe_pb_ratio_info;
 SELECT * FROM mysql_portfolio.price_cashflow_info;
 SELECT * FROM mysql_portfolio.fundamental_analysis;
SELECT * FROM mysql_portfolio.value_analysis;
SELECT * FROM mysql_portfolio. growth_analysis;