-- If we made any changes in the SP first create the SPs again
-- CALL  mysql_portfolio.drop_base_data();
USE mysql_portfolio;

CALL mysql_portfolio.eps_info('NSE');
SELECT 'procedure eps_info for NSE ran successfully!';
COMMIT;
-- 4
CALL mysql_portfolio.cagr_info('NSE');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('cagr_info','NSE',now());
SELECT 'procedure cagr_info for NSE ran successfully!';
COMMIT;
-- 5
CALL mysql_portfolio.golden_death_cross_info('NSE');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('golden_death_cross_info','NSE',now());
SELECT 'procedure golden_death_cross_info for NSE ran successfully!';
COMMIT;
-- 6
CALL mysql_portfolio.pepb_info('NSE');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('pepb_info','NSE',now());
SELECT 'procedure pepb_info for NSE ran successfully!';
COMMIT;
-- 7
CALL mysql_portfolio.price_cah_flow_info('NSE');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('price_cah_flow_info','NSE',now());
SELECT 'procedure price_cah_flow_info for NSE ran successfully!';
COMMIT;
-- 8
-- Change exchange name in the procedure itself.
CALL mysql_portfolio.decision_view_info('NSE');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('decision_view_info','NSE',now());
SELECT 'procedure decision_view_info for NSE ran successfully!';
COMMIT;
-- 9
CALL mysql_portfolio.fundamental_analysis_info('NSE');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('fundamental_analysis_info','NSE',now());
SELECT 'procedure fundamental_analysis_info for NSE ran successfully!';
COMMIT;