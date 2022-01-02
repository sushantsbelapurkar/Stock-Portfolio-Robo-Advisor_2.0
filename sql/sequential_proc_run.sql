-- 1
CALL  mysql_portfolio.drop_base_data();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('drop_base_data',now());

-- 2 Load all python data

-- 3
CALL mysql_portfolio.eps_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('eps_info',now());
-- 4
CALL mysql_portfolio.cagr_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('cagr_info',now());
-- 5
CALL mysql_portfolio.golden_death_cross_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('golden_death_cross_info',now());
-- 6
CALL mysql_portfolio.pepb_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('pepb_info',now());
-- 7
CALL mysql_portfolio.price_cah_flow_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('price_cah_flow_info',now());
-- 8
CALL mysql_portfolio.decision_view_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('decision_view_info',now());
-- 9
CALL mysql_portfolio.fundamental_analysis_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('fundamental_analysis_info',now());
-- 10
CALL mysql_portfolio.growth_analysis_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('growth_analysis_info',now());
-- 11
CALL mysql_portfolio.value_analysis_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('value_analysis_info',now());
-- 12
CALL mysql_portfolio.capm_wacc_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('capm_wacc_info',now());
-- 13
CALL mysql_portfolio.dcf_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('dcf_info',now());
-- 14
CALL mysql_portfolio.company_analysis_score_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('company_analysis_score_info',now());
