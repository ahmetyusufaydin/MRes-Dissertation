

use "$Data\built\balanced.dta", clear

merge m:1 isin using "$Data\built\similarity.dta"
drop if _m==2
drop _m

********************************************************************************
******************* Spillovers of Big vs Small Scandals ************************
********************************************************************************

gen small = 0<envph & envph<5
gen big = envph>=5

egen x = group(isin) if big==1		// firm-years with more than 5 controv
egen k = max(x), by(isin)
drop x

egen x = group(isin) if small==1	// firm-years with less than 5 controv
egen l = max(x), by(isin)
drop x



//------------------ Spillovers of big scandals --------------------------------
sum k, meanonly
forvalues k = 1/`r(max)' { 
    gen T= envph*big if k==`k'
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
egen totbigS = rowtotal(S*)
egen maxbigS = rowmax(S*)

// sum over k (T_{kt}*C_{ik})
egen totbigC = rowtotal(C*)
egen maxbigC = rowmax(C*)

//if only 1 controversial firm within industry, that firm is missing 
recode totbig* (0=.) if missing(maxbigC) & !missing(k)		//exclude that firm

//if no controversial firm within industry, all firms in that industry are missing
recode maxbig* (.=0) if missing(maxbigC) & missing(k)		//convert them to zero since no spillover

//Unable to calculate similarity index due to missing revenue distribution data
recode totbigS (0=.) if missing(maxbigS)					//exclude them

drop T* S* C* k
//------------------------------------------------------------------------------

//------------------ Spillovers of small scandals ------------------------------
sum l, meanonly
forvalues l = 1/`r(max)' { 
    gen T= envph*small if l==`l'
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
egen totsmaS = rowtotal(S*)
egen maxsmaS = rowmax(S*)

// sum over l (T_{lt}*C_{il})
egen totsmaC = rowtotal(C*)
egen maxsmaC = rowmax(C*)

//if only 1 controversial firm within industry, that firm is missing 
recode totsma* (0=.) if missing(maxsmaC) & !missing(l)		// exclude that firm

//if no controversial firm within industry, all firms in that industry are missing
recode maxsma* (.=0) if missing(maxsmaC) & missing(l)		//convert them to zero since no spillover

//Unable to calculate similarity index due to missing revenue distribution data
recode totsmaS (0=.) if missing(maxsmaS)

drop T* S* C* l
//------------------------------------------------------------------------------
drop fki*

//News count for big vs. small scandals
gen bigcount = big*envph
gen smallcount = small*envph

save "$Data\built\spillover_bigsmall.dta", replace
