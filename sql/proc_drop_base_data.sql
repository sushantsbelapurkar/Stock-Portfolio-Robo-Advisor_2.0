CREATE TABLE mysql_portfolio.proc_exec_history
 (
 proc_name varchar(255) not null,
 executed_at timestamp not null
 );

DELIMITER //
CREATE PROCEDURE mysql_portfolio.drop_base_data()
BEGIN
DROP TABLE mysql_portfolio.symbol_list;
DROP TABLE mysql_portfolio.balance_sheet;
DROP TABLE mysql_portfolio.income_statement;
DROP TABLE mysql_portfolio.cash_flow_statement;
DROP TABLE mysql_portfolio.financial_growth;
DROP TABLE mysql_portfolio.financial_ratios;
DROP TABLE mysql_portfolio.key_metrics;
DROP TABLE mysql_portfolio.sector_pe;
DROP TABLE mysql_portfolio.industry_pe;
DROP TABLE mysql_portfolio.stock_screener;
DROP TABLE mysql_portfolio.historical_prices;
DROP TABLE mysql_portfolio.shares_float;
DROP TABLE mysql_portfolio.api_dcf;
DROP TABLE mysql_portfolio.api_rating;
drop table mysql_portfolio.eps_info;
drop table mysql_portfolio.ebitda_info;
drop table mysql_portfolio.netincome_info;
drop table mysql_portfolio.sales_info;
drop table mysql_portfolio.free_cash_flow_info;
drop table mysql_portfolio._50_day_avg_price_info;
drop table mysql_portfolio._200_day_avg_price_info;
drop table mysql_portfolio._5_year_avg_price_info;
DROP TABLE mysql_portfolio.golden_death_cross;
drop table mysql_portfolio.pe_pb_ratio_info;
drop table mysql_portfolio.price_cashflow_info;
DROP VIEW mysql_portfolio.vw_stock_parameter_check;
DROP TABLE mysql_portfolio.fundamental_analysis;
DROP TABLE mysql_portfolio.growth_analysis;
DROP TABLE mysql_portfolio.value_analysis;
drop table mysql_portfolio.rate_of_return_info;
DROP TABLE mysql_portfolio.avg_std_dev;
drop table mysql_portfolio.expected_return;
drop table mysql_portfolio.risk_free_rate;
DROP TABLE mysql_portfolio.cost_of_equity;
DROP TABLE mysql_portfolio.cost_of_debt;
DROP TABLE mysql_portfolio.debt_to_equity_ratio;
DROP TABLE mysql_portfolio.wacc_data;
DROP TABLE mysql_portfolio.gdp_data;
DROP TABLE mysql_portfolio.progressive_free_cashflow;
DROP TABLE mysql_portfolio.dcf_data;
DROP TABLE mysql_portfolio.company_analysis;
DROP TABLE mysql_portfolio.company_score;
DROP TABLE mysql_portfolio.fair_price_analysis;


END //
DELIMITER ;
DROP PROCEDURE mysql_portfolio.drop_base_data;
DROP TABLE mysql_portfolio.proc_exec_history;