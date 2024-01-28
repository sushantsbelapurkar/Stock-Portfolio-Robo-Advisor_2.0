-- If we made any changes in the SP first create the SPs again
-- CALL  mysql_portfolio.drop_base_data();
USE mysql_portfolio;
-- 11
CALL mysql_portfolio.value_analysis_info('NYSE');
SELECT 'procedure value_analysis_info for NYSE ran successfully!';
COMMIT;
-- 12
CALL mysql_portfolio.capm_wacc_tmp('NYSE');
SELECT 'procedure capm_wacc_tmp for NYSE ran successfully!';
COMMIT;
-- 10
CALL mysql_portfolio.growth_analysis_info('NYSE');
SELECT 'procedure growth_analysis_info for NYSE ran successfully!';
COMMIT;
-- 13
CALL mysql_portfolio.dcf_info('NYSE');
SELECT 'procedure dcf_info for NYSE ran successfully!';
COMMIT;
-- 14
CALL mysql_portfolio.company_analysis_score_info('NYSE');
SELECT 'procedure company_analysis_score_info for NYSE ran successfully!';
COMMIT;

