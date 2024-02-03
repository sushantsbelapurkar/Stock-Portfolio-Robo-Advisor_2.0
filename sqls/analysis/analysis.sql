select * from mysql_portfolio.symbol_list where name like '%ORIENTAL%' limit 10;
SELECT * FROM mysql_portfolio.vw_stock_parameter_check limit 10;
-- FUNDAMENTAL TOTAL Range	71 -->	53 -->	22
-- GROWTH TOTAL	Range       68 -->	47 -->	28
select * from mysql_portfolio.company_score
where fundamental_score >= 53 and growth_score >= 47;

-- portfolio VALUE analysis, score and api rating
select
portfolio.stock,portfolio.symbol,portfolio.exchange,
portfolio.latest_price, portfolio.quantity,
portfolio.investment_price,
stock_view.company_cap,stock_view.industry,stock_view.sector,stock_view.beta, stock_view._5yr_avg_eps,
stock_view.freeCashFlow,(15*stock_view._5yr_avg_eps) as fair_value,
stock_view.grahamNumber, (((15*stock_view._5yr_avg_eps) + stock_view.grahamNumber)/2) avg_fair_price,
stock_view._50day_avg_price, stock_view._200day_avg_price,
analysis.calendarYear,analysis.current_ratio_analysis,analysis.debt_to_equity_analysis,
analysis.inventory_analysis,analysis.is_roic_greater_wacc,analysis.pb_ratio_analysis,
analysis.pe_and_sector_pe_analysis,analysis.pepb_ratio_analysis,analysis.pe_ratio_analysis,
analysis.price_ocf_analysis,analysis.price_to_sales_analysis,analysis.roe_analysis,
analysis.roic_analysis,
score.fundamental_score,score.fundamental_signal,score.inventory_score,
score.main_param_signal,score.main_score,
score.roic_wacc_score,score.total_score,
api_rating.rating, api_rating.ratingScore,api_rating.ratingRecommendation
 from mysql_portfolio.portfolio_stocks portfolio
left join mysql_portfolio.company_analysis analysis
on analysis.symbol = portfolio.symbol
left join mysql_portfolio.company_score score
on score.symbol = portfolio.symbol
left join mysql_portfolio.api_rating
on api_rating.symbol = portfolio.symbol
left join mysql_portfolio.vw_stock_parameter_check stock_view
on stock_view.symbol = portfolio.symbol
where portfolio.latest_price != 0
order by fundamental_score desc
;

-- portfolio GROWTH analysis, score and api rating
select
portfolio.stock,portfolio.symbol,portfolio.exchange,
portfolio.latest_price, portfolio.quantity,
portfolio.investment_price,
stock_view.company_cap,stock_view.industry,stock_view.sector,stock_view.beta, stock_view._5yr_avg_eps,
stock_view.freeCashFlow,(15*stock_view._5yr_avg_eps) as fair_value,
stock_view.grahamNumber, (((15*stock_view._5yr_avg_eps) + stock_view.grahamNumber)/2) avg_fair_price,
stock_view._50day_avg_price, stock_view._200day_avg_price,
analysis.calendarYear,analysis.capex_growth_ofc,analysis.capex_growth_revenue,
analysis.divident_growth,analysis.ebitda_growth,analysis.eps_growth_analysis,
analysis.is_roic_greater_wacc,analysis.netincome_growth,analysis.operating_cash_flow_growth,
analysis.rdexpense_growth,analysis.roe_growth,analysis.sales_growth,
analysis.shareholder_equity_growth,
score.growth_score,score.growth_signal, score.main_param_signal,score.main_score,
score.roic_wacc_score,score.total_score,
api_rating.rating, api_rating.ratingScore,api_rating.ratingRecommendation
 from mysql_portfolio.portfolio_stocks portfolio
