eststo clear

*use "$Data\built\unbalanced.dta", clear
use "$Data\built\balanced.dta", clear

********************************************************************************
//------------- Regressions --------------------------------------------
********************************************************************************

//Net Effect
eststo: reghdfe lrev envph esg other [aw=nof], absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"

//Spillover due to substitution
eststo: reghdfe lrev totS envph esg other [aw=nof], absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"
eststo: reghdfe lrev maxS envph esg other [aw=nof], absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"

//Spillover due to country-related reputation
eststo: reghdfe lrev totC envph esg other [aw=nof], absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"
eststo: reghdfe lrev maxC envph esg other [aw=nof], absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"

eststo: reghdfe lrev totS totC envph esg other [aw=nof], absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"
eststo: reghdfe lrev maxS maxC envph esg other [aw=nof], absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"


********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************
esttab using "$Results//spillover_bal_w.tex", replace booktabs ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	title(Spillover Effects - Balanced Panel (weighted)) ///
	nomtitles ///
	order(envph totS maxS totC maxC) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count") ///
	substitute(\_ _)	///
	s(firm year indyear N, label("Firm FE" "Year FE" "Industry*Year FE" "N") fmt(0)) ///
	addnote("Notes: Balanced Panel" "Robust SE" "All regressions are weighted by the number of firms within industries.")
	

