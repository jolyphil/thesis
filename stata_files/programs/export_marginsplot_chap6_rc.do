********************************************************************************
* Project:	Dissertation
* Task:		Chapter 6: Export marginsplots, robustness checks
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop export_marginsplot_chap6_rc
program export_marginsplot_chap6_rc
args modelname level

* ______________________________________________________________________________
* Find dv + adjust legend

if regexm("`modelname'", "demonstration")==1 {
	local dv "demonstration"
	local title "Attended a lawful demonstration"
}
else if regexm("`modelname'", "petition")==1 {
	local dv "petition"
	local title "Signed a petition"
}
else if regexm("`modelname'", "boycott")==1  {
	local dv "boycott"
	local title "Boycotted certain products"
}
else {
	error "Unknown model"
}

* ______________________________________________________________________________
* Restore model

est restore `modelname'

* ______________________________________________________________________________
* Calculate marginal effects and attribute labels

if "`level'" == "cohort" {
	margins if e(sample)==1, dydx(eastsoc) at(cohort=(1920(5)1985))
	local xlines "xline(1929,lcolor(edkblue) lpattern(dash)) xline(1970,lcolor(edkblue) lpattern(dash))"
	local xlab "1920(10)1985"
	local xtitle "Birth cohorts"
}
else if "`level'" == "period" {
	margins if e(sample)==1, dydx(eastsoc) at(period=(2002(2)2016))
	local xlines ""
	local xlab "2002(2)2016"
	local xtitle "Periods"
}
else {
	error "Unknown level"
}

* ______________________________________________________________________________
* Plot 

marginsplot, /// exports Figures A1 to A3
	`xlines' ///
	yline(0,lcolor(edkblue)) ///
	plotop(mcolor(black) lcolor(black) lpattern(dash))  ///
	recastci(rarea) ///
	ciop(lcolor(gs13))  ///
	ci(fcolor(gs13)) ///
	xlab(`xlab') ///
	xtitle("`xtitle'") ///
	/*ylab(0.05(-0.05)-0.15)*/ ///
	ytitle("Effect of socialization in Eastern Germany") ///
	title(`title', nospan) ///
	saving("${figures_gph}6_`dv'_rc_`level'.gph", replace)
	
end
