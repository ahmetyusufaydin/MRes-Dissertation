eststo clear

local panel balanced


********************************************************************************
****** Automobile and Light Duty Motor Vehicle Manufacturing *******************
********************************************************************************
foreach bal of local panel {

use "$Data\built/`bal'.dta", clear
keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing

eststo: reghdfe lrev scandal, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev envph, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev scandal esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev envph esg other, absorb(id year) vce(cluster id)
estadd local firm "Yes"
estadd local year "Yes"
estadd local cluster "Yes"
}

********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************
esttab using "$Tables//Table1_pres.tex", replace booktabs nonotes ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles ///
	title(Net Effect of Controversies on Firm Sales - Automobile Industry) ///
	order(envph scandal) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			scandal "Scandal Dummy") ///
	substitute(\_ _)	///
	s(firm year cluster N, label("Firm FE" "Year FE" "Clustered SE" "N") fmt(0)) ///
	addnote("Notes: Robust standard errors in parentheses" "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
