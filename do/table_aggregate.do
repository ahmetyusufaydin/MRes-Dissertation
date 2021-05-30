eststo clear

use "$Data\built\balanced.dta", clear

replace revenue=. if treat==1

collapse (sum) envph other revenue (mean) esg (max) scandal cont nof, by(naics* year)

gen lrev = log(revenue)


eststo: reghdfe lrev envph other [aw=nof], absorb(naics5 year) vce(cluster naics5)
estadd local industry "Yes"
estadd local year "Yes"

eststo: reghdfe lrev envph esg other [aw=nof], absorb(naics5 year) vce(cluster naics5)
estadd local industry "Yes"
estadd local year "Yes"

eststo: reghdfe lrev envph other, absorb(naics5 year) vce(cluster naics5)
estadd local industry "Yes"
estadd local year "Yes"

eststo: reghdfe lrev envph esg other, absorb(naics5 year) vce(cluster naics5)
estadd local industry "Yes"
estadd local year "Yes"



esttab using "$Tables//agg_bal.tex", replace booktabs nonotes ///
	drop(_cons) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles ///
	title(Effect of controversies at industry level) ///
	mgroups("WLS" "OLS", pattern(1 0 1 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	coeflabels(esg "Average ESG Score" ///
			other "Other Controversies" ///
			envph "News Count") ///
	substitute(\_ _)	///
	s(industry year N, label("Industry FE" "Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust standard errors in parentheses, clustered at industry level" "Balanced Sample (2010-2018)" "Revenues are aggregated after excluding firms involved in scandals." "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")


********************************************************************************
********************************************************************************
********************************************************************************
