-- If we made any changes in the SP first create the SPs again
-- CALL  mysql_portfolio.drop_base_data();
USE mysql_portfolio;
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

