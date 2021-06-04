********************************************************************************
* Project:	Dissertation
* Task:		Chap. 7: Export scatter plot, bivariate relationship
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop export_scatter_chap7
program export_scatter_chap7
args dv iv

preserve

collapse ///
	(first) postcommunist ///
	(mean) `dv' `iv' [pw = dweight], ///
	by(country)

gen temp_ln = ln(`iv') // Logarithmic transformation
	
reg `dv' temp_ln

local b0 = _b[_cons] // Store intercept
local b1 = _b[temp_ln] // Store slope

summ `iv'
local max = r(max) // Define range
local min = r(min)

if "`dv'" == "demonstration" {
	local legend "col(1) off"
	local title "Attended a lawful demonstration"
} 	
if "`dv'" == "petition" {
	local legend "col(1) off"
	local title "Signed a petition"
} 
if "`dv'" == "boycott" {
	local legend "col(1) ring(0) pos(3) xoffset(60) order(1 `"Old democracies"' 2 `"New democracies"' 3 `"Logarithmic prediction"')"
	local title "Boycotted certain products"
}  

if "`iv'" == "exposure_clr" {
	local xtitle "Early Exposure to CLR, mean"
} 	
if "`iv'" == "exposure_piv" {
	local xtitle "Exposure to PIV, mean"
} 

twoway ///
	(scatter `dv' `iv' if postcommunist==0, ///
		mcolor("166 206 227") mlabel(country)) ///
	(scatter `dv' `iv' if postcommunist == 1, ///
		mcolor("31 120 180") mlabel(country)) ///
	(function y=`b0'+`b1'*ln(x), range(`min' `max')), ///
	xtitle("`xtitle'") ///
	ytitle("Proportion, last 12 months") ///
	title("`title'") ///
	legend(`legend') ///
	saving("${figures_gph}7_scatter_`dv'_`iv'.gph", replace)

restore

end
