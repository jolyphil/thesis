********************************************************************************
* Project:	Dissertation
* Task:		Chapter 5: Prepare data for analysis
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop prepare_data_chap5
program prepare_data_chap5

* ______________________________________________________________________________
* Load external packages and programs

do "${programs}cluster_centering.do"

* ______________________________________________________________________________
* Center macro variables

cluster_centering lgdp_lag
rename lgdp_lag_mean lgdp_mean
rename lgdp_lag_diff lgdp_diff
drop lgdp_lag_*

replace year = year - 2002

* ______________________________________________________________________________
* Dummy for Eastern Germany

gen eastde = (country == "DEE")

end
