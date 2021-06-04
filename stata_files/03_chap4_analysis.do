********************************************************************************
* Project: Dissertation
* Task:    Chap. 4, analysis
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

version 16
capture log close
capture log using "${logfiles}03_chap4_analysis.smcl", replace
set more off

set scheme minimal

* ______________________________________________________________________________
* Load external packages and programs

do "${programs}export_tab_APC_models.do"
do "${programs}prepare_data_chap4.do"
do "${programs}model_chap4.do"
do "${programs}export_marginsplot_chap4.do"

* ______________________________________________________________________________
* Load merged dataset

use "${data}master.dta", clear

* ______________________________________________________________________________
* Prepare data

prepare_data_chap4

* ______________________________________________________________________________
* Base model (m0)

foreach dv of varlist demonstration petition boycott {

	meqrlogit ///
			`dv' c.age10##c.age10 i.countrynum ///
			|| _all: R.countrywave || country_yrbrn:, 
	
	est store m0_`dv'
	est save  "${estimates}m0_`dv'.ster", replace
}

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Save temporary data (backup)
	
save "${data_temp}chap4_m0.dta", replace

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Export table

export_tab_APC_models /// 
	m0_demonstration /// 
	m0_petition /// 
	m0_boycott /// 
	"tbl_m0.tex" // filename
	
* ______________________________________________________________________________
* Main Model (m1): Exposure to CLR + exposure to PIV

foreach dv of varlist demonstration petition boycott {
	model_chap4 ///
		`dv' /// dv
		"exposure_clr exposure_piv" /// iv
		"" /// condition
		m0_`dv' /// from
		m1_`dv' // modelname
}

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Save temporary data (backup)
	
save "${data_temp}chap4_m1.dta", replace

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Export table

export_tab_APC_models /// 
	m1_demonstration /// 
	m1_petition /// 
	m1_boycott /// 
	"tbl_4_1_m1.tex" // filename

* ______________________________________________________________________________
* Export marginsplot: demonstration 

export_marginsplot_chap4 ///
	m1_demonstration /// modelname
	exposure_clr /// iv
	4_margins_clr // filename

export_marginsplot_chap4 ///
	m1_demonstration /// modelname
	exposure_piv /// iv
	4_margins_piv // filename

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Combine graphs and export (Figure 4.1)

gr combine ///
	"${figures_gph}4_margins_clr.gph" ///
	"${figures_gph}4_margins_piv.gph", ///
	ycommon ///
	title("Attended a lawful demonstration", size(small)) ///
	saving("${figures_gph}fig_4_2_margins.gph", replace)
graph export "${figures_pdf}fig_4_2_margins.pdf", replace
graph export "${figures_png}fig_4_2_margins.png", replace ///
	width(2750) height(2000)
	
* ______________________________________________________________________________
* Close

log close
exit
