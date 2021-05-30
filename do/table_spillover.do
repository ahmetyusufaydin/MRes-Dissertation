eststo clear

use "$Data\built\balanced.dta", clear


********************************************************************************
//------------- Unweighted --------------------------------------------
********************************************************************************

//Net Effect
eststo: reghdfe lrev envph esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"

//Spillover due to country-related reputation
eststo: reghdfe lrev totC envph esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"

//Spillover on competitors
eststo: reghdfe lrev totS envph esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"

//Both
eststo: reghdfe lrev totS totC envph esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"
 


********************************************************************************
//------------- Weighted --------------------------------------------
********************************************************************************

eststo: reghdfe lrev totS totC envph esg other [aw=nof], absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"


********************************************************************************
//------------- UnWeighted / 3-digit ind*year ----------------------------------
********************************************************************************

eststo: reghdfe lrev totS totC envph esg other, absorb(id i.naics3#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "3-digit"


********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************
esttab using "$Tables//spillover_general.tex", replace booktabs nonotes ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mgroups("OLS" "WLS" "OLS", pattern(1 0 0 0 1 1) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nomtitles ///
	title(Spillover Effects in Generalized Model) ///
	order(envph totC totS) ///
	coeflabels(totS "Competitors" ///
			totC "Same Country" ///
			esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			scandal "Scandal Dummy") ///
	substitute(\_ _)	///
	s(firm indyear N, label("Firm FE" "Industry*Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust standard errors in parentheses, clustered at firm level" "Balanced Sample (2010-2018)" "Weighted regressions use the number of firms within industries as weights." "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
