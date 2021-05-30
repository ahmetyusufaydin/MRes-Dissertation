
use "$Data\built\spillover_bigsmall.dta", clear

eststo clear
********************************************************************************
//------------- Unweighted --------------------------------------------
********************************************************************************
//Net Effect
eststo: reghdfe lrev bigcount smallcount esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"

//Spillover due to country-related reputation
eststo: reghdfe lrev totbigC totsmaC bigcount smallcount esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"

//Spillover on competitors
eststo: reghdfe lrev totbigS totsmaS bigcount smallcount esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"

//Both
eststo: reghdfe lrev totbigS totbigC totsmaS totsmaC bigcount smallcount esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"

********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************
esttab using "$Tables//spillover_bigsmall.tex", replace booktabs nonotes ///
	drop(_cons esg other) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles ///
	title(Spillover Effects in Generalized Model: Big vs. Small Scandals) ///
	order(bigcount smallcount totbigC totsmaC totbigS totsmaS) ///
	coeflabels(bigcount "News Count (Big)" ///
			smallcount "News Count (Small)" ///
			totbigS "Competitors (Big)" ///
			totbigC "Same Country (Big)" ///
			totsmaS "Competitors (Small)" ///
			totsmaC "Same Country (Small)" ///
			esg "ESG Score" ///
			other "Other Controversies") ///
	substitute(\_ _)	///
	s(control firm indyear N, label("Controls" "Firm FE" "Industry*Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust standard errors in parentheses, clustered at firm level" "Balanced Sample (2010-2018)"  "Controls are ESG score and other controversies." "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
