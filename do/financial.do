import excel "$Data\Financial.xlsx", sheet("part2") firstrow clear
tempfile part2
save `part2'

import excel "$Data\Financial.xlsx", sheet("part1") firstrow clear
append using `part2'

drop A
rename (B C D TotalRevenue NetSales) (isin date fyear revenue sales)
drop if missing(isin)

gen year = substr(fyear,3,.)
destring year, replace

destring revenue sales, replace force

replace revenue=sales if missing(revenue)
drop sales
drop if missing(year)		// 815 firms without financial info
drop if missing(revenue) | revenue<=0
drop if year<2000	

/*
duplicates report isin year
duplicates tag isin year, gen(dup)
drop if dup!=0 & missing(revenue)
drop dup
*/


save "$Data\built\financial", replace

