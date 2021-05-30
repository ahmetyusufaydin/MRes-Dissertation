clear all
set more off

set maxvar 15000

* ************************************
* ********** Download ****************
* ************************************
/*
ssc install mdesc
ssc install labutil
ssc install coefplot
ssc install reghdfe
ssc install ftools
ssc install estout
*/
* ************************************
* ******** Define directory **********
* ************************************

*Uni
	global dir "C:\Users\u1891663\Dropbox\MRes Dissertation"
*ASUS
*	global dir "C:\Users\ASUS\Dropbox\MRes Dissertation"

* ************************************
* ********** Define paths ************
* ************************************

global Do "$dir\do"
global Data "$dir\data"
global Results "$dir\results"
global Tables "$dir\tables"
global Figures "$dir\figures"

* ************************************
* ********** Run code ****************
* ************************************

//Import from excel
do "$Do\controversies.do"		//controversy counts
do "$Do\ESGScore.do"			//ESG Score for companies
do "$Do\financial.do"			//Revenue in USD
do "$Do\sector.do"				//Industry codes
do "$Do\market.do"				//Revenue distribution
do "$Do\awareness.do"			//Environmental Awareness level across countries
do "$Do\gdp.do"					//GDP in 2017 by country
do "$Do\continent.do"

*do "$Do\location.do"			//I use the country codes in isin number
*do "$Do\Env.do"				//Source information for Environmental Controversies
*do "$Do\PublicHealth.do"		//Source information for PH Controversies

//Similarity Index
do "$Do\similarity.do"			//Construct similarity index within industries

//Fragility Index
do "$Do\fragility.do"			//Construct environmental fragility index

//Merge and clean
do "$Do\merge.do"
do "$Do\clean.do"

//Additional Spillover Data
do "$Do\spillover_vw_other.do"
do "$Do\spillover_bigsmall.do"


//Summary Statistics
do "$Do\sumstat.do"


//FIGURES
do "$Do\figure_trend_auto.do"
do "$Do\figure_dynamic.do"

//TABLES
do "$Do\table_auto.do"
do "$Do\table_general.do"
do "$Do\table_spillover_vw.do"
do "$Do\table_spillover_vw_other.do"
do "$Do\table_spillover_auto.do"
do "$Do\table_spillover.do"
do "$Do\table_spillover_bigsmall.do"
do "$Do\table_heterogeneity.do"
do "$Do\table_aggregate.do"

/*
//Preliminary TABLES and FIGURES
do "$Do\industry.do"
do "$Do\industry_trial.do"
do "$Do\general.do"
do "$Do\general_w.do"

do "$Do\spillover_ind.do"
do "$Do\spillover.do"
do "$Do\spillover_w.do"
do "$Do\spillover_w_noindyr.do"

do "$Do\heterogeneity.do"
do "$Do\heterogeneity_w.do"
do "$Do\heterogeneity_w_noindyr.do"
do "$Do\heterogeneity_ind.do"


