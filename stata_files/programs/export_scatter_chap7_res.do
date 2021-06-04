********************************************************************************
* Project:	Dissertation
* Task:		Chap. 7: Export residuals plot
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop export_scatter_chap7_res
program export_scatter_chap7_res
args dv 

preserve

collapse ///
	(first) postcommunist earlyprotest ///
	(mean) `dv' exposure_clr exposure_piv [pw = dweight], ///
	by(country)

gen temp_ln_clr = ln(exposure_clr)
gen temp_ln_piv = ln(exposure_piv)
	
reg `dv' temp_ln_clr temp_ln_piv
predict temp_res, res

reg temp_res earlyprotest

if "`dv'" == "demonstration" {
	local legend "col(1) off"
	local title "Attended a lawful demonstration"
} 	
if "`dv'" == "petition" {
	local legend "col(1) off"
	local title "Signed a petition"
} 
if "`dv'" == "boycott" {
	local legend "col(1) ring(0) pos(3) xoffset(60)"
	local title "Boycotted certain products"
}  

twoway ///
	(scatter temp_res earlyprotest if postcommunist == 1, ///
		mcolor("31 120 180") mlabel(country) mlabcolor("31 120 180")), ///
	yline(0,lcolor(edkblue)) ///
	xtitle("Early exposure to protest (generation 1989)") ///
	ytitle("Residuals") ///
	title("`title'") ///
	legend(`legend') ///
	saving("${figures_gph}7_scatter_res_`dv'.gph", replace)

restore

end
