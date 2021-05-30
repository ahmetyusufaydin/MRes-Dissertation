
use "$Data\built\spillover_vw_others.dta", clear


********************************************************************************
********** Spillover Effects of Volkswagen Scandal (with news count) ***********
********************************************************************************
eststo clear

//Spillover due to country-related reputation
eststo: reghdfe lrev vwC esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev vwC envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

//Spillover on competitors
eststo: reghdfe lrev vwS esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev vwS envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

//Both spillovers
eststo: reghdfe lrev vwS vwC esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev vwS vwC envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

********************************************************************************
//------------------------   TABLE   ------------------------
********************************************************************************
esttab using "$Tables//Table3_pres.tex", replace booktabs nonotes ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	title(Spillover Effects of Volkswagen Scandal) ///
	nomtitles ///
	order(envph vwC vwS) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			vwS "Competitors ($ T_{vt} S_{iv}$)" ///
			vwC "Same Country ($ T_{vt} C_{iv}$)") ///
	substitute(\_ _)	///
	s(firm year N, label("Firm FE" "Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust standard errors in parentheses" "Volkswagen is excluded in spillover regressions." "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
********************************************************************************
		