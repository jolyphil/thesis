********************************************************************************
* Project:	Dissertation
* Task:		Chapter 4: Model
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop model_chap4
program model_chap4
args dv iv condition from modelname

	local controls "i.female c.age10##c.age10 i.edu i.unemp i.partygroup i.union i.native i.city i.class5 year polyarchy_lag lgdp_lag i.countrynum"

	if "`from'" != "" {
		est use "${estimates}`from'.ster"
		mat temp_est = e(b)
		
		capture noisily meqrlogit ///
			`dv' `iv' `controls' `condition' ///
			|| _all: R.countrywave || country_yrbrn:, from(temp_est, skip)
			
		mat drop temp_est
	}
	else  {
		capture noisily meqrlogit ///
			`dv' `iv' `controls' `condition' ///
			|| _all: R.countrywave || country_yrbrn:, 
	}
	
	est store `modelname'
	est save  "${estimates}`modelname'.ster", replace
	
end
