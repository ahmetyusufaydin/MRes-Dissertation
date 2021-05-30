eststo clear

local panel balanced unbalanced


********************************************************************************
****** Automobile and Light Duty Motor Vehicle Manufacturing *******************
********************************************************************************
foreach bal of local panel {

use "$Data\built/`bal'.dta", clear
keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing

eststo: reghdfe lrev scandal esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev envph esg other, absorb(id year) vce(robust)
*vif, uncentered
estadd local firm "Yes"
estadd local year "Yes"


//------------------ Dynamic DiD -----------------------
gen zero=0
reghdfe lrev minus3 minus2 zero envph plus* before after esg other, absorb(id year) vce(robust)
estimates store dynamic

coefplot dynamic, omitted keep(minus* plus* envph zero) vertical yline(0) recast(connected) title("Automobile (`bal')") coeflabels(minus3="t-3" minus2="t-2" zero="t-1" envph="Treatment period" plus1="T+1" plus2="T+2") ciopts(recast(rcap))
graph export "$Results/dynamic_Auto_`bal'.png", replace
}

********************************************************************************


********************************************************************************
************************ Petroleum Refineries **********************************
********************************************************************************
foreach bal of local panel {

use "$Data\built/`bal'.dta", clear
keep if naics5==32411		//Petroleum Refineries

eststo: reghdfe lrev scandal esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"


//------------------ Dynamic DiD -----------------------
gen zero=0
reghdfe lrev minus3 minus2 zero envph plus* before after esg other, absorb(id year) vce(robust)
estimates store dynamic

coefplot dynamic, omitted keep(minus* plus* envph zero) vertical yline(0) recast(connected) title("Petroleum (`bal')") coeflabels(minus3="t-3" minus2="t-2" zero="t-1" envph="Treatment period" plus1="T+1" plus2="T+2") ciopts(recast(rcap))
graph export "$Results/dynamic_Petro_`bal'.png", replace
}
********************************************************************************



********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************
esttab using "$Results//industry.tex", replace booktabs ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles ///
	title(Net Effect of Controversies on Firm Sales - Industries) ///
	mgroups("Automobile" "Petroleum", pattern(1 0 0 0 1 0 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(scandal envph) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			scandal "Scandal Dummy") ///
	substitute(\_ _)	///
	s(firm year N, label("Firm FE" "Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust SE")



