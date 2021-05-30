*use "$Data\built\unbalanced.dta", clear
use "$Data\built\balanced.dta", clear

*keep if naics5==32411		//Petroleum Refineries
*keep if naics5==32541		//Pharmaceutical and Medicine Manufacturing
*keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing
*keep if naics5==51721		//Wireless Telecommunications Carriers
/*
preserve
drop if scandal == 1
collapse (mean) lrev, by(treat year)
twoway connected lrev year if treat==0 || connected lrev year if treat==1
restore
*/

//--------------------- BP ----------------------
/*
egen mlrev = mean(lrev), by(year)
egen mlrev_unt = mean(lrev) if treat==0, by(year)
gen lrev_bp=lrev if name=="BP"
gen lrev_08=lrev if name=="BP" | name=="PETROLEO BRASILEIRO PN" | name=="ROYAL DUTCH SHELL A" | name=="VALERO ENERGY"
egen bp=mean(lrev_bp), by(year)
egen s08=mean(lrev_08), by(year)

egen tag = tag(year)
twoway connected bp mlrev_unt year if tag, sort xline(2008)
twoway connected s08 mlrev_unt year if tag, sort xline(2008)
twoway connected mlrev year if tag, sort
*/

//--------------------- VW ----------------------
/*
keep if name=="VOLKSWAGEN PREF." | treat==0
egen mlrev_unt = mean(lrev) if treat==0, by(year)
gen lrev_vw=lrev if name=="VOLKSWAGEN PREF."
egen vw=mean(lrev_vw), by(year)
egen tag = tag(year)
twoway connected vw mlrev_unt year if tag, sort xline(2014.5)
graph export "$Results/trend_Auto_bal.png", replace
*/

//--------------------- BAYER ----------------------
/*
keep if name=="BAYER" | treat==0
egen mlrev_unt = mean(lrev) if treat==0, by(year)
gen lrev_bayer=lrev if name=="BAYER"
egen bayer=mean(lrev_bayer), by(year)
egen tag = tag(year)
gen treatment=25
local barcall treatment year if inrange(year, 2011.5, 2013.5) | inrange(year, 2015.5, 2016.5) | inrange(year, 2017.5, 2018.5), bcolor(gs14)
twoway bar `barcall' || connected bayer mlrev_unt year if tag, sort
*/


//------------------- Regression ---------------------
xtset id year
*xtreg lrev envph i.year, fe
xtreg lrev envph esg other i.year, fe robust
xtreg lrev envph esg other i.year, fe vce(robust)
xtreg lrev envph esg other i.year, fe vce(cluster id)
xtreg lrev envph esg other i.year, fe vce(cluster naics5)
*xtreg lrev scandal esg other i.year, fe robust		//Treatment as a dummy
*xtreg lrev envph esg other i.year i.id#c.year, fe
*xtreg lrev envph esg other i.year i.id#c.year, fe cluster(id)
*reg lrev envph esg other i.id i.year
*areg lrev envph i.year, absorb(id)
*reghdfe lrev scandal esg other, absorb(id year) vce(robust)
reghdfe lrev envph esg other, absorb(id year)
reghdfe lrev envph esg other, absorb(id year) vce(robust)
reghdfe lrev envph esg other, absorb(id year) vce(cluster naics5)
reghdfe lrev envph esg other, absorb(id year) vce(cluster id)




//------------------ Dynamic DiD -----------------------
*xtreg lrev minus3 minus2 minus1 envph plus* esg other i.year, fe robust
gen zero=0
reghdfe lrev minus3 minus2 zero envph plus* before after esg other, absorb(id year) vce(robust)
*reghdfe lrev minus3 minus2 scandal plus* before after esg other, absorb(id year) vce(robust)
estimates store dynamic

coefplot dynamic, omitted keep(minus* plus* envph zero) vertical yline(0) recast(connected) coeflabels(minus3="t-3" minus2="t-2" zero="t-1" envph="Treatment period" plus1="T+1" plus2="T+2") ciopts(recast(rcap))
