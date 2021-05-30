use "$Data\built\aware.dta", clear

rename iso2 market

merge 1:m market using "$Data\built\market.dta"
drop if _m==1
drop _m


forvalues i = 1/3 {
    preserve
    drop if missing(aware`i')

	gen times`i' = fraction*aware`i'	
	
	collapse (sum) times`i' fraction, by(isin)
	gen fragility`i' = times`i'/fraction*100
	
	// Centered and standardized fragility index
	egen mfrag`i' =mean(fragility`i')
	gen cfrag`i' =fragility`i' - mfrag`i'
	
	egen zfrag`i' = std(fragility`i')
	
	drop fraction times`i' mfrag`i'

	tempfile file`i'
	save `file`i''
	restore
}

use `file1', clear
forvalues i=2/3 {
    merge 1:1 isin using `file`i''
	drop _m
}

forvalues i=1/3 {
    sum fragility`i' cfrag`i'
}

corr cfrag*
rename zfrag1 zfrag

save "$Data\built\fragility.dta", replace




/*
drop if missing(aware1)

//Probability that a customer of the company argues: 
//"Protecting the environment should be given priority, even if it causes slower economic growth and some loss of jobs"
gen times = fraction*aware	

collapse (sum) times fraction, by(isin)
gen fragility = times/fraction*100

// Centered fragility index
egen mfrag=mean(fragility)
gen cfrag=fragility-mfrag

sum fragility cfrag

drop times fraction mfrag
*/