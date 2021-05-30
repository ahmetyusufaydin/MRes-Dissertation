
import excel "$Data\Name.xlsx", sheet("Name") firstrow clear
tempfile name
save `name'

use "$Data\built\financial.dta", clear

merge 1:1 isin year using "$Data\built\controversies.dta"
drop _m

merge 1:1 isin year using "$Data\built\ESGScore.dta"
drop _m

merge m:1 isin using "$Data\built\sector.dta"
drop if _m==2
drop _m

merge m:1 isin using `name'
drop if _m==2
drop _m

merge m:1 isin using "$Data\built\fragility.dta"
drop _m


//Generate country code
gen country = substr(isin,1,2)

merge m:1 country using "$Data\built\continent.dta"
drop if _m==2
drop _m

/*
merge m:1 isin using "$Data\built\headquarter.dta"
drop if _m==2
drop _m
*/

drop if missing(revenue)
drop if missing(naics2)
drop if missing(esg)


save "$Data\built\merged.dta", replace

