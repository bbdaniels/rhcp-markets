cap program drop xtoaxaca_calc_means
program define xtoaxaca_calc_means, rclass
    syntax varlist [if], model(name) timevar(varname) times(numlist) groupvar(varname) groupcat(numlist) ///
                    timebandwidth(string)  varlistdetail(string) [DETail] [NOISily] [weights(string)]
    
	marksample touse
	
    local n_timepoints = wordcount("`times'")

    *** matrix tempnames ****
    tempname meansA meansB meansA_var meansB_var coefsA coefsB coefsA_var coefsB_var meansA_SD meansB_SD ///
             helper helper_var helper_SD unity
            
    *** initiate matrices ***
    mat `meansA' = J(1,`n_timepoints',.)
    mat `meansB' = J(1,`n_timepoints',.)

    mat `meansA_SD' = J(1,`n_timepoints',.)
    mat `meansB_SD' = J(1,`n_timepoints',.)
    local j = 1

    qui: est restore `model'
    qui: tokenize "`cmdline2'"
    local decompnumb = wordcount("`cmdline2'")
    local reqs2: colfullnames e(b)
	
	*********************************
	**** generate weights locals ****
	*********************************
	
	if "`weights'" == "" {
		local pweights ""
		local aweights ""
	}
	else if "`weights'" != "" {
		local pweights "[pweight=`weights']"
		local aweights "[aweight=`weights']"
	}
    
	**######################################**		   
	**### 								 ###**
	**### xtoaxaca_helpers.do            ###**
	**### 								 ###**
    **######################################**
    local i = 1
    xtoaxaca_helper_get_scales `varlist', reqs2("`reqs2'")     
    local factors  `r(factors)'
    local metrics  `r(metrics)'
   
    local catA = word("`groupcat'", 1)
    local catB = word("`groupcat'", 2)
    
    *** Iterate over composition variables ****
    local fv_varnames
    
	**######################################**		   
	**### 								 ###**
	**### xtoaxaca_helpers.do            ###**
	**### 								 ###**
    **######################################**
    foreach varname in `varlist' {
	
        **** determine whether decomp variable is categorical (factor variable)
        if regexm("`factors'","`varname'") == 1 {
            if regexm("`reqs2'","[0-9]+b[/.]`varname'") == 1 {
                if regexm(regexs(0),"[0-9]+b.") == 1 {
                    if regexm(regexs(0),"[0-9]+") {
                        local fv_`varname'_refcat = regexs(0)
                    }
                }
            }
	    
            qui: levelsof `varname' if `touse', local(varcats)
            local `varname'_varcats  = wordcount("`varcats'")
            local `varname'_colrange1 = `i'
            local `varname'_colrange2 = `i'+``varname'_varcats'-1
            local i = `i' + ``varname'_varcats'
			return scalar `varname'_colrange1 = ``varname'_colrange1'
			return scalar `varname'_colrange2 = ``varname'_colrange2'
	    
	    * Iterate over variable categories
            foreach V in `varcats' {
                tempvar tv`varname'`V'
                qui gen `tv`varname'`V''     = 1 if `varname' == `V' & `touse'
                qui recode `tv`varname'`V'' .= 0 if `varname' != . & `touse'
            
		* Iterate over groups A and B
	        foreach Z in A B {
                    mat  `helper' = J(1,`n_timepoints',.)
                  
                    mat  `helper_SD' = J(1,`n_timepoints',.)
                    local j =1
		    
		    * Iterate over times
                    foreach M in `times' {	
                        // e.g. mean divorced if education == 1 & timemarried > 0 - 1 & timemarried <= 0 + 1
                        *qui mean `tv`varname'`V'' `pweights' if `groupvar' ==`cat`Z'' & (`timevar' > `M' - `timebandwidth') & (`timevar' <=`M' + `timebandwidth')  & `touse'
                        
                        *mat `helper_var'[1,`j'] =  e(V)
                        qui sum `tv`varname'`V'' `aweights' if `groupvar' ==`cat`Z'' & (`timevar' > `M' - `timebandwidth') & (`timevar' <=`M' + `timebandwidth')  & `touse'
                        mat `helper_SD'[1,`j'] = `r(Var)'
						mat `helper'[1,`j'] =  r(mean)
                        local ++j

		    }
                   mat `means`Z'' = `means`Z'' \ `helper'
                   
                   mat `means`Z'_SD' = `means`Z'_SD' \ `helper_SD'
                    
                }
                qui: drop `tv`varname'`V''
            }
        }
	
        else if regexm("`metrics'","`varname'") == 1 {
		**** if variable is not a categorical factor variable, it is treated as continuous
		local fv_`varname' ="c"

		if regexm("`cmdline2'","[/.]`varname'") == 0 &  regexm("`cmdline2'","#`varname'") == 0 {
			*di as text "WARNING: `varname' does not seem to specified as a factor variable. It is treated as continuous. The use of factor variables for all (decomposition, time and group) variables in the models is highly recommended."
			local fv_`varname' ="none"
		}

		foreach Z in A B {
			mat `helper' = J(1,`n_timepoints',.)
			
			mat `helper_SD' = J(1,`n_timepoints',.)
			local j =1
			foreach M in `times' {	
				// e.g. mean divorced if education == 1 & timemarried > 0 - 1 & timemarried <= 0 + 1
				qui sum `varname' `aweights' if `groupvar' ==`cat`Z'' & (`timevar' > `M' - `timebandwidth') & (`timevar' <=`M' + `timebandwidth')  & `touse'
				mat `helper'[1,`j'] =  r(mean)
				mat `helper_SD'[1,`j'] = `r(Var)'
				local ++j

			}
		    mat `means`Z'' = `means`Z'' \ `helper'
		    
		    mat `means`Z'_SD' = `means`Z'_SD' \ `helper_SD'
		}
		local ++i
        }
        else {
			**######################################**		   
			**### 								 ###**
			**### xtoaxaca_helpers.do            ###**
			**### 								 ###**
			**######################################**
            xtoaxaca_helper_Error 198 "Error in factor parsing"
        }
	
    }

    * Add intercepts
    mat `unity' =  J(1,`n_timepoints',1) 
    mat `meansA' = (`meansA' \ `unity')
    mat `meansB' = (`meansB' \ `unity')

	mat `meansA_SD' = (`meansA_SD' \ `unity')
    mat `meansB_SD' = (`meansB_SD' \ `unity')
  
    * Clean means matrices
    foreach X in  `meansA' `meansB' `meansA_SD' `meansB_SD' {
	di "``X''"
        local rof = rowsof(`X')
        local cof = colsof(`X')
        mat `X' = `X'[2..`rof',1..`cof']
        mat coln `X' = `times'
	    mat rown `X' = `varlistdetail' Intercept
    }
    
	if ("`detail'" != "" | "`noisiy'" != "") {
	    estout matrix(`meansA'), mlabel(, none) title(Endowment means group A)
		estout matrix(`meansB'), mlabel(, none) title(Endowment means group B)
	}
	
    * Return
    return matrix meansA = `meansA'
    return matrix meansB = `meansB'

    return matrix meansA_SD = `meansA_SD'
    return matrix meansB_SD = `meansB_SD'

end

