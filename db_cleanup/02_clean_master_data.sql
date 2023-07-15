DELIMITER //
CREATE OR REPLACE PROCEDURE mysql_portfolio.drop_master_data()
BEGIN

-- -------------------- CALCULATION TABLES ----------------------------------
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

SELECT 'sp_drop_master_tables_cleanup_completed';
END //
DELIMITER ;