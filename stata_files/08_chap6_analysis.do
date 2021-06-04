********************************************************************************
* Project: Dissertation
* Task:    Chap. 6: APC analysis
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

version 16
capture log close
capture log using "${logfiles}08_chap6_analysis.smcl", replace
set more off

set scheme minimal

* ______________________________________________________________________________
* Load external packages and programs

do "${programs}export_coefplot_chap6.do"
do "${programs}export_tab_APC_chap6.do"
do "${programs}export_rs_chap6.do"
do "${programs}model_chap6.do"

* ______________________________________________________________________________
* Load data

use "${data}master.dta", clear

* ______________________________________________________________________________
* Prepare data

keep if country == "DEE" | country == "DEW"
keep if cohort >= 1920 & cohort <= 1985


* ______________________________________________________________________________
* Run models

foreach dv of varlist demonstration petition boycott {
	foreach level_rs in "cohort" "period" {
		model_chap6 ///
			`dv' /// dependent variable
			`level_rs' /// level of the random slope 
			chap6_`dv'_`level_rs' // model name
	}
}

* ______________________________________________________________________________
* Export coefficient plot (Figure 6.2)

export_coefplot_chap6 ///
	chap6_demonstration_cohort /// Model 1
	chap6_petition_cohort /// Model 2
	chap6_boycott_cohort /// Model 3
	fig_6_2_coefplot // filename

* ______________________________________________________________________________
* Obtain odds ratios (East vs West German)

foreach dv of varlist demonstration petition boycott {
	disp "`dv'-------------------------------------------------------------"
	est restore chap6_`dv'_cohort
	local b = _b[eq1:1.eastsoc]
	disp "b = `b'"
	local or = round(exp(`b'), 0.01)
	local or : di %3.2f `or'
	disp "Odds ratio = `or'"
}

* ______________________________________________________________________________
* Plot random slopes

* Cohort (Figure 6.3) ----------------------------------------------------------

foreach dv of varlist demonstration petition boycott {
	export_rs_chap6 ///
	chap6_`dv'_cohort // model name
}
	
gr combine ///
	"${figures_gph}chap6_demonstration_cohort.gph" ///
	"${figures_gph}chap6_petition_cohort.gph" ///
	"${figures_gph}chap6_boycott_cohort.gph", ///
	col(2) row(2) ///
	saving("${figures_gph}fig_6_3_rs_cohort.gph", replace)
graph export "${figures_pdf}fig_6_3_rs_cohort.pdf", replace
graph export "${figures_png}fig_6_3_rs_cohort.png", replace  ///
		width(2750) height(2000)

* Period (Figure 6.4) ----------------------------------------------------------
			
foreach dv of varlist demonstration petition boycott {
		export_rs_chap6 ///
			chap6_`dv'_period // model name
}
	
gr combine ///
	"${figures_gph}chap6_demonstration_period.gph" ///
	"${figures_gph}chap6_petition_period.gph" ///
	"${figures_gph}chap6_boycott_period.gph", ///
	col(2) row(2) ///
	saving("${figures_gph}fig_6_4_rs_period.gph", replace)
graph export "${figures_pdf}fig_6_4_rs_period.pdf", replace
graph export "${figures_png}fig_6_4_rs_period.png", replace  ///
		width(2750) height(2000)
			
* ______________________________________________________________________________
* Export Tables

export_tab_APC_chap6 /// Table R.-slope cohort
	chap6_demonstration_cohort /// Model 1
	chap6_petition_cohort /// Model 2
	chap6_boycott_cohort /// Model 3
	1 /// 1st model number
	tbl_6_1_APC_cohort // filename
	
export_tab_APC_chap6 /// Table R.-slope period
	chap6_demonstration_period /// Model 1
	chap6_petition_period /// Model 2
	chap6_boycott_period /// Model 3
	4 /// 1st model number
	tbl_6_2_APC_period // filename

* ______________________________________________________________________________
* Close

log close
exit
