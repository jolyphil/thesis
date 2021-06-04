********************************************************************************
* Project:	Dissertation
* Task:		Chap. 6: Export regression tables for 3 APC models in TeX
* Author:	Philippe Joly, WZB & HU-Berlin
********************************************************************************

capture program drop export_tab_APC_chap6
program export_tab_APC_chap6

capture ssc install estout

* ______________________________________________________________________________
* Input arguments

local M1 `1' // Assume all models have the same hierarchical structure
local M2 `2'
local M3 `3'

local mnum1 = `4' // 1st model number
local mnum2 = `mnum1' + 1 // 2nd model number
local mnum3 = `mnum1' + 2 // 3rd model number

local saveas_a "${tables_tex}`5'_a.tex"
local saveas_b "${tables_tex}`5'_b.tex"

* ______________________________________________________________________________
* Hierarchical structure

est restore `M1'

local posspace = strpos(e(ivars), " ") 
	// find position of space in stored result e(ivars)
	// e.g. "_all cohort" --> position = 5
local L2 = substr(e(ivars),`posspace' + 1,.)
	// extract second grouping variable, e.g "cohort"
if "`L2'" == "cohort" {
	local L3 "period"
} 
else {
	local L3 "cohort"
}
disp "Note: `L2' nested within `L3'."	

* ______________________________________________________________________________
* Extract number of clusters

forval i = 1/3 {
	est restore `M`i''
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Number of clusters at L2
	mat M_clust = e(N_g)
	estadd scalar N_L2 = M_clust[1,2], replace : `M`i''
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Number of clusters at L3

	tempvar tag_L3
	tempvar sum_L3_clusters
	
	egen `tag_L3' = tag(`L3') if e(sample)==1
	egen `sum_L3_clusters' = sum(`tag_L3')
	summ `sum_L3_clusters'
	estadd scalar N_L3 = r(max), replace : `M`i''
	
	drop `tag_L3' `sum_L3_clusters'
}
* ______________________________________________________________________________
* Spaces and subtitles

local vspacing "\hspace{0.4cm}"
local hspacing " & & & &  & & \\ "
local subtitle1 "\textit{Individual-level variables} & & & & & & \\ "
local subtitle2 "\textit{State fixed effects} & & & & & & \\ "
*local notdisp "XX dummy &\multicolumn{1}{c}{yes} & &\multicolumn{1}{c}{yes} & &\multicolumn{1}{c}{yes} & \\ "

* ______________________________________________________________________________
* Table

#delimit ;

esttab `M1' `M2' `M3' using "`saveas_a'", replace 
	b(2) se(2) noomit nobase noobs wide booktabs fragment nonum
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) alignment(S S) compress
	mtitles("(`mnum1') Demonstration" "(`mnum2') Petition" "(`mnum3') Boycott")
	collabels("\multicolumn{1}{c}{Coef.}" "\multicolumn{1}{c}{SE}")
	drop(*.land_de _cons)
	refcat( 
		2.edu "Education, Low (ref.)"
		2.city "Town size, Home in countryside (ref.)"
		2.class5 "Social class, Unskilled workers (ref.)" 
		, nolabel
		) 
	coeflabel(
		1.eastsoc "`subtitle1'East German"
		1.female "Woman" 
		age10 "Age (10 years)"
		c.age10#c.age10 "Age\textsuperscript{2}"	
		2.edu "`vspacing'Middle"
		3.edu "`vspacing'High"
		1.unemp "Unemployed" 
		1.union "Union member" 
		2.city "`vspacing'Country village"
		3.city "`vspacing'Town or small city"
		4.city "`vspacing'Outskirts of big city"
		5.city "`vspacing'A big city"
		2.class5 "`vspacing'Skilled workers"
		3.class5 "`vspacing'Small business owners"
		4.class5 "`vspacing'Low service class"
		5.class5 "`vspacing'Higher service class"
		)
	eqlabels("" "" "" "", none)
;

esttab `M1' `M2' `M3' using "`saveas_b'", replace 
	b(2) se(2) noomit nobase noobs wide booktabs fragment nonum
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardrop(ln*:_cons) alignment(S S) 
	compress
	mtitles("(`mnum1') Demonstration" "(`mnum2') Petition" "(`mnum3') Boycott")
	collabels("\multicolumn{1}{c}{Coef.}" "\multicolumn{1}{c}{SE}")
	label
	keep(*.land_de *_cons)
	refcat( 
		2.land_de "`subtitle2'Baden-Wuerttemberg (ref.)"
		, nolabel) 
	coeflabel(		
		_cons "`hspacing'Intercept"
		)
	transform(ln*: exp(2*@) 2*exp(2*@))
	eqlabels("" "\midrule Variance (`L3': intercept)" "Variance (`L2': slope)" "Variance (`L2': intercept)", none)
	stats(bic N_L3 N_L2 N, 
		fmt(1 0 0 0)
		layout(
			"\multicolumn{1}{c}{@}"
			"\multicolumn{1}{c}{@}"
			"\multicolumn{1}{c}{@}"
			"\multicolumn{1}{c}{@}"
			)
		labels(
			`"BIC"'
			`"N (`L3's)"'
			`"N (`L2's)"'
			`"N (individuals)"'
			)
		)
;

#delimit cr

end
