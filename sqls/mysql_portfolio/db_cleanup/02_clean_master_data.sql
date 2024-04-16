DROP PROCEDURE IF EXISTS mysql_portfolio.clean_master_data;
CREATE PROCEDURE mysql_portfolio.clean_master_data()
BEGIN
-- -------------------- CALCULATION/FACT TABLES ----------------------------------
TRUNCATE TABLE mysql_portfolio.eps_info;
TRUNCATE TABLE mysql_portfolio.ebitda_info;
TRUNCATE TABLE mysql_portfolio.netincome_info;
TRUNCATE TABLE mysql_portfolio.sales_info;
TRUNCATE TABLE mysql_portfolio.free_cash_flow_info;
TRUNCATE TABLE mysql_portfolio._50_day_avg_price_info;
TRUNCATE TABLE mysql_portfolio._200_day_avg_price_info;
TRUNCATE TABLE mysql_portfolio._5_year_avg_price_info;
TRUNCATE TABLE mysql_portfolio.golden_death_cross;
TRUNCATE TABLE mysql_portfolio.pe_pb_ratio_info;
TRUNCATE TABLE mysql_portfolio.price_cashflow_info;
TRUNCATE TABLE mysql_portfolio.vw_stock_parameter_check;
TRUNCATE TABLE mysql_portfolio.fundamental_analysis;
TRUNCATE TABLE mysql_portfolio.growth_analysis;
TRUNCATE TABLE mysql_portfolio.value_analysis;
TRUNCATE TABLE mysql_portfolio.rate_of_return_info;
TRUNCATE TABLE mysql_portfolio.avg_std_dev;
TRUNCATE TABLE mysql_portfolio.expected_return;
TRUNCATE TABLE mysql_portfolio.risk_free_rate;
TRUNCATE TABLE mysql_portfolio.cost_of_equity;
TRUNCATE TABLE mysql_portfolio.cost_of_debt;
TRUNCATE TABLE mysql_portfolio.debt_to_equity_ratio;
TRUNCATE TABLE mysql_portfolio.wacc_data;
TRUNCATE TABLE mysql_portfolio.gdp_data;
TRUNCATE TABLE mysql_portfolio.progressive_free_cashflow;
TRUNCATE TABLE mysql_portfolio.dcf_data;
TRUNCATE TABLE mysql_portfolio.company_analysis;
TRUNCATE TABLE mysql_portfolio.company_score;

INSERT INTO mysql_portfolio.risk_free_rate (latest_date, t_bill_rate,exchange_name)values ('2022-12-31',5.3,'NYSE');
INSERT INTO mysql_portfolio.risk_free_rate (latest_date, t_bill_rate,exchange_name)values ('2022-12-31',5.3,'NASDAQ');
INSERT INTO mysql_portfolio.risk_free_rate (latest_date, t_bill_rate,exchange_name)values ('2022-12-31',7.4,'NSE');
INSERT INTO mysql_portfolio.risk_free_rate (latest_date, t_bill_rate,exchange_name)values ('2022-12-31',7.4,'BSE');

INSERT INTO mysql_portfolio.gdp_data VALUES ('USA', 2023, 1.5);
INSERT INTO mysql_portfolio.gdp_data VALUES ('India', 2021, 5.5);

INSERT INTO mysql_portfolio.proc_exec_history VALUES ('all base tables truncated','all exchanges',now());
SELECT 'sp_drop_master_tables_cleanup_completed';
END;
