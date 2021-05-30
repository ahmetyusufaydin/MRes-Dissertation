eststo clear

********************************************************************************
*use "$Data\built\unbalanced.dta", clear
use "$Data\built\balanced.dta", clear

keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing


********************************************************************************
//------------- Regressions --------------------------------------------
********************************************************************************

//Net Effect
eststo: reghdfe lrev envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

//Spillover due to substitution
eststo: reghdfe lrev totS envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
eststo: reghdfe lrev maxS envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

//Spillover due to country-related reputation
eststo: reghdfe lrev totC envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
eststo: reghdfe lrev maxC envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev totS totC envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
eststo: reghdfe lrev maxS maxC envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"


********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************
esttab using "$Results//spillover_auto_bal.tex", replace booktabs ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	title(Spillover Effects - Automobile Industry - Balanced Panel) ///
	nomtitles ///
	order(envph totS maxS totC maxC) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count") ///
	substitute(\_ _)	///
	s(firm year N, label("Firm FE" "Year FE" "N") fmt(0)) ///
	addnote("Notes: Balanced Panel" "Industry: Automobile and Light Duty Motor Vehicle Manufacturing" "Robust SE")
	

	
	
	





