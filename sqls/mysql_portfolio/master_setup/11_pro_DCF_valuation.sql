DROP PROCEDURE IF EXISTS mysql_portfolio.dcf_info;

CREATE PROCEDURE mysql_portfolio.dcf_info(
IN exchangeName varchar(255)
)
BEGIN
 DROP TABLE IF EXISTS mysql_portfolio.gdp_data;
 CREATE TABLE mysql_portfolio.gdp_data
 (
   country varchar(20),
   year int,
   gdp float(4,2)
 );

 INSERT INTO mysql_portfolio.gdp_data VALUES ('USA', 2023, 1.5);
 INSERT INTO mysql_portfolio.gdp_data VALUES ('India', 2021, 5.5);


-- ------///////////////METHOD 2 --> MOSTLY USED SIMPLE FREE CASHFLOW METHOD --> USING NOW
-- SOURCE = https://www.youtube.com/watch?v=fd_emLLzJnk&t=645s
-- CONSIDERING PERPETUALL GROWTH RATE = 3.2% OR 0.032 : source: https://macabacus.com/valuation/dcf/terminal-value
 DROP TABLE IF EXISTS mysql_portfolio.progressive_free_cashflow;
CREATE TABLE mysql_portfolio.progressive_free_cashflow as
SELECT terminal.*,wacc_data.wacc,
ROUND (((yr5_prog_fcf*(1+0.032))/
((wacc_data.wacc/100.00) - 0.032)),2) AS terminal_value FROM
(
SELECT *, round((yr4_prog_fcf*(1+(fcf_cagr/100))),2) as yr5_prog_fcf FROM (
SELECT *, round((yr3_prog_fcf*(1+(fcf_cagr/100))),2) as yr4_prog_fcf FROM (
SELECT *, round((yr2_prog_fcf*(1+(fcf_cagr/100))),2) as yr3_prog_fcf FROM (
SELECT *, round((yr1_prog_fcf*(1+(fcf_cagr/100))),2) as yr2_prog_fcf FROM (
SELECT DISTINCT cash_flow_statement.symbol,stock_screener.exchangeShortName,
year(cash_flow_statement.date) as calendarYear,cash_flow_statement.freeCashFlow as current_fcf,free_cash_flow_info.fcf_cagr,
round(cash_flow_statement.freeCashFlow*(1+(free_cash_flow_info.fcf_cagr/100.00)),2) as yr1_prog_fcf
FROM  mysql_portfolio.symbol_list
INNER JOIN mysql_portfolio.free_cash_flow_info
ON symbol_list.symbol = free_cash_flow_info.symbol
AND symbol_list.exchangeShortName = exchangeName
LEFT JOIN mysql_portfolio.cash_flow_statement
ON free_cash_flow_info.symbol = cash_flow_statement.symbol
AND free_cash_flow_info.calendarYear =  cash_flow_statement.calendarYear
LEFT JOIN mysql_portfolio.stock_screener
ON stock_screener.symbol = cash_flow_statement.symbol

-- WHERE cash_flow_statement.date) = (SELECT MAX(year(date)) FROM mysql_portfolio.cash_flow_statement)
)a)b)c)d
)terminal
LEFT JOIN mysql_portfolio.wacc_data
ON wacc_data.symbol = terminal.symbol
-- AND year(wacc_data.date) = (SELECT MAX(year(wacc_data.date)) FROM mysql_portfolio.wacc_data)
;
-- SELECT * FROM mysql_portfolio.progressive_free_cashflow;

DROP TABLE IF EXISTS mysql_portfolio.dcf_data;
CREATE TABLE mysql_portfolio.dcf_data as
SELECT dcf.*,shares_float.outstandingShares, (todays_value/shares_float.outstandingShares) as dcf_fair_value FROM
(
SELECT *, (pv_fcf_yr1+pv_fcf_yr2+pv_fcf_yr3+pv_fcf_yr4+pv_fcf_yr5+pv_fcf_terminal_value) AS todays_value FROM
(
SELECT *,yr1_prog_fcf/power((1+wacc/100),1) as pv_fcf_yr1, yr2_prog_fcf/power((1+wacc/100),2)  as pv_fcf_yr2,
yr3_prog_fcf/power((1+wacc/100),3)  as pv_fcf_yr3,yr4_prog_fcf/power((1+wacc/100),2)  as pv_fcf_yr4,
yr5_prog_fcf/power((1+wacc/100),2)  as pv_fcf_yr5,
terminal_value/power((1+wacc/100),5)  as pv_fcf_terminal_value
FROM mysql_portfolio.progressive_free_cashflow
-- WHERE mysql_portfolio.progressive_free_cashflow.calendarYear = (SELECT MAX(calendarYear) FROM mysql_portfolio.progressive_free_cashflow)
)pv
)dcf
LEFT JOIN mysql_portfolio.shares_float
ON  shares_float.symbol = dcf.symbol
-- AND year(shares_float.date) = (SELECT MAX(year(shares_float.date)) FROM mysql_portfolio.shares_float)
;

SELECT COUNT(*) FROM mysql_portfolio.dcf_data;
END ;




