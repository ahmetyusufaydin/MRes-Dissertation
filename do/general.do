eststo clear

local panel balanced unbalanced

********************************************************************************
********************************************************************************
foreach bal of local panel {

use "$Data\built/`bal'.dta", clear


//------------------- Regression ---------------------
*xtset id year
*xtreg lrev envph i.year, fe
*xtreg lrev envph esg other i.year, fe robust
*xtreg lrev scandal esg other i.year, fe robust		//Treatment as a dummy

eststo: reghdfe lrev scandal esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"


eststo: reghdfe lrev envph esg other, absorb(id year) vce(robust)
*vif, uncentered
estadd local firm "Yes"
estadd local year "Yes"


//Industry*year FE
*xtreg lrev scandal esg other i.year i.naics5#i.year, fe robust
eststo: reghdfe lrev scandal esg other, absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"

eststo: reghdfe lrev envph esg other, absorb(id i.naics5#i.year) vce(robust)
*vif, uncentered
estadd local firm "Yes"
estadd local indyear "Yes"

//------------------ Dynamic DiD -----------------------
*xtreg lrev minus3 minus2 minus1 envph plus* esg other i.year i.naics5#i.year, fe robust
gen zero=0
reghdfe lrev minus3 minus2 zero envph plus* before after esg other, absorb(id i.naics5#i.year) vce(robust)
estimates store dynamic

if "`bal'" == "balanced" local title "Balanced (2010-2018)"
else local title "Unbalanced (2001-2020)"

coefplot dynamic, omitted keep(minus* plus* envph zero) vertical yline(0) title(`title')  recast(connected) coeflabels(minus3="t-3" minus2="t-2" zero="t-1" envph="Treatment period" plus1="T+1" plus2="T+2") ciopts(recast(rcap))
graph export "$Results/dynamic_`bal'.png", replace

}
********************************************************************************



********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************

esttab using "$Results//general.tex", replace booktabs ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles ///
	title(Net Effect of Controversies on Firm Sales (unweighted)) ///
	mgroups("Balanced" "Unbalanced", pattern(1 0 0 0 1 0 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(scandal envph) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			scandal "Scandal Dummy") ///
	substitute(\_ _)	///
	s(firm year indyear N, label("Firm FE" "Year FE" "Industry*Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust SE")

