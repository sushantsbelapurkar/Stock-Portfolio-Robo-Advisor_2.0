-- If we made any changes in the SP first create the SPs again
-- CALL  mysql_portfolio.drop_base_data();
USE mysql_portfolio;
DROP PROCEDURE IF EXISTS exchange_proc_loop;
CREATE PROCEDURE exchange_proc_loop()
--    SET value_list = 'NSE,NYSE,NASDAQ';
-- INSERTING DATA FOR NSE
-- SET message = 'NYSE exchange data insertion begins';
-- SELECT message;
CALL mysql_portfolio.eps_info('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('eps_info','NSE',now());
SELECT 'procedure eps_info for NSE ran successfully!';
-- 4
CALL mysql_portfolio.cagr_info('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('cagr_info','NSE',now());
SELECT 'procedure cagr_info for NSE ran successfully!';
-- 5
CALL mysql_portfolio.golden_death_cross_info('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('golden_death_cross_info','NSE',now());
SELECT 'procedure golden_death_cross_info for NSE ran successfully!';
-- 6
CALL mysql_portfolio.pepb_info('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('pepb_info','NSE',now());
SELECT 'procedure pepb_info for NSE ran successfully!';
-- 7
CALL mysql_portfolio.price_cah_flow_info('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('price_cah_flow_info','NSE',now());
SELECT 'procedure price_cah_flow_info for NSE ran successfully!';
-- 8
CALL mysql_portfolio.decision_view_info('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('decision_view_info','NSE',now());
SELECT 'procedure decision_view_info for NSE ran successfully!';
-- 9
CALL mysql_portfolio.fundamental_analysis_info('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('fundamental_analysis_info','NSE',now());
SELECT 'procedure fundamental_analysis_info for NSE ran successfully!';
-- 11
CALL mysql_portfolio.value_analysis_info('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('value_analysis_info','NSE',now());
SELECT 'procedure value_analysis_info for NSE ran successfully!';
-- 12
CALL mysql_portfolio.capm_wacc_tmp('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('capm_wacc_tmp','NSE',now());
SELECT 'procedure capm_wacc_tmp for NSE ran successfully!';
-- 10
CALL mysql_portfolio.growth_analysis_info('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('growth_analysis_info','NSE',now());
SELECT 'procedure growth_analysis_info for NSE ran successfully!';
-- 13
CALL mysql_portfolio.dcf_info('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('dcf_info','NSE',now());
SELECT 'procedure dcf_info for NSE ran successfully!';
-- 14
CALL mysql_portfolio.company_analysis_score_info('NSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('company_analysis_score_info','NSE',now());
SELECT 'procedure company_analysis_score_info for NSE ran successfully!';
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
-- 11
CALL mysql_portfolio.value_analysis_info('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('value_analysis_info','NYSE',now());
SELECT 'procedure value_analysis_info for NYSE ran successfully!';
-- 12
CALL mysql_portfolio.capm_wacc_tmp('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('capm_wacc_tmp','NYSE',now());
SELECT 'procedure capm_wacc_tmp for NYSE ran successfully!';
-- 10
CALL mysql_portfolio.growth_analysis_info('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('growth_analysis_info','NYSE',now());
SELECT 'procedure growth_analysis_info for NYSE ran successfully!';
-- 13
CALL mysql_portfolio.dcf_info('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('dcf_info','NYSE',now());
SELECT 'procedure dcf_info for NYSE ran successfully!';
-- 14
CALL mysql_portfolio.company_analysis_score_info('NYSE');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('company_analysis_score_info','NYSE',now());
SELECT 'procedure company_analysis_score_info for NYSE ran successfully!';
-- INSERTING DATA FOR NASDAQ
CALL mysql_portfolio.eps_info('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('eps_info','NASDAQ',now());
SELECT 'procedure eps_info for NASDAQ ran successfully!';
-- 4
CALL mysql_portfolio.cagr_info('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('cagr_info','NASDAQ',now());
SELECT 'procedure cagr_info for NASDAQ ran successfully!';
-- 5
CALL mysql_portfolio.golden_death_cross_info('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('golden_death_cross_info','NASDAQ',now());
SELECT 'procedure golden_death_cross_info for NASDAQ ran successfully!';
-- 6
CALL mysql_portfolio.pepb_info('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('pepb_info','NASDAQ',now());
SELECT 'procedure pepb_info for NASDAQ ran successfully!';
-- 7
CALL mysql_portfolio.price_cah_flow_info('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('price_cah_flow_info','NASDAQ',now());
SELECT 'procedure price_cah_flow_info for NASDAQ ran successfully!';
-- 8
CALL mysql_portfolio.decision_view_info('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('decision_view_info','NASDAQ',now());
SELECT 'procedure decision_view_info for NASDAQ ran successfully!';
-- 9
CALL mysql_portfolio.fundamental_analysis_info('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('fundamental_analysis_info','NASDAQ',now());
SELECT 'procedure fundamental_analysis_info for NASDAQ ran successfully!';
-- 11
CALL mysql_portfolio.value_analysis_info('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('value_analysis_info','NASDAQ',now());
SELECT 'procedure value_analysis_info for NASDAQ ran successfully!';
-- 12
CALL mysql_portfolio.capm_wacc_tmp('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('capm_wacc_tmp','NASDAQ',now());
SELECT 'procedure capm_wacc_tmp for NASDAQ ran successfully!';
-- 10
CALL mysql_portfolio.growth_analysis_info('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('growth_analysis_info','NASDAQ',now());
SELECT 'procedure growth_analysis_info for NASDAQ ran successfully!';
-- 13
CALL mysql_portfolio.dcf_info('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('dcf_info','NASDAQ',now());
SELECT 'procedure dcf_info for NASDAQ ran successfully!';
-- 14
CALL mysql_portfolio.company_analysis_score_info('NASDAQ');
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('company_analysis_score_info','NASDAQ',now());
SELECT 'procedure company_analysis_score_info for NASDAQ ran successfully!';
END  ;
CALL exchange_proc_loop();
