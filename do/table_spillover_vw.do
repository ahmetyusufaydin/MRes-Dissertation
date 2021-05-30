
use "$Data\built\spillover_vw_others.dta", clear


********************************************************************************
********** Spillover Effects of Volkswagen Scandal (with news count) ***********
********************************************************************************
eststo clear

//Baseline regression without spillover
eststo: reghdfe lrev envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"


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
esttab using "$Tables//spillover_vw.tex", replace booktabs nonotes ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	title(Spillover Effects of Volkswagen Scandal) ///
	nomtitles ///
	mgroups("Eqn (1)" "Spillover of News Count for VW", pattern(0 1 0 0 0 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(envph vwC vwS) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			vwS "Competitors ($ T_{vt} S_{iv}$)" ///
			vwC "Same Country ($ T_{vt} C_{iv}$)") ///
	substitute(\_ _)	///
	s(firm year N, label("Firm FE" "Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust standard errors in parentheses" "Balanced Sample (2010-2018) for Automobile and Light Duty Motor Vehicle Manufacturing Industry" "Volkswagen is excluded in spillover regressions." "4 firms have missing similarity index since they do not have revenue distribution data." "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
********************************************************************************
	


********************************************************************************
******** Spillover Effects of Volkswagen Scandal (with VW scandal dummy) *******
********************************************************************************
eststo clear

//Spillover due to country-related reputation
eststo: reghdfe lrev vwCdum esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev vwCdum envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

//Spillover due to substitution
eststo: reghdfe lrev vwSdum esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev vwSdum envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"


//Both spillovers
eststo: reghdfe lrev vwSdum vwCdum esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev vwSdum vwCdum envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

********************************************************************************
********************************************************************************

********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************
esttab using "$Tables//spillover_vw_dummy.tex", replace booktabs nonotes ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	title(Spillover Effects of Volkswagen Scandal (with scandal dummy)) ///
	nomtitles ///
	order(envph vwCdum vwSdum) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			vwSdum "Competitors ($ D_{vt} S_{iv}$)" ///
			vwCdum "Same Country ($ D_{vt} C_{iv}$)") ///
	substitute(\_ _)	///
	s(firm year N, label("Firm FE" "Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust standard errors in parentheses" "Balanced Sample (2010-2018) for Automobile and Light Duty Motor Vehicle Manufacturing Industry" "Volkswagen is excluded in spillover regressions." "4 firms have missing similarity index since they do not have revenue distribution data." "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
	