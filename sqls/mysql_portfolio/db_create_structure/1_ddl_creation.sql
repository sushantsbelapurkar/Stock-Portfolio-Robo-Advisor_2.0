USE mysql_portfolio;
DROP TABLE IF EXISTS _200_day_avg_price_info;
CREATE TABLE `_200_day_avg_price_info` (
  `symbol` text,
  `latest_price_date` text,
  `latest_close_price` double DEFAULT NULL,
  `_200day_avg_price` double DEFAULT NULL,
  `days_considered` bigint unsigned DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE (symbol(255), latest_close_price, latest_price_date(255))
);

DROP TABLE IF EXISTS _50_day_avg_price_info;
CREATE TABLE `_50_day_avg_price_info` (
  `symbol` text,
  `latest_price_date` text,
  `latest_close_price` double DEFAULT NULL,
  `_50day_avg_price` double DEFAULT NULL,
  `days_considered` bigint unsigned DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE (symbol(255), latest_close_price, latest_price_date(255))
);

DROP TABLE IF EXISTS _5_year_avg_price_info;
CREATE TABLE `_5_year_avg_price_info` (
  `symbol` text,
  `latest_price_date` text,
  `latest_close_price` double DEFAULT NULL,
  `_5yr_avg_price` double DEFAULT NULL,
  `days_considered` bigint unsigned DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE (symbol(255), latest_close_price, latest_price_date(255))
);

DROP TABLE IF EXISTS avg_std_dev;
CREATE TABLE `avg_std_dev` (
  `symbol` varchar(20) DEFAULT NULL,
  `latest_price_date` date DEFAULT NULL,
  `avg_return` double DEFAULT NULL,
  `volatility` double DEFAULT NULL,
  `count_of_years_considered` bigint DEFAULT '0',
  INDEX idx_symbol (symbol)
  -- UNIQUE(symbol,latest_price_date,avg_return)
);

DROP TABLE IF EXISTS company_analysis;
CREATE TABLE `company_analysis` (
  `symbol` text,
  `calendarYear` bigint DEFAULT NULL,
  `eps_growth_analysis` varchar(15) CHARACTER SET latin1 DEFAULT NULL,
  `debt_to_equity_analysis` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `current_ratio_analysis` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `inventory_analysis` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `roe_analysis` varchar(7) CHARACTER SET latin1 DEFAULT NULL,
  `roic_analysis` varchar(7) CHARACTER SET latin1 DEFAULT NULL,
  `pe_ratio_analysis` varchar(12) CHARACTER SET latin1 DEFAULT NULL,
  `pe_and_sector_pe_analysis` varchar(23) CHARACTER SET latin1 DEFAULT NULL,
  `pb_ratio_analysis` varchar(12) CHARACTER SET latin1 DEFAULT NULL,
  `pepb_ratio_analysis` varchar(12) CHARACTER SET latin1 DEFAULT NULL,
  `price_to_sales_analysis` varchar(7) CHARACTER SET latin1 DEFAULT NULL,
  `price_ocf_analysis` varchar(12) CHARACTER SET latin1 DEFAULT NULL,
  `ebitda_growth` varchar(17) CHARACTER SET latin1 DEFAULT NULL,
  `netincome_growth` varchar(17) CHARACTER SET latin1 DEFAULT NULL,
  `sales_growth` varchar(17) CHARACTER SET latin1 DEFAULT NULL,
  `roe_growth` varchar(17) CHARACTER SET latin1 DEFAULT NULL,
  `shareholder_equity_growth` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `operating_cash_flow_growth` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `divident_growth` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `rdexpense_growth` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `capex_growth_ofc` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `capex_growth_revenue` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `is_roic_greater_wacc` varchar(1) CHARACTER SET latin1 DEFAULT NULL,
   INDEX idx_symbol (symbol(255))
   -- UNIQUE(symbol(255),calendarYear,eps_growth_analysis,pb_ratio_analysis)
);

