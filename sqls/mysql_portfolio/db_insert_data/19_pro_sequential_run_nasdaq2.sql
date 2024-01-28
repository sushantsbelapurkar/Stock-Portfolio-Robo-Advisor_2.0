-- If we made any changes in the SP first create the SPs again
-- CALL  mysql_portfolio.drop_base_data();
USE mysql_portfolio;

--    SET value_list = 'NSE,NYSE,NASDAQ';
-- 11
CALL mysql_portfolio.value_analysis_info('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('value_analysis_info','NASDAQ',now());
SELECT 'procedure value_analysis_info for NASDAQ ran successfully!';
COMMIT;
-- 12
CALL mysql_portfolio.capm_wacc_tmp('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('capm_wacc_tmp','NASDAQ',now());
SELECT 'procedure capm_wacc_tmp for NASDAQ ran successfully!';
COMMIT;
-- 10
CALL mysql_portfolio.growth_analysis_info('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('growth_analysis_info','NASDAQ',now());
SELECT 'procedure growth_analysis_info for NASDAQ ran successfully!';
COMMIT;
-- 13
CALL mysql_portfolio.dcf_info('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('dcf_info','NASDAQ',now());
SELECT 'procedure dcf_info for NASDAQ ran successfully!';
COMMIT;
-- 14
CALL mysql_portfolio.company_analysis_score_info('NASDAQ');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('company_analysis_score_info','NASDAQ',now());
SELECT 'procedure company_analysis_score_info for NASDAQ ran successfully!';
COMMIT;
