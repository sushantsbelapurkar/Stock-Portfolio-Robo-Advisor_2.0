 DROP PROCEDURE IF EXISTS mysql_portfolio.value_analysis_info;

  CREATE PROCEDURE mysql_portfolio.value_analysis_info()
  BEGIN
   DROP TABLE IF EXISTS mysql_portfolio.value_analysis;
   CREATE TABLE mysql_portfolio.value_analysis AS
   SELECT symbol,latest_price_date, latest_close_price,_50day_avg_price,_200day_avg_price,_5yr_avg_price,final_pe_ratio,live_peratio,
   pbratio,live_pbratio,ratio_pe_into_pb,price_fcf_ratio,price_ocf_ratio,priceToSalesRatio,
   CASE
   WHEN final_pe_ratio <=15 THEN 'undervalued'
   WHEN (final_pe_ratio >15 AND final_pe_ratio <= 25) THEN 'considerable'
   WHEN final_pe_ratio >25  THEN 'overvalued'
   WHEN final_pe_ratio IS NULL THEN 'data_na' END as pe_ratio_analysis,
   CASE
   WHEN final_pe_ratio < sector_pe_ratio THEN 'undervalued_than_sector'
   WHEN final_pe_ratio >= sector_pe_ratio THEN 'overvalued_than_sector' END as pe_and_sector_pe_analysis,
   CASE
   WHEN pbratio <=1.5 THEN 'undervalued'
   WHEN (pbratio >1.5 AND pbratio <= 3) THEN 'considerable'
   WHEN pbratio >3  THEN 'overvalued'
   WHEN pbratio IS NULL THEN 'data_na' END as pb_ratio_analysis,
   CASE
   WHEN ratio_pe_into_pb <=22.5 THEN 'undervalued'
   WHEN (ratio_pe_into_pb > 22.5 AND ratio_pe_into_pb <=40) THEN 'considerable'
   WHEN ratio_pe_into_pb > 40 THEN 'overvalued'
   WHEN ratio_pe_into_pb IS NULL THEN 'data_na' END AS pepb_ratio_analysis,
   CASE
   WHEN priceToSalesRatio < 1 THEN 'strong'
   WHEN (priceToSalesRatio >=1 AND priceToSalesRatio < 3.75)  THEN 'good'
   WHEN priceToSalesRatio > 3.75 THEN 'risky'
   WHEN priceToSalesRatio is null THEN 'data_na'END as price_to_sales_analysis,
   CASE
   WHEN price_ocf_ratio <=10 THEN 'undervalued'
   WHEN (price_ocf_ratio > 10 AND price_ocf_ratio <=15) THEN 'considerable'
   WHEN price_ocf_ratio > 15 THEN 'overvalued'
   WHEN price_ocf_ratio IS NULL THEN 'data_na' END AS price_ocf_analysis,
   CURDATE() as created_at
   FROM mysql_portfolio.vw_stock_parameter_check;

   END ;

