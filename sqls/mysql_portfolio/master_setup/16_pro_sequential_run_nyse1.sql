-- If we made any changes in the SP first create the SPs again
-- CALL  mysql_portfolio.drop_base_data();
USE mysql_portfolio;
-- 11
-- INSERTING DATA FOR NYSE
CALL mysql_portfolio.eps_info('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('eps_info','NYSE',now());
SELECT 'procedure eps_info for NYSE ran successfully!';
-- 4
CALL mysql_portfolio.cagr_info('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('cagr_info','NYSE',now());
SELECT 'procedure cagr_info for NYSE ran successfully!';
-- 5
CALL mysql_portfolio.golden_death_cross_info('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('golden_death_cross_info','NYSE',now());
SELECT 'procedure golden_death_cross_info for NYSE ran successfully!';
-- 6
CALL mysql_portfolio.pepb_info('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('pepb_info','NYSE',now());
SELECT 'procedure pepb_info for NYSE ran successfully!';
-- 7
CALL mysql_portfolio.price_cah_flow_info('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('price_cah_flow_info','NYSE',now());
SELECT 'procedure price_cah_flow_info for NYSE ran successfully!';
-- 8
CALL mysql_portfolio.decision_view_info('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('decision_view_info','NYSE',now());
SELECT 'procedure decision_view_info for NYSE ran successfully!';
-- 9
CALL mysql_portfolio.fundamental_analysis_info('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('fundamental_analysis_info','NYSE',now());
SELECT 'procedure fundamental_analysis_info for NYSE ran successfully!';

