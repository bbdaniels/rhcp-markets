* ********************************** *
* Calculate predicted means ******** *
* ********************************** *
cap program drop xtoaxaca_predict_outcome_means
program define xtoaxaca_predict_outcome_means, rclass
    syntax [if], model(name) timevar(varname) times(numlist) groupvar(name) groupcat(numlist) [atvarmeans(string)] [nose(string)] [NOISily] [DETail]
    
	marksample touse
    local n_timepoints = wordcount("`times'")
    tempname basediff baseline basediff_var baseline_var A Y_b1 Y_b2 Y_v1 Y_v2 outcome
    
	local quietly "qui: "

	
    * Load estimates of `baseline' model (no covariates) and normalize results
    qui: est restore `model'
    local cmd = "`e(cmdline)'"


		* Create empty matrices
		mat `basediff'     = J(1,`n_timepoints',.)
		mat `baseline'     = J(2,`n_timepoints',.)
		mat `baseline_var' = J(2,`n_timepoints',.)
		local k =1
		foreach X in `groupcat' {
			qui: est restore `model'
			preserve 
				`quietly' keep if `touse'
				`quietly' di ""
				`quietly' di as text "[ Calculating outcome ] Estimating marginal outcomes from model {bf:`model'} ..."
				`quietly' di ""
				qui: drop if _n !=1
				`quietly' est esample: , replace
				`quietly' margins, at(`timevar'=(`times') `groupvar'=(`X') `atvarmeans' ) post   nose noestimcheck 
			restore
		
			mat `A' = e(V)
			
			forvalues M = 1/`n_timepoints' {	
					local this = `M'
					if "`this'" == "1" {
						local this "1bn"
					}

					mat `baseline'[`k ',`M'] = _b[`this'._at]
					
					mat `baseline_var'[`k ',`M'] = `A'[`M',`M']
				}
				local ++k
		}
		
			
	
	
	* Create output
	mat `basediff' = `baseline'[1,1...] - `baseline'[2,1...]
	
    mat rown `basediff' = Diff
    mat rown `baseline' = A B	
    mat coln `basediff' = `times'
    mat coln `baseline' = `times'
    
    mat `outcome' = (`baseline' \ `basediff')
    mat rown `outcome' = "Group A" "Group B" "Diff"
    
	* Display results
	if ("`detail'" != "") {
	    di ""
	    estout matrix(`outcome'), mlabel(, none) title(Predicted outcome differences, model: `model')
    }
	
	* Return
    return matrix means = `outcome'
    return matrix baseline = `baseline'
    return matrix basediff = `basediff'
    return matrix baseline_var = `baseline_var'
end

