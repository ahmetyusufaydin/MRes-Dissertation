import excel "$Data\Env Awareness\ISO.xlsx", firstrow clear
rename (Alpha3code Alpha2code Country) (iso3 iso2 countryname)
drop Numeric

tempfile ISO
save `ISO'

import excel "$Data\Env Awareness\GDP", firstrow clear

keep Country* BJ

rename BJ gdp17
rename CountryCode iso3

merge 1:1 iso3 using `ISO'
drop if _m==1 | _m==2

drop _m CountryName countryname iso3

save "$Data\built\gdp.dta", replace