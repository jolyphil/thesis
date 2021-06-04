********************************************************************************
* Project: Dissertation
* Task:    Chap. 4, Robustness checks
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

version 16
capture log close
capture log using "${logfiles}04_chap4_robustness.smcl", replace
set more off

set scheme minimal

* ______________________________________________________________________________
* Load external packages and programs

do "${programs}export_coefplot_chap4.do"
do "${programs}export_tab_APC_models.do"
do "${programs}model_chap4.do"
do "${programs}prepare_data_chap4.do"

* ______________________________________________________________________________
* Load merged dataset

use "${data}master.dta", clear

* ______________________________________________________________________________
* Prepare data

prepare_data_chap4

* ______________________________________________________________________________
* Robustness check 1: Exposure to repression (7-17 years old)

foreach dv of varlist demonstration petition boycott {
	
	model_chap4 ///
		`dv' /// dv
		"exposure_clr_7_17 exposure_piv_7_17" /// iv
		"" /// condition
		m1_`dv' /// from
		m1_`dv'_rc1 // modelname
}

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Export table

export_tab_APC_models /// 
	m1_demonstration_rc1 /// Model 1
	m1_petition_rc1 /// Model 2
	m1_boycott_rc1 /// Model 3
	"tbl_m1_rc1.tex" // filename

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Export coefplot (Figure 4.3)

export_coefplot_chap4 ///
	m1_demonstration_rc1 ///
	m1_petition_rc1 ///
	m1_boycott_rc1 ///
	"Exposure: 7 to 17 years old" ///
	fig_4_3_rc1
	
* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Save temporary data (backup)
	
save "${data_temp}chap4_m1_rc1.dta", replace

* ______________________________________________________________________________
* Robustness check 2: Liberation effect (15-25 years old)

foreach dv of varlist demonstration petition boycott {
	
	model_chap4 ///
		`dv' /// dv
		"liberation_clr liberation_piv" /// iv
		"" /// condition
		m1_`dv' /// from
		m1_`dv'_rc2 // modelname
}

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Export table

export_tab_APC_models /// 
	m1_demonstration_rc2 /// Model 1
	m1_petition_rc2 /// Model 2
	m1_boycott_rc2 /// Model 3
	"tbl_m1_rc2.tex" // filename

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Export coefplot (Figure 4.4)

export_coefplot_chap4 ///
	m1_demonstration_rc2 ///
	m1_petition_rc2 ///
	m1_boycott_rc2 ///
	"Relative measures (liberation effect)" ///
	fig_4_4_rc2
	
* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Save temporary data (backup)
	
save "${data_temp}chap4_m1_rc2.dta", replace
	
* ______________________________________________________________________________
* Close

log close
exit
