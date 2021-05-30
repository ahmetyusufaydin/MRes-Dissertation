import excel "$Data\Location.xlsx", firstrow clear

drop A
rename B isin
drop if missing(isin)

rename (ISO2CodeofCompanyLocationCo ISO2CodeofPrimaryCountryof ISO2CodeofCompanyPrimaryLis CountryISO2CodeofHeadquarter) (location risk listing headq)

*ISIN: company’s home country or in most cases where the company is domiciled in or may have a corporate headquarter base
gen country = substr(isin,1,2)

drop location risk listing
replace headq=country if missing(headq)

drop country
rename headq country

save "$Data\built\headquarter.dta"

// inconsistencies accross 
/*
count if headq != country
count if location != country
count if listing != country
count if risk != country

count if headq != location
count if headq != location
