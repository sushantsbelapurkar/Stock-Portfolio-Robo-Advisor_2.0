
DROP PROCEDURE IF EXISTS mysql_portfolio.pepb_info;
CREATE PROCEDURE mysql_portfolio.pepb_info(
IN exchangeName varchar(255)
)
BEGIN
-- DROP TABLE IF EXISTS mysql_portfolio.pe_pb_ratio_info;
-- create table mysql_portfolio.pe_pb_ratio_info as
INSERT INTO mysql_portfolio.pe_pb_ratio_info


 -- ###################### Placeholder for sensitive code #############################

SELECT count(*), 'records inserted in pe_pb_ratio_info table' from mysql_portfolio.pe_pb_ratio_info;
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('pepb_info',exchangeName,now());
 END ;
