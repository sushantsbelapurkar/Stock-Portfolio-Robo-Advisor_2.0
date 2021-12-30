-- METHOD 1 --> unlevered free cash flow  --> NOT USING CURRENTLY
SELECT
income_statement.symbol,income_statement.date,cost_of_debt.ebit,cost_of_debt.effective_tax_rate,income_statement.depreciationAndAmortization,
cash_flow_statement.capitalExpenditure,(balance_sheet.totalCurrentAssets-balance_sheet.totalCurrentLiabilities)as workingCapital,
(cost_of_debt.ebit*(1- effective_tax_rate)+income_statement.depreciationAndAmortization+
cash_flow_statement.capitalExpenditure-(balance_sheet.totalCurrentAssets-balance_sheet.totalCurrentLiabilities))
as free_cash_flow
FROM mysql_portfolio.income_statement
LEFT JOIN mysql_portfolio.cash_flow_statement
ON cash_flow_statement.symbol = income_statement.symbol
AND year(cash_flow_statement.date) = (SELECT MAX(year(date)) FROM mysql_portfolio.cash_flow_statement)
LEFT JOIN mysql_portfolio.cost_of_debt
ON cost_of_debt.symbol = income_statement.symbol
AND year(cost_of_debt.date) = (SELECT MAX(year(date)) FROM mysql_portfolio.cost_of_debt)
LEFT JOIN mysql_portfolio.balance_sheet
ON balance_sheet.symbol = income_statement.symbol
AND year(balance_sheet.date) =  (SELECT MAX(year(date)) FROM mysql_portfolio.key_metrics)
WHERE year(income_statement.date) = (SELECT MAX(year(date)) FROM mysql_portfolio.income_statement)
;

DROP TABLE mysql_portfolio.gdp_data;
 CREATE TABLE mysql_portfolio.gdp_data
 (
   country varchar(20),
   year int,
   gdp float(4,2)
 );

 INSERT INTO mysql_portfolio.gdp_data VALUES ('USA', 2021, 2.4);
 INSERT INTO mysql_portfolio.gdp_data VALUES ('India', 2021, 5.4);
 SELECT * FROM mysql_portfolio.gdp_data;

-- METHOD 2 --> MOSTLY USED SIMPLE FREE CASHFLOW METHOD --> USING NOW
-- SOURCE = https://www.youtube.com/watch?v=fd_emLLzJnk&t=645s
-- CONSIDERING PERPETUALL GROWTH RATE = 3.2% OR 0.032 : source: https://macabacus.com/valuation/dcf/terminal-value
DROP TABLE mysql_portfolio.progressive_free_cashflow;
CREATE TABLE mysql_portfolio.progressive_free_cashflow as
SELECT terminal.*,wacc_data.wacc,
-- CASE
-- WHEN exchangeShortName = 'NASDAQ'
-- THEN
-- ROUND((yr5_prog_fcf*(1+(SELECT (gdp/100.00) FROM mysql_portfolio.gdp_data where country = 'USA')))/
-- ((wacc_data.wacc/100.00) - (SELECT (gdp/100.00) FROM mysql_portfolio.gdp_data where country = 'USA')),2)
-- WHEN exchangeShortName = 'NYSE'
-- THEN
-- ROUND((yr5_prog_fcf*(1+(SELECT (gdp/100.00) FROM mysql_portfolio.gdp_data where country = 'USA')))/
-- ((wacc_data.wacc/100.00) - (SELECT (gdp/100.00) FROM mysql_portfolio.gdp_data where country = 'USA')),2)
-- WHEN exchangeShortName = 'NSE'
-- THEN
-- ROUND((yr5_prog_fcf*(1+(SELECT (gdp/100.00) FROM mysql_portfolio.gdp_data where country = 'India')))/
-- ((wacc_data.wacc/100.00) - (SELECT (gdp/100.00) FROM mysql_portfolio.gdp_data where country = 'India')),2)
-- END
--  as terminal_value
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
FROM mysql_portfolio.free_cash_flow_info
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
SELECT * FROM mysql_portfolio.progressive_free_cashflow;

DROP TABLE mysql_portfolio.dcf_data;
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
SELECT * FROM mysql_portfolio.dcf_data
;

