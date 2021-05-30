use "$Data\built\merged.dta", clear

//Recode missing observations to 0 when isin-year is within scope of esg data
recode other envph (.=0) //if !missing(esg)

//Treated vs untreated dummy
bysort isin: egen mean = mean(envph)
gen treat= mean>0
drop mean

//Outcome variable
gen lrev=log(revenue)

//Scandal dummy
gen scandal = envph!=0 & !missing(envph)

//Leads and Lags
bysort isin (year): gen minus1 = scandal==0 & scandal[_n+1]==1
bysort isin (year): gen minus2 = scandal==0 & scandal[_n+1]==0 & scandal[_n+2]==1
bysort isin (year): gen minus3 = scandal==0 & scandal[_n+1]==0 & scandal[_n+2]==0 & scandal[_n+3]==1

bysort isin (year): gen plus1 = scandal==0 & scandal[_n-1]==1
bysort isin (year): gen plus2 = scandal==0 & scandal[_n-1]==0 & scandal[_n-2]==1

bysort isin (year): replace minus1=0 if plus1==1 | plus2==1
bysort isin (year): replace minus2=0 if plus1==1 | plus2==1
bysort isin (year): replace minus3=0 if plus1==1 | plus2==1

//Distant Relevant Periods (before&after)
gen syear=year if scandal==1
bysort isin (year): egen firstscan=min(syear)
bysort isin (year): egen lastscan =max(syear)
bysort isin (year): gen before= firstscan-year>3
bysort isin (year): gen after = year-lastscan>2
replace after=0 if before==1					//before=1 if not treated

replace before=1 if before!=1 & after!=1 & minus1!=1 & minus2!=1 & minus3!=1 & plus1!=1 & plus2!=1 & scandal!=1

//Fiscal year ending date
*FY ending dates are various for firms. I need to manage them to synchronise in calendar year.
replace year = year - 1 if month(date)<6 & year==year(date)
drop if year<2000

*duplicates report isin year
//It creates duplications since some companies change their fiscal year ending date. The revenue for the first fy after the change covers either less or more than a year. So I drop them.

duplicates tag isin year, gen(tag)
*bysort isin (year): egen dup=mean(tag), 
*br if dup>0
drop if tag==1 & year != year(date)
drop tag

//Detect the gap years
/*
capture drop gap wgap
bysort isin (year): gen gap = _n==1
bysort isin (year): replace gap=1 if year==year[_n-1]+1
bysort isin (year): egen wgap = mean(gap)
*br if wgap<1
replace year = year - 1 if month(date)<6 & wgap<1
*/


save "$Data\built\cleaned.dta", replace


********************************************************************************
//------------------- Unbalanced Panel -----------------------------------------
********************************************************************************

use "$Data\built\cleaned.dta", clear

//Total number of controversies in each sector
bysort naics5: egen cont=total(envph)

//Number of firms in each sector
egen tag = tag(isin)
egen nof = total(tag), by(naics5) 
drop tag

keep if nof>10		// Keep naics5 sectors with more than 10 companies
*drop if cont==0		// Drop naics5 sectors without any controversy

//Generate non-string id
encode isin, gen(id)

sort isin year

save "$Data\built\unbalanced.dta", replace
********************************************************************************
********************************************************************************


********************************************************************************
//------------------- Balanced Panel (2010-2018)--------------------------------
********************************************************************************

use "$Data\built\cleaned.dta", clear

drop if year<2010 | year>2018
bysort isin: gen full=_N
keep if full==9
drop full

//Total number of controversies in each sector
bysort naics5: egen cont=total(envph)

//Number of firms in each sector
egen tag = tag(isin)
egen nof = total(tag), by(naics5) 
drop tag

//Treated vs untreated dummy
drop treat
bysort isin: egen mean = mean(envph)
gen treat= mean>0
drop mean

keep if nof>10		// Keep naics5 sectors with more than 10 companies
*drop if cont==0		// Drop naics5 sectors without any controversy

//Generate non-string id
encode isin, gen(id)


*************************************************
//------------- Spillovers ----------------------
*************************************************
merge m:1 isin using "$Data\built\similarity.dta"
drop if _m==2

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

//if only 1 controversial firm within industry, that firm is missing 
recode tot* (0=.) if missing(maxC) & !missing(k)	// exclude that firm	(13 firms)

//if no controversial firm within industry, all firms in that industry are missing
recode max* (.=0) if missing(maxC) & missing(k)		//convert them to zero since no spillover

//Unable to calculate similarity index due to missing revenue distribution data
recode totS (0=.) if missing(maxS)
	*54 firms with controversy but unable to calculate maxS
		*52 of them have no rev.dist.data
		*2 of them have rev.dist.data but the only other firm with controv. within industry has no rev.dist.data
	*469 firms with no controversy and unable to calculate maxS
		*424 of them have no rev.dist.data
		*45 of them have rev.dist.data but all other firms with controv. in their industry have no rev.dist.data

drop fki* T* S* C* k _m
*************************************************
*************************************************

sort isin year

save "$Data\built\balanced.dta", replace
********************************************************************************
********************************************************************************
