********************************************************************************
* Project: Dissertation
* Task:    Chap.5: Generate and export descriptive figures
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

version 16
capture log close
capture log using "${logfiles}05_chap5_descriptives.smcl", replace
set more off

set scheme minimal

* ______________________________________________________________________________
* Load external packages and programs

do "${programs}export_bar_chap5.do"
do "${programs}export_scatter_chap5.do"

* ______________________________________________________________________________
* Load data

use "${data}master.dta", clear

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Prepare data

keep if gen1989 == 1

* ______________________________________________________________________________
* Generate Figure 5.1: 
*     Protest experience of the 1989 generation as measured during the second 
*     wave of the European Values Study conducted between 1990 and 1993

export_bar_chap5

* ______________________________________________________________________________
* Generate Figure 5.3: 
*     Annual participation in demonstrations, petitions, and boycotts 
*     (2002-2017) as a function of early exposure to protest (1990-1993), 
*     aggregated by country

export_scatter_chap5 demonstration
export_scatter_chap5 petition
export_scatter_chap5 boycott

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Combine graphs

gr combine ///
	"${figures_gph}scatter_earlyprotest_demonstration.gph" ///
	"${figures_gph}scatter_earlyprotest_petition.gph" ///
	"${figures_gph}scatter_earlyprotest_boycott.gph", ///
	col(2) row(2)  ///
	saving("${figures_gph}fig_5_3_scatter_earlyprotest.gph", replace)
graph export "${figures_pdf}fig_5_3_scatter_earlyprotest.pdf", replace
graph export "${figures_png}fig_5_3_scatter_earlyprotest.png", replace ///
			width(2750) height(2000)

* ______________________________________________________________________________
* Close

log close
exit
