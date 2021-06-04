********************************************************************************
* Project:	Dissertation
* Task:		Export connected lines, by country
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop export_connected_by_country
program export_connected_by_country
args sample filename

* ______________________________________________________________________________
* Load programs

do "${programs}cluster_centering.do"

* ______________________________________________________________________________
* Preserve

preserve

* ______________________________________________________________________________
* Adjust sample

if "`sample'" != "" {
		keep if `sample'
	}
	
* ______________________________________________________________________________
* Generate country mean, country-wave mean, and differences

cluster_centering demonstration
cluster_centering petition
cluster_centering boycott

* ______________________________________________________________________________
* Generate temporary tages

egen tag_c = tag(country)
egen tag_cw = tag(countrywave)

* ______________________________________________________________________________
* Determine legend position

summ tag_c
local legend_at = r(sum) + 1

* ______________________________________________________________________________
* Generate temporary tages

twoway ///
	(connected demonstration_mean_cw year if tag_cw == 1, ///
		sort msymbol(circle)) ///
	(connected petition_mean_cw year if tag_cw == 1, ///
		sort msymbol(triangle)) ///
	(connected boycott_mean_cw year if tag_cw == 1, ///
		sort msymbol(square)), ///
	by(, legend(position(3) at(`legend_at'))) ///
		legend(order(1 "Attended a lawful demonstration" ///
					 2 "Signed a petition" ///
					 3 "Boycotted certain products")) ///
	by(country, note("")) ///
	xlabel(2002(4)2018) ///
	xtitle("Year", size(2)) ///
	ytitle("Proportion, last 12 months", size(2)) ///
	saving("${figures_gph}`filename'.gph", replace)
graph export "${figures_pdf}`filename'.pdf", replace
graph export "${figures_png}`filename'.png", replace  ///
	width(3000) height(2000)
	
* ______________________________________________________________________________
* Restore

restore

end
