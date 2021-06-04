********************************************************************************
* Project:	Transition spillovers
* Task:		Export regression tables for 3 multilevel models in TeX
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

* ______________________________________________________________________________
* Input arguments

local M1 `1' // Assume all models have the same hierarchical structure
local M2 `2'
local M3 `3'
local mnum1 = `4' // 1st model number
local filename "${tables_tex}`5'"

local models "`1' `2' `3'"

local mnum2 = `mnum1' + 1 // 2nd model number
local mnum3 = `mnum1' + 2 // 3rd model number

forvalues i = 1/3 {
	est restore `M`i''
	mat M_clust = e(N_g)
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Extract number of countries
	estadd scalar N_c = M_clust[1,1], replace : `M`i''
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Extract number of country-waves
	estadd scalar N_cw = M_clust[1,2], replace : `M`i''
	
	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Extract N subpopulation
	estadd scalar N_sub = e(N_sub), replace : `M`i''
}

* ______________________________________________________________________________
* Spaces and titles

local hspacing " & & & & & & \\ "
local vspacing "\hspace{0.4cm}"
local controls "Individual-level controls &\multicolumn{1}{c}{yes} & &\multicolumn{1}{c}{yes} & &\multicolumn{1}{c}{yes} & \\ "
* ______________________________________________________________________________
* Generate table

if `mnum1' > 3 {

	* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
	* Simplified table

	#delimit ;

	esttab `models' using "`filename'",
		replace b(2) se(2) noomit nobase wide booktabs fragment nonum
		star(+ 0.10 * 0.05 ** 0.01 *** 0.001) alignment(S S) compress
		mtitles("(`mnum1') Demonstration" "(`mnum2') Petition" "(`mnum3') Boycott")
		collabels("\multicolumn{1}{c}{Coef.}" "\multicolumn{1}{c}{SE}")
		equations(
			main=1:1:1, 
			var=2:2:2
			)
		eqlabels(none)
		drop(
			1.female
			agerel
			2.edu
			3.edu
			1.unemp
			1.partygroup
			1.union
			1.native
			2.city
			3.city
			4.city
			5.city
			2.class5
			3.class5
			4.class5
			5.class5
			)
		refcat( 
			1.postcommunist "\textit{Macro-level predictors}"
			, nolabel)
		coeflabel( 
			1.postcommunist "New democracy"
			earlyprotest "Early exp. to protest"
			1.postcommunist#c.earlyprotest "New democracy $\times$ Early exp. to protest"
			1.eastde "Eastern Germany"
			year "Year"
			lgdp_mean "Logged GDP/cap. (mean)"
			lgdp_diff "Logged GDP/cap. (diff.)"
			_cons "`hspacing'`controls'`hspacing'Intercept"
			
			var(_cons[country]) "\midrule Variance (countries)"
			var(_cons[country>countrywave]) "Variance (country-waves)"
			
			)
		stats(N_c N_cw N_sub, 
			fmt(0 0 0) 
			labels(
				`"N (countries)"'
				`"N (country-waves)"'
				`"N (individuals)"'
				
			))
		stardrop(var*:) 
	;

	#delimit cr
}
else {

* _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
*Full table

	#delimit ;

	esttab `models' using "`filename'",
		replace b(2) se(2) noomit nobase wide booktabs fragment nonum
		star(+ 0.10 * 0.05 ** 0.01 *** 0.001) alignment(S S) compress
		mtitles("(`mnum1') Demonstration" "(`mnum2') Petition" "(`mnum3') Boycott")
		collabels("\multicolumn{1}{c}{Coef.}" "\multicolumn{1}{c}{SE}")
		equations(
			main=1:1:1, 
			var=2:2:2
			)
		eqlabels(none)
		refcat( 
			1.female "\textit{Individual-level predictors}"
			2.edu "Education, Low (ref.)"
			2.city "Town size, Home in countryside (ref.)"
			2.class5 "Social class, Unskilled workers (ref.)"
			1.postcommunist "`hspacing'\textit{Macro-level predictors}"
			, nolabel)
		coeflabel( 
			1.female "Woman" 
			agerel "Age, relative"	
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
			1.postcommunist "New democracy"
			earlyprotest "Early exp. to protest"
			1.postcommunist#c.earlyprotest "New democracy x Early exp. to protest"
			1.eastde "Eastern Germany"
			year "Year"
			lgdp_mean "Logged GDP/cap. (mean)"
			lgdp_diff "Logged GDP/cap. (diff.)"
			_cons "`hspacing'Intercept"
			
			var(_cons[country]) "\midrule Variance (countries)"
			var(_cons[country>countrywave]) "Variance (country-waves)"
			
			)
		stats(N_c N_cw N_sub, 
			fmt(0 0 0) 
			labels(
				`"N (countries)"'
				`"N (country-waves)"'
				`"N (individuals)"'
				
			))
		stardrop(var*:) 
	;

	#delimit cr
}


