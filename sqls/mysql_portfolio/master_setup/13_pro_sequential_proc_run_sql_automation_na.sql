-- If we made any changes in the SP first create the SPs again
-- CALL  mysql_portfolio.drop_base_data();
USE mysql_portfolio;
DROP PROCEDURE IF EXISTS exchange_proc_loop;
CREATE PROCEDURE exchange_proc_loop()
BEGIN
    DECLARE counter INT DEFAULT 1;
    DECLARE max_counter INT DEFAULT 3;
    DECLARE value_list VARCHAR(255);
    DECLARE values_array TEXT;

    -- Define your list of string values
    SET value_list = 'NSE,NYSE,NASDAQ';
    SET values_array = REPLACE(value_list, ',', '\n');

    WHILE counter <= max_counter DO
        -- Set the value based on the counter
        SET @value_to_use = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(values_array, '\n', counter), '\n', -1) AS CHAR);

        -- Execute your MySQL code using the value
        -- Replace the following code with your own MySQL statements


-- INSERT INTO mysql_portfolio.proc_exec_history VALUES ('drop_base_data',@value_to_use,now());
-- SELECT * FROM mysql_portfolio.proc_exec_history;
-- 2 Load all python data

-- 3 CALL ALL SPs to create master data
CALL mysql_portfolio.eps_info(@value_to_use);
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('eps_info',@value_to_use,now());
-- 4
CALL mysql_portfolio.cagr_info(@value_to_use);
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('cagr_info',@value_to_use,now());
-- 5
CALL mysql_portfolio.golden_death_cross_info(@value_to_use);
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('golden_death_cross_info',@value_to_use,now());
-- 6
CALL mysql_portfolio.pepb_info(@value_to_use);
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('pepb_info',@value_to_use,now());
-- 7
CALL mysql_portfolio.price_cah_flow_info(@value_to_use);
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('price_cah_flow_info',@value_to_use,now());
-- 8
-- Change exchange name in the procedure itself.
CALL mysql_portfolio.decision_view_info();
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('decision_view_info',@value_to_use,now());
-- 9
CALL mysql_portfolio.fundamental_analysis_info(@value_to_use);
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('fundamental_analysis_info',@value_to_use,now());

-- 11
CALL mysql_portfolio.value_analysis_info(@value_to_use);
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('value_analysis_info',@value_to_use,now());
-- 12
CALL mysql_portfolio.capm_wacc_tmp(@value_to_use);
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('capm_wacc_tmp',@value_to_use,now());
-- 10
CALL mysql_portfolio.growth_analysis_info(@value_to_use);
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('growth_analysis_info',@value_to_use,now());
-- 13
CALL mysql_portfolio.dcf_info(@value_to_use);
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('dcf_info',@value_to_use,now());
-- 14
CALL mysql_portfolio.company_analysis_score_info(@value_to_use);
INSERT INTO mysql_portfolio.proc_exec_history VALUES ('company_analysis_score_info',@value_to_use,now());

        SET counter = counter + 1;
    END WHILE;
END  ;

CALL exchange_proc_loop();
