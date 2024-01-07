DROP PROCEDURE IF EXISTS mysql_portfolio.pepb_info;

CREATE PROCEDURE mysql_portfolio.pepb_info(
IN exchangeName varchar(255)
)
BEGIN
DROP TABLE IF EXISTS mysql_portfolio.pe_pb_ratio_info;
create table mysql_portfolio.pe_pb_ratio_info as
 WITH key_metrics_rownum as
 (
  SELECT km.*,year(km.date) as calendarYear, row_number() over (partition by km.symbol order by year(km.date)) as row_numb
  FROM mysql_portfolio.key_metrics km
  INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = km.symbol
and symbol_list.exchangeShortName = exchangeName
  ),
  key_metrics_max as
  (
  SELECT symbol, max(row_numb) as max_row_numb FROM key_metrics_rownum group by 1
  ),
  key_metrics_maxyr as
  (
  SELECT key_metrics_max.symbol,key_metrics_max.max_row_numb, key_metrics_rownum.bookValuePerShare
  FROM key_metrics_max LEFT JOIN key_metrics_rownum ON key_metrics_rownum.symbol = key_metrics_max.symbol
  WHERE key_metrics_rownum.row_numb = key_metrics_max.max_row_numb
  )
 SELECT
 eps.*,_50day.latest_price_date,_50day.latest_close_price,_50day._50day_avg_price, _200day._200day_avg_price,_5year._5yr_avg_price,
 round(_50day_avg_price/NULLIF(ttm_eps,0),2) as current_pe_ratio,round(_200day_avg_price/NULLIF(ttm_eps,0),2) as _200day_pe_ratio,
 round(_5yr_avg_price/NULLIF(_5yr_avg_eps,0),2) as _5year_pe_ratio,
 round((round(_50day_avg_price/NULLIF(ttm_eps,0),2)+round(_200day_avg_price/NULLIF(ttm_eps,0),2)+round(_5yr_avg_price/NULLIF(_5yr_avg_eps,0),2))/3,2) as final_pe_ratio,
 key_metrics_maxyr.bookValuePerShare,
 round(_50day_avg_price/NULLIF(key_metrics_maxyr.bookValuePerShare,0),2) as pbratio,
 round((_50day_avg_price/NULLIF(key_metrics_maxyr.bookValuePerShare,0))
 *(round((round(_50day_avg_price/NULLIF(ttm_eps,0),2)+round(_200day_avg_price/NULLIF(ttm_eps,0),2)+round(_5yr_avg_price/NULLIF(_5yr_avg_eps,0),2))/3,2)),2) as ratio_pe_into_pb,
 curdate() as created_at
 -- (pe_ratio1+pe_ratio2+pe_ratio3+pe_ratio4)/4 as avg_pe_ratio
 FROM
 mysql_portfolio.eps_info eps
 INNER JOIN mysql_portfolio.symbol_list
 on symbol_list.symbol = eps.symbol
 and symbol_list.exchangeShortName = exchangeName
 LEFT JOIN mysql_portfolio._50_day_avg_price_info _50day
 ON _50day.symbol = eps.symbol
 LEFT JOIN mysql_portfolio._200_day_avg_price_info _200day
 ON _200day.symbol = eps.symbol
 LEFT JOIN mysql_portfolio._5_year_avg_price_info _5year
 ON _5year.symbol = eps.symbol
 LEFT JOIN key_metrics_maxyr
 ON eps.symbol = key_metrics_maxyr.symbol;
 SELECT count(*) from mysql_portfolio.pe_pb_ratio_info;
 END ;
