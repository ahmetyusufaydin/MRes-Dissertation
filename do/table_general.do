
local panel balanced unbalanced

********************************************************************************
********************************************************************************
foreach bal of local panel {
eststo clear

use "$Data\built/`bal'.dta", clear

************************* Unweighted *************************
eststo: reghdfe lrev envph esg other, absorb(id year) vce(cluster id)
estadd local firm "Yes"
estadd local year "Yes"

//Industry*year FE
eststo: reghdfe lrev scandal esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"

eststo: reghdfe lrev envph esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"

************************* Weighted *************************
eststo: reghdfe lrev envph esg other [aw=nof], absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"

********************************************************************************

if "`bal'" == "balanced" local note "Balanced Sample (2010-2018)"
else local note "Whole Sample (2001-2020)"

********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************

esttab using "$Tables//general_`bal'.tex", replace booktabs nonotes ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles ///
	title(Net Effect of Controversies on Firm Sales) ///
	mgroups("OLS" "WLS", pattern(1 0 0 1) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(envph scandal) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			scandal "Scandal Dummy") ///
	substitute(\_ _)	///
	s(firm year indyear N, label("Firm FE" "Year FE" "Industry*Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust standard errors in parentheses, clustered at firm level" "`note'" "Weighted regressions use the number of firms within industries as weights." "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
}
