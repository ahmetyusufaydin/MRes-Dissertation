use "$Data\built\balanced.dta", clear

keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing

//------------------ Dynamic DiD -----------------------
gen zero=0
reghdfe lrev minus3 minus2 zero envph plus* before after esg other, absorb(id year) vce(robust)
estimates store dynamic

coefplot dynamic, omitted keep(minus* plus* envph zero) vertical yline(0) recast(connected) coeflabels(minus3="t-3" minus2="t-2" zero="t-1" envph="Treatment period" plus1="T+1" plus2="T+2") ciopts(recast(rcap))
graph export "$Figures/dynamic_Auto.png", replace

********************************************************************************
********************************************************************************
********************************************************************************

use "$Data\built\balanced.dta", clear

//------------------ Dynamic DiD -----------------------
gen zero=0
reghdfe lrev minus3 minus2 zero envph plus* before after esg other, absorb(id i.naics5#i.year) vce(robust)
estimates store dynamic

coefplot dynamic, omitted keep(minus* plus* envph zero) vertical yline(0) recast(connected) coeflabels(minus3="t-3" minus2="t-2" zero="t-1" envph="Treatment period" plus1="T+1" plus2="T+2") ciopts(recast(rcap))
graph export "$Figures/dynamic.png", replace

