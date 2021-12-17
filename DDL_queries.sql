-- drop table mysql_portfolio.symbol_list; 
-- truncate table mysql_portfolio.symbol_list;
-- CREATE table mysql_portfolio.symbol_list
-- ( 
--   id int not nulincome_statementl auto_increment, 	
--   symbol_name varchar(250) null,
--   created_at timestamp not null default now(),
--   updated_at timestamp not null default now() on update now(),
--   primary key (id)
--   );

/* INITIAL QUERIES TO RUN AFTER LOADING ALL THE DATA IN DB */
USE mysql_portfolio;

DELIMITER //
CREATE PROCEDURE mysql_portfolio.insert_datetime_symbols_list () 
BEGIN
 ALTER TABLE mysql_portfolio.symbol_list
 ADD COLUMN created_at timestamp not null default now(), 
 ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  mysql_portfolio.insert_datetime_symbols_list();
 -- DROP PROCEDURE insert_datetime_symbols_list;

DELIMITER //

CREATE PROCEDURE mysql_portfolio.insert_datetime_historical_prices () 
BEGIN
	ALTER TABLE mysql_portfolio.historical_prices
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  mysql_portfolio.insert_datetime_historical_prices();
 
 DELIMITER //
CREATE PROCEDURE mysql_portfolio.insert_datetime_industry_pe () 
BEGIN
	ALTER TABLE mysql_portfolio.industry_pe
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  mysql_portfolio.insert_datetime_industry_pe();
 
 -- DROP TABLE mysql_portfolio.stock_screener;
 DELIMITER //
CREATE PROCEDURE mysql_portfolio.insert_datetime_stock_screener () 
BEGIN
	ALTER TABLE mysql_portfolio.stock_screener
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  mysql_portfolio.insert_datetime_stock_screener();
 
 DELIMITER //
CREATE PROCEDURE mysql_portfolio.insert_datetime_key_metrics () 
BEGIN
	ALTER TABLE mysql_portfolio.key_metrics
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  mysql_portfolio.insert_datetime_key_metrics();
 
 DELIMITER //
CREATE PROCEDURE mysql_portfolio.insert_datetime_financial_ratios () 
BEGIN
	ALTER TABLE mysql_portfolio.financial_ratios
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  mysql_portfolio.insert_datetime_financial_ratios();
 
 DELIMITER //
CREATE PROCEDURE mysql_portfolio.insert_datetime_balance_sheet () 
BEGIN
	ALTER TABLE mysql_portfolio.balance_sheet
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  mysql_portfolio.insert_datetime_balance_sheet();

DELIMITER //
CREATE PROCEDURE mysql_portfolio.insert_datetime_cash_flow_statement () 
BEGIN
	ALTER TABLE mysql_portfolio.cash_flow_statement
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  mysql_portfolio.insert_datetime_cash_flow_statement();
 
 DELIMITER //
CREATE PROCEDURE mysql_portfolio.insert_datetime_income_statemnent () 
BEGIN
	ALTER TABLE mysql_portfolio.income_statement
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  mysql_portfolio.insert_datetime_income_statemnent();

DELIMITER //
CREATE PROCEDURE mysql_portfolio.insert_datetime_financial_growth () 
BEGIN
	ALTER TABLE mysql_portfolio.financial_growth
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  mysql_portfolio.insert_datetime_financial_growth();


DELIMITER //
CREATE PROCEDURE mysql_portfolio.insert_datetime_sector_pe () 
BEGIN
	ALTER TABLE mysql_portfolio.sector_pe
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  mysql_portfolio.insert_datetime_sector_pe();

