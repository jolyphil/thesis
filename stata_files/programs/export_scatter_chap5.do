	********************************************************************************
* Project:	Dissertation
* Task:		Chap. 5: Export scatter plot, bivariate relationship
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop export_scatter_chap5
program export_scatter_chap5
args var

preserve

collapse ///
	(first) earlyprotest postcommunist ///
	(mean) `var' [pw = dweight], ///
	by(country)

reg `var' earlyprotest if postcommunist == 0
gen yhat_olddem = _b[_cons] + _b[earlyprotest]*earlyprotest ///
	if postcommunist == 0

reg `var' earlyprotest if postcommunist == 1
gen yhat_newdem = _b[_cons] + _b[earlyprotest]*earlyprotest ///
	if postcommunist == 1

if "`var'" == "demonstration" {
	local legend "col(1) off"
	local title "Attended a lawful demonstration"
} 	
if "`var'" == "petition" {
	local legend "col(1) off"
	local title "Signed a petition"
} 
if "`var'" == "boycott" {
	local legend "col(1) ring(0) pos(3) xoffset(60) order(1 `"Old democracies"' 2 `"New democracies"' 3 `"Linear prediction, old democracies"' 4 `"Linear prediction, new democracies"')"
	local title "Boycotted certain products"
} 

twoway ///
	(scatter `var' earlyprotest if postcommunist==0, ///
		mcolor("166 206 227") mlabel(country)) ///
	(scatter `var' earlyprotest if postcommunist == 1, ///
		mcolor("31 120 180") mlabel(country)) ///
	(line yhat_olddem earlyprotest, ///
		lcolor("166 206 227")) ///
	(line yhat_newdem earlyprotest, ///
		lcolor("31 120 180")), ///
	xlabel(0(0.2)0.6) ///
	xtitle("Early exposure to protest") ///
	ytitle("Proportion, last 12 months") ///
	title("`title'") ///
	legend(`legend') ///
	saving("${figures_gph}scatter_earlyprotest_`var'.gph", replace)

restore

end
