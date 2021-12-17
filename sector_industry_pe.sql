SELECT * FROM mysql_portfolio.sector_industry_pe;

USE mysql_portfolio;
DELIMITER //
CREATE PROCEDURE insert_datetime_sector_industry_pe () 
BEGIN
	ALTER TABLE mysql_portfolio.sector_industry_pe
	DROP COLUMN id,
    ADD COLUMN id bigint not null auto_increment primary key FIRST,
    ADD COLUMN created_at timestamp not null default now(),
	ADD COLUMN updated_at timestamp not null default now() on update now();
END //
 DELIMITER ;
 
 CALL  insert_datetime_sector_industry_pe();
