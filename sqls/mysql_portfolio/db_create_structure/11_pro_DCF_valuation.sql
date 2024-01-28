DROP PROCEDURE IF EXISTS mysql_portfolio.dcf_info;

CREATE PROCEDURE mysql_portfolio.dcf_info(
IN exchangeName varchar(255)
)
BEGIN
-- DROP TABLE IF EXISTS mysql_portfolio.gdp_data;
-- CREATE TABLE mysql_portfolio.gdp_data


-- ------///////////////METHOD 2 --> MOSTLY USED SIMPLE FREE CASHFLOW METHOD --> USING NOW
-- SOURCE = https://www.youtube.com/watch?v=fd_emLLzJnk&t=645s
-- CONSIDERING PERPETUALL GROWTH RATE = 3.2% OR 0.032 : source: https://macabacus.com/valuation/dcf/terminal-value
-- DROP TABLE IF EXISTS mysql_portfolio.progressive_free_cashflow;
-- CREATE TABLE mysql_portfolio.progressive_free_cashflow as
INSERT INTO mysql_portfolio.progressive_free_cashflow
SELECT
    terminal.*,
    wacc_data.wacc,
    CASE
        WHEN NULLIF((wacc_data.wacc / 100.00 - 0.032), 0) IS NULL THEN NULL
        ELSE ROUND(((yr5_prog_fcf * (1 + 0.032)) / NULLIF((wacc_data.wacc / 100.00 - 0.032), 0)), 2)
    END AS terminal_value
FROM (
    SELECT
        *,
        ROUND((yr4_prog_fcf * (1 + (fcf_cagr / 100))), 2) AS yr5_prog_fcf
    FROM (
        SELECT
            *,
            ROUND((yr3_prog_fcf * (1 + (fcf_cagr / 100))), 2) AS yr4_prog_fcf
        FROM (
            SELECT
                *,
                ROUND((yr2_prog_fcf * (1 + (fcf_cagr / 100))), 2) AS yr3_prog_fcf
            FROM (
                SELECT
                    *,
                    ROUND((yr1_prog_fcf * (1 + (fcf_cagr / 100))), 2) AS yr2_prog_fcf
                FROM (
                    SELECT DISTINCT
                        cash_flow_statement.symbol,
                        stock_screener.exchangeShortName,
                        YEAR(cash_flow_statement.date) AS calendarYear,
                        cash_flow_statement.freeCashFlow AS current_fcf,
                        free_cash_flow_info.fcf_cagr,
                        ROUND(cash_flow_statement.freeCashFlow * (1 + (free_cash_flow_info.fcf_cagr / 100.00)), 2) AS yr1_prog_fcf
                    FROM
                        mysql_portfolio.symbol_list
                        INNER JOIN mysql_portfolio.free_cash_flow_info
                            ON symbol_list.symbol = free_cash_flow_info.symbol
                               AND symbol_list.exchangeShortName = exchangeName
                        LEFT JOIN mysql_portfolio.cash_flow_statement
                            ON free_cash_flow_info.symbol = cash_flow_statement.symbol
                               AND free_cash_flow_info.calendarYear = cash_flow_statement.calendarYear
                        LEFT JOIN mysql_portfolio.stock_screener
                            ON stock_screener.symbol = cash_flow_statement.symbol
                    -- WHERE cash_flow_statement.date) = (SELECT MAX(year(date)) FROM mysql_portfolio.cash_flow_statement)
                ) a
            ) b
        ) c
    ) d
) terminal
LEFT JOIN mysql_portfolio.wacc_data
    ON wacc_data.symbol = terminal.symbol
 ;

-- AND year(wacc_data.date) = (SELECT MAX(year(wacc_data.date)) FROM mysql_portfolio.wacc_data)

-- SELECT * FROM mysql_portfolio.progressive_free_cashflow;

-- DROP TABLE IF EXISTS mysql_portfolio.dcf_data;
-- CREATE TABLE mysql_portfolio.dcf_data as
INSERT INTO mysql_portfolio.dcf_data
SELECT
    dcf.*,
    shares_float.outstandingShares,
    CASE
        WHEN NULLIF(shares_float.outstandingShares, 0) IS NULL THEN NULL  -- Handle division by zero
        ELSE (todays_value / NULLIF(shares_float.outstandingShares, 0))
    END AS dcf_fair_value
FROM (
    SELECT
        *,
        (pv_fcf_yr1 + pv_fcf_yr2 + pv_fcf_yr3 + pv_fcf_yr4 + pv_fcf_yr5 + pv_fcf_terminal_value) AS todays_value
    FROM (
        SELECT
            *,
            yr1_prog_fcf / POWER((1 + wacc / 100), 1) AS pv_fcf_yr1,
            yr2_prog_fcf / POWER((1 + wacc / 100), 2) AS pv_fcf_yr2,
            yr3_prog_fcf / POWER((1 + wacc / 100), 3) AS pv_fcf_yr3,
            yr4_prog_fcf / POWER((1 + wacc / 100), 2) AS pv_fcf_yr4,
            yr5_prog_fcf / POWER((1 + wacc / 100), 2) AS pv_fcf_yr5,
            terminal_value / POWER((1 + wacc / 100), 5) AS pv_fcf_terminal_value
        FROM mysql_portfolio.progressive_free_cashflow
        -- WHERE mysql_portfolio.progressive_free_cashflow.calendarYear = (SELECT MAX(calendarYear) FROM mysql_portfolio.progressive_free_cashflow)
    ) pv
) dcf
LEFT JOIN mysql_portfolio.shares_float
ON shares_float.symbol = dcf.symbol
;

-- AND year(shares_float.date) = (SELECT MAX(year(shares_float.date)) FROM mysql_portfolio.shares_float)


SELECT COUNT(*), 'records inserted in wacc_data table' FROM mysql_portfolio.dcf_data;
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('dcf_info',exchangeName,now());
END ;


