eststo clear

use "$Data\built\spillover_vw_others.dta", clear

********************************************************************************
//------------- Automobile Industry --------------------------------------------
********************************************************************************
eststo: reghdfe lrev totS totC envph esg other, absorb(id year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
estadd local control "Yes"

********************************************************************************
********************************************************************************
********************************************************************************

use "$Data\built\balanced.dta", clear


********************************************************************************
//------------- All --------------------------------------------
********************************************************************************
eststo: reghdfe lrev totS totC envph esg other, absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"

//------------- Weighted -------------------------------------------
eststo: reghdfe lrev totS totC envph esg other [aw=nof], absorb(id i.naics5#i.year) vce(cluster id)
estadd local firm "Yes"
estadd local indyear "Yes"
estadd local control "Yes"


********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************
esttab using "$Tables//Table4_5_pres.tex", replace booktabs nonotes ///
	drop(_cons esg other) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mgroups("Auto" "All Industries", pattern(1 1 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mtitles("OLS" "OLS" "WLS") ///
	title(Spillover Effects in Generalized Model) ///
	order(envph totC totS) ///
	coeflabels(totS "Competitors" ///
			totC "Same Country" ///
			esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count" ///
			scandal "Scandal Dummy") ///
	substitute(\_ _)	///
	s(control firm year indyear N, label("Controls" "Firm FE" "Year FE" "Industry*Year FE" "N") fmt(0)) 
