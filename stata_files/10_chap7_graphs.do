********************************************************************************
* Project: Dissertation
* Task:    Chap. 7, Graphs
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

version 16
capture log close
capture log using "${logfiles}10_chap7_graphs.smcl", replace
set more off

set scheme minimal

* ______________________________________________________________________________
* Load external packages and programs

do "${programs}export_scatter_chap7.do"
do "${programs}export_scatter_chap7_res.do"

* ______________________________________________________________________________
* Load merged dataset

use "${data}master.dta", clear

* ______________________________________________________________________________
* Export scatter plots

* Exposure CLR (Figure 7.1) ----------------------------------------------------

foreach dv of varlist demonstration petition boycott {
	export_scatter_chap7 `dv' exposure_clr
}

gr combine ///
	"${figures_gph}7_scatter_demonstration_exposure_clr.gph" ///
	"${figures_gph}7_scatter_petition_exposure_clr.gph" ///
	"${figures_gph}7_scatter_boycott_exposure_clr.gph", ///
	col(2) row(2)  ///
	saving("${figures_gph}fig_7_1_scatter_exposure_clr.gph", replace)
graph export "${figures_pdf}fig_7_1_scatter_exposure_clr.pdf", replace
graph export "${figures_png}fig_7_1_scatter_exposure_clr.png", replace ///
		width(2750) height(2000)

* Exposure PIV (Figure 7.2) ----------------------------------------------------

foreach dv of varlist demonstration petition boycott {
	export_scatter_chap7 `dv' exposure_piv
}

gr combine ///
	"${figures_gph}7_scatter_demonstration_exposure_piv.gph" ///
	"${figures_gph}7_scatter_petition_exposure_piv.gph" ///
	"${figures_gph}7_scatter_boycott_exposure_piv.gph", ///
	col(2) row(2)  ///
	saving("${figures_gph}fig_7_2_scatter_exposure_piv.gph", replace)
graph export "${figures_pdf}fig_7_2_scatter_exposure_piv.pdf", replace
graph export "${figures_png}fig_7_2_scatter_exposure_piv.png", replace ///
		width(2750) height(2000)
			
* ______________________________________________________________________________
* Export residual plot (Figure 7.3)

foreach dv of varlist demonstration petition boycott {
	export_scatter_chap7_res `dv'
}

gr combine ///
	"${figures_gph}7_scatter_res_demonstration.gph" ///
	"${figures_gph}7_scatter_res_petition.gph" ///
	"${figures_gph}7_scatter_res_boycott.gph", ///
	col(2) row(2)  ///
	saving("${figures_gph}fig_7_3_scatter_res.gph", replace)
graph export "${figures_pdf}fig_7_3_scatter_res.pdf", replace
graph export "${figures_png}fig_7_3_scatter_res.png", replace ///
		width(2750) height(2000)

* ______________________________________________________________________________
* Data on membership

preserve

collapse ///
	(first) postcommunist ///
	(mean) partygroup [pw = dweight], ///
	by(country)

summ partygroup if postcommunist == 1
summ partygroup if postcommunist == 0
	
restore
		
* ______________________________________________________________________________
* Close

log close
exit
