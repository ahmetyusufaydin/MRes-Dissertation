********************************************************************************
//--   WVS-EVS (Environment vs Economic Growth)   - Lowest coverage
********************************************************************************
//"Protecting the environment should be given priority, even if it causes slower economic growth and some loss of jobs."
//"Economic growth and creating jobs should be the top priority, even if the environment suffers to some extent."

use "$Data\Env Awareness\EVS_WVS_Joint_v1.1.0 STATA.dta", clear

keep uniqid gwght cntry_AN B008
drop if B008==3
recode B008 2=0

collapse (mean) aware=B008 [aweight=gwght], by(cntry_AN) 
rename cntry_AN iso2

rename aware aware1

//Correlation of awareness level with GDP
merge 1:1 iso2 using "$Data\built\gdp.dta"
drop if _m==2
drop _m

corr aware gdp

save "$Data\built\aware1.dta", replace

********************************************************************************
********************************************************************************

// Country ISO Codes
import excel "$Data\Env Awareness\ISO.xlsx", firstrow clear
rename (Alpha3code Alpha2code Country) (iso3 iso2 countryname)
drop Numeric

tempfile ISO
save `ISO'

********************************************************************************
//--   World Risk Perception 2019 (Climate Change)   - Highets coverage
********************************************************************************
//"Do you think that climate change is a serious threat to the people in this country in the next 20 years?"
import excel "$Data\Env Awareness\wrp2019.xlsx", firstrow clear
drop if missing(A)

rename A countryname

gen aware= Very+ Somewhat/2
drop B Veryseriousthreat Somewhatseriousthreat Notathreatatall Refused DK Total

merge 1:1 countryname using `ISO'
keep if _m==3
drop _m iso3

rename aware aware2

save "$Data\built\aware2.dta", replace

********************************************************************************
//--  Gallup 2007-8  (Climate Change)  ------------------------
********************************************************************************
//"How much do you know about global warming or climate change?"
//"How serious of a threat is global warming to you and your family?"
import excel "$Data\Env Awareness\gallup2007-8.xlsx", sheet("DatasetS1") firstrow clear
drop if missing(ISO)
keep ISO Aware Serious
rename ISO iso3

gen aware=Aware*Serious/10000
drop Aware Serious

merge 1:1 iso3 using `ISO' 
drop if _m==2
drop _m iso3

rename aware aware3

save "$Data\built\aware3.dta", replace


********************************************************************************
//--  MERGE  ------------------------
********************************************************************************
use "$Data\built\aware2.dta", clear

merge 1:1 iso2 using "$Data\built\aware1.dta"
drop _m
merge 1:1 iso2 using "$Data\built\aware3.dta"
drop _m

corr aware*


save "$Data\built\aware.dta", replace