DROP TABLE IF EXISTS cost_of_debt;
CREATE TABLE `cost_of_debt` (
  `symbol` text,
  `date` datetime DEFAULT NULL,
  `ebit` bigint DEFAULT NULL,
  `effective_tax_rate` decimal(23,4) DEFAULT NULL,
  `after_tax_cost_of_debt` decimal(45,2) DEFAULT NULL,
  INDEX idx_symbol (symbol(255))
   -- UNIQUE(symbol(255),date,ebit)
);

DROP TABLE IF EXISTS cost_of_equity;
CREATE TABLE `cost_of_equity` (
  `symbol` varchar(20) DEFAULT NULL,
  `expected_rate_of_return` double DEFAULT NULL,
  `risk_free_rate` float(4,2) DEFAULT NULL,
  `equity_risk_premium` double DEFAULT NULL,
  `beta` double DEFAULT NULL,
  `cost_of_equity` double DEFAULT NULL,
  INDEX idx_symbol (symbol)
   -- UNIQUE(symbol,expected_rate_of_return,risk_free_rate)
);

DROP TABLE IF EXISTS dcf_data;
CREATE TABLE `dcf_data` (
  `symbol` text,
  `exchangeShortName` text,
  `calendarYear` int unsigned DEFAULT NULL,
  `current_fcf` bigint DEFAULT NULL,
  `fcf_cagr` double DEFAULT NULL,
  `yr1_prog_fcf` double DEFAULT NULL,
  `yr2_prog_fcf` double DEFAULT NULL,
  `yr3_prog_fcf` double DEFAULT NULL,
  `yr4_prog_fcf` double DEFAULT NULL,
  `yr5_prog_fcf` double DEFAULT NULL,
  `wacc` double DEFAULT NULL,
  `terminal_value` double DEFAULT NULL,
  `pv_fcf_yr1` double DEFAULT NULL,
  `pv_fcf_yr2` double DEFAULT NULL,
  `pv_fcf_yr3` double DEFAULT NULL,
  `pv_fcf_yr4` double DEFAULT NULL,
  `pv_fcf_yr5` double DEFAULT NULL,
  `pv_fcf_terminal_value` double DEFAULT NULL,
  `todays_value` double DEFAULT NULL,
  `outstandingShares` bigint DEFAULT NULL,
  `dcf_fair_value` double DEFAULT NULL,
  INDEX idx_symbol (symbol(255))
   -- UNIQUE(symbol(255),exchangeShortName(255),calendarYear,current_fcf)
);

DROP TABLE IF EXISTS debt_to_equity_ratio;
CREATE TABLE `debt_to_equity_ratio` (
  `symbol` text,
  `date` datetime DEFAULT NULL,
  `debt_to_capitalization` decimal(24,4) DEFAULT NULL,
  `equity_to_capitalization` decimal(24,4) DEFAULT NULL,
  `debt_to_equity_ratio` decimal(27,2) DEFAULT NULL,
  INDEX idx_symbol (symbol(255))
   -- UNIQUE(symbol(255),date,debt_to_capitalization)
);

DROP TABLE IF EXISTS ebitda_info;
CREATE TABLE `ebitda_info` (
  `symbol` text,
  `calendarYear` bigint DEFAULT NULL,
  `recent_ebitda` bigint DEFAULT NULL,
  `recent_ebitda_growth` varchar(1) CHARACTER SET latin1 DEFAULT '',
  `avg_ebitda` decimal(22,2) DEFAULT NULL,
  `number_of_yrs` bigint DEFAULT '0',
  `ebitda_cagr` double DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
   -- UNIQUE(symbol(255),calendarYear,recent_ebitda)
);

DROP TABLE IF EXISTS eps_info;
CREATE TABLE `eps_info` (
  `symbol` text,
  `calendarYear` bigint DEFAULT NULL,
  `ttm_eps` double DEFAULT NULL,
  `recent_eps_growth` int NOT NULL DEFAULT '0',
  `positive_eps_growth_3yrs` int NOT NULL DEFAULT '0',
  `_5yr_avg_eps` double DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),calendarYear,ttm_eps)
);

