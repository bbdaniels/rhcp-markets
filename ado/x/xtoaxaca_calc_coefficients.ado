* ********************************** *
* Calculate coefficients *********** *
* ********************************** *
cap program drop xtoaxaca_calc_coefficients
program define xtoaxaca_calc_coefficients, rclass
    syntax varlist [if], model(name) groupvar(varname) groupcat(numlist) timevar(string) times(numlist) [atvars(string)] [atvarmeans(string)] ///
                   [atvarmeans(string)] [varmeansA(string)] [varmeansB(string)] [nose] varlistdetail(string)  [DETail] [NOISily] 
				   
	marksample touse
    local n_timepoints = wordcount("`times'")
    local n_decvars = wordcount("`varlistdetail'") 
	
	local quietly "qui: "


    tempname A

    foreach X in `groupcat' {
        qui: est restore `model'
		local cmd = "`e(cmdline)'"
        local catt = strpos(ustrregexra("`groupcat'", " ", ""), "`X'")

        tempname coefs_`X' coefs_`X'_var meansat_`X' Ints IntsA IntsB Ints_var IntsA_var IntsB_var mod`X' tmpA tmpB

		

			preserve 
			    `quietly' keep if `touse'
				`quietly' drop if _n != 1
				`quietly' est esample: , replace
				* Calculate group-specific marginal effects based on group-specific means 
				`quietly' margins, dydx(`varlist') at( `timevar'=(`times') `groupvar'=(`X') `atvarmeans' `varmeans`X'') atmeans post nose  noestimcheck coeflegend
			restore
   

        

		* Sort results list into matrix
        mat `meansat_`X'' = r(at)
        mat `coefs_`X''     = J(`n_timepoints',`n_decvars',.)
        mat `coefs_`X'_var' = J(`n_timepoints',`n_decvars',.)

        forvalues M = 1/`n_timepoints' {	
			if (`n_timepoints' == 1) {
				mat `coefs_`X'' = (`coefs_`X'' \ e(b))
			    mat `coefs_`X'' = `coefs_`X''[2, 1...]
			}
			
			else {
				local z = 1
				foreach dc in `varlistdetail' {
					// To recognize interaction effects
					local varpos = strpos("`cmdline2'", "`dc'") - 1
					local prefix ""
					if (substr("`cmdline2'", `varpos', 1) == "#") {
						local prefix "1."
					}

					*** parse factor variable again to access e(V) ***
					local numpref = substr("`dc'",1,strpos("`dc'",".")-1)
					local varsuf  = substr("`dc'",strpos("`dc'",".")+1,.)
					
					
					
					// Save coefficients
					if "`M'"=="1" {
						local dc`M' = _b[`prefix'`dc':1bn._at]
					}
					
					else if "`M'"!="1" {
						local dc`M' = _b[`prefix'`dc':`M'._at]
					}
					
					mat `coefs_`X''[`M',`z'] = `dc`M''
					
					local z = `z' +1
				}
			}
        }
    } 

    * Get group and time-specific constants
    local A = word("`groupcat'", 1)
    local B = word("`groupcat'", 2)
	
	
	**######################################**		   
	**### 								 ###**
	**### xtoaxaca_calc_intercepts       ###**
	**### 								 ###**
    **######################################**



	* Calculate intercept for pooled decomposition

		xtoaxaca_calc_intercepts `varlist' if `touse', model(`model') groupvar(`groupvar') groupcat(`groupcat') timevar(`timevar') times(`times')  atvars("`atvars'") atvarmeans("`atvarmeans'") 
		mat `Ints' = r(intercepts)
	
	
    mat `IntsA' = `Ints'[1,1...]'
    mat `IntsB' = `Ints'[2,1...]'
    
    mat `Ints_var' = r(intercepts_var)
    mat `IntsA_var' = `Ints_var'[1,1...]'
    mat `IntsB_var' = `Ints_var'[2,1...]'
    
	* Add intercepts to group coefficients
    mat `coefs_`A'' = (`coefs_`A'', `IntsA')
    mat `coefs_`B'' = (`coefs_`B'', `IntsB')
    
    mat `coefs_`A'_var' = (`coefs_`A'_var', `IntsA_var')
    mat `coefs_`B'_var' = (`coefs_`B'_var', `IntsB_var')
     
    mat coln `coefs_`A'' = `varlistdetail' Intercept
    mat rown `coefs_`A'' = `times'
    mat coln `coefs_`B'' = `varlistdetail' Intercept
    mat rown `coefs_`B'' = `times'
    
    mat coln `coefs_`A'_var' = `varlistdetail' Intercept
    mat rown `coefs_`A'_var' = `times'
    mat coln `coefs_`B'_var' = `varlistdetail' Intercept
    mat rown `coefs_`B'_var' = `times'
	
	if ("`detail'" != "") {
	    mat `tmpA' = `coefs_`A'''
		mat `tmpB' = `coefs_`B'''
	    estout matrix(`tmpA'), mlabel(,none) title(Coefficients group A)
		estout matrix(`tmpB'), mlabel(,none) title(Coefficients group B)
	}
    
	* Return
    return matrix coefsA = `coefs_`A''
    return matrix coefsB = `coefs_`B''
    return matrix coefsA_var = `coefs_`A'_var'
    return matrix coefsB_var = `coefs_`B'_var' 
end

