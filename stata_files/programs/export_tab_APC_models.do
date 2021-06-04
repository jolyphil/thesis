********************************************************************************
* Project:	Dissertation
* Task:		Export regression tables for 3 models in TeX
* Author:	Philippe Joly, WZB & HU-Berlin
********************************************************************************

capture program drop export_tab_APC_models
program export_tab_APC_models

capture ssc install estout

* ______________________________________________________________________________
* Input arguments

local M1 `1' // Assume all models have the same hierarchical structure
local M2 `2'
local M3 `3'

local saveas "${tables_tex}`4'"

* ______________________________________________________________________________
* Hierarchical structure

est restore `M1'

local posspace = strpos(e(ivars), " ") 
	// find position of space in stored result e(ivars)
	// e.g. "_all cohort" --> position = 5
local L2 = substr(e(ivars),`posspace' + 1,.)
	// extract second grouping variable, e.g "cohort"
if "`L2'" == "country_yrbrn" {
	local L3 "countrywave"
	
	local L2_lbl "country-cohort"
	local L3_lbl "country-wave"
} 
else {
	local L2_lbl "country-wave"
	local L3_lbl "country-cohort"
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
local subtitle1 "\textit{Exposure to repression} & & & & & & \\ "
local subtitle2 "\textit{Individual-level variables} & & & & & & \\ "
local subtitle3 "\textit{Country-wave-level variables} & & & & & & \\ "
local dummies "Country dummies &\multicolumn{1}{c}{yes} & &\multicolumn{1}{c}{yes} & &\multicolumn{1}{c}{yes} & \\ "

* ______________________________________________________________________________
* Table

#delimit ;

esttab `M1' `M2' `M3' using `saveas', replace 
	b(2) se(2) noomit nobase noobs wide booktabs fragment nonum
	star(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardrop(ln*:_cons) alignment(S S) 
	compress
	mtitles("Demonstration" "Petition" "Boycott")
	collabels("\multicolumn{1}{c}{Coef.}" "\multicolumn{1}{c}{SE}")
	drop(*.countrynum)
	refcat( 
		2.edu "Education, Low (ref.)"
		2.city "Town size, Home in countryside (ref.)"
		2.class5 "Social class, Unskilled workers (ref.)" 
		, nolabel
		) 
	coeflabel(
		exposure_clr "`subtitle1'Civil liberties restrictions"
		exposure_clr_7_17 "`subtitle1'Civil liberties restrictions"
		exposure_piv "Personal integrity violations"
		exposure_piv_7_17 "Personal integrity violations"
		liberation "`subtitle1A'Liberation"
		1.female "`hspacing'`subtitle2'Woman" 
		age10 "Age (10 years)"
		c.age10#c.age10 "Age\textsuperscript{2}"	
		2.edu "`vspacing'Middle"
		3.edu "`vspacing'High"
		1.unemp "Unemployed"
		1.partygroup "Worked for party or group"
		1.union "Union member" 
		1.native "Native"
		2.city "`vspacing'Country village"
		3.city "`vspacing'Town or small city"
		4.city "`vspacing'Outskirts of big city"
		5.city "`vspacing'A big city"
		2.class5 "`vspacing'Skilled workers"
		3.class5 "`vspacing'Small business owners"
		4.class5 "`vspacing'Low service class"
		5.class5 "`vspacing'Higher service class"
		year "`hspacing'`subtitle3'Year"
		polyarchy_lag "Electoral democracy index"
		lgdp_lag "Logged GDP/cap."
		_cons "`hspacing'`dummies'`hspacing'Intercept"
		)
	transform(ln*: exp(2*@) 2*exp(2*@))
	eqlabels("" "\midrule Variance (`L3_lbl')" "Variance (`L2_lbl')", none)
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
			`"N (`L3_lbl's)"'
			`"N (`L2_lbl's)"'
			`"N (individuals)"'
			)
		)
;

#delimit cr

end
