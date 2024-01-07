DROP PROCEDURE IF EXISTS mysql_portfolio.capm_wacc_info;
DELIMITER //
 CREATE PROCEDURE mysql_portfolio.capm_wacc_tmp(
 IN exchangeName varchar(20))
 BEGIN

     DECLARE i INT;
     DECLARE curr_yr varchar(20);
     SET  i=5,curr_yr = year(curdate());

     create TEMPORARY table tmp_rate_of_return
   (
     hp_symbol varchar(20),
     hp_year varchar(20),
     hp_date date,
     hp_close float,
     hp_ror float,
     hp_row_numb bigint,
     hp_created_at date
   );

     WHILE i > 0 DO

       SET curr_yr = curr_yr - 1;
		insert into tmp_rate_of_return
       SELECT hp.symbol,year(hp.date) as year, hp.date,hp.close,
       -- LAST_VALUE(close) over(partition by symbol,year(date) order by date),
      -- FIRST_VALUE(close) over(partition by symbol,year(date) order by date),
       (LAST_VALUE(hp.close) over(partition by hp.symbol,year(hp.date) order by hp.date)- FIRST_VALUE(hp.close) over(partition by hp.symbol,year(hp.date) order by hp.date))
       /(FIRST_VALUE(hp.close) over(partition by hp.symbol,year(hp.date) order by hp.date))*100 as ror,
       row_number() over (partition by hp.symbol,year(hp.date)) as row_numb,curdate() as created_at
        FROM mysql_portfolio.historical_prices hp
        INNER JOIN mysql_portfolio.symbol_list
        on symbol_list.symbol = hp.symbol
        and symbol_list.exchangeShortName = exchangeName
        WHERE hp.close !=0 AND hp.close is not NULL
        AND year(hp.date) = curr_yr;
      SET i = i-1;
     END WHILE;

      SET  i=5,curr_yr = year(curdate());

      create TEMPORARY table tmp_rate_of_return1
   (
     symbol varchar(20),
     year varchar(20),
     latest_date date,
     rate_of_return float,
     row_numb bigint,
     rank_ bigint
   );

      WHILE i > 0 DO

       SET curr_yr = curr_yr - 1;
       insert into tmp_rate_of_return1
       SELECT tror.hp_symbol,tror.hp_year as year,tror.hp_date as latest_date,
       round(tror.hp_ror,2) as rate_of_return,tror.hp_row_numb as row_numb,
       rank() over(partition by tror.hp_symbol, tror.hp_year order by tror.hp_row_numb desc) as rank_
       FROM tmp_rate_of_return tror
	   INNER JOIN mysql_portfolio.symbol_list
	   on symbol_list.symbol = tror.hp_symbol
	   and symbol_list.exchangeShortName = exchangeName
       WHERE tror.hp_year = curr_yr;
        SET i = i-1;
     END WHILE;

   DROP TABLE IF EXISTS mysql_portfolio.rate_of_return_info;
   CREATE TABLE mysql_portfolio.rate_of_return_info as
     SELECT tror1.symbol,tror1.year,tror1.latest_date,tror1.rate_of_return
     FROM mysql_portfolio.tmp_rate_of_return1 tror1
     INNER JOIN mysql_portfolio.symbol_list
	on symbol_list.symbol = tror1.symbol
	and symbol_list.exchangeShortName = exchangeName
     WHERE tror1.rank_ = 1;

