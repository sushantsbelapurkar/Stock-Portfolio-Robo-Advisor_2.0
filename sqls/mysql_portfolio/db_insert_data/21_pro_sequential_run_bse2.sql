USE mysql_portfolio;

-- 11
CALL mysql_portfolio.value_analysis_info('BSE');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('value_analysis_info','BSE',now());
SELECT 'procedure value_analysis_info for BSE ran successfully!';
COMMIT;
-- 12
CALL mysql_portfolio.capm_wacc_tmp('BSE');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('capm_wacc_tmp','BSE',now());
SELECT 'procedure capm_wacc_tmp for BSE ran successfully!';
COMMIT;
-- 10
CALL mysql_portfolio.growth_analysis_info('BSE');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('growth_analysis_info','BSE',now());
SELECT 'procedure growth_analysis_info for BSE ran successfully!';
COMMIT;
-- 13
CALL mysql_portfolio.dcf_info('BSE');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('dcf_info','BSE',now());
SELECT 'procedure dcf_info for BSE ran successfully!';
COMMIT;
-- 14
CALL mysql_portfolio.company_analysis_score_info('BSE');
-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('company_analysis_score_info','BSE',now());
SELECT 'procedure company_analysis_score_info for BSE ran successfully!';
COMMIT;
