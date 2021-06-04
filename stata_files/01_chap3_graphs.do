********************************************************************************
* Project: Dissertation
* Task:    Chapter 3: graphs
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

* version 16
capture log close
capture log using "${logfiles}01_chap3_graphs.smcl", replace
set more off

set scheme minimal

* ______________________________________________________________________________
* Load programs

do "${programs}export_bar.do"
do "${programs}export_trend.do"
do "${programs}export_connected_by_country.do"

* ______________________________________________________________________________
* Load merged dataset

use "${data}master.dta", clear

* ______________________________________________________________________________
* Bar charts

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Generate separate bar charts

export_bar demonstration
export_bar petition
export_bar boycott

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Combine graph and export (Figure 3.2)

gr combine ///
	"${figures_gph}bar_demonstration.gph" ///
	"${figures_gph}bar_petition.gph" ///
	"${figures_gph}bar_boycott.gph", ///
	col(3) row(1) xsize(3) ysize(2) ///
	saving("${figures_gph}fig_3_2_bar_combined.gph", replace)
graph export "${figures_pdf}fig_3_2_bar_combined.pdf", replace
graph export "${figures_png}fig_3_2_bar_combined.png", replace ///
	width(3000) height(2000)

* ______________________________________________________________________________
* Overall trends
	
* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Generate separate trend graphs

export_trend demonstration
export_trend petition
export_trend boycott

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Combine graphs (Figure 3.3)

gr combine ///
	"${figures_gph}trend_demonstration.gph" ///
	"${figures_gph}trend_petition.gph" ///
	"${figures_gph}trend_boycott.gph", ///
	col(2) row(2) /*xcommon ycommon*/ ///
	saving("${figures_gph}fig_3_3_trend_combined.gph", replace)
graph export "${figures_pdf}fig_3_3_trend_combined.pdf", replace
graph export "${figures_png}fig_3_3_trend_combined.png", replace ///
	width(2750) height(2000)

* ______________________________________________________________________________
* Country connected lines (Figures B.1 and B.2)

* Export graph: new democracies
export_connected_by_country ///
	"postcommunist == 1" /// sample
	fig_B_1_connected_newdem // filename
	
* Export graph: old democracies
export_connected_by_country ///
	"postcommunist == 0" /// sample
	fig_B_2_connected_olddem // filename
	
* ______________________________________________________________________________
* Close

log close
exit
