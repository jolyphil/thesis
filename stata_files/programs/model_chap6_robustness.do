********************************************************************************
* Project:	Dissertation
* Task:		Chapter 6: Model, robustness checks
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop model_chap6_robustness
program model_chap6_robustness
args dv modelname

local controls "i.female i.edu i.unemp i.union i.city i.class5 i.land_de"

logit `dv' i.eastsoc i.cohort i.period ///
	i.eastsoc#i.cohort i.eastsoc#i.period `controls' [pw=dweight]

est store `modelname'
est save  "${estimates}`modelname'.ster", replace

end
