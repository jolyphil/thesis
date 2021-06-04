********************************************************************************
* Project:	Dissertation
* Task:		Export coefplots for Chap. 4
* Author:	Philippe Joly, WZB & HU-Berlin
********************************************************************************

capture program drop export_coefplot_chap4
program export_coefplot_chap4

capture ssc install coefplot

* ______________________________________________________________________________
* Input arguments

local M1 `1'
local M2 `2'
local M3 `3'
local title `4'
local saveas "`5'"

forvalues i = 1(1)3 {

	if regexm("`M`i''", "demonstration")==1 {
		local M`i'_label = "Demonstration"
	}
	else if regexm("`M`i''", "petition")==1 {
		local M`i'_label = "Petition"
	}
	else if regexm("`M`i''", "boycott")==1  {
		local M`i'_label = "Boycott"
	}
	else {
		error "Unknown variable"
	}

	display "`M`i'_label'"
}

* ______________________________________________________________________________
* Graph

#delimit ;
coefplot
	(`M1', label(`M1_label'))
	(`M2', label(`M2_label') msymbol(triangle))
	(`M3', label(`M3_label') msymbol(square)),
	keep(exposure_clr* exposure_piv* liberation_clr liberation_piv) 
	xline(0)
	title(`title')
	xtitle("LogitPr(Protest = 1)", size(small))
	coeflabels(
		exposure_clr* = "CLR"
		exposure_piv* = "PIV"
		liberation_clr = "CLR"
		liberation_piv = "PIV"
	)
	saving("${figures_gph}`saveas'.gph", replace)
;
#delimit cr

graph export "${figures_pdf}`saveas'.pdf", replace
graph export "${figures_png}`saveas'.png", replace ///
	width(2750) height(2000)
	
end
