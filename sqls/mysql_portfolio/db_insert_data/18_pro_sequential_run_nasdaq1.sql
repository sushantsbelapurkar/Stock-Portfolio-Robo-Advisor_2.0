-- If we made any changes in the SP first create the SPs again
-- CALL  mysql_portfolio.drop_base_data();
USE mysql_portfolio;

-- INSERTING DATA FOR NASDAQ
CALL mysql_portfolio.eps_info('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('eps_info','NASDAQ',now());
SELECT 'procedure eps_info for NASDAQ ran successfully!';
-- 4
CALL mysql_portfolio.cagr_info('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('cagr_info','NASDAQ',now());
SELECT 'procedure cagr_info for NASDAQ ran successfully!';
-- 5
CALL mysql_portfolio.golden_death_cross_info('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('golden_death_cross_info','NASDAQ',now());
SELECT 'procedure golden_death_cross_info for NASDAQ ran successfully!';
COMMIT;
-- 6
CALL mysql_portfolio.pepb_info('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('pepb_info','NASDAQ',now());
SELECT 'procedure pepb_info for NASDAQ ran successfully!';
COMMIT;
-- 7
CALL mysql_portfolio.price_cah_flow_info('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('price_cah_flow_info','NASDAQ',now());
SELECT 'procedure price_cah_flow_info for NASDAQ ran successfully!';
COMMIT;
-- 8
-- Change exchange name in the procedure itself.
CALL mysql_portfolio.decision_view_info('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('decision_view_info','NASDAQ',now());
SELECT 'procedure decision_view_info for NASDAQ ran successfully!';
COMMIT;
-- 9
CALL mysql_portfolio.fundamental_analysis_info('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('fundamental_analysis_info','NASDAQ',now());
SELECT 'procedure fundamental_analysis_info for NASDAQ ran successfully!';
COMMIT;

