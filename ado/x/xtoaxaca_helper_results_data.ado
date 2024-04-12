cap program drop xtoaxaca_helper_results_data
program define xtoaxaca_helper_results_data
    syntax namelist, components(string) resultsdata(string) type(string) percentage(string) /// 
	refe(string) [bs(string)] [NOLevels]

	 
	 tokenize `namelist'
	 
		
		tempname minmin ccc muh
		local p "p"
		local i =1
		
		local vars ""
		foreach X in `components' {
				tempfile f`X' 
				preserve
					clear
					*mat list ``i''
					mat `minmin' = ``i'''
					local `ccc': colnames(`minmin')
					local `muh': rownames(`minmin')
					local `muh' = subinstr("``muh''"," ","\",.)
					mat `minmin' = `minmin', (``muh'')
					qui svmat `minmin', names("A")
					local `ccc' "``ccc'' time"
					local m = 1
					foreach B in ``ccc'' {
						if  ustrregexm(substr("`B'",1,1),"[0-9]") == 1 {
							gettoken mj jm : B ,parse(".")
							local jm = substr("`jm'",2,.) 
							rename A`m' `jm'_`mj'
							if "`i'" == "1" {
								local vars "`vars' `jm'_`mj'"
							}
						}
						else if  ustrregexm(substr("`B'",1,1),"[0-9]") == 0 {
							rename A`m' `B'
							if "`i'" == "1" {
								local vars "`vars' `B'"
							}
						}	
						local ++m
					}
					qui gen component = "`X'"
					qui gen percentage = "`percentage'"
					qui gen type = "`type'"
					
					qui save `f`X''
				restore
				local ++i
		}
		
		preserve 
			clear
			foreach X in `components' {
				qui append using `f`X''
			}
			
			
			*** better integrate RE/FE component
			if "`refe'" != "." {
				cap drop `refe'1
				qui egen mm = mean(`refe'), by(time)
				qui replace `refe' = mm
				qui drop if component == "RE" |  component == "re"
				drop mm
			}
			else {
				qui drop if component == "RE" |  component == "re"
				qui cap drop re
				qui cap drop re2
				qui cap drop r1
				qui cap drop r2
				qui cap drop re1
			}
			
			
			if substr("`resultsdata'",-4,4) == ".dta" {
				local dta = ""
			}
			else if substr("`resultsdata'",-4,4) != ".dta" {
				local dta = ".dta"
			}
			
			
			
			**** check whether this is a bootstrapped command ***
			
			if "`bs'" == "" | "`bs'" == "0" {
				if "`bs'" == "0" {
					qui gen bs = 0
				}
				order  Intercept Total time component percentage type
				foreach ML in `vars' {
					move `ML' Intercept
				}
				capture confirm file "`resultsdata'`dta'"
				if _rc==0 {
					qui append using "`resultsdata'`dta'"
					qui save "`resultsdata'`dta'", replace
				}
				else {
					qui save "`resultsdata'`dta'"
				}
			}
			else if "`bs'" != "" & "`bs'" != "0" {
				order  Intercept Total time component percentage type
				foreach ML in `vars' {
					move `ML' Intercept
				}
				qui append using "`resultsdata'`dta'"
				qui sum bs
				
				if ("`percentage'" == "no" & "`type'" == "level") | ("`percentage'" == "no" & "`type'" != "level" & "`nolevels'" == "nolevels") {
					qui replace bs = 1 +  r(max) if bs ==.
				}
				else if "`percentage'" == "yes" {
					qui replace bs = 0 +  r(max) if bs ==.
				}
				
				qui drop if bs == 0
			
				qui save "`resultsdata'`dta'", replace
				describe
			
			}
		restore

end