DROP TABLE IF EXISTS mysql_portfolio.avg_std_dev;
CREATE TABLE mysql_portfolio.avg_std_dev AS
 WITH avg_stdev AS
 (
 SELECT rori.*,
 round(avg(rori.rate_of_return) over(partition by rori.symbol),2) as avg_return,
 round(stddev(rori.rate_of_return) over(partition by rori.symbol),2) as std_dev
 FROM mysql_portfolio.rate_of_return_info rori
 INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = rori.symbol
 AND symbol_list.exchangeShortName = exchangeName
 ),
 yr_count as
 (
 SELECT distinct symbol,count(year) as count_of_years_considered  FROM avg_stdev group by 1
 )
 SELECT DISTINCT avg_stdev.symbol,MAX(avg_stdev.latest_date) over(partition by symbol)as latest_price_date,avg_stdev.avg_return,
 avg_stdev.std_dev as volatility,
 yr_count.count_of_years_considered
 FROM avg_stdev
 LEFT JOIN yr_count
 ON yr_count.symbol = avg_stdev.symbol
 INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = avg_stdev.symbol
 AND symbol_list.exchangeShortName = exchangeName;

 DROP TABLE IF EXISTS mysql_portfolio.expected_return;
 CREATE table mysql_portfolio.expected_return AS
 WITH expected_parameters AS
 (
 SELECT avg_std_dev.symbol,avg_std_dev.latest_price_date,
 round(avg_return,2) as true_avg_return,volatility as std_dev,
 CASE
 WHEN volatility <= 25.00 THEN 0.6
 WHEN (volatility > 25.00 AND volatility<=50) THEN 0.4
 WHEN volatility > 50 THEN 0.2 END AS probability_true,
 CASE
 WHEN volatility <= 25.00 THEN 0.2
 WHEN (volatility > 25.00 AND volatility<=50) THEN 0.3
 WHEN volatility > 50 THEN 0.4 END AS probability_positive,
 CASE
 WHEN volatility <= 25.00 THEN 0.2
 WHEN (volatility > 25.00 AND volatility<=50) THEN 0.3
 WHEN volatility > 50 THEN 0.4 END AS probability_negative
 FROM mysql_portfolio.avg_std_dev
 INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = avg_std_dev.symbol
 AND symbol_list.exchangeShortName = exchangeName
 )
 SELECT *,
 round((probability_true*round(true_avg_return,2))+(probability_positive*round(true_avg_return+true_avg_return*0.10,2))
 +(probability_negative*round(true_avg_return+true_avg_return*-0.15,2)),2) AS expected_rate_of_return
 FROM expected_parameters
 ;

DROP TABLE IF EXISTS mysql_portfolio.risk_free_rate;
 CREATE TABLE mysql_portfolio.risk_free_rate
 (
  latest_date date,
  t_bill_rate float(4,2),
  exchange_name varchar(255)
  );
--  SELECT * FROM mysql_portfolio.risk_free_rate;
--  LOAD XML LOCAL INFILE '/Users/sushantbelapurkar/downloads/SUSHANT/XmlView.xml'
-- INTO TABLE mysql_portfolio.risk_free_rate(latest_date, t_bill_rate);
-- SHOW GLOBAL VARIABLES LIKE 'local_infile';
-- SET GLOBAL local_infile = true;
 INSERT INTO mysql_portfolio.risk_free_rate (latest_date, t_bill_rate,exchange_name)values ('2022-12-31',3.5,'NYSE');
 INSERT INTO mysql_portfolio.risk_free_rate (latest_date, t_bill_rate,exchange_name)values ('2022-12-31',3.5,'NASDAQ');
 INSERT INTO mysql_portfolio.risk_free_rate (latest_date, t_bill_rate,exchange_name)values ('2022-12-31',7.4,'NSE');
 -- SELECT * FROM mysql_portfolio.risk_free_rate;

 -- SELECT DISTINCT rate.symbol,rate.expected_rate_of_return,rate.risk_free_rate,
--  (rate.expected_rate_of_return-rate.risk_free_rate) as equity_risk_premium,stock_screener.beta,
--  round((rate.risk_free_rate + (rate.expected_rate_of_return-rate.risk_free_rate)*stock_screener.beta),2) as cost_of_equity
--  FROM(
--  SELECT symbol,expected_rate_of_return,
--  (SELECT t_bill_rate FROM mysql_portfolio.risk_free_rate WHERE latest_date = (SELECT MAX(latest_date) FROM mysql_portfolio.risk_free_rate))
--  as risk_free_rate FROM mysql_portfolio.expected_rate_of_return
--  )rate
--  LEFT JOIN mysql_portfolio.stock_screener ON
--  rate.symbol = stock_screener.symbol;

 -- ABOVE SAME QUERY CAN BE WRITTEN/SIMPLIFIED AS

