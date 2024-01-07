  -- REMEMBER TO ADD/CHECK SHAREHOLDING PATTERN IN FUNDAMENTALS
  DROP PROCEDURE IF EXISTS mysql_portfolio.fundamental_analysis_info;
  DELIMITER //
  CREATE PROCEDURE mysql_portfolio.fundamental_analysis_info(
  IN exchangeName varchar(255)
  )
  BEGIN
   DROP TABLE IF EXISTS mysql_portfolio.fundamental_analysis;
   CREATE TABLE mysql_portfolio.fundamental_analysis AS
   SELECT vw_param_chk.symbol,industry,sector,calendarYear,positive_eps_growth_3yrs,recent_eps_growth,debtToEquity,currentRatio,inventoryTurnover,
   roe,roic,
   CASE
   WHEN positive_eps_growth_3yrs = 1 AND recent_eps_growth = 1 THEN 'strong'
   WHEN positive_eps_growth_3yrs = 1 AND recent_eps_growth = 0 THEN 'recent_negative'
   WHEN positive_eps_growth_3yrs = 0 AND recent_eps_growth = 1 THEN 'bit_risky'
   WHEN positive_eps_growth_3yrs = 0 AND recent_eps_growth = 0 THEN 'risky'
   WHEN positive_eps_growth_3yrs IS NULL OR recent_eps_growth IS NULL THEN 'data_na' END AS eps_growth_analysis,
   CASE
   WHEN debtToEquity <= 0.5 THEN 'strong'
   WHEN (debtToEquity > 0.5 AND debtToEquity <=0.75) THEN 'bit_risky'
   WHEN debtToEquity > 0.75 THEN 'risky'
   WHEN debtToEquity IS NULL THEN 'data_na' END AS debt_to_equity_analysis,
   CASE
   WHEN currentRatio >= 2 THEN 'strong'
   WHEN (currentRatio >= 1.1 AND currentRatio < 2) THEN 'bit_risky'
   WHEN currentRatio < 1.1 THEN 'risky'
   WHEN currentRatio IS NULL THEN 'data_na' END AS current_ratio_analysis,
   CASE
   WHEN (sector <> "Technology" or sector <> "Financial Services" or sector <> "Communication Services" or sector <> "Financial" or sector <> "Services" or sector <> "Banking" or sector <> "Media" or sector <> "Insurance")
   AND inventoryTurnover > 5 THEN 'strong'
   WHEN (sector <> "Technology" or sector <> "Financial Services" or sector <> "Communication Services" or sector <> "Financial" or sector <> "Services" or sector <> "Banking" or sector <> "Media" or sector <> "Insurance")
   AND (inventoryTurnover > 2 AND inventoryTurnover<=5) THEN 'bit_risky'
   WHEN (sector <> "Technology" or sector <> "Financial Services" or sector <> "Communication Services" or sector <> "Financial" or sector <> "Services" or sector <> "Banking" or sector <> "Media" or sector <> "Insurance")
   AND inventoryTurnover <=2 THEN 'risky'
   WHEN (sector <> "Technology" or sector <> "Financial Services" or sector <> "Communication Services" or sector <> "Financial" or sector <> "Services" or sector <> "Banking" or sector <> "Media" or sector <> "Insurance")
   AND inventoryTurnover IS NULL THEN 'data_na'
   WHEN (sector = "Technology" or sector = "Financial Services" or sector = "Communication Services" or sector = "Financial" or sector = "Services" or sector = "Banking" or sector = "Media" or sector = "Insurance")
   THEN 'na' END AS inventory_analysis,
   CASE
   WHEN roe*100 > 25 THEN 'strong'
   WHEN (roe*100 >=15 AND roe < 25)  THEN 'good'
   WHEN roe*100 < 15 THEN 'risky'
   WHEN roe is null THEN 'data_na'END as roe_analysis,
   CASE
   WHEN roic*100 > 25 THEN 'strong'
   WHEN (roic*100 >=15 AND roic < 25)  THEN 'good'
   WHEN roic*100 < 15 THEN 'risky'
   WHEN roic is null THEN 'data_na'END as roic_analysis,
   curdate() created_at
FROM mysql_portfolio.vw_stock_parameter_check vw_param_chk
INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = vw_param_chk.symbol
and symbol_list.exchangeShortName = exchangeName;

SELECT count(*) from mysql_portfolio.fundamental_analysis;
END //
DELIMITER ;