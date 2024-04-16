DROP PROCEDURE IF EXISTS mysql_portfolio.decision_view_info;

CREATE PROCEDURE mysql_portfolio.decision_view_info(
IN exchangeName varchar(255)
)
BEGIN
-- DROP VIEW view_name;
CREATE VIEW mysql_portfolio.vw_stock_parameter_check AS
SELECT DISTINCT
    screener.companyName,screener.exchangeShortName,screener.industry,screener.sector,sector.pe as sector_pe_ratio,
    screener.marketCap,
    CASE
    WHEN

-- ###################### Placeholder for sensitive code #############################

FROM mysql_portfolio.stock_screener screener
    INNER JOIN mysql_portfolio.symbol_list
	on symbol_list.symbol = screener.symbol
	-- and symbol_list.exchangeShortName = exchange_name()
    and symbol_list.exchangeShortName = exchangeName
    LEFT JOIN mysql_portfolio.pe_pb_ratio_info pepb
    ON pepb.symbol = screener.symbol
    LEFT JOIN mysql_portfolio.ebitda_info ebitda
    ON screener.symbol = ebitda.symbol
    LEFT JOIN mysql_portfolio.netincome_info netincome
	ON screener.symbol = netincome.symbol
	LEFT JOIN mysql_portfolio.sales_info sales
	ON screener.symbol = sales.symbol
    LEFT JOIN mysql_portfolio.price_cashflow_info pcashflow
    ON pcashflow.symbol = screener.symbol
    LEFT JOIN key_metrics_maxyr keymetrics
    ON screener.symbol = keymetrics.symbol
    LEFT JOIN mysql_portfolio.sector_pe sector
    ON sector.sector = screener.sector
    AND sector.exchange = screener.exchangeShortName
    WHERE screener.isEtf = 0
    AND pepb.symbol is not null order by symbol
    ;

    SELECT count(*), 'records inserted in vw_stock_parameter_check table' from mysql_portfolio.vw_stock_parameter_check;
    INSERT INTO mysql_portfolio.proc_exec_history VALUES ('decision_view_info',exchangeName,now());
    END  ;

