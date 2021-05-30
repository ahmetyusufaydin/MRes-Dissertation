
use "$Data\built\spillover_vw_others.dta", clear

********************************************************************************
//------------- Regressions --------------------------------------------
********************************************************************************
eststo clear

//Baseline regression without spillover
eststo: reghdfe lrev envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

//Spillover due to country-related reputation
eststo: reghdfe lrev totC envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

//Spillover on competitors
eststo: reghdfe lrev totS envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

//Both spillovers
eststo: reghdfe lrev totS totC envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"


********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************
esttab using "$Tables//spillover_auto.tex", replace booktabs nonotes ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles ///
	title(Spillover Effects within Automobile Industry) ///
	order(envph totC totS) ///
	coeflabels(totS "Competitors" ///
			totC "Same Country" ///
			esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			scandal "Scandal Dummy") ///
	substitute(\_ _)	///
	s(firm year N, label("Firm FE" "Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust standard errors in parentheses" "Balanced Sample (2010-2018)" "Industry: Automobile and Light Duty Motor Vehicle Manufacturing" "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