DROP TABLE IF EXISTS mysql_portfolio.cost_of_equity;
 CREATE TABLE mysql_portfolio.cost_of_equity AS
 (
 WITH rate as
 (
 SELECT symbol,expected_rate_of_return,
 (SELECT t_bill_rate FROM mysql_portfolio.risk_free_rate WHERE latest_date =
 (SELECT MAX(latest_date) FROM mysql_portfolio.risk_free_rate WHERE exchange_name = exchangeName)
 AND exchange_name = exchangeName)
 as risk_free_rate

 FROM mysql_portfolio.expected_return
 )
 SELECT DISTINCT rate.symbol,rate.expected_rate_of_return,rate.risk_free_rate,
 (rate.expected_rate_of_return-rate.risk_free_rate) as equity_risk_premium,stock_screener.beta,
 round((rate.risk_free_rate + (rate.expected_rate_of_return-rate.risk_free_rate)*stock_screener.beta),2) as cost_of_equity
 FROM rate
 INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = rate.symbol
 and symbol_list.exchangeShortName = exchangeName
 LEFT JOIN mysql_portfolio.stock_screener ON
 rate.symbol = stock_screener.symbol
 );

-- SELECT * FROM mysql_portfolio.cost_of_equity;

DROP TABLE IF EXISTS mysql_portfolio.cost_of_debt;
CREATE TABLE mysql_portfolio.cost_of_debt AS
WITH balance_sheet_row_num AS
(
 SELECT balance_sheet.*,row_number() over (partition by balance_sheet.symbol order by balance_sheet.calendarYear) as row_numb
 FROM mysql_portfolio.balance_sheet
 INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = balance_sheet.symbol
 and symbol_list.exchangeShortName = exchangeName
 ),
balance_sheet_max as
  (
  SELECT symbol, max(row_numb) as max_row_numb FROM balance_sheet_row_num group by 1
  ),
balance_sheet_maxyr AS
(
 SELECT balance_sheet_row_num.symbol,balance_sheet_row_num.netDebt
 FROM balance_sheet_max LEFT JOIN balance_sheet_row_num
 ON balance_sheet_max.symbol = balance_sheet_row_num.symbol
 AND balance_sheet_row_num.row_numb = balance_sheet_max.max_row_numb
 ),
 income_statement_row_num AS
(
 SELECT income_statement.*,row_number() over (partition by income_statement.symbol order by income_statement.calendarYear) as row_numb
 FROM mysql_portfolio.income_statement
 INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = income_statement.symbol
 and symbol_list.exchangeShortName = exchangeName
 ),
income_statement_max as
  (
  SELECT symbol, max(row_numb) as max_row_numb
  FROM income_statement_row_num
  group by 1
  ),
income_statement_maxyr AS
(
 SELECT income_statement_row_num.symbol,income_statement_row_num.date,income_statement_row_num.interestExpense,
 income_statement_row_num.ebitda,income_statement_row_num.depreciationAndAmortization,income_statement_row_num.incomeTaxExpense
 FROM income_statement_max LEFT JOIN income_statement_row_num
 ON income_statement_max.symbol = income_statement_row_num.symbol
 AND income_statement_row_num.row_numb = income_statement_max.max_row_numb
 ),
 cost_of_debt_temp AS
(
 SELECT income_statement.symbol,income_statement.date,
 (income_statement.interestExpense/NULLIF(balance_sheet.netDebt,0)) as cost_of_debt,
(income_statement.ebitda - income_statement.depreciationAndAmortization) as ebit,
(income_statement.incomeTaxExpense/NULLIF((income_statement.ebitda - income_statement.depreciationAndAmortization),0)) as effective_tax_rate
FROM income_statement_maxyr income_statement
INNER JOIN mysql_portfolio.symbol_list
on symbol_list.symbol = income_statement.symbol
and symbol_list.exchangeShortName = exchangeName
LEFT JOIN balance_sheet_maxyr balance_sheet
ON income_statement.symbol = balance_sheet.symbol
)
SELECT symbol,date, ebit,effective_tax_rate,round((cost_of_debt * (1- effective_tax_rate))*100,2) as after_tax_cost_of_debt
FROM cost_of_debt_temp;