DROP TABLE IF EXISTS expected_return;
CREATE TABLE `expected_return` (
  `symbol` varchar(20) DEFAULT NULL,
  `latest_price_date` date DEFAULT NULL,
  `true_avg_return` double DEFAULT NULL,
  `std_dev` double DEFAULT NULL,
  `probability_true` decimal(2,1) DEFAULT NULL,
  `probability_positive` decimal(2,1) DEFAULT NULL,
  `probability_negative` decimal(2,1) DEFAULT NULL,
  `expected_rate_of_return` double DEFAULT NULL,
  INDEX idx_symbol (symbol)
  -- UNIQUE(symbol,latest_price_date,true_avg_return)
);

DROP TABLE IF EXISTS free_cash_flow_info;
CREATE TABLE `free_cash_flow_info` (
  `symbol` text,
  `calendarYear` bigint DEFAULT NULL,
  `recent_free_cash_flow` bigint DEFAULT NULL,
  `recent_fcf_growth` varchar(1) CHARACTER SET latin1 DEFAULT '',
  `avg_fcf` decimal(22,2) DEFAULT NULL,
  `number_of_yrs` bigint DEFAULT '0',
  `fcf_cagr` double DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),calendarYear,recent_free_cash_flow)
);

DROP TABLE IF EXISTS fundamental_analysis;
CREATE TABLE `fundamental_analysis` (
  `symbol` text,
  `industry` text,
  `sector` text,
  `calendarYear` bigint DEFAULT NULL,
  `positive_eps_growth_3yrs` int DEFAULT '0',
  `recent_eps_growth` int DEFAULT '0',
  `debtToEquity` double DEFAULT NULL,
  `currentRatio` double DEFAULT NULL,
  `inventoryTurnover` double DEFAULT NULL,
  `roe` double DEFAULT NULL,
  `roic` double DEFAULT NULL,
  `eps_growth_analysis` varchar(15) CHARACTER SET latin1 DEFAULT NULL,
  `debt_to_equity_analysis` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `current_ratio_analysis` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `inventory_analysis` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `roe_analysis` varchar(7) CHARACTER SET latin1 DEFAULT NULL,
  `roic_analysis` varchar(7) CHARACTER SET latin1 DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),calendarYear,debtToEquity)
);

DROP TABLE IF EXISTS gdp_data;
CREATE TABLE `gdp_data` (
  `country` varchar(20) DEFAULT NULL,
  `year` int DEFAULT NULL,
  `gdp` float(4,2) DEFAULT NULL,
  INDEX idx_country (country)
  -- UNIQUE(country,year,gdp)
);

DROP TABLE IF EXISTS golden_death_cross;
CREATE TABLE `golden_death_cross` (
  `symbol` text,
  `latest_price_date` text,
  `days_consider_50` bigint unsigned DEFAULT NULL,
  `_50day_avg_price` double DEFAULT NULL,
  `days_consider_200` bigint unsigned DEFAULT NULL,
  `_200day_avg_price` double DEFAULT NULL,
  `_10percentDownOf_200day` double DEFAULT NULL,
  `_10percentUpOf_200day` double DEFAULT NULL,
  `near_to_golden_death_cross` varchar(1) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `price_difference` double DEFAULT NULL,
  `percent_diff_in_50_200_price` double DEFAULT NULL,
  `note` varchar(20) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),latest_price_date(255),_50day_avg_price)
);

