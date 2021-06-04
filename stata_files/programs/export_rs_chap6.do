********************************************************************************
* Project:	Dissertation
* Task:		Chap 6: Plot random slope
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop export_rs_chap6
program export_rs_chap6
args modelname

preserve

* ______________________________________________________________________________
* Find dv + adjust legend

if regexm("`modelname'", "demonstration")==1 {
	local dv "demonstration"
	local title "Attended a lawful demonstration"
	local legend "col(1) off"
}
else if regexm("`modelname'", "petition")==1 {
	local dv "petition"
	local title "Signed a petition"
	local legend "col(1) off"
}
else if regexm("`modelname'", "boycott")==1  {
	local dv "boycott"
	local title "Boycotted certain products"
	local legend "col(1) ring(0) pos(3) xoffset(60) order(2 `"Random effect"' 3 `"Fixed effect"')"
}
else {
	error "Unknown model"
}

* ______________________________________________________________________________
* Find level_es + attribute labels and titles

if regexm("`modelname'", "cohort")==1 {
	local level_rs "cohort"
	local lines "xline(1929,lcolor(edkblue) lpattern(dash)) xline(1970,lcolor(edkblue) lpattern(dash))"
	local xlab "1920(10)1985"
	local xtitle "Birth cohorts"
}
else if regexm("`modelname'", "period")==1 {
	local lines ""
	local level_rs "period"
	local xlab "2002(2)2016"
	local xtitle "Periods"
}
else {
	error "Unknown model"
}

* ______________________________________________________________________________
* Create Tag

egen tag = tag(`level_rs')

* ______________________________________________________________________________
* Postestimation (EB prediction)

est restore `modelname'

predict b*, reffects relevel(`level_rs')
predict se*, reses relevel(`level_rs')

gen slope = _b[eq1:1.eastsoc] + b1
gen ll = _b[eq1:1.eastsoc] + b1 - 1.96*se1
gen ul = _b[eq1:1.eastsoc] + b1 + 1.96*se1

gen fe_east = _b[eq1:1.eastsoc]

* ______________________________________________________________________________
* Generate plot

twoway ///
	(rarea ll ul `level_rs' if tag == 1, sort fcolor(gs13) lcolor(gs13)) ///
	(connected slope `level_rs' if tag == 1, sort mcolor(black) lcolor(black)) ///
	(line fe_east `level_rs' if tag == 1, sort lcolor(black) lpattern(dash)), ///
	`lines' ///
	yline(0,lcolor(edkblue)) ///
	xlab(`xlab') ///
	xtitle(`xtitle') ///
	ylab(0(-0.2)-0.6) ///
	ytitle("Effect of socialization in Eastern Germany") ///
	title("`title'") ///
	legend(`legend') ///
	saving("${figures_gph}`modelname'.gph", replace)

* ______________________________________________________________________________
* Quit

restore

end
