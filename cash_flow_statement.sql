SELECT * FROM mysql_portfolio.cash_flow_statement;

USE mysql_portfolio;
DELIMITER //
CREATE PROCEDURE insert_datetime_cash_flow_statement () 
BEGIN
	ALTER TABLE mysql_portfolio.cash_flow_statement
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  insert_datetime_cash_flow_statement();
