
-- CALL mysql_portfolio.company_analysis_score_info('NSE');
 DROP PROCEDURE IF EXISTS mysql_portfolio.company_analysis_score_info;

 CREATE PROCEDURE mysql_portfolio.company_analysis_score_info(
 IN exchangeName varchar(255))
 BEGIN
-- DROP TABLE IF EXISTS mysql_portfolio.company_analysis;
-- CREATE TABLE mysql_portfolio.company_analysis AS
INSERT INTO mysql_portfolio.company_analysis
 SELECT DISTINCT fundamental.symbol,fundamental.calendarYear,fundamental.eps_growth_analysis,fundamental.debt_to_equity_analysis,
 fundamental.current_ratio_analysis,fundamental.inventory_analysis,fundamental.roe_analysis,fundamental.roic_analysis,
 value_a.pe_ratio_analysis,value_a.pe_and_sector_pe_analysis,value_a.pb_ratio_analysis,value_a.pepb_ratio_analysis,
 value_a.price_to_sales_analysis,value_a.price_ocf_analysis,
 growth.ebitda_growth, growth.netincome_growth,growth.sales_growth,growth.roe_growth,growth.shareholder_equity_growth,
 growth.operating_cash_flow_growth,growth.divident_growth,growth.rdexpense_growth,growth.capex_growth_ofc,growth.capex_growth_revenue,
 growth.is_roic_greater_wacc
 FROM mysql_portfolio.fundamental_analysis fundamental
 INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = fundamental.symbol
 and symbol_list.exchangeShortName = exchangeName
 LEFT JOIN mysql_portfolio.value_analysis value_a
 ON value_a.symbol = fundamental.symbol
 LEFT JOIN mysql_portfolio.growth_analysis growth
 ON growth.symbol = fundamental.symbol;

 -- SELECT * FROM mysql_portfolio.company_analysis;