-- SELECT * FROM mysql_portfolio.cost_of_debt;


 DROP TABLE IF EXISTS mysql_portfolio.debt_to_equity_ratio;
CREATE TABLE mysql_portfolio.debt_to_equity_ratio AS
WITH balance_sheet_row_num AS
(
 SELECT balance_sheet.*,row_number() over (partition by balance_sheet.symbol order by balance_sheet.calendarYear) as row_numb
 FROM mysql_portfolio.balance_sheet
 INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = balance_sheet.symbol
and symbol_list.exchangeShortName = exchangeName
 ),
balance_sheet_max as
  (
  SELECT symbol, max(row_numb) as max_row_numb FROM balance_sheet_row_num group by 1
  ),
balance_sheet_maxyr AS
(
 SELECT balance_sheet_row_num.symbol,balance_sheet_row_num.date,balance_sheet_row_num.shortTermDebt,balance_sheet_row_num.longTermDebt,
 balance_sheet_row_num.totalStockholdersEquity,balance_sheet_row_num.totalAssets,balance_sheet_row_num.totalLiabilities
 FROM balance_sheet_max LEFT JOIN balance_sheet_row_num
 ON balance_sheet_max.symbol = balance_sheet_row_num.symbol
 AND balance_sheet_row_num.row_numb = balance_sheet_max.max_row_numb
 ),
-- debt_to_equity AS
-- (
-- SELECT symbol,date,((shortTermDebt+longTermDebt)/NULLIF((shortTermDebt+longTermDebt+totalStockholdersEquity),0)) as debt_to_capitalization,
-- ((totalAssets - totalLiabilities)/NULLIF((longTermDebt + totalStockholdersEquity),0)) as equity_to_capitalization
-- FROM balance_sheet_maxyr
-- )
debt_to_equity AS
(
SELECT symbol,date,((shortTermDebt+longTermDebt)/(shortTermDebt+longTermDebt+totalStockholdersEquity)) as debt_to_capitalization,
((totalAssets - totalLiabilities)/(longTermDebt + totalStockholdersEquity)) as equity_to_capitalization
FROM balance_sheet_maxyr
)
SELECT symbol,date,debt_to_capitalization,equity_to_capitalization,
round((debt_to_capitalization/equity_to_capitalization),2) as debt_to_equity_ratio
FROM debt_to_equity;

-- SELECT * FROM mysql_portfolio.debt_to_equity_ratio;

DROP TABLE IF EXISTS mysql_portfolio.wacc_data;
CREATE TABLE mysql_portfolio.wacc_data AS
SELECT debt_to_equity_ratio.symbol,debt_to_equity_ratio.date,debt_to_equity_ratio.debt_to_capitalization, debt_to_equity_ratio.equity_to_capitalization,
cost_of_equity.cost_of_equity,cost_of_debt.after_tax_cost_of_debt,
round((cost_of_equity.cost_of_equity*debt_to_equity_ratio.equity_to_capitalization) +
(cost_of_debt.after_tax_cost_of_debt*debt_to_equity_ratio.debt_to_capitalization),2)
as wacc
FROM mysql_portfolio.debt_to_equity_ratio
INNER JOIN mysql_portfolio.symbol_list
on symbol_list.symbol = debt_to_equity_ratio.symbol
and symbol_list.exchangeShortName = exchangeName
LEFT JOIN mysql_portfolio.cost_of_equity
ON cost_of_equity.symbol = debt_to_equity_ratio.symbol
LEFT JOIN mysql_portfolio.cost_of_debt
ON cost_of_debt.symbol = debt_to_equity_ratio.symbol
;
SELECT COUNT(*) FROM mysql_portfolio.wacc_data;

   END //
   DELIMITER ;