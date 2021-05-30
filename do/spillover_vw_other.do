	
use "$Data\built/balanced.dta", clear

keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing

drop tot* max*


merge m:1 isin using "$Data\built\similarity_auto.dta"
drop if _m==2
drop _m

******************** Spillover of VW vs other controversies ********************

********************************************************************************
//---------------------- VW -------------------------
********************************************************************************
gen vw=envph if isin=="DE0007664005"
egen Tvw=mean(vw), by(year)
gen Dvw= Tvw>0
gen vwS=Tvw*fkiDE0007664005
gen vwSdum=Dvw*fkiDE0007664005

gen vwC = country=="DE"
gen vwCdum = Dvw*vwC
replace vwC = Tvw*vwC

// drop VW from spillover regressions
replace vwS=.		if isin=="DE0007664005"
replace vwSdum=.	if isin=="DE0007664005"
replace vwC=.		if isin=="DE0007664005"
replace vwCdum=.	if isin=="DE0007664005"

drop vw Tvw
********************************************************************************


********************************************************************************
//---------------------- Others -------------------------
********************************************************************************
egen x = group(isin) if envph>0 & isin!="DE0007664005"
egen l = max(x), by(isin)
drop x

sum l, meanonly
forvalues l = 1/`r(max)' { 
    gen T= envph if l==`l'
	egen T`l'= mean(T), by(naics5 year)				//Allow spillovers within industry
	
	//------------- Substitution Effect ------------------------------------
	levelsof isin if l==`l', local(isin) clean		//isin code of firm l
	gen S`l'= T`l'*fki`isin'						//T_{lst}*S_{il}
	replace S`l'=. if l==`l'						//exclude spillover on itself
	
	//----- Country-Related Reputational Spillover ----------------
	levelsof country if l==`l', local(cntry) clean	//country of firm l
	gen C`l'= country=="`cntry'" 					//tag if from same country
	replace C`l'= C`l'*T`l'							//T_{lst}*C_{il}
	replace C`l'=. if l==`l'						//exclude spillover on itself
	
	drop T
}

// sum over l (T_{lt}*S_{il})
egen tototherS = rowtotal(S*)
egen maxotherS = rowmax(S*)

// sum over l (T_{lt}*C_{il})
egen tototherC = rowtotal(C*)
egen maxotherC = rowmax(C*)

// missing since unable to calculate similarity index due to missing revenue distribution data
recode tototherS (0=.) if maxotherS==.				

drop T* S* C* l
********************************************************************************


********************************************************************************
//------------- Spillovers of all controversies --------------------------------
********************************************************************************
egen x = group(isin) if treat==1
egen k = max(x), by(isin)
drop x

sum k, meanonly
forvalues k = 1/`r(max)' { 
    gen T= envph if k==`k'
	egen T`k'= mean(T), by(naics5 year)				//Allow spillovers within industry
	
	//------------- Substitution Effect ------------------------------------
	levelsof isin if k==`k', local(isin) clean		//isin code of firm k
	gen S`k'= T`k'*fki`isin'						//T_{kst}*S_{ik}
	replace S`k'=. if k==`k'						//exclude spillover on itself
	
	//----- Country-Related Reputational Spillover ----------------
	levelsof country if k==`k', local(cntry) clean	//country of firm k
	gen C`k'= country=="`cntry'" 					//tag if from same country
	replace C`k'= C`k'*T`k'							//T_{kst}*C_{ik}
	replace C`k'=. if k==`k'						//exclude spillover on itself
	
	drop T
}
// sum over k (T_{kt}*S_{ik})
egen totS = rowtotal(S*)
egen maxS = rowmax(S*)

// sum over k (T_{kt}*C_{ik})
egen totC = rowtotal(C*)
egen maxC = rowmax(C*)

// missing since unable to calculate similarity index due to missing revenue distribution data
recode totS (0=.) if missing(maxS)					

drop T* S* C* k
********************************************************************************

drop fki*

save "$Data\built\spillover_vw_others.dta", replace

