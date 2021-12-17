SELECT * FROM mysql_portfolio.financial_growth;
TRUNCATE TABLE mysql_portfolio.financial_growth;

USE mysql_portfolio;
DELIMITER //
CREATE PROCEDURE insert_datetime_financial_growth () 
BEGIN
	ALTER TABLE mysql_portfolio.financial_growth
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  insert_datetime_financial_growth();
 DROP PROCEDURE insert_datetime_income_statemnent;
 
 DROP TABLE mysql_portfolio.financial_growth;