eststo clear

local panel balanced unbalanced

********************************************************************************
********************************************************************************
foreach bal of local panel {
	
use "$Data\built/`bal'.dta", clear

keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing



//------------------- Regression ---------------------
eststo: reghdfe lrev envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

*reghdfe lrev c.envph##c.fragility1 esg other, absorb(id year) vce(robust)

eststo: reghdfe lrev c.envph##c.cfrag1 esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"

eststo: reghdfe lrev c.envph##c.cfrag2 esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
}

********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************

esttab using "$Results//heterogeneity_auto.tex", replace booktabs ///
	drop(_cons cfrag*) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	title(Heterogeneity - Environmental Fragility (Automobile Industry)) ///
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
	s(firm year N, label("Firm FE" "Year FE" "N") fmt(0)) ///
	addnote("Notes: Robust SE" "Industry: Automobile and Light Duty Motor Vehicle Manufacturing" "Fragility indices are centered around their mean.")
