-- If we made any changes in the SP first create the SPs again
-- CALL  mysql_portfolio.drop_base_data();
USE mysql_portfolio;
-- 11
-- INSERTING DATA FOR NYSE
CALL mysql_portfolio.eps_info('NYSE');
SELECT 'procedure eps_info for NYSE ran successfully!';
COMMIT;
-- 4
CALL mysql_portfolio.cagr_info('NYSE');
SELECT 'procedure cagr_info for NYSE ran successfully!';
COMMIT;
-- 5
CALL mysql_portfolio.golden_death_cross_info('NYSE');
SELECT 'procedure golden_death_cross_info for NYSE ran successfully!';
COMMIT;
-- 6
CALL mysql_portfolio.pepb_info('NYSE');
SELECT 'procedure pepb_info for NYSE ran successfully!';
COMMIT;
-- 7
CALL mysql_portfolio.price_cah_flow_info('NYSE');
SELECT 'procedure price_cah_flow_info for NYSE ran successfully!';
COMMIT;
-- 8
CALL mysql_portfolio.decision_view_info('NYSE');
SELECT 'procedure decision_view_info for NYSE ran successfully!';
COMMIT;
-- 9
CALL mysql_portfolio.fundamental_analysis_info('NYSE');
SELECT 'procedure fundamental_analysis_info for NYSE ran successfully!';
COMMIT;