left join mysql_portfolio.company_analysis analysis
on analysis.symbol = portfolio.symbol
left join mysql_portfolio.company_score score
on score.symbol = portfolio.symbol
left join mysql_portfolio.api_rating
on api_rating.symbol = portfolio.symbol
left join mysql_portfolio.vw_stock_parameter_check stock_view
on stock_view.symbol = portfolio.symbol
where portfolio.latest_price != 0
order by growth_score desc
;
select * from mysql_portfolio.stock_screener limit 10;
-- Overall VALUE analysis, score and api rating
select
analysis.symbol, stock_screener.price,
stock_view.company_cap,stock_view.industry,stock_view.sector,stock_view.beta, stock_view._5yr_avg_eps,
stock_view.freeCashFlow, (15*stock_view._5yr_avg_eps) as fair_value,
stock_view.grahamNumber, (((15*stock_view._5yr_avg_eps) + stock_view.grahamNumber)/2) avg_fair_price,
stock_view._50day_avg_price, stock_view._200day_avg_price,
analysis.calendarYear,analysis.current_ratio_analysis,analysis.debt_to_equity_analysis,
analysis.inventory_analysis,analysis.is_roic_greater_wacc,analysis.pb_ratio_analysis,
analysis.pe_and_sector_pe_analysis,analysis.pepb_ratio_analysis,analysis.pe_ratio_analysis,
analysis.price_ocf_analysis,analysis.price_to_sales_analysis,analysis.roe_analysis,
analysis.roic_analysis,
score.fundamental_score,score.fundamental_signal,score.inventory_score,
score.main_param_signal,score.main_score,
score.roic_wacc_score,score.total_score,
api_rating.rating, api_rating.ratingScore,api_rating.ratingRecommendation
from
mysql_portfolio.company_analysis analysis
left join mysql_portfolio.company_score score
on score.symbol = analysis.symbol
left join mysql_portfolio.api_rating
on api_rating.symbol = analysis.symbol
left join mysql_portfolio.vw_stock_parameter_check stock_view
on stock_view.symbol = analysis.symbol
left join mysql_portfolio.stock_screener
on stock_screener.symbol = analysis.symbol
WHERE
analysis.symbol like '%TDUP%'
-- fundamental_score >= 53
and analysis.symbol not in (select distinct symbol from mysql_portfolio.portfolio_stocks where latest_price !=0)
order by fundamental_score desc
;
-- Overall GROWTH analysis, score and api rating
select
analysis.symbol, stock_screener.price,
stock_view.company_cap,stock_view.industry,stock_view.sector,stock_view.beta, stock_view._5yr_avg_eps,
stock_view.freeCashFlow, (15*stock_view._5yr_avg_eps) as fair_value,
stock_view.grahamNumber, (((15*stock_view._5yr_avg_eps) + stock_view.grahamNumber)/2) avg_fair_price,
stock_view._50day_avg_price, stock_view._200day_avg_price,
analysis.calendarYear,analysis.capex_growth_ofc,analysis.capex_growth_revenue,
analysis.divident_growth,analysis.ebitda_growth,analysis.eps_growth_analysis,
analysis.is_roic_greater_wacc,analysis.netincome_growth,analysis.operating_cash_flow_growth,
analysis.rdexpense_growth,analysis.roe_growth,analysis.sales_growth,
analysis.shareholder_equity_growth,
score.main_param_signal,score.main_score,
score.roic_wacc_score,score.total_score,
api_rating.rating, api_rating.ratingScore,api_rating.ratingRecommendation
from  mysql_portfolio.company_analysis analysis
left join mysql_portfolio.company_score score
on score.symbol = analysis.symbol
left join mysql_portfolio.api_rating
on api_rating.symbol = analysis.symbol
left join mysql_portfolio.vw_stock_parameter_check stock_view
on stock_view.symbol = analysis.symbol
left join mysql_portfolio.stock_screener
on stock_screener.symbol = analysis.symbol
WHERE growth_score >= 47
and analysis.symbol not in (select distinct symbol from mysql_portfolio.portfolio_stocks where latest_price !=0)
order by growth_score desc
;
