********************************************************************************
* Project:	Dissertation
* Task:		Generate country mean, country-wave mean, and differences
* Author:	Philippe Joly, WZB and HU-Berlin
********************************************************************************

capture program drop cluster_centering
program cluster_centering
args var

* ______________________________________________________________________________
* Generate temporary tags

egen temp_tag_c = tag(country)
egen temp_tag_cw = tag(countrywave)

* ______________________________________________________________________________
* Generate temporary number of countrywaves by country

by country, sort: egen temp_n_cw = sum(temp_tag_cw)
* ______________________________________________________________________________
* Country-wave mean

by countrywave, sort: egen `var'_mean_cw = mean(`var')

* ______________________________________________________________________________
* Sum of country-wave means

by country, sort: egen temp_sum = sum(`var'_mean_cw) if temp_tag_cw == 1

* ______________________________________________________________________________
* Mean of country-waves

by country, sort: gen temp_mean = temp_sum / temp_n_cw if temp_tag_cw==1

* ______________________________________________________________________________
* Attribute to all observations in country

by country, sort: egen `var'_mean = max(temp_mean) 

* ______________________________________________________________________________
* Differences with country-mean

gen `var'_diff = `var'_mean_cw - `var'_mean // difference with country-mean

* ______________________________________________________________________________
* Delete temporary variables

drop temp_*

end