DROP TEMPORARY TABLE IF EXISTS mysql_portfolio.param_score;
CREATE TEMPORARY TABLE mysql_portfolio.param_score AS
 SELECT DISTINCT comp.symbol, comp.calendarYear,
 CASE
 WHEN comp.eps_growth_analysis = 'strong' THEN 10
 WHEN comp.eps_growth_analysis IN ('recent_negative','bit_risky') THEN 7
 WHEN comp.eps_growth_analysis IN ('risky','data_na') THEN 3
 END AS eps_growth_score,
 CASE
 WHEN comp.debt_to_equity_analysis = 'strong' THEN 10
 WHEN comp.debt_to_equity_analysis = 'bit_risky' THEN 7
 WHEN comp.debt_to_equity_analysis IN ('risky','data_na') THEN 3
 END AS debt_to_equity_score,
 CASE
 WHEN comp.current_ratio_analysis = 'strong' THEN 10
 WHEN comp.current_ratio_analysis = 'bit_risky' THEN 7
 WHEN comp.current_ratio_analysis IN ('risky', 'data_na') THEN 3
 END AS current_ratio_score,
 CASE
 WHEN comp.inventory_analysis = 'strong' THEN 5
 WHEN comp.inventory_analysis = 'bit_risky' THEN 3
 WHEN comp.inventory_analysis IN ('risky','data_na') THEN 1
 WHEN comp.inventory_analysis = 'na' THEN 0
 END AS inventory_score,
 CASE
 WHEN comp.roe_analysis = 'strong' THEN 10
 WHEN comp.roe_analysis = 'good' THEN 8
 WHEN comp.roe_analysis IN ('risky','data_na') THEN 1
 END AS roe_score,
 CASE
 WHEN comp.roic_analysis = 'strong' THEN 5
 WHEN comp.roic_analysis = 'good' THEN 4
 WHEN comp.roic_analysis IN ('risky','data_na') THEN 1
 END AS roic_score,
 CASE
 WHEN comp.pe_ratio_analysis = 'undervalued' THEN 8
 WHEN comp.pe_ratio_analysis = 'considerable' THEN 6
 WHEN comp.pe_ratio_analysis IN ('overvalued','data_na') THEN 3
 END AS pe_ratio_score,
 CASE
 WHEN comp.pb_ratio_analysis = 'undervalued' THEN 8
 WHEN comp.pb_ratio_analysis = 'considerable' THEN 6
 WHEN comp.pb_ratio_analysis IN ('overvalued', 'data_na') THEN 3
 END AS pb_ratio_score,
 CASE
 WHEN comp.pepb_ratio_analysis = 'undervalued' THEN 10
 WHEN comp.pepb_ratio_analysis = 'considerable' THEN 8
 WHEN comp.pepb_ratio_analysis IN ('overvalued','data_na') THEN 3
 END AS pepb_ratio_score,
 CASE
 WHEN comp.pe_and_sector_pe_analysis = 'undervalued_than_sector' THEN 5
 WHEN comp.pe_and_sector_pe_analysis = 'overvalued_than_sector' THEN 3
 END AS pe_vs_sector_pe_score,
 CASE
 WHEN comp.price_to_sales_analysis = 'strong' THEN 5
 WHEN comp.price_to_sales_analysis = 'good' THEN 4
 WHEN comp.price_to_sales_analysis IN ('risky','data_na') THEN 1
 END AS price_to_sales_score,
 CASE
 WHEN comp.price_ocf_analysis = 'undervalued' THEN 8
 WHEN comp.price_ocf_analysis = 'considerable' THEN 6
 WHEN comp.price_ocf_analysis IN ('overvalued', 'data_na') THEN 3
 END AS price_ocf_score,
 CASE
 WHEN comp.ebitda_growth = 'hyper_growth' THEN 10
 WHEN comp.ebitda_growth IN ('very_rapid_growth','rapid_growth') THEN 8
 WHEN comp.ebitda_growth = 'good_growth' THEN 6
 WHEN comp.ebitda_growth IN ('slow_growth','data_na') THEN 3
 END AS ebitda_growth_score,
 CASE
 WHEN comp.netincome_growth = 'hyper_growth' THEN 5
 WHEN comp.netincome_growth IN ('very_rapid_growth','rapid_growth') THEN 3
 WHEN comp.netincome_growth = 'good_growth' THEN 2
 WHEN comp.netincome_growth IN ('slow_growth','data_na') THEN 1
 END AS netincome_growth_score,
 CASE
 WHEN comp.sales_growth = 'hyper_growth' THEN 5
 WHEN comp.sales_growth IN ('very_rapid_growth','rapid_growth') THEN 3
 WHEN comp.sales_growth = 'good_growth' THEN 2
 WHEN comp.sales_growth IN ('slow_growth', 'data_na') THEN 1
 END AS sales_growth_score,
 CASE
 WHEN comp.roe_growth = 'hyper_growth' THEN 10
 WHEN comp.roe_growth IN ('very_rapid_growth', 'rapid_growth') THEN 8
 WHEN comp.roe_growth = 'good_growth' THEN 6
 WHEN comp.roe_growth IN ('slow_growth','data_na') THEN 3
 END AS roe_growth_score,
 CASE
 WHEN comp.shareholder_equity_growth = 'positive' THEN 5
 WHEN comp.shareholder_equity_growth = 'no_change' THEN 3
 WHEN comp.shareholder_equity_growth IN ('negative','data_na') THEN 1
 END AS shareholder_equity_growth_score,
 CASE
 WHEN comp.operating_cash_flow_growth = 'positive' THEN 8
 WHEN comp.operating_cash_flow_growth = 'no_change' THEN 5
 WHEN comp.operating_cash_flow_growth IN ('negative','data_na') THEN 3
 END AS operating_cash_flow_growth_score,
 CASE
 WHEN comp.divident_growth = 'positive' THEN 5
 WHEN comp.divident_growth = 'no_change' THEN 3
 WHEN comp.divident_growth IN ('negative', 'data_na') THEN 1
 END AS divident_growth_score,
 CASE
 WHEN comp.rdexpense_growth = 'positive' THEN 5
 WHEN comp.rdexpense_growth = 'no_change' THEN 3
 WHEN comp.rdexpense_growth IN ('negative','data_na') THEN 1
 END AS rdexpense_growth_score,
 CASE
 WHEN comp.capex_growth_ofc = 'positive' THEN 5
 WHEN comp.capex_growth_ofc = 'no_change' THEN 3
 WHEN comp.capex_growth_ofc IN ('negative','data_na') THEN 1
 END AS capex_growth_ofc_score,
 CASE
 WHEN comp.capex_growth_revenue = 'positive' THEN 5
 WHEN comp.capex_growth_revenue = 'no_change' THEN 3
 WHEN comp.capex_growth_revenue IN ('negative','data_na') THEN 1
 END AS capex_growth_revenue_score,
 CASE
 WHEN comp.is_roic_greater_wacc = 'Y' THEN 10
 WHEN comp.is_roic_greater_wacc = 'N' THEN 5
 ELSE 0
 END AS roic_wacc_score
 FROM mysql_portfolio.company_analysis comp
 INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = comp.symbol
 and symbol_list.exchangeShortName = exchangeName
 ;
 DROP TEMPORARY TABLE IF EXISTS mysql_portfolio.fundamental_score;
 CREATE TEMPORARY TABLE mysql_portfolio.fundamental_score AS
  SELECT distinct param_score.symbol,
  (eps_growth_score+debt_to_equity_score+current_ratio_score+roe_score+roic_score+pe_ratio_score+pb_ratio_score+pepb_ratio_score) as fundamental_score
  FROM mysql_portfolio.param_score
  INNER JOIN mysql_portfolio.symbol_list
  on symbol_list.symbol = param_score.symbol
  and symbol_list.exchangeShortName = exchangeName
