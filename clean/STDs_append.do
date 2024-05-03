*******************************
****APPEND STDs datasets*******
*******************************

clear all
cd "../data/STDs"
import delimited "1_2011.csv", varnames(1) numericcols(3 4 5)
save "1_2011.dta", replace


**Format: from .csv to .dta // *j no available: 3,7,11,14,43,52
forvalues i=2011/2024 {
	forvalues j=1/56 { 
		if inlist(`j',3,7,11,14,43,52) continue
		
		import delimited "`j'_`i'.csv" , varnames(1) numericcols(3 4 5) clear
		capture rename borough county 
		capture rename parish county 
		capture rename parishvalue countyvalue
		capture rename boroughvalue countyvalue
		gen year = `i'
		gen fips=`j'
		save "`j'_`i'.dta", replace
		clear
	}
}

**Append STDs datasets
use "1_2011.dta", clear
gen id="x"

forvalues i=2011/2024 {
	forvalues j=1/56{
		if inlist(`j',3,7,11,14,43,52) continue
		
		append using "`j'_`i'.dta"
		replace id="`j'_`i'.dta"
	}
}
drop if id=="x"

drop id

save "std_allstatesyears.dta", replace


**Merge STDs and states names

clear all
import delimited "../state_fips_master.csv"
save "state_fips_master.dta", replace

clear all
use "std_allstatesyears.dta", clear
merge m:1 fips using "state_fips_master.dta"

drop if _merge==2
drop _merge 

save "std_allstatesyears.dta", replace


