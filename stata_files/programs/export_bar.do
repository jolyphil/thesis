********************************************************************************
* Project:	Dissertation
* Task:		Export bar chart
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop export_bar
program export_bar
args var

capture ssc install sencode

* ______________________________________________________________________________
* Preserve

preserve

* ______________________________________________________________________________
* Assign title

if "`var'" == "demonstration" {
	local title "Attended a lawful demonstration"
}
else if "`var'" == "petition" {
	local title "Signed a petition"
}
else if "`var'" == "boycott" {
	local title "Boycotted certain products"
}
else {
	display as err "Error: Unknown variable"
	exit
}

* ______________________________________________________________________________
* Collapse

sort country
collapse ///
	(mean) `var' ///
	(first) postcommunist ///
	[pweight=dweight], by(country)

* ______________________________________________________________________________
* Convert to percentages

replace `var' = `var' * 100

* ______________________________________________________________________________
* Sort countries
	
gsort `var'
sencode country, gen(countryrank)
summ countryrank
local N_c = r(max)
disp `N_c'

* ______________________________________________________________________________
* Mean and SD

summ `var' if postcommunist == 1
local mean_newdem = round(r(mean), 0.1)
local mean_newdem : di %3.1f `mean_newdem'

summ `var' if postcommunist == 0
local mean_olddem = round(r(mean), 0.1)
local mean_olddem : di %3.1f `mean_olddem'

* ______________________________________________________________________________
* Generate graph

twoway ///
	(bar `var' countryrank if postcommunist==0, ///
		sort horizontal fcolor("166 206 227") lwidth(none) ///
		barwidth(0.8)) ///
	(bar `var' countryrank if postcommunist==1, ///
		sort horizontal fcolor("31 120 180") lwidth(none) ///
		barwidth(0.8)), ///
	title("`title'") ///
	xtitle("Percentage, last 12 months") ///
	ylabel(1(1)`N_c', valuelabel nogrid) ///
	ytitle("") ///
	legend(position(7) ///
		order(1 "Old democracies" "(mean = `mean_olddem')" ///
			  2 "New democracies" "(mean = `mean_newdem')")) ///
	saving("${figures_gph}bar_`var'.gph", replace)
	
* ______________________________________________________________________________
* Restore

restore

end