;
DROP TEMPORARY TABLE IF EXISTS mysql_portfolio.growth_score;
  CREATE TEMPORARY TABLE mysql_portfolio.growth_score AS
	SELECT distinct param_score.symbol,
    (ebitda_growth_score+netincome_growth_score+sales_growth_score+roe_growth_score+shareholder_equity_growth_score+operating_cash_flow_growth_score
    +divident_growth_score+rdexpense_growth_score+capex_growth_ofc_score+capex_growth_revenue_score) as growth_score
    FROM mysql_portfolio.param_score
    INNER JOIN mysql_portfolio.symbol_list
    on symbol_list.symbol = param_score.symbol
   and symbol_list.exchangeShortName = exchangeName
  ;
  DROP TEMPORARY TABLE IF EXISTS mysql_portfolio.main_param_score;
  CREATE TEMPORARY TABLE mysql_portfolio.main_param_score AS
    SELECT distinct param_score.symbol,
    (eps_growth_score+debt_to_equity_score+current_ratio_score+roe_score+pepb_ratio_score+ebitda_growth_score+sales_growth_score+roe_growth_score+
    roic_wacc_score) AS main_score
    FROM mysql_portfolio.param_score
    INNER JOIN mysql_portfolio.symbol_list
    on symbol_list.symbol = param_score.symbol
   and symbol_list.exchangeShortName = exchangeName
;
DROP TEMPORARY TABLE IF EXISTS mysql_portfolio.total_score;
   CREATE TEMPORARY TABLE mysql_portfolio.total_score AS
     SELECT distinct param.symbol,
     fun.fundamental_score, gr.growth_score, main.main_score as main_param_score,
     (fun.fundamental_score+gr.growth_score+param.inventory_score+param.pe_vs_sector_pe_score+param.price_ocf_score+param.price_to_sales_score
     +param.roic_wacc_score) as total_score
     FROM mysql_portfolio.param_score param
     INNER JOIN mysql_portfolio.symbol_list
     on symbol_list.symbol = param.symbol
     and symbol_list.exchangeShortName = exchangeName
     LEFT JOIN mysql_portfolio.fundamental_score fun ON fun.symbol = param.symbol
     LEFT JOIN mysql_portfolio.growth_score gr ON gr.symbol = param.symbol
     LEFT JOIN mysql_portfolio.main_param_score main ON main.symbol = param.symbol
 ;

DROP TEMPORARY TABLE IF EXISTS mysql_portfolio.all_score;
CREATE TEMPORARY TABLE mysql_portfolio.all_score AS
     SELECT distinct param.symbol,param.calendarYear, fun.fundamental_score,gr.growth_score, main.main_score,total.total_score,
     CASE
     WHEN fun.fundamental_score >=62 THEN 'buy'
     WHEN fun.fundamental_score >=53 AND fun.fundamental_score <62  THEN 'border_level'
     WHEN fun.fundamental_score >=37 AND fun.fundamental_score <53  THEN 'risky'
     ELSE 'weak' END AS fundamental_signal,
     CASE
     WHEN gr.growth_score >=57 THEN 'buy'
     WHEN gr.growth_score >=47 AND gr.growth_score <57  THEN 'border_level'
     WHEN gr.growth_score >=37 AND gr.growth_score <47  THEN 'risky'
     ELSE 'weak' END AS growth_signal,
	 CASE
     WHEN main.main_score >=78 THEN 'buy'
     WHEN main.main_score >=66 AND main.main_score <78  THEN 'border_level'
     WHEN main.main_score >=49 AND main.main_score <66  THEN 'risky'
     ELSE 'weak' END AS main_param_signal,
	 CASE
     WHEN total.total_score >=146 THEN 'buy'
     WHEN gr.growth_score >=121 AND gr.growth_score <146  THEN 'border_level'
     WHEN gr.growth_score >=88 AND gr.growth_score <121  THEN 'risky'
     ELSE 'weak' END AS overall_signal,
     param.roic_wacc_score,param.inventory_score
     -- api_rating.rating as api_rating, api_rating.ratingScore as api_score
     FROM mysql_portfolio.param_score param
     INNER JOIN mysql_portfolio.symbol_list
     on symbol_list.symbol = param.symbol
     and symbol_list.exchangeShortName = exchangeName
     LEFT JOIN mysql_portfolio.fundamental_score fun ON fun.symbol = param.symbol
     LEFT JOIN mysql_portfolio.growth_score gr ON gr.symbol = param.symbol
     LEFT JOIN mysql_portfolio.main_param_score main ON main.symbol = param.symbol
     LEFT JOIN mysql_portfolio.total_score total ON total.symbol = param.symbol
;

create index idx_symbol on mysql_portfolio.all_score(symbol(255));

-- DROP TABLE IF EXISTS mysql_portfolio.company_score;
-- CREATE TABLE mysql_portfolio.company_score AS
INSERT INTO mysql_portfolio.company_score
     SELECT * from mysql_portfolio.all_score;

DROP TEMPORARY TABLE mysql_portfolio.param_score;
DROP TEMPORARY TABLE mysql_portfolio.fundamental_score;
DROP TEMPORARY TABLE mysql_portfolio.growth_score;
DROP TEMPORARY TABLE mysql_portfolio.main_param_score;
DROP TEMPORARY TABLE mysql_portfolio.total_score;
DROP TEMPORARY TABLE mysql_portfolio.all_score;

SELECT COUNT(*), 'records inserted in company_score table' FROM mysql_portfolio.company_score;
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('company_analysis_score_info',exchangeName,now());
END  ;