DROP TABLE IF EXISTS growth_analysis;
CREATE TABLE `growth_analysis` (
  `symbol` text,
  `latest_price_date` text,
  `recent_ebitda_growth` varchar(1) CHARACTER SET latin1 DEFAULT '',
  `ebitda_cagr` double DEFAULT NULL,
  `recent_netincome_growth` varchar(1) CHARACTER SET latin1 DEFAULT '',
  `netincome_cagr` double DEFAULT NULL,
  `recent_revenue_growth` varchar(1) CHARACTER SET latin1 DEFAULT '',
  `revenue_cagr` double DEFAULT NULL,
  `roe` double DEFAULT NULL,
  `fiveYShareholdersEquityGrowthPerShare` double DEFAULT NULL,
  `fiveYOperatingCFGrowthPerShare` double DEFAULT NULL,
  `fiveYDividendperShareGrowthPerShare` double DEFAULT NULL,
  `rdexpenseGrowth` bigint DEFAULT NULL,
  `capexToOperatingCashFlow` double DEFAULT NULL,
  `capexToRevenue` double DEFAULT NULL,
  `roic` double DEFAULT NULL,
  `wacc` double DEFAULT NULL,
  `ebitda_growth` varchar(17) CHARACTER SET latin1 DEFAULT NULL,
  `netincome_growth` varchar(17) CHARACTER SET latin1 DEFAULT NULL,
  `sales_growth` varchar(17) CHARACTER SET latin1 DEFAULT NULL,
  `roe_growth` varchar(17) CHARACTER SET latin1 DEFAULT NULL,
  `shareholder_equity_growth` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `operating_cash_flow_growth` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `divident_growth` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `rdexpense_growth` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `capex_growth_ofc` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `capex_growth_revenue` varchar(9) CHARACTER SET latin1 DEFAULT NULL,
  `is_roic_greater_wacc` varchar(1) CHARACTER SET latin1 DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),latest_price_date(255),roic,wacc)
);

DROP TABLE IF EXISTS netincome_info;
CREATE TABLE `netincome_info` (
  `symbol` text,
  `calendarYear` bigint DEFAULT NULL,
  `recent_netincome` bigint DEFAULT NULL,
  `recent_netincome_growth` varchar(1) CHARACTER SET latin1 DEFAULT '',
  `avg_netincome` decimal(22,2) DEFAULT NULL,
  `number_of_yrs` bigint DEFAULT '0',
  `netincome_cagr` double DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),calendarYear,recent_netincome,avg_netincome)
);

DROP TABLE IF EXISTS pe_pb_ratio_info;
CREATE TABLE `pe_pb_ratio_info` (
  `symbol` text,
  `calendarYear` bigint DEFAULT NULL,
  `ttm_eps` double DEFAULT NULL,
  `recent_eps_growth` int NOT NULL DEFAULT '0',
  `positive_eps_growth_3yrs` int NOT NULL DEFAULT '0',
  `_5yr_avg_eps` double DEFAULT NULL,
  `created_at` date NOT NULL,
  `latest_price_date` text,
  `latest_close_price` double DEFAULT NULL,
  `_50day_avg_price` double DEFAULT NULL,
  `_200day_avg_price` double DEFAULT NULL,
  `_5yr_avg_price` double DEFAULT NULL,
  `current_pe_ratio` double DEFAULT NULL,
  `_200day_pe_ratio` double DEFAULT NULL,
  `_5year_pe_ratio` double DEFAULT NULL,
  `final_pe_ratio` double DEFAULT NULL,
  `bookValuePerShare` double DEFAULT NULL,
  `pbratio` double DEFAULT NULL,
  `ratio_pe_into_pb` double DEFAULT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),calendarYear,ttm_eps)
);

DROP TABLE IF EXISTS price_cashflow_info;
CREATE TABLE `price_cashflow_info` (
  `symbol` text,
  `latest_cash_flow_date` datetime DEFAULT NULL,
  `calendarYear` bigint DEFAULT NULL,
  `freeCashFlow` bigint DEFAULT NULL,
  `operatingCashFlow` bigint DEFAULT NULL,
  `_50day_avg_price` double DEFAULT NULL,
  `latest_price_date` text,
  `outstandingShares` bigint DEFAULT NULL,
  `outstanding_share_total_price` double DEFAULT NULL,
  `price_fcf_ratio` double DEFAULT NULL,
  `price_ocf_ratio` double DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),latest_cash_flow_date,calendarYear,freeCashFlow)
);

