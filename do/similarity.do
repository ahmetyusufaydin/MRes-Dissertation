
use "$Data\built\market.dta", clear

levelsof naics3, local(sectorlist)					//list of naics3 sectors

foreach sector of local sectorlist {
	use "$Data\built\market.dta", clear				//call revenue distribution data

	keep if naics3==`sector'						//compute similarity matrix industry by industry
	
	levelsof isin, local(firmlist`sector') 			//list of firms in an industry

	foreach firm of local firmlist`sector' {		//take a firm within industry
		use "$Data\built\market.dta", clear
		qui keep if naics3==`sector'				//keep the firms within the same industry

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
		egen match=rowmin(fraction frac2)			//overlapping shares
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
}
************************************************
foreach sector of local sectorlist {
	foreach firm of local firmlist`sector' {
		qui merge 1:1 isin using ``firm''
		drop _m
	}
}

//Generate missing similarity index for the firms without revenue distribution data
merge 1:1 isin using "$Data\built\sector.dta"

levelsof isin if _m==2, local(misin)
foreach m of local misin {
	gen fki`m'=.
}

drop _m

sort naics3 isin
order naics* isin

save "$Data\built\similarity.dta", replace 



