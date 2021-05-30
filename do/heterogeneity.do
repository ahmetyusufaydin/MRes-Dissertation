eststo clear

local panel balanced unbalanced

********************************************************************************
********************************************************************************
foreach bal of local panel {
	
use "$Data\built/`bal'.dta", clear

//------------------- Regression ---------------------
eststo: reghdfe lrev envph esg other, absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"

eststo: reghdfe lrev c.envph##c.cfrag1 esg other, absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"

eststo: reghdfe lrev c.envph##c.cfrag2 esg other, absorb(id i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local indyear "Yes"

}

********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************

esttab using "$Results//heterogeneity.tex", replace booktabs ///
	drop(_cons cfrag*) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	title(Heterogeneity - Environmental Fragility) ///
	nomtitles ///
	mgroups("Balanced" "Unbalanced", pattern(1 0 0 1 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	order(envph c.envph#c.cfrag*) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			c.envph#c.cfrag1 "News*Fragility1" ///
			c.envph#c.cfrag2 "News*Fragility2") ///
	substitute(\_ _)	///
	s(firm year indyear N, label("Firm FE" "Year FE" "Industry*Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust SE" "Fragility indicies are centered around their mean.")
