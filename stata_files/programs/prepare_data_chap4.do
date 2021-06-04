********************************************************************************
* Project:	Dissertation
* Task:		Chapter 4: Prepare data for analysis
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop prepare_data_chap4
program prepare_data_chap4

* ______________________________________________________________________________
* Load external packages and programs

do "${programs}cluster_centering.do"

* ______________________________________________________________________________
* Keep postcommunist democracies only

keep if postcommunist == 1

* ______________________________________________________________________________
* Center macro variables

cluster_centering polyarchy_lag
replace polyarchy_lag = polyarchy_lag_diff
drop polyarchy_lag_*

cluster_centering lgdp_lag
replace lgdp_lag = lgdp_lag_diff
drop lgdp_lag_*

replace year = year - 2002

* ______________________________________________________________________________
* Create country factor variable

encode country, generate(countrynum)

end
