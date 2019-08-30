clear
cd "C:\Users\bmy31\Documents\毕业\金融\数据与模型"
import delimited C:\Users\bmy31\Documents\毕业\金融\数据与模型\数据.csv, clear
gen date_new = date(date,"YMD")
format date_new %td
drop date
rename date_new date
gen month = mofd(date)
format %tm month
drop if date<date("2009-10-01","YMD")
drop if date==date("2011-04-01","YMD")
xtset code date	//面板数据规定截面序号和时间线

//设置虚拟变量 取对数
gen time_category = 0
replace time_category = 1 if date>=date("2010-3-31","YMD")
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

global xlist log_volume_2 log_cirrculation_value_2 log_return_2 log_trade_value_2
global urlist log_volatility log_volume log_cirrculation_value log_return log_trade_value
global ylist log_volatility

xtunitroot fisher log_return, dfuller drift lags(1) demean

// foreach i in $urlist{
// logout, save(xtunitroot_`i') word replace: xtunitroot fisher `i', dfuller drift lags(1) demean
// }

// preserve
// drop if date>=date("2010-3-31","YMD")								
// //画图check一下趋势
// bysort category month: egen mean_volatility = mean(volatility*100)
// keep category month mean_volatility
// duplicates drop category month mean_volatility, force
// export delimited C:\Users\bmy31\Documents\毕业\金融\数据与模型\time_series.csv, replace
// // twoway (line mean_volatility month if category==1, yaxis(1)) (line mean_volatility month if category==0)
// restore


//倾向匹配得分双重差分模型
diff $ylist, treat(category) period(time_category) cov($xlist) report support
est sto did
outreg2 [did] using did.xls, replace st(coef se tstat pval ci_low ci_high)


//分组描述性统计
// bysort time_category category: tabstat volatility cirrculation_value daily_return volume trade_value, stat(count mean p50 min max)
// logout, save("describe") word   ///
//  replace: bysort time_category category:  ///
//  tabstat volatility cirrculation_value daily_return volume trade_value, stat(count mean p50 min max)

