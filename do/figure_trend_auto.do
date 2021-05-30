use "$Data\built\balanced.dta", clear

keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing

//--------------------- Treated vs. Untreated ----------------------

egen mlrev_unt = mean(lrev) if treat==0, by(year)
egen mlrev_t = mean(lrev) if treat==1, by(year)
egen ttreated = mean(mlrev_t), by(year)
egen tuntreated = mean(mlrev_unt), by(year)
egen tag = tag(year)

label var ttreated "Treated After 2015"
label var tuntreated "Never Treated"

twoway connected ttreated tuntreated year if tag, sort xline(2014.5) ytitle("Log of Revenue")
graph export "$Figures/trend_Auto.png", replace 


********************************************************************************

use "$Data\built\balanced.dta", clear

keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing

//--------------------- VW ----------------------
keep if name=="VOLKSWAGEN PREF." | treat==0
egen mlrev_unt = mean(lrev) if treat==0, by(year)
gen lrev_vw=lrev if name=="VOLKSWAGEN PREF."
egen vw=mean(lrev_vw), by(year)
egen tag = tag(year)

label var vw Volkswagen
label var mlrev_unt "Never Treated Automobile Manufacturers"

twoway connected vw mlrev_unt year if tag, sort xline(2014.5) ytitle("Log of Revenue")
graph export "$Figures/trend_Auto_vw.png", replace 

