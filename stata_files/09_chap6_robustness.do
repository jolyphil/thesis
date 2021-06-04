********************************************************************************
* Project: Dissertation
* Task:    Chap. 6: Robustness checks
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

version 16
capture log close
capture log using "${logfiles}09_chap6_robustness.smcl", replace
set more off

set scheme minimal

* ______________________________________________________________________________
* Load external packages and programs

do "${programs}export_marginsplot_chap6_rc.do"
do "${programs}model_chap6_robustness.do"

* ______________________________________________________________________________
* Load data

use "${data}master.dta", clear

* ______________________________________________________________________________
* Prepare data

keep if country == "DEE" | country == "DEW"
keep if cohort >= 1920 & cohort <= 1985

* ______________________________________________________________________________
* Fixed effect models with interaction terms (excluding age)

* ______________________________________________________________________________
* Run models

foreach dv of varlist demonstration petition boycott {
	model_chap6_robustness ///
		`dv' /// dependent variable
		chap6_`dv'_rc // model name
}

* ______________________________________________________________________________
* Marginal effect plots

* Cohort (Figure 6.5) ----------------------------------------------------------

foreach dv of varlist demonstration petition boycott  {
	export_marginsplot_chap6_rc ///
		chap6_`dv'_rc /// model name
		cohort // cohort or period
}

gr combine ///
	"${figures_gph}6_demonstration_rc_cohort.gph" ///
	"${figures_gph}6_petition_rc_cohort.gph" ///
	"${figures_gph}6_boycott_rc_cohort.gph", ///
	ycommon ///
	saving("${figures_gph}fig_6_5_rc_cohort.gph", replace)
graph export "${figures_pdf}fig_6_5_rc_cohort.pdf", replace
graph export "${figures_png}fig_6_5_rc_cohort.png", replace  ///
		width(2750) height(2000)

* Period (Figure 6.6) ----------------------------------------------------------
		
foreach dv of varlist demonstration petition boycott  {
	export_marginsplot_chap6_rc ///
		chap6_`dv'_rc /// model name
		period // cohort or period
}

gr combine ///
	"${figures_gph}6_demonstration_rc_period.gph" ///
	"${figures_gph}6_petition_rc_period.gph" ///
	"${figures_gph}6_boycott_rc_period.gph", ///
	ycommon ///
	saving("${figures_gph}fig_6_6_rc_period.gph", replace)
graph export "${figures_pdf}fig_6_6_rc_period.pdf", replace
graph export "${figures_png}fig_6_6_rc_period.png", replace  ///
		width(2750) height(2000)
* ______________________________________________________________________________
* Close

log close
exit

