********************************************************************************
* Project:	Dissertation
* Task:		Chap. 5: Export bar chart
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop export_bar_chap5
program export_bar_chap5

* ______________________________________________________________________________
* Install necessary programs

ssc install sencode

* ______________________________________________________________________________
* Preserve

preserve

* ______________________________________________________________________________
* Collapse

sort country
keep if earlyprotest != .
collapse (first) earlyprotest postcommunist, by(country)

* ______________________________________________________________________________
* Sort countries
	
gsort earlyprotest
sencode country, gen(countryrank)
summ countryrank
local N_c = r(max) // Count number of countries

* ______________________________________________________________________________
* Mean 

summ earlyprotest if postcommunist == 1
local mean_newdem = round(r(mean), 0.01)
local mean_newdem : di %3.2f `mean_newdem'

summ earlyprotest if postcommunist == 0
local mean_olddem = round(r(mean), 0.01)
local mean_olddem : di %3.2f `mean_olddem'

* ______________________________________________________________________________
*SD

summ earlyprotest if postcommunist == 1
local sd_newdem = round(r(sd), 0.01)
local sd_newdem : di %3.2f `sd_newdem'

summ earlyprotest if postcommunist == 0
local sd_olddem = round(r(sd), 0.01)
local sd_olddem : di %3.2f `sd_olddem'

* ______________________________________________________________________________
* Generate graph

twoway ///
	(bar earlyprotest countryrank if postcommunist==1, ///
		sort horizontal fcolor("31 120 180") lwidth(none) ///
		barwidth(0.8)) ///
	(bar earlyprotest countryrank if postcommunist==0, ///
		sort horizontal fcolor("166 206 227") lwidth(none) ///
		barwidth(0.8)), ///
	title("`title'") ///
	xlabel(0(0.1)0.6) ///
	xtitle("Proportion having taken part in a demonstration") ///
	ylabel(1(1)`N_c', valuelabel nogrid) ///
	ytitle("") ///
	legend(position(3) ///
		order(1 "New democracies" "(mean = `mean_newdem'; sd = `sd_newdem')" ///
			  2 "Old democracies" "(mean = `mean_olddem'; sd = `sd_olddem')")) ///
	saving("${figures_gph}fig_5_1_earlyprotest.gph", replace)
graph export "${figures_pdf}fig_5_1_earlyprotest.pdf", replace
graph export "${figures_png}fig_5_1_earlyprotest.png", replace ///
			width(2750) height(2000)
	
* ______________________________________________________________________________
* Restore

restore

end
