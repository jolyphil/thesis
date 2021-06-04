********************************************************************************
* Project:	Dissertation
* Task:		Export trend graph
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop export_trend
program export_trend
args var

* ______________________________________________________________________________
* Load programs

do "${programs}cluster_centering.do"

* ______________________________________________________________________________
* Preserve

preserve

* ______________________________________________________________________________
* Generate country mean, country-wave mean, and differences

cluster_centering `var'

* ______________________________________________________________________________
* Generate temporary tages

egen tag_c = tag(country)
egen tag_cw = tag(countrywave)

* ______________________________________________________________________________
* Collapse

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
statsby sa=_b[_cons] sb=_b[year], by(country) ///
	saving("${data_temp}ols.dta", replace) ///
	: regress `var'_mean_cw year if tag_cw==1
sort country year

merge m:1 country using "${data_temp}ols.dta"
drop _merge

gen yhat = sa + sb * year

* Average trend: old democracies -----
summ sa if tag_c == 1 & postcommunist == 0, mean
gen sa_mean_olddem = r(mean)
summ sb if tag_c == 1 & postcommunist == 0, mean
gen sb_mean_olddem = r(mean)
gen yhat_mean_olddem = sa_mean_olddem + sb_mean_olddem * year

* Average trend: new democracies -----
summ sa if tag_c == 1 & postcommunist == 1, mean
gen sa_mean_newdem = r(mean)
summ sb if tag_c == 1 & postcommunist == 1, mean
gen sb_mean_newdem = r(mean)
gen yhat_mean_newdem = sa_mean_newdem + sb_mean_newdem * year


if "`var'" == "demonstration" {
	local legend "col(1) off"
	local title "Attended a lawful demonstration"
} 	
if "`var'" == "petition" {
	local legend "col(1) off"
	local title "Signed a petition"
} 
if "`var'" == "boycott" {
	local legend "col(1) ring(0) pos(3) xoffset(60) order(1 `"Country-slope"' 2 `"Average, old democracies"' 3 `"Average, new democracies"')"
	local title "Boycotted certain products"
} 


* Average trend: new democracies -----
twoway ///
(line yhat year, ///
	connect(ascending) lcolor(gs14)) ///
(line yhat_mean_olddem year, ///
	sort lcolor("166 206 227") lpattern(dash) lwidth(medthick)) ///
(line yhat_mean_newdem year, ///
	sort lcolor("31 120 180") lpattern(dash_dot) lwidth(medthick)) ///
if tag_cw==1, ///
xlabel(2002(4)2018) ///
xtitle("Year") ///
ytitle("Proportion, last 12 months") ///
title("`title'") ///
legend(`legend') ///
saving("${figures_gph}trend_`var'.gph", replace)
	
* ______________________________________________________________________________
* Restore

restore

end
