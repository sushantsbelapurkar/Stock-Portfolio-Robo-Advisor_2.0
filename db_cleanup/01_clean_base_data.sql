DELIMITER //
CREATE OR REPLACE PROCEDURE mysql_portfolio.drop_base_data()
BEGIN
-- ----------------------- API DATA TABLES --------------------------
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

SELECT 'sp_drop_base_tables_cleanup_completed';
END //
DELIMITER ;
--DROP PROCEDURE mysql_portfolio.drop_base_data;
--DROP TABLE mysql_portfolio.proc_exec_history;
--DROP TABLE mysql_portfolio.api_rating;
--CALL mysql_portfolio.drop_base_data();
