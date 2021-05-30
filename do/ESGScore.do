import excel "$Data\ESG Score.xlsx", sheet("part2") firstrow clear
tempfile part2
save `part2'

import excel "$Data\ESG Score.xlsx", sheet("part1") firstrow clear
append using `part2'

drop A
rename (B C D) (isin date fyear)
rename (ESGScore ESGCombinedScore ESGControversiesScore) (esg esgcomb esgcont)
drop if missing(isin)
drop esgcom esgcont

gen year = substr(fyear,3,.)
destring year, replace

drop if missing(year)		// 20 firms without score
drop if missing(esg)

save "$Data\built\ESGScore", replace
