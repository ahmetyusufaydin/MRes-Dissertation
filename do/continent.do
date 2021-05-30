import delimited "$Data\continent.txt", clear

drop three_letter country_number continent_code

rename (two_letter continent_name) (country continent)

duplicates tag country, gen(tag)

drop if tag==1 & continent=="Europe"

duplicates drop country, force

drop country_name tag

save "$Data\built\continent.dta", replace