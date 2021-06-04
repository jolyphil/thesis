********************************************************************************
* Project:	Dissertation
* Task:		Chap 6: Coefplot
* Author:	Philippe Joly, WZB and HU-Berlin
*********************************************************************************

capture program drop export_coefplot_chap6
program export_coefplot_chap6

capture ssc install coefplot

* ______________________________________________________________________________
* Input arguments

local M1 `1'
local M2 `2'
local M3 `3'

local saveas "`4'"

* ______________________________________________________________________________
* Attribute Model labels

forvalues i = 1(1)3 {
	if regexm("`M`i''", "demonstration")==1 {
		local M`i'_label "Demonstration"
	}
	else if regexm("`M`i''", "petition")==1 {
		local M`i'_label "Petition"
	}
	else if regexm("`M`i''", "boycott")==1  {
		local M`i'_label "Boycott"
	}
	else {
		error "Unknown model"
	}
}

* ______________________________________________________________________________
* Graph

#delimit ;
coefplot
	(`M1', label(`M1_label'))
	(`M2', label(`M2_label') msymbol(triangle))
	(`M3', label(`M3_label') msymbol(square)),
	drop(*.land_de _cons) /*eform*/ xline(0) xtitle("LogitPr(Protest = 1)", size(small))
	headings( 
		1.female = " "
		age10 = " "
		2.edu = "Education, Low (ref.)" 
		1.unemp = " " 
		1.union = " "
		2.city = "Town size, Home in countryside (ref.)" 
		2.class5 = "Social class, Unskilled workers (ref.)"  
		)
	coeflabels(
		1.eastsoc = "East German"
		1.female = "Woman" 
		age10 = "Age (10 years)"
		c.age10#c.age10 = "Age{superscript:2} "	
		2.edu = "Middle"
		3.edu = "High"
		1.unemp = "Unemployed" 
		1.union = "Union member" 
		2.city = "Country village"
		3.city = "Town or small city"
		4.city = "Outskirts of big city"
		5.city = "A big city"
		2.class5 = "Skilled workers"
		3.class5 = "Small business owners"
		4.class5 = "Low service class"
		5.class5 = "High service class"
	)
	saving("${figures_gph}`saveas'.gph", replace)
;
#delimit cr

graph export "${figures_pdf}`saveas'.pdf", replace
graph export "${figures_png}`saveas'.png", replace ///
	width(2750) height(2000)
	
end
