eststo clear

********************************************************************************
********************************************************************************
*use "$Data\built\unbalanced.dta", clear
use "$Data\built\balanced.dta", clear

merge m:1 isin using "$Data\built\similarity.dta"
drop if _m==2
drop if _m==1		// 35% of the companies in our balanced sample has no similarity index
drop _m

sort naics5 treat isin year
********************************************************************************
//------------- Spillovers --------------------------------------------
********************************************************************************

egen k = group(isin) if treat==1

sum k, meanonly
forvalues k = 1/`r(max)' { 
    gen T= envph if k==`k'
	egen T`k'= mean(T), by(naics5 year)
	
	//------------- Substitution Effect ------------------------------------
	levelsof isin if k==`k', local(isin) clean		//isin code of firm k
	gen S`k'= T`k'*fki`isin'						//T_{kt}*S_{ik}
	replace S`k'=0 if k==`k'						//exclude spillover on itself
	
	//----- Country-Related Reputational Spillover ----------------
	levelsof country if k==`k', local(cntry) clean	//country of firm k
	gen C`k'= country=="`cntry'" 					//tag if from same country
	replace C`k'= C`k'*T`k'							//T_{kt}*C_{ik}
	replace C`k'=0 if k==`k'						//exclude spillover on itself
	
	drop T
}
// sum over k (T_{kt}*S_{ik})
egen totS = rowtotal(S*)
egen maxS = rowmax(S*)

// sum over k (T_{kt}*C_{ik})
egen totC = rowtotal(C*)
egen maxC = rowmax(C*)

drop if missing(maxS) 		//Firms within industries without controversy in remaining sample 

drop T* S* C* k


********************************************************************************
//------------- Regressions --------------------------------------------
********************************************************************************

//Net Effect
eststo: reghdfe lrev envph esg other, absorb(id year i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
estadd local indyear "Yes"

//Net Effect
eststo: reghdfe lrev c.envph##c.cfrag1 esg other, absorb(id year i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
estadd local indyear "Yes"

//Spillover due to substitution
eststo: reghdfe lrev c.totS##c.cfrag1 c.envph##c.cfrag1 esg other, absorb(id year i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
estadd local indyear "Yes"
eststo: reghdfe lrev c.maxS##c.cfrag1 c.envph##c.cfrag1 esg other, absorb(id year i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
estadd local indyear "Yes"

//Spillover due to country-related reputation
eststo: reghdfe lrev c.totC##c.cfrag1 c.envph##c.cfrag1 esg other, absorb(id year i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
estadd local indyear "Yes"
eststo: reghdfe lrev c.maxC##c.cfrag1 c.envph##c.cfrag1 esg other, absorb(id year i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
estadd local indyear "Yes"

eststo: reghdfe lrev c.totS##c.cfrag1 c.totC##c.cfrag1 c.envph##c.cfrag1 esg other, absorb(id year i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
estadd local indyear "Yes"
eststo: reghdfe lrev c.maxS##c.cfrag1 c.maxC##c.cfrag1 c.envph##c.cfrag1 esg other, absorb(id year i.naics5#i.year) vce(robust)
estadd local firm "Yes"
estadd local year "Yes"
estadd local indyear "Yes"


********************************************************************************
//------------------------   TABLE    ------------------------
********************************************************************************
esttab using "$Results//spillover_bal_frag.tex", replace booktabs ///
	drop(_cons cfrag* other esg) label b(3) se(3) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	nomtitles ///
	order(envph c.envph#c.cfrag1 totS c.totS#c.cfrag1 maxS c.maxS#c.cfrag1 totC c.totC#c.cfrag1 maxC c.maxC#c.cfrag1) ///
	coeflabels(esg "ESG Score" ///
			other "Other Controversies" ///
			envph "News Count") ///
	substitute(\_ _)	///
	s(firm year indyear N, label("Firm FE" "Year FE" "Industry*Year FE" "N") fmt(0)) ///
	addnote("Notes: Balanced Panel" "Robust SE")
	

