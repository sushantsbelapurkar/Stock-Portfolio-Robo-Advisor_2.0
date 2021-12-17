-- drop table mysql_portfolio.symbol_list; 
-- truncate table mysql_portfolio.symbol_list;
-- CREATE table mysql_portfolio.symbol_list
-- ( 
--   id int not null auto_increment, 	
--   symbol_name varchar(250) null,
--   created_at timestamp not null default now(),
--   updated_at timestamp not null default now() on update now(),
--   primary key (id)
--   );
 USE mysql_portfolio;
DELIMITER //
CREATE PROCEDURE insert_datetime_symbols_list () 
BEGIN
 ALTER TABLE mysql_portfolio.symbol_list
 ADD COLUMN created_at timestamp not null default now(), 
 ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  insert_datetime_symbols_list();
 DROP PROCEDURE insert_datetime_symbols_list;
 
 SELECT * FROM mysql_portfolio.symbol_list;
 TRUNCATE mysql_portfolio.symbol_list;
 
 SELECT COUNT(*) FROM mysql_portfolio.symbol_list WHERE exchange = 'NSE' AND type = 'stock'