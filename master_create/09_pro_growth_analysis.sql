DROP PROCEDURE IF EXISTS mysql_portfolio.growth_analysis_info;
DELIMITER //
  CREATE PROCEDURE mysql_portfolio.growth_analysis_info(
  IN exchangeName varchar(255)
  )
  BEGIN
  DROP TABLE IF EXISTS mysql_portfolio.growth_analysis;
  CREATE TABLE mysql_portfolio.growth_analysis AS
   SELECT stock_param.symbol,stock_param.latest_price_date, stock_param.recent_ebitda_growth,stock_param.ebitda_cagr,
   stock_param.recent_netincome_growth,stock_param.netincome_cagr,stock_param.recent_revenue_growth,stock_param.revenue_cagr,
   key_m.roe,fin_growth.fiveYShareholdersEquityGrowthPerShare,fin_growth.fiveYOperatingCFGrowthPerShare,fin_growth.fiveYDividendperShareGrowthPerShare,
   fin_growth.rdexpenseGrowth,key_m.capexToOperatingCashFlow,key_m.capexToRevenue,key_m.roic,wacc_data.wacc,
   CASE
   WHEN stock_param.ebitda_cagr >=8 AND stock_param.ebitda_cagr <15 THEN 'good_growth'
   WHEN stock_param.ebitda_cagr >=15 AND stock_param.ebitda_cagr <25 THEN 'rapid_growth'
   WHEN stock_param.ebitda_cagr >=25 AND stock_param.ebitda_cagr <50 THEN 'very_rapid_growth'
   WHEN stock_param.ebitda_cagr >=50 THEN 'hyper_growth'
   WHEN stock_param.ebitda_cagr <8 THEN 'slow_growth'
   WHEN stock_param.ebitda_cagr is null then 'data_na'
   END as ebitda_growth,
   CASE
   WHEN stock_param.netincome_cagr >=8 AND stock_param.netincome_cagr <15 THEN 'good_growth'
   WHEN stock_param.netincome_cagr >=15 AND stock_param.netincome_cagr <25 THEN 'rapid_growth'
   WHEN stock_param.netincome_cagr >=25 AND stock_param.netincome_cagr <50 THEN 'very_rapid_growth'
   WHEN stock_param.netincome_cagr >=50 THEN 'hyper_growth'
   WHEN stock_param.netincome_cagr <8 THEN 'slow_growth'
   WHEN stock_param.netincome_cagr IS NULL THEN 'data_na'
   END as netincome_growth,
   CASE
   WHEN stock_param.revenue_cagr >=8 AND stock_param.revenue_cagr <15 THEN 'good_growth'
   WHEN stock_param.revenue_cagr >=15 AND stock_param.revenue_cagr <25 THEN 'rapid_growth'
   WHEN stock_param.revenue_cagr >=25 AND stock_param.revenue_cagr <50 THEN 'very_rapid_growth'
   WHEN stock_param.revenue_cagr >=50 THEN 'hyper_growth'
   WHEN stock_param.revenue_cagr <8 THEN 'slow_growth'
   WHEN stock_param.revenue_cagr IS NULL THEN 'data_na'
   END as sales_growth,
   CASE
   WHEN key_m.roe*100 >=15 AND key_m.roe*100 <25 THEN 'rapid_growth'
   WHEN key_m.roe*100 >=25 AND key_m.roe*100 <50 THEN 'very_rapid_growth'
   WHEN key_m.roe*100 >=50 THEN 'hyper_growth'
   WHEN key_m.roe*100 <14 THEN 'slow_growth'
   WHEN key_m.roe IS NULL THEN 'data_na'
   END as roe_growth,
   CASE
   WHEN fin_growth.fiveYShareholdersEquityGrowthPerShare > 0 THEN 'positive'
   WHEN fin_growth.fiveYShareholdersEquityGrowthPerShare < 0 THEN 'negative'
   WHEN fin_growth.fiveYShareholdersEquityGrowthPerShare = 0 THEN 'no_change'
   WHEN fin_growth.fiveYShareholdersEquityGrowthPerShare is null THEN 'data_na'
   END AS shareholder_equity_growth,
   CASE
   WHEN fin_growth.fiveYOperatingCFGrowthPerShare > 0 THEN 'positive'
   WHEN fin_growth.fiveYOperatingCFGrowthPerShare < 0 THEN 'negative'
   WHEN fin_growth.fiveYOperatingCFGrowthPerShare = 0 THEN 'no_change'
   WHEN fin_growth.fiveYOperatingCFGrowthPerShare is null THEN 'data_na'
   END AS operating_cash_flow_growth,
   CASE
   WHEN fin_growth.fiveYDividendperShareGrowthPerShare > 0 THEN 'positive'
   WHEN fin_growth.fiveYDividendperShareGrowthPerShare <= 0 THEN 'negative'
   WHEN fin_growth.fiveYDividendperShareGrowthPerShare = 0 THEN 'no_change'
   WHEN fin_growth.fiveYDividendperShareGrowthPerShare is null THEN 'data_na'
   END AS divident_growth,
   CASE
   WHEN fin_growth.rdexpenseGrowth > 0 THEN 'positive'
   WHEN fin_growth.rdexpenseGrowth <= 0 THEN 'negative'
   WHEN fin_growth.rdexpenseGrowth = 0 THEN 'no_change'
   WHEN fin_growth.rdexpenseGrowth is null THEN 'data_na'
   END AS rdexpense_growth,
   CASE
   WHEN key_m.capexToOperatingCashFlow > 0 THEN 'positive'
   WHEN key_m.capexToOperatingCashFlow <= 0 THEN 'negative'
   WHEN key_m.capexToOperatingCashFlow = 0 THEN 'no_change'
   WHEN key_m.capexToOperatingCashFlow is null THEN 'data_na'
   END AS capex_growth_ofc,
   CASE
   WHEN key_m.capexToRevenue > 0 THEN 'positive'
   WHEN key_m.capexToRevenue <= 0 THEN 'negative'
   WHEN key_m.capexToRevenue = 0 THEN 'no_change'
   WHEN key_m.capexToRevenue is null THEN 'data_na'
   END AS capex_growth_revenue,
   CASE
   WHEN key_m.roic*100 > wacc_data.wacc THEN 'Y'
   WHEN key_m.roic*100 < wacc_data.wacc THEN 'N'
   END AS is_roic_greater_wacc,
   curdate() as created_at
   FROM mysql_portfolio.vw_stock_parameter_check stock_param
   INNER JOIN mysql_portfolio.symbol_list
   on symbol_list.symbol = stock_param.symbol
   and symbol_list.exchangeShortName = exchangeName
   LEFT JOIN mysql_portfolio.financial_growth fin_growth
   ON fin_growth.symbol = stock_param.symbol
   AND YEAR(fin_growth.date) = stock_param.calendarYear
   LEFT JOIN mysql_portfolio.key_metrics key_m
   ON key_m.symbol = stock_param.symbol
   AND YEAR(key_m.date) = stock_param.calendarYear
   LEFT JOIN mysql_portfolio.wacc_data
   ON wacc_data.symbol = stock_param.symbol
   AND YEAR(wacc_data.date) = stock_param.calendarYear
   ;
   SELECT count(*) FROM mysql_portfolio.growth_analysis;
   END //
   DELIMITER ;

