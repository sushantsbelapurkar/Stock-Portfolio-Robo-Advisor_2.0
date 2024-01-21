USE mysql_portfolio;

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
