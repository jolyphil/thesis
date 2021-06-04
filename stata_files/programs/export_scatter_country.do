	********************************************************************************
* Project:	Dissertation
* Task:		Export scatter plot, bivariate relationship at the country-level
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop export_scatter_country
program export_scatter_country
args y x

preserve

collapse (mean) `y' `x' [pw = dweight], by(country)

regress `y' `x'
predict temp_xb

if "`y'" == "demonstration" {
	local legend "col(1) off"
	local title "Attended a lawful demonstration"
} 	
if "`y'" == "petition" {
	local legend "col(1) off"
	local title "Signed a petition"
} 
if "`y'" == "boycott" {
	local legend "col(1) ring(0) pos(3) xoffset(60) order(1 `"Fitted value"' 2 `"Country-mean"')"
	local title "Boycotted certain products"
} 

if "`x'" == "exposure_clr" {
	local xtitle "Early exposure to CLR, mean"
}

if "`x'" == "exposure_piv" {
	local xtitle "Early exposure to PIV, mean"
}

twoway ///
	(line temp_xb `x', sort mlabel(country)) ///
	(scatter `y' `x', sort mlabel(country)), ///
	xtitle("`xtitle'") ///
	ytitle("Proportion, last 12 months") ///
	title("`title'") ///
	legend(`legend') ///
	saving("${figures_gph}scatter_`y'_`x'.gph", replace)

restore

end
