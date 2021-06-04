********************************************************************************
* Project: Dissertation
* Task:    Chap. 5: Perform the multilevel analysis
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

version 16
capture log close
capture log using "${logfiles}06_chap5_analysis.smcl", replace
set more off

capture ssc install estout

set scheme minimal

* ______________________________________________________________________________
* Load external packages and programs

do "${programs}prepare_data_chap5.do"

* ______________________________________________________________________________
* Load merged dataset

use "${data}master.dta", clear

* ______________________________________________________________________________
* Prepare data

prepare_data_chap5

* ______________________________________________________________________________
* Set survey characteristics

gen one = 1
svyset country, weight(one) || countrywave, weight(one) || _n, weight(dweight)

* ______________________________________________________________________________
* Multilevel models

* Individual-level controls, incorporated in all models
local iv_L1 "i.female agerel i.edu i.unemp i.partygroup i.union i.native i.city i.class5"

foreach dv of varlist demonstration petition boycott {
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Models 1, 2, and 3
	
	local iv "`iv_L1' i.postcommunist##c.earlyprotest"
	svy, subpop(gen1989): melogit `dv' `iv' || country: || countrywave: 
	est store M_a_`dv'
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Models 4, 5, and 6
	
	local iv "`iv_L1' i.postcommunist##c.earlyprotest i.eastde"
	svy, subpop(gen1989): melogit `dv' `iv' || country: || countrywave: 
	est store M_b_`dv'
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Models 7, 8, and 9
	
	local iv "`iv_L1' i.postcommunist##c.earlyprotest i.eastde year lgdp_mean lgdp_diff"
	svy, subpop(gen1989): melogit `dv' `iv' || country: || countrywave: 
	est store M_c_`dv'
}

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Export tables

do "${programs}export_tab_3MLM_tex.do" ///
	"M_a_demonstration" /// Save models
	"M_a_petition" ///
	"M_a_boycott" ///
	1 /// 1st model number
	"tbl_5_2_MLM_a.tex"
	
do "${programs}export_tab_3MLM_tex.do" ///
	"M_b_demonstration" /// Save models
	"M_b_petition" ///
	"M_b_boycott" ///
	4 /// 1st model number
	"tbl_5_3_MLM_b.tex"
	
do "${programs}export_tab_3MLM_tex.do" ///
	"M_c_demonstration" /// Save models
	"M_c_petition" ///
	"M_c_boycott" ///
	7 /// 1st model number
	"tbl_5_4_MLM_c.tex"

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Adjusted prediction

egen tag_c = tag(country)
gen bar = "|" // Small bars used to display distribution of cases
gen ypos = -0.0175 // Vertical position of the bars

foreach dv of varlist demonstration petition boycott {
* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Restore base models 1, 2, and 3
est restore M_a_`dv'

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Generate adjusted predictions for each protest activity separately 
margins postcommunist, at(earlyprotest=(0(0.1)0.6)) subpop(gen1989)

if "`dv'" == "demonstration" {
	local legend "col(1) off"
	local title "Attended a lawful demonstration"
} 	
if "`dv'" == "petition" {
	local legend "col(1) off"
	local title "Signed a petition"
} 
if "`dv'" == "boycott" {
	local legend "col(1) ring(0) pos(3) xoffset(60)"
	local title "Boycotted certain products"
} 
* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Generate plots for each protest activity

#delimit ;
marginsplot, 
	plot1opts(mcolor("166 206 227") lcolor("166 206 227"))
	plot2opts(mcolor("31 120 180") lcolor("31 120 180"))
	addplot( 
		scatter ypos earlyprotest if tag_c == 1 & postcommunist==0, 
			msymbol(i) mlabpos(0) mlabel(bar) mlabcolor("166 206 227") || 
		scatter ypos earlyprotest if tag_c == 1 & postcommunist==1, 
			msymbol(i) mlabpos(0) mlabel(bar) mlabcolor("31 120 180") 
			legend(order(3 "Old democracies" 4 "New democracies"))
		) 
	title("`title'")
	xtitle("Early exposure to protest")
	ytitle("Predicted probabilities")
	legend(`legend')
	
	saving("${figures_gph}5_pred_prob_`dv'.gph", replace);
	
#delimit cr
}
* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Generate Figure 5.4:
*     Predicted probabilities of having taken part in a protest activity in the
*     12 months preceding the survey, in new and old democracies, as a function 
*     as a function of the protest level measured during the second wave of the 
*     EVS(based on Models 3, 6, and 9)

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Combine plots

gr combine ///
	"${figures_gph}5_pred_prob_demonstration.gph" ///
	"${figures_gph}5_pred_prob_petition.gph" ///
	"${figures_gph}5_pred_prob_boycott.gph", ///
	col(2) row(2) xcommon ycommon ///
	saving("${figures_gph}fig_5_4_pred_prob.gph", replace)
graph export "${figures_pdf}fig_5_4_pred_prob.pdf", replace
graph export "${figures_png}fig_5_4_pred_prob.png", replace  ///
			width(2750) height(2000)

* ______________________________________________________________________________
* Close

log close
exit
