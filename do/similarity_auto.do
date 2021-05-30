
use "$Data\built\market.dta", clear

keep if naics5==33611		//Automobile and Light Duty Motor Vehicle Manufacturing
levelsof isin, local(firmlist33611) 

foreach firm of local firmlist33611 {		//take a firm within industry
	use "$Data\built\market.dta", clear
	qui keep if naics5==33611				//keep the firms within the same industry

	//save the revenue distribution for that firm into a tempfile
	preserve
	qui keep if isin=="`firm'"
	keep market fraction
	rename fraction frac2
	tempfile `firm'
	save ``firm''
	restore

	//match the revenue share of that firm for each market (country) to other firms in industry
	qui merge m:1 market using ``firm''
	drop _m
	qui recode frac2 .=0

	//obtain similarity rate of that firm to each firm in industry
	egen match=rowmin(fraction frac2)		//overlapping shares
	collapse (sum) match, by(isin)

	//Rescale
	/*
	qui gen scale=match if isin=="`firm'"
	egen denom=min(scale)
	qui replace match=match/denom
	drop scale denom
	*/
	rename match fki`firm'

	save ``firm'', replace
}
**************************************************

foreach firm of local firmlist33611 {
    qui merge 1:1 isin using ``firm''
	drop _m
}

//Generate missing similarity index for the firms without revenue distribution data
preserve
use "$Data\built\sector.dta", clear
keep if naics5==33611
tempfile auto
save `auto'
restore

merge 1:1 isin using `auto'

levelsof isin if _m==2, local(misin)
foreach m of local misin {
	gen fki`m'=.
}

drop _m naics*

sort isin

save "$Data\built\similarity_auto.dta", replace 


