* ********************************** *
* Calculate intercept ************** *
* ********************************** *
cap program drop xtoaxaca_calc_intercepts
program define xtoaxaca_calc_intercepts, rclass
    syntax varlist [if], model(name) [model2(name)] groupvar(name) groupcat(numlist) timevar(varname) times(numlist) ///
	 [atvars(string)] [ atvarmeans(string)] 
       marksample touse
    tempname intercepts intercepts_var variance isfactor cmd levels minlevel intA intB varA varB

    qui: est restore `model'
	local `cmd' = e(cmdline)
	
    * Initiate intercept matrix
    local n_timepoints = wordcount("`times'")
    mat `intercepts' = J(1,`n_timepoints',.)
    mat `intercepts_var' = J(1,`n_timepoints',.)
    
    * Create string for setting vars to zero <-- should be actual ref cats!!!
   
    foreach var of local varlist {
		
		* Check if variable is a factor variable
		local reqs2: colfullnames e(b)
		
	    xtoaxaca_helper_is_factor, reqs(`reqs2') variable(`var')
		 
	    local `var'_isfactor = r(is_factor)
		local fv_`var'_refcat = r(fv_`var'_refcat)
		
		
			
            **** distinguish between continuous and categorical variables ***
            if ``var'_isfactor' ==0  {
                local varmeansat0 "`varmeansat0' `var'=0"
            }
            else if ``var'_isfactor' ==1 {
                local varmeansat0 "`varmeansat0' `var'=`fv_`var'_refcat'"
            }
    }
		
  
    
	
	qui: gettoken catA catB: groupcat
	local catB = subinstr("`catB'"," ","",1)
	
			
		tempname intercept interceptdiff intercept_var interceptdiff_var A
		* Calculate margins for intercept for each group and time
		mat `interceptdiff' = J(1,`n_timepoints',.)
		mat `intercept'     = J(2,`n_timepoints',.)
		mat `interceptdiff_var' = J(1,`n_timepoints',.)
		mat `intercept_var' = J(2,`n_timepoints',.)
		local k = 1
		foreach X in `groupcat' {
			qui: est restore `model'
			// Predict outcome for each combination of group and time based on `baseline' ///
			// fixed effects model, covariate means over all years and groups are used
			preserve 
			    qui: keep if `touse'
				qui: drop if _n !=1
				qui: est esample: , replace
				qui: margins,  at(`timevar'=(`times') `groupvar'=(`X')  `varmeansat0' `atvarmeans') post  nose noestimcheck coeflegend
			restore
			
			
			// Create empty matrices
			
			
			
			// Calculate group differences in predicted outcomes 
			forvalues M = 1/`n_timepoints' {	
				local this = `M'
				if "`this'" == "1" {
					local this "1bn"
				}

				mat `intercept'[`k ',`M'] = _b[`this'._at]
				
				
			}
			local ++k
		}	
			tempname intercept_`catA' intercept_`catB' intercept_`catA'_var intercept_`catB'_var 
			mat `intercept_`catA''     = `intercept'[1,1...]
			mat `intercept_`catB''     = `intercept'[2,1...]
			mat `intercept_`catA'_var' = `intercept_var'[1,1...]
			mat `intercept_`catB'_var' = `intercept_var'[2,1...]    
			mat `intercepts' = `intercept'
			mat `intercepts_var' = `intercept_var'
		
	mat coln `intercepts' = `times'
    mat rown `intercepts' = "Group A" "Group B"
    mat coln `intercepts_var' = `times'
    mat rown `intercepts_var' = "Group A" "Group B"
    
    * Return 
	return local cmd_margins = "margins, at(`timevar'=(`times') `groupvar'=GROUCAT `at_zero') post"
    return matrix intercepts = `intercepts'
    return matrix intercepts_var = `intercepts_var'

end