DROP TABLE IF EXISTS proc_exec_history;
CREATE TABLE `proc_exec_history` (
  `proc_name` varchar(255) NOT NULL,
  `exchange` varchar(255) NOT NULL,
  `executed_at` timestamp NOT NULL
);

DROP TABLE IF EXISTS progressive_free_cashflow;
CREATE TABLE `progressive_free_cashflow` (
  `symbol` text,
  `exchangeShortName` text,
  `calendarYear` int unsigned DEFAULT NULL,
  `current_fcf` bigint DEFAULT NULL,
  `fcf_cagr` double DEFAULT NULL,
  `yr1_prog_fcf` double DEFAULT NULL,
  `yr2_prog_fcf` double DEFAULT NULL,
  `yr3_prog_fcf` double DEFAULT NULL,
  `yr4_prog_fcf` double DEFAULT NULL,
  `yr5_prog_fcf` double DEFAULT NULL,
  `wacc` double DEFAULT NULL,
  `terminal_value` double DEFAULT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),exchangeShortName(255),calendarYear,current_fcf)
);

DROP TABLE IF EXISTS rate_of_return_info;
CREATE TABLE `rate_of_return_info` (
  `symbol` varchar(20) DEFAULT NULL,
  `year` varchar(20) DEFAULT NULL,
  `latest_date` date DEFAULT NULL,
  `rate_of_return` float DEFAULT NULL,
  INDEX idx_symbol (symbol)
  -- UNIQUE(symbol,year,rate_of_return)
);

DROP TABLE IF EXISTS risk_free_rate;
CREATE TABLE `risk_free_rate` (
  `latest_date` date DEFAULT NULL,
  `t_bill_rate` float(4,2) DEFAULT NULL,
  `exchange_name` varchar(255) DEFAULT NULL,
  INDEX idx_symbol (exchange_name)
  -- UNIQUE(exchange_name,latest_date,t_bill_rate)
);

DROP TABLE IF EXISTS sales_info;
CREATE TABLE `sales_info` (
  `symbol` text,
  `calendarYear` bigint DEFAULT NULL,
  `recent_revenue` bigint DEFAULT NULL,
  `recent_revenue_growth` varchar(1) CHARACTER SET latin1 DEFAULT '',
  `avg_revenue` decimal(22,2) DEFAULT NULL,
  `number_of_yrs` bigint DEFAULT '0',
  `revenue_cagr` double DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),calendarYear,avg_revenue)
);

DROP TABLE IF EXISTS value_analysis;
CREATE TABLE `value_analysis` (
  `symbol` text,
  `latest_price_date` text,
  `latest_close_price` double DEFAULT NULL,
  `_50day_avg_price` double DEFAULT NULL,
  `_200day_avg_price` double DEFAULT NULL,
  `_5yr_avg_price` double DEFAULT NULL,
  `final_pe_ratio` double DEFAULT NULL,
  `live_peratio` double DEFAULT NULL,
  `pbratio` double DEFAULT NULL,
  `live_pbratio` double DEFAULT NULL,
  `ratio_pe_into_pb` double DEFAULT NULL,
  `price_fcf_ratio` double DEFAULT NULL,
  `price_ocf_ratio` double DEFAULT NULL,
  `priceToSalesRatio` double DEFAULT NULL,
  `pe_ratio_analysis` varchar(12) CHARACTER SET latin1 DEFAULT NULL,
  `pe_and_sector_pe_analysis` varchar(23) CHARACTER SET latin1 DEFAULT NULL,
  `pb_ratio_analysis` varchar(12) CHARACTER SET latin1 DEFAULT NULL,
  `pepb_ratio_analysis` varchar(12) CHARACTER SET latin1 DEFAULT NULL,
  `price_to_sales_analysis` varchar(7) CHARACTER SET latin1 DEFAULT NULL,
  `price_ocf_analysis` varchar(12) CHARACTER SET latin1 DEFAULT NULL,
  `created_at` date NOT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),latest_price_date(255),latest_close_price)
);

