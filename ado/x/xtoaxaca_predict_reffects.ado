* ********************************** *
* Calculate predicted means ******** *
* ********************************** *
cap program drop xtoaxaca_predict_reffects
program define xtoaxaca_predict_reffects, rclass
    syntax [if], [model1(name)] model2(name) reffects(string) timevar(varname) times(numlist) groupvar(name) groupcat(numlist) ///
	[atvarmeans(string)] [nose(string)] [NOISily] [DETail] timebandwidth(string)
    
	marksample touse
	
    ************************************************************************
	**** STEPS in mean calculation of random effects                    ****
	**** 1) how many RE are there? just intercept or slopes as well?    ****
	**** 2) estimate REs for model1 (for both groups)                   ****
	**** 3) estimate REs for model2 (for both groups)                   ****
	************************************************************************
	local n_timepoints = wordcount("`times'")
	tempname refvar1 refvar2 refmat
	
	local quietly "qui: "
	if ("`noisily'" != "") {
		di as text "[ Estimating random effects ] Estimating mean of random effects for both groups {bf:`model`mod''} ..."
	}
	
	mat `refmat' = J(2,`n_timepoints',.)
	
	if "`model1'" != "" {
		local modlist "1 2"
	}
	else {
		local modlist "2"
	}
	
	foreach mod in `modlist' {
		*** 2) ***
		qui: est restore `model`mod''
				
					`quietly' di ""
					`quietly' di ""
					`quietly' est esample: , replace
					if "`reffects'" == "xtreg" {
						`quietly' predict `refvar`mod'' if `touse', u
					}
					else if "`reffects'" == "mixed" {
						local nref = `e(redim)'
						if `nref' == 1 {
							`quietly' predict `refvar`mod'' if `touse', reffects
						}
						else if `nref' >= 2 {
							forvalues X = 1/`nref' {
								tempvar  refvar`mod'_`X'  
								local revarlist`mod' "`revarlist`mod'' `refvar`mod'_`X''"
							}
							`quietly' predict `revarlist`mod''  if `touse', reffects
						}
					}
				
				
				
				
				
				if "`reffects'" == "xtreg" | ("`reffects'" == "mixed" & "`nref'" == "1") {
					local j =1
					foreach Y in `times' {
						local i = 1
						foreach X in `groupcat' {
							`quietly' sum `refvar`mod'' if `groupvar' == `X' & (`timevar' > `Y' - `timebandwidth') & (`timevar' <=`Y' + `timebandwidth')  & `touse'
							local re`i' = `r(mean)'
							local ++i
						}
						mat `refmat'[`mod',`j'] = `re1' - `re2'
						local ++j
					}
				}
				else if "`reffects'" == "mixed" & "`nref'" != "1" {
					local j =1
					foreach Y in `times' {
						local i = 1
						foreach X in `groupcat' {
							local re`i' = 0
							**** sum over RE and add them up ***
							forvalues Z = 1/`nref' {
								`quietly' sum `refvar`mod'_`Z'' if `groupvar' == `X' & (`timevar' > `Y' - `timebandwidth') & (`timevar' <=`Y' + `timebandwidth') & `touse'
								local re`i' = `re`i'' + `r(mean)'
							}
							local ++i
						}
						mat `refmat'[`mod',`j'] = `re1' - `re2'
						local ++j
					}
				}
	}
	
	
			
	
	* Return
    return matrix refmat = `refmat'

end
