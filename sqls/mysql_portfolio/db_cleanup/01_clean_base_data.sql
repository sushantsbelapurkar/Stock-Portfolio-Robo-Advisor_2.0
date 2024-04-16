DELIMITER //

CREATE OR REPLACE PROCEDURE mysql_portfolio.drop_base_data()
BEGIN
-- ----------------------- CLEAN API DATA TABLES --------------------------
DROP TABLE IF EXISTS mysql_portfolio.symbol_list; -- dimension table
DROP TABLE IF EXISTS mysql_portfolio.balance_sheet;
DROP TABLE IF EXISTS mysql_portfolio.income_statement;
DROP TABLE IF EXISTS mysql_portfolio.cash_flow_statement;
DROP TABLE IF EXISTS mysql_portfolio.financial_growth;
DROP TABLE IF EXISTS mysql_portfolio.financial_ratios;
DROP TABLE IF EXISTS mysql_portfolio.key_metrics; -- dimension table
DROP TABLE IF EXISTS mysql_portfolio.sector_pe;
DROP TABLE IF EXISTS mysql_portfolio.industry_pe;
DROP TABLE IF EXISTS mysql_portfolio.stock_screener; -- dimension table
DROP TABLE IF EXISTS mysql_portfolio.historical_prices;
DROP TABLE IF EXISTS mysql_portfolio.shares_float;
DROP TABLE IF EXISTS mysql_portfolio.api_dcf;
DROP TABLE IF EXISTS mysql_portfolio.api_rating;

SELECT 'sp_drop_base_tables_cleanup_completed';
END //
DELIMITER ;
--DROP PROCEDURE mysql_portfolio.drop_base_data;
--DROP TABLE mysql_portfolio.proc_exec_history;
--DROP TABLE mysql_portfolio.api_rating;
--CALL mysql_portfolio.drop_base_data();
