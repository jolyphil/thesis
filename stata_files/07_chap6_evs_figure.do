********************************************************************************
* Project: Dissertation
* Task:    Generate figure from EVS data
* Author:  Philippe Joly, WZB & HU-Berlin
********************************************************************************

version 16
capture log close
capture log using "${logfiles}07_chap6_evs_figure.smcl", replace
set more off

set scheme minimal

* Get EVS data -----------------------------------------------------------------

cd "${data}"
unzipfile "${data}/raw/ZA4804_v3-1-0.dta.zip", replace

use "${data}ZA4804_v3-1-0.dta", clear // EVS (1-4) Longitudinal 1981-2008 
keep if S003==276 & S002EVS == 2 // Keep German data in wave 1990

* Clean EVS data ---------------------------------------------------------------

* Region of interview  | S003A --> east
recode S003A (900 = 0) (901 = 1), gen(east) // East Germany == 1
label variable east "Region of interview"
label define eastlb				///
	0 "West Germany"			///
	1 "East Germany", modify
label values east eastlb

* Weight | S017 --> weight 
gen weight = S017
_crcslbl weight S017

* Taking part in a demonstration | E027 --> demonstration
recode E027 (2 3 = 0), gen(demonstration)
_crcslbl demonstration E027 // Copies var. label
label define poliactlb ///
	0 "Not done" ///
	1 "Have done", modify
label values demonstration poliactlb // Copies label values

* Year of birth | X002 --> yearborn
gen yrbrn = X002
_crcslbl yrbrn X002

* Year of birth, centered | yrbrn --> yrbrn_c

summ yrbrn
gen yrbrn_c = yrbrn - r(mean)
label variable yrbrn_c "Year of birth, centered"

* Model + Prediction -----------------------------------------------------------

logit demonstration east##c.yrbrn_c##c.yrbrn_c [pw = weight]
predict pr, pr
predict stdp, stdp
gen pr_se = pr * (1 - pr) * stdp
gen pr_ll = pr - 1.96 * pr_se
gen pr_ul = pr + 1.96 * pr_se


* Export graph (Figure 6.1) ----------------------------------------------------

twoway ///
	(line pr yrbrn if east == 1, sort lcolor("31 120 180")) ///
	(line pr_ll yrbrn if east == 1, sort lcolor("31 120 180") lpattern(dash)) ///
	(line pr_ul yrbrn if east == 1, sort lcolor("31 120 180") lpattern(dash)) ///
	(line pr yrbrn if east == 0, lcolor("166 206 227") sort) ///
	(line pr_ll yrbrn if east == 0, sort lcolor("166 206 227") lpattern(dash)) ///
	(line pr_ul yrbrn if east == 0, sort lcolor("166 206 227") lpattern(dash)), ///
	title("Having attended a demonstration, ever") ///
	xlabel(1910(20)1970) ///
	xtitle("Year of birth") ///
	ytitle("Predicted probabilities") ///
	legend(order(1 "East Germany" 4 "West Germany")) ///
	saving("${figures_gph}fig_6_1_evs_demo.gph", replace)
graph export "${figures_pdf}fig_6_1_evs_demo.pdf", replace
graph export "${figures_png}fig_6_1_evs_demo.png", replace ///
		width(2750) height(2000)
        
* Close ------------------------------------------------------------------------

log close
exit
