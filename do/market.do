
import excel "$Data\Risk.xlsx", firstrow clear

drop A

rename (B C CountriesofRiskRevenueFracti) (isin market fraction)

destring fraction, replace force

drop if missing(market)

duplicates drop isin market, force

// Merge with sector data
merge m:1 isin using "$Data\built\sector.dta"
drop if _m==2
drop _m

save "$Data\built\market.dta", replace