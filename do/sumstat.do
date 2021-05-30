use "$Data\built\balanced.dta", clear

********************************************************************************
********************************************************************************
//Distribution of Controversies by Year
preserve
collapse (sum) envph other scandal (max) nof=id, by(year)
restore

//Distribution of Controversies by Industry
preserve
collapse (sum) envph other treat (count) id, by(naics2)
gen nof=id/9
gen nocof=treat/9
drop id treat
gen envphperfirm=envph/nof
gen otherperfirm=other/nof
gen nofind = _N
restore

//Distribution of Controversies by Continent
preserve
collapse (sum) envph other treat (count) id, by(continent)
gen nof=id/9
gen nocof=treat/9
drop id treat
restore


//Distribution of Controversies by Year - Automobile Industry
preserve
keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing

gen str firm = ""
replace firm = "vw" if isin=="DE0007664005"
replace firm = "daim" if isin=="DE0007100000"
replace firm = "bmw" if isin=="DE0005190003"
replace firm = "nong" if missing(firm)

collapse (sum) envph other (count) id, by(year firm)

reshape wide envph other id, i(year) j(firm) string

gen envphperfirm=envphnong/idnong
gen otherperfirm=othernong/idnong
drop id*
br
restore
********************************************************************************


********************************************************************************
********** Balance *************************************************************
********************************************************************************
reg lrev treat
reg lrev treat other
reg lrev treat other esg

reg other treat
reg esg treat
reg esg treat if year==2010

reg lrev treat if year==2010
reg lrev treat other esg if year==2010

reg lrev treat if year<2015 & naics5==33611

// Compare Treated vs Untreated Firms for the first year of sample
keep if year==2010

levelsof naics5, local(indlist)
foreach ind of local indlist{
	qui reg rev treat if naics5==`ind'
	gen dif`ind' = _b[treat]
	gen se`ind' = _se[treat]
	local t`ind' = _b[treat]/_se[treat]
	gen pv`ind'= 2*ttail(e(df_r),abs(`t`ind''))
}

collapse (mean) mrev=revenue (sd) sdrev=revenue (count) nof=id (max) pv* dif* se*, by(naics5 treat)

preserve
keep pv* dif* se*
keep if _n==1
gen i=1
reshape long dif se pv, i(i) j(ind) 
drop i
drop if pv==.
rename ind naics5

tempfile comp
save `comp'
restore

drop pv* dif* se*

merge m:1 naics5 using `comp'
drop if _m==1					//industries without treated
drop _m

reshape wide mrev sdrev nof, i(naics5) j(treat)

rename (mrev0 mrev1 sdrev0 sdrev1 dif se) (rev0m rev1m rev0sd rev1sd difm difsd) 

reshape long rev0 rev1 dif, i(naics5) j(stat) string

replace naics5=. if stat=="sd"
replace nof0=. if stat=="sd"
replace nof1=. if stat=="sd"
replace pv=. if stat=="sd"

drop stat
order naics5 nof1 rev1 nof0 rev0 dif pv 

//billions
replace rev1=rev1/1000000000
replace rev0=rev0/1000000000
replace dif = dif/1000000000

replace rev1=round(rev1, 0.001)
replace rev0=round(rev0, 0.001)
replace dif=round(dif, 0.001)
replace pv =round(pv,0.001)

count if pv>0.05 & !missing(pv)		//20













/*
use "$Data\built\cleaned.dta", clear


capture log close
log using "$Results\sumstat", text replace

//Firms with a controversy
collapse (sum) envph other, by(isin name naics*)
gen cont = envph!=0

tab naics2 cont
tab naics2 cont,nolab
tab naics3 cont
tab naics3 cont,nolab
tab naics4 cont
tab naics4 cont,nolab
tab naics5 cont
tab naics5 cont,nolab

bysort naics5: gen many=_N
tab naics5 cont if many>60
tab naics5 cont if many>60, nolab
tab naics5 if many>60


*gen country=substr(isin,1,2)

*tab country cont

use "$Data\built\balanced.dta", clear

corr esg envph other

keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing

corr esg envph other

gen vw = isin=="DE0007664005"
tab envph vw



log close