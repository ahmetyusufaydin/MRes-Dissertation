import excel "$Data\Controversies.xlsx", sheet("part2") firstrow clear
tempfile part2
save `part2'

import excel "$Data\Controversies.xlsx", sheet("part1") firstrow clear
append using `part2'

drop A
rename (B C D) (isin date fyear)
rename (EnvironmentalControversiesCoun PublicHealthControversies) (env publich)
rename (AntiCompetitionControversiesC BusinessEthicsControversies IntellectualPropertyControvers CriticalCountriesControversies TaxFraudControversies ChildLaborControversies HumanRightsControversies MgtCompensationControversiesC ConsumerComplaintsControversie ControversiesCustomerHealth ControversiesPrivacy ControversiesProductAccess ControversiesResponsibleMarket ControversiesResponsibleRD AccountingControversiesCount InsiderDealingsControversiesC ShareholderRightsControversies DiversityandOpportunityContro EmployeesHealthSafetyContro WagesWorkingConditionControve) (c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15 c16 c17 c18 c19 c20)

gen year = substr(fyear,3,.)
destring year, replace

drop if missing(year)					// 7,047 firms without controversy

egen total= rowtotal(env publich c*)	//total number of controversies
drop if total==0						//drop obs without any controversy

egen envph= rowtotal(env publich)
gen other=total-envph
drop total
drop env publich c*

/*
drop if missing(isin)

duplicates report isin year
duplicates tag isin year, gen(dup)
egen total= rowtotal(env publich c*)
drop if dup!=0 & total==0
drop dup total
*/

save "$Data\built\controversies", replace