DROP TABLE IF EXISTS vw_stock_parameter_check;
CREATE TABLE `vw_stock_parameter_check` (
  `companyName` text,
  `exchangeShortName` text,
  `industry` text,
  `sector` text,
  `sector_pe_ratio` double DEFAULT NULL,
  `marketCap` bigint DEFAULT NULL,
  `company_cap` varchar(14) CHARACTER SET latin1 NOT NULL DEFAULT '',
  `beta` double DEFAULT NULL,
  `symbol` text,
  `calendarYear` bigint DEFAULT NULL,
  `ttm_eps` double DEFAULT NULL,
  `recent_eps_growth` int DEFAULT '0',
  `positive_eps_growth_3yrs` int DEFAULT '0',
  `_5yr_avg_eps` double DEFAULT NULL,
  `created_at` date,
  `latest_price_date` text,
  `latest_close_price` double DEFAULT NULL,
  `_50day_avg_price` double DEFAULT NULL,
  `_200day_avg_price` double DEFAULT NULL,
  `_5yr_avg_price` double DEFAULT NULL,
  `current_pe_ratio` double DEFAULT NULL,
  `_200day_pe_ratio` double DEFAULT NULL,
  `_5year_pe_ratio` double DEFAULT NULL,
  `final_pe_ratio` double DEFAULT NULL,
  `bookValuePerShare` double DEFAULT NULL,
  `pbratio` double DEFAULT NULL,
  `ratio_pe_into_pb` double DEFAULT NULL,
  `recent_ebitda` bigint DEFAULT NULL,
  `recent_ebitda_growth` varchar(1) CHARACTER SET latin1 DEFAULT '',
  `avg_ebitda` decimal(22,2) DEFAULT NULL,
  `ebitda_cagr` double DEFAULT NULL,
  `recent_netincome` bigint DEFAULT NULL,
  `recent_netincome_growth` varchar(1) CHARACTER SET latin1 DEFAULT '',
  `avg_netincome` decimal(22,2) DEFAULT NULL,
  `netincome_cagr` double DEFAULT NULL,
  `recent_revenue` bigint DEFAULT NULL,
  `recent_revenue_growth` varchar(1) CHARACTER SET latin1 DEFAULT '',
  `avg_revenue` decimal(22,2) DEFAULT NULL,
  `revenue_cagr` double DEFAULT NULL,
  `freeCashFlow` bigint DEFAULT NULL,
  `latest_cash_flow_date` datetime DEFAULT NULL,
  `operatingCashFlow` bigint DEFAULT NULL,
  `price_fcf_ratio` double DEFAULT NULL,
  `price_ocf_ratio` double DEFAULT NULL,
  `priceToSalesRatio` double DEFAULT NULL,
  `dividendYield` double DEFAULT NULL,
  `debtToEquity` double DEFAULT NULL,
  `currentRatio` double DEFAULT NULL,
  `roe` double DEFAULT NULL,
  `roic` double DEFAULT NULL,
  `inventoryTurnover` double DEFAULT NULL,
  `live_peratio` double DEFAULT NULL,
  `live_pbratio` double DEFAULT NULL,
  `grahamNetNet` double DEFAULT NULL,
  `grahamNumber` double DEFAULT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),exchangeShortName(255),pbratio)
);

DROP TABLE IF EXISTS wacc_data;
CREATE TABLE `wacc_data` (
  `symbol` text,
  `date` datetime DEFAULT NULL,
  `debt_to_capitalization` decimal(24,4) DEFAULT NULL,
  `equity_to_capitalization` decimal(24,4) DEFAULT NULL,
  `cost_of_equity` double DEFAULT NULL,
  `after_tax_cost_of_debt` decimal(45,2) DEFAULT NULL,
  `wacc` double DEFAULT NULL,
  INDEX idx_symbol (symbol(255))
  -- UNIQUE(symbol(255),date,debt_to_capitalization)
);



