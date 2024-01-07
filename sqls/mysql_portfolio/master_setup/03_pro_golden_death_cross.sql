DROP PROCEDURE IF EXISTS mysql_portfolio.golden_death_cross_info;
CREATE PROCEDURE mysql_portfolio.golden_death_cross_info(
IN exchangeName varchar(255)
)
BEGIN
-- -------------------------------- 50 DAY AVG/MOVING AVG ----------------------------
DROP TABLE IF EXISTS mysql_portfolio._50_day_avg_price_info;
create table mysql_portfolio._50_day_avg_price_info as
 WITH fifty_days AS
 (
 SELECT hp.symbol,hp.date,hp.close,
round(avg(hp.close) over(partition by hp.symbol order by date rows between unbounded preceding and unbounded following),2) as avg_price,
row_number() over (partition by hp.symbol order by hp.date) as row_numb, curdate() as created_at
  FROM mysql_portfolio.historical_prices hp
  INNER JOIN mysql_portfolio.symbol_list
  on symbol_list.symbol = hp.symbol
 and symbol_list.exchangeShortName = exchangeName

 WHERE hp.date >= (DATE_SUB((SELECT MAX(date)FROM mysql_portfolio.historical_prices), INTERVAL 70 DAY)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 -- AND symbol IN ('AAPL','MSFT') order by 1,2 desc
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM fifty_days GROUP BY 1
 )
  SELECT fifty_days.symbol, fifty_days.date as latest_price_date, fifty_days.close as latest_close_price, fifty_days.avg_price as _50day_avg_price,
  max_row_numb as days_considered, curdate() as created_at
  FROM fifty_days
  LEFT JOIN max_row ON max_row.symbol = fifty_days.symbol
  WHERE fifty_days.row_numb = max_row.max_row_numb
 -- WE TOOK approx 70 calendar days in DATE_SUB() AS 70 calendar days = 50 working days
;
 -- SELECT * FROM mysql_portfolio._50_day_avg_price_info;

 -- -------------------------------- 200 DAY AVG/MOVING AVG ------------------------------------
 DROP TABLE IF EXISTS mysql_portfolio._200_day_avg_price_info;
 create table mysql_portfolio._200_day_avg_price_info as
 WITH twohundred_days AS
 (
 SELECT hp.symbol,hp.date,hp.close,
round(avg(hp.close) over(partition by hp.symbol order by date rows between unbounded preceding and unbounded following),2) as avg_price,
row_number() over (partition by hp.symbol order by hp.date) as row_numb, curdate() as created_at
  FROM mysql_portfolio.historical_prices hp
  INNER JOIN mysql_portfolio.symbol_list
  on symbol_list.symbol = hp.symbol
 and symbol_list.exchangeShortName = exchangeName
 WHERE hp.date >= (DATE_SUB((SELECT MAX(date)FROM mysql_portfolio.historical_prices), INTERVAL 300 DAY)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 -- AND symbol IN ('AAPL','MSFT') order by 1,2 desc
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM twohundred_days GROUP BY 1
 )
  SELECT twohundred_days.symbol, twohundred_days.date as latest_price_date, twohundred_days.close as latest_close_price, twohundred_days.avg_price as _200day_avg_price,
  max_row_numb as days_considered, curdate() as created_at
  FROM twohundred_days
  LEFT JOIN max_row ON max_row.symbol = twohundred_days.symbol
  WHERE twohundred_days.row_numb = max_row.max_row_numb
  ;
 -- WE TOOK approx 300 calendar days in DATE_SUB() AS 300 calendar days = 200 working days
 -- SELECT * FROM mysql_portfolio._200_day_avg_price_info;

 -- -------------------------------- 5 YEAR AVG ------------------------------------
DROP TABLE IF EXISTS mysql_portfolio._5_year_avg_price_info;
 create table mysql_portfolio._5_year_avg_price_info as
 WITH five_yr_days AS
 (
 SELECT hp.symbol,hp.date,hp.close,
round(avg(hp.close) over(partition by hp.symbol order by date rows between unbounded preceding and unbounded following),2) as avg_price,
row_number() over (partition by hp.symbol order by hp.date) as row_numb, curdate() as created_at
  FROM mysql_portfolio.historical_prices hp
  INNER JOIN mysql_portfolio.symbol_list
  on symbol_list.symbol = hp.symbol
 and symbol_list.exchangeShortName = exchangeName
 WHERE hp.date >= (DATE_SUB((SELECT MAX(date)FROM mysql_portfolio.historical_prices), INTERVAL 1827 DAY)) -- in redshift we use dateadd() function to do the same; mysql also have date_add() for future dates
 -- AND symbol IN ('AAPL','MSFT') order by 1,2 desc
 ),
 max_row as
 (
  SELECT symbol, max(row_numb) as max_row_numb FROM five_yr_days GROUP BY 1
 )
  SELECT five_yr_days.symbol, five_yr_days.date as latest_price_date,five_yr_days.close as latest_close_price, five_yr_days.avg_price as _5yr_avg_price,
  max_row_numb as days_considered, curdate() as created_at
  FROM five_yr_days
  LEFT JOIN max_row ON max_row.symbol = five_yr_days.symbol
  WHERE five_yr_days.row_numb = max_row.max_row_numb
  ;
 -- WE TOOK approx 1827 calendar days in DATE_SUB() AS 300 calendar days = 1238 working days/5 working years
--  SELECT * FROM mysql_portfolio._5_year_avg_price_info;

 -- ---------------------GOLDEN/DEATH CROSS ANALYSIS ------------------------------------
DROP TABLE IF EXISTS mysql_portfolio.golden_death_cross;
 CREATE TABLE mysql_portfolio.golden_death_cross AS
 WITH _50_200_days AS
 (
SELECT _50day.symbol, _50day.latest_price_date,_50day.days_considered as days_consider_50,_50day._50day_avg_price,
_200day.days_considered as days_consider_200,_200day._200day_avg_price,
round(_200day._200day_avg_price-(_200day._200day_avg_price*0.1),2) as _10percentDownOf_200day,
round(_200day._200day_avg_price+(_200day._200day_avg_price*0.1),2) as _10percentUpOf_200day
FROM mysql_portfolio._200_day_avg_price_info _200day
LEFT JOIN mysql_portfolio._50_day_avg_price_info _50day
ON _50day.symbol = _200day.symbol
WHERE _200day._200day_avg_price != 0 AND _200day._200day_avg_price IS NOT NULL
)
SELECT _50_200_days.*,
CASE
WHEN (_50day_avg_price BETWEEN _10percentDownOf_200day AND _10percentUpOf_200day) THEN 'Y' ELSE 'N' END AS near_to_golden_death_cross,
round((_200day_avg_price - _50day_avg_price),2) as price_difference,
round(100-((_50day_avg_price*100)/NULLIF(_200day_avg_price,0)),2) as percent_diff_in_50_200_price,
'Check trading volume' as note, curdate() as created_at
FROM _50_200_days
WHERE _200day_avg_price !=0 AND _200day_avg_price IS NOT NULL
;
-- SELECT * FROM mysql_portfolio.golden_death_cross;
SELECT count(*) from mysql_portfolio.golden_death_cross;
END  ;

