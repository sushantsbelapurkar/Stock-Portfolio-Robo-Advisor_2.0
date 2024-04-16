
DROP PROCEDURE IF EXISTS mysql_portfolio.capm_wacc_tmp;

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
       /NULLIF(FIRST_VALUE(hp.close) OVER (PARTITION BY hp.symbol, YEAR(hp.date) ORDER BY hp.date), 0)*100 as ror,
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

   -- ###################### Placeholder for sensitive code #############################