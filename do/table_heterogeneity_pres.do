
use "$Data\built\balanced.dta", clear

eststo clear 
********************************************************************************
//WLS
eststo: reghdfe lrev c.envph##c.zfrag esg other [aw=nof], absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"

//OLS
eststo: reghdfe lrev c.envph##c.zfrag esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"

eststo: reghdfe lrev c.envph##c.zfrag c.totC##c.zfrag esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"

eststo: reghdfe lrev c.envph##c.zfrag c.totC##c.zfrag c.totS##c.zfrag esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"





********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************

esttab using "$Tables//heterogeneity_pres.tex", replace booktabs nonotes ///
	drop(_cons zfrag esg other) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	title(Heterogeneity - Environmental Fragility Index) ///
	mgroups("WLS" "OLS", pattern(1 1 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	nomtitles ///
	order(envph c.envph#c.zfrag totC c.totC#c.zfrag) ///
	coeflabels(esg "ESG Score" ///
			totS "Competitors" ///
			totC "Same Country" ///
			c.totS#c.zfrag "Competitors*Fragility Index" ///
			c.totC#c.zfrag "Same Country*Fragility Index" ///
			other "Other Controversies" ///
			envph "News Count" ///
			c.envph#c.zfrag "News Count*Fragility Index") ///
	substitute(\_ _)	///
	s(control firm indyear N, label("Controls" "Firm FE" "Industry*Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust standard errors in parentheses, clustered at firm level" "Fragility indices are standardized." "WLS use the number of firms within industries as weights." "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
