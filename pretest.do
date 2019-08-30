clear
import delimited data.csv, clear


# Preprocess
gen date_new = date(date,"YMD")
format date_new %td
drop date
rename date_new date
gen q=qofd(date)
drop if date<date("2009-10-01","YMD")
xtset code date

gen volatility = (high-low)/(0.5*high+0.5*low)
gen log_volatility = log(volatility)
gen log_cirrculation_value = log(cirrculation_value)
gen log_return = log(daily_return+1)
gen log_volume = log(volume)
gen log_trade_value = log(trade_value)
gen log_market_value = log(market_value)

gen log_cirrculation_value_2=L.log_cirrculation_value
gen log_return_2=L.log_return
gen log_volume_2=L.log_volume
gen log_trade_value_2=L.log_trade_value
gen log_market_value_2=L.log_market_value

global xlist log_return_2 log_trade_value_2 log_cirrculation_value_2 log_volume_2

drop if q <= 198|q == 205

# Generating Dummy Varibles
forvalues i = 1(-1)1{
gen q_m_`i' = 0
replace q_m_`i' = 1 if q == 201-`i'
replace q_m_`i' = q_m_`i'*category
}

forvalues j = 1(1)4{
gen q_`j' = 0
replace q_`j' = 1 if q == 200+`j'
replace q_`j' = q_`j'*category
}

# Pretest Regression (Event Study)
xi: xtreg log_volatility  q_* i.q  $xlist, fe level(99)
est sto reg
outreg2 [reg] using pretest.xls, replace st(coef se tstat pval ci_low ci_high)
coefplot reg, keep(q_*) vertical recast(connect) yline(0) xline(2, lp(dash)) levels(99)
