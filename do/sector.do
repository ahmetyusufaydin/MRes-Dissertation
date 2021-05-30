

import excel "$Data\Sector.xlsx", sheet("Sector") firstrow clear

drop A TRBC* SIC* NACE
rename B isin
rename (NAICSSectorName NAICSSectorCode NAICSSubsectorCode NAICSSubsectorName NAICSIndustryGroupCode NAICSIndustryGroupName NAICSInternationalIndustryCod NAICSInternationalIndustryNam) (naics2n naics2 naics3 naics3n naics4 naics4n naics5 naics5n)
drop if missing(isin)

duplicates tag isin, gen(dup)
drop if dup==1 & missing(naics5)
drop dup

replace naics2=substr(naics2,1,2)
destring naics2 naics3 naics4 naics5, replace

labmask naics2, values(naics2n)
labmask naics3, values(naics3n)
labmask naics4, values(naics4n)
labmask naics5, values(naics5n)

drop naics*n

save "$Data\built\sector.dta", replace