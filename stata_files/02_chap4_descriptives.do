********************************************************************************
* Project: Dissertation
* Task:    Chap. 4, Descriptives
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

version 16
capture log close
capture log using "${logfiles}02_chap4_descriptives.smcl", replace
set more off

set scheme minimal

* ______________________________________________________________________________
* Load external packages and programs

do "${programs}export_scatter_country.do"

* ______________________________________________________________________________
* Load merged dataset

use "${data}master.dta", clear

* ______________________________________________________________________________
* Keep postcommunist democracies only

keep if postcommunist == 1

* ______________________________________________________________________________
* Graph: Exposure by year of birth, by country (Figure 4.1)

by country yrbrn, sort: egen yearmax = max(year)

twoway ///
	(line exposure_clr yrbrn if year == yearmax, ///
		sort lcolor(black)) ///
	(line exposure_piv yrbrn if year == yearmax, ///
		sort lcolor(cranberry) lpattern(dash)), ///
	by(, legend(position(3) at(11))) ///
		legend(order(1 "Civil liberties restrictions (CLR)" 2 "Personal integrity violations (PIV)") ///
			   title("Early exposure to repression", size(3) just(left) bexpand)) /// 
	by(country, note("")) ///
	xtitle("Year of birth", size(2)) ///
	ytitle("Level of exposure", size(2)) ///
	saving("${figures_gph}fig_4_1_exposure.gph", replace)
graph export "${figures_pdf}fig_4_1_exposure.pdf", replace
graph export "${figures_png}fig_4_1_exposure.png", replace  ///
	width(2750) height(2000)

* Note: just(left) bexpand --> trick to move legend title to the left
	
* ______________________________________________________________________________
* Close

log close
exit
