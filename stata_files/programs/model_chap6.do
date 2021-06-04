********************************************************************************
* Project:	Dissertation
* Task:		Chapter 6: Model
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop model_chap6
program model_chap6
args dv level_rs modelname

local iv "i.eastsoc i.female c.age10##c.age10 i.edu i.unemp i.union i.city i.class5 i.land_de"

if "`level_rs'" == "cohort" {
	local re "|| _all: R.period || cohort: eastsoc"
}
else if "`level_rs'" == "period" {
	local re "|| _all: R.cohort || period: eastsoc"
}

meqrlogit `dv' `iv' `re'
est store `modelname'
est save  "${estimates}`modelname'.ster", replace

end
