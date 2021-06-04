********************************************************************************
* Project:	Dissertation
* Task:		Look for missing data by country
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop look_for_missing
program look_for_missing
args var

encode country, generate(temp_countrynum)

qui: summ temp_countrynum
local temp_Ncountry = r(max) // count number of countries

forvalues c = 1(1)`temp_Ncountry' {

	tab country `var' if temp_countrynum == `c', miss
}

drop temp_*

end