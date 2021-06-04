********************************************************************************
* Project:	Dissertation
* Task:		Export marginsplot, chap. 4
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop export_marginsplot_chap4
program export_marginsplot_chap4
args modelname iv filename

est restore `modelname'

/*
* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Define title

if regexm("`modelname'", "demonstration")==1 {
	local title "Attended a lawful demonstration"
}
else if regexm("`modelname'", "petition")==1 {
	local title "Signed a petition"
}
else if regexm("`modelname'", "boycott")==1  {
	local title "Boycotted certain products"
}
else {
	error "Unknown model"
}
*/

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Define x-axis title

if "`iv'" == "exposure_clr" {
	local xtitle "Early exposure to CLR"
}
else if "`iv'" == "exposure_piv" {
	local xtitle "Early exposure to PIV"
}

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Store 10th and 90th percentile

qui: summ `iv', d
local p10 = r(p10)
local p90 = r(p90)

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Calculate marginal effects

margins, at(`iv'=(`p10' `p90')) predict(mu fixed)

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
* Generate and export plot

marginsplot, ///
	plotopts(color("31 120 180")) ciopts(color("31 120 180")) ///
	title("") ///
	xtitle("`xtitle'") ///
	ytitle("Predicted probabilities") ///
	saving("${figures_gph}`filename'.gph", replace)

* ______________________________________________________________________________
* Load programs


end
