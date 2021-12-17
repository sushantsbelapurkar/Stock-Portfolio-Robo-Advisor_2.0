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

DROP VIEW mysql_portfolio.vw_stock_parameter_check;
CREATE VIEW mysql_portfolio.vw_stock_parameter_check AS 
	SELECT DISTINCT 
    screener.companyName,screener.exchangeShortName,screener.industry,screener.sector,
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
    pcashflow.price_fcf_ratio,pcashflow.price_ocf_ratio,
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
    LEFT JOIN mysql_portfolio.key_metrics keymetrics
    ON screener.symbol = keymetrics.symbol
    AND YEAR(keymetrics.date) = (SELECT MAX(YEAR(date)) FROM mysql_portfolio.key_metrics keymetrics)
    WHERE screener.isEtf = 0
    AND screener.symbol in ('AAPL','MSFT')
    ;
    
    SELECT * FROM mysql_portfolio.key_metrics;
    SELECT * FROM mysql_portfolio.financial_growth;
    SELECT * FROM mysql_portfolio.vw_stock_parameter_check WHERE symbol in ('AAPL','MSFT');
    SELECT positive_eps_growth_3yrs, debtToEquity, currentRatio, inventoryTurnover FROM mysql_portfolio.vw_stock_parameter_check WHERE symbol in ('AAPL','MSFT');
    
   DROP TABLE mysql_portfolio.strong_fundamentals;
   CREATE TABLE mysql_portfolio.fundamental_analysis AS
   SELECT symbol,calendarYear,positive_eps_growth_3yrs,recent_eps_growth,debtToEquity,currentRatio,inventoryTurnover,
   CASE 
   WHEN positive_eps_growth_3yrs = 1 AND recent_eps_growth = 1 AND debtToEquity < 0.5 AND currentRatio >= 2 AND inventoryTurnover > 5 THEN 'strong_fundamentals'
   WHEN positive_eps_growth_3yrs = 1 AND (debtToEquity >0.5 AND debtToEquity <=0.75)  AND (currentRatio >= 1.1 AND currentRatio < 2)
   AND (inventoryTurnover > 2 AND inventoryTurnover<=5) THEN 'bit_risky_fundamentals'
   WHEN (positive_eps_growth_3yrs IS NULL OR debtToEquity IS NULL OR currentRatio IS NULL OR inventoryTurnover IS NULL) THEN 'data_na'
   ELSE 'risky_fundamentals' END AS fundamental_risk
   FROM mysql_portfolio.vw_stock_parameter_check;
   
   -- REMEMBER TO ADD/CHECK SHAREHOLDING PATTERN IN FUNDAMENTALS
   
   SELECT * FROM mysql_portfolio.fundamental_analysis;
   
  DROP TABLE mysql_portfolio.pepb_analysis;
  CREATE TABLE mysql_portfolio.pepb_analysis AS
   SELECT symbol,latest_price_date, final_pe_ratio,pbratio,ratio_pe_into_pb,
   CASE 
   WHEN ratio_pe_into_pb <=22.5 THEN 'undervalued' 
   WHEN ratio_pe_into_pb <=40 THEN 'conisderable' 
   WHEN ratio_pe_into_pb IS NULL THEN 'data_na' ELSE 'overvalued' END AS pepb_value
   FROM mysql_portfolio.vw_stock_parameter_check;
   
   SELECT * FROM mysql_portfolio.pepb_analysis;
   
   
  DROP TABLE mysql_portfolio.growth_factors;
  CREATE TABLE mysql_portfolio.growth_factors AS
   SELECT stock_param.symbol,stock_param.latest_price_date, stock_param.recent_ebitda_growth,stock_param._5yr_ebitda_cagr, 
   stock_param.recent_netincome_growth,stock_param._5yr_netincome_cagr,stock_param.recent_revenue_growth,stock_param._5yr_revenue_cagr,
   key_m.roe,fin_growth.fiveYShareholdersEquityGrowthPerShare,fin_growth.fiveYOperatingCFGrowthPerShare,fin_growth.fiveYDividendperShareGrowthPerShare,
   fin_growth.rdexpenseGrowth,key_m.capexToOperatingCashFlow,key_m.capexToRevenue,
   CASE 
   WHEN stock_param._5yr_ebitda_cagr >=8 AND stock_param._5yr_ebitda_cagr <15 THEN 'good_growth'
   WHEN stock_param._5yr_ebitda_cagr >=15 AND stock_param._5yr_ebitda_cagr <25 THEN 'rapid_growth'
   WHEN stock_param._5yr_ebitda_cagr >=25 AND stock_param._5yr_ebitda_cagr <50 THEN 'very_rapid_growth'
   WHEN stock_param._5yr_ebitda_cagr >=50 THEN 'hyper_growth' 
   WHEN stock_param._5yr_ebitda_cagr <8 THEN 'slow_growth'  
   WHEN stock_param._5yr_ebitda_cagr is null then 'data_na'
   END as _5y_ebitda_growth,
   CASE 
   WHEN stock_param._5yr_netincome_cagr >=8 AND stock_param._5yr_netincome_cagr <15 THEN 'good_growth'
   WHEN stock_param._5yr_netincome_cagr >=15 AND stock_param._5yr_netincome_cagr <25 THEN 'rapid_growth'
   WHEN stock_param._5yr_netincome_cagr >=25 AND stock_param._5yr_netincome_cagr <50 THEN 'very_rapid_growth'
   WHEN stock_param._5yr_netincome_cagr >=50 THEN 'hyper_growth' 
   WHEN stock_param._5yr_netincome_cagr <8 THEN 'slow_growth'
   WHEN stock_param._5yr_netincome_cagr IS NULL THEN 'data_na' 
   END as _5y_netincome_growth,
   CASE 
   WHEN stock_param._5yr_revenue_cagr >=8 AND stock_param._5yr_revenue_cagr <15 THEN 'good_growth'
   WHEN stock_param._5yr_revenue_cagr >=15 AND stock_param._5yr_revenue_cagr <25 THEN 'rapid_growth'
   WHEN stock_param._5yr_revenue_cagr >=25 AND stock_param._5yr_revenue_cagr <50 THEN 'very_rapid_growth'
   WHEN stock_param._5yr_revenue_cagr >=50 THEN 'hyper_growth' 
   WHEN stock_param._5yr_revenue_cagr <8 THEN 'slow_growth'  
   WHEN stock_param._5yr_revenue_cagr IS NULL THEN 'data_na'
   END as _5y_sales_growth,
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
   END AS _5y_shareholder_equity_growth,
   CASE
   WHEN fin_growth.fiveYOperatingCFGrowthPerShare > 0 THEN 'positive' 
   WHEN fin_growth.fiveYOperatingCFGrowthPerShare < 0 THEN 'negative'
   WHEN fin_growth.fiveYOperatingCFGrowthPerShare = 0 THEN 'no_change'
   WHEN fin_growth.fiveYOperatingCFGrowthPerShare is null THEN 'data_na'
   END AS _5y_operating_cash_flow_growth,
   CASE
   WHEN fin_growth.fiveYDividendperShareGrowthPerShare > 0 THEN 'positive' 
   WHEN fin_growth.fiveYShareholdersEquityGrowthPerShare <= 0 THEN 'negative'
   WHEN fin_growth.fiveYShareholdersEquityGrowthPerShare = 0 THEN 'no_change'
   WHEN fin_growth.fiveYShareholdersEquityGrowthPerShare is null THEN 'data_na'
   END AS _5y_divident_growth,
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
   END AS capex_growth_revenue
   FROM mysql_portfolio.vw_stock_parameter_check stock_param 
   LEFT JOIN mysql_portfolio.financial_growth fin_growth
   ON fin_growth.symbol = stock_param.symbol
   AND YEAR(fin_growth.date) = (SELECT MAX(YEAR(date)) FROM mysql_portfolio.financial_growth)
   LEFT JOIN mysql_portfolio.key_metrics key_m
   ON key_m.symbol = stock_param.symbol
   AND YEAR(key_m.date) = (SELECT MAX(YEAR(date)) FROM mysql_portfolio.key_metrics);
   
   SELECT * FROM mysql_portfolio.growth_factors;

  