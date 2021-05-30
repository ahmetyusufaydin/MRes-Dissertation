
use "$Data\built\balanced.dta", clear

eststo clear
********************************************************************************

eststo: reghdfe lrev c.envph##c.zfrag esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
estadd local control "Yes"

//Industry*Year FE
eststo: reghdfe lrev c.envph##c.zfrag esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"

//Weighted
eststo: reghdfe lrev c.envph##c.zfrag esg other [aw=nof], absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"

********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************

esttab using "$Tables//heterogeneity.tex", replace booktabs nonotes ///
	drop(_cons zfrag esg other) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	title(Heterogeneity - Environmental Fragility Index) ///
	nomtitles ///
	mgroups("OLS" "WLS", pattern(1 0 1) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(envph c.envph#c.zfrag) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			c.envph#c.zfrag "News Count*Fragility Index") ///
	substitute(\_ _)	///
	s(control firm year indyear N, label("Controls" "Firm FE" "Year FE" "Industry*Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust standard errors in parentheses, clustered at firm level" "Controls are ESG score and other controversies." "Fragility indicies are standardized." "Balanced Sample (2010-2018)" "WLS use the number of firms within industries as weights." "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
