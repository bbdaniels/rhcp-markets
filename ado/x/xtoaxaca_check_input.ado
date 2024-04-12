





	**######################################**		   
	**### 								 ###**
	**### program checking all the input ###**
	**### 								 ###**
    **######################################**
	
	
cap program drop xtoaxaca_check_input
program define xtoaxaca_check_input, rclass
	syntax varlist [if], groupvar(varname) groupcat(string) timevar(varname) times(numlist) ///
                    [model1(name)] model2(name) [timebandwidth(string)] [timeref(string)] ///
                     [nose]  ///
                   [change(string)] [forcesample] [muh] [normalize(varlist)] [NOISily] ///
                   [twofold(string)] [tfweight(string)] [NOLEVels] [NOCHange] [DETail] [POOLed] ///
				   [fmt(string)] [atdecompvars(string)] [resultsdata(string)] [bs(string)] ///
				   [nolevels] [weights(string)] [replay(string)] [BLOcks(string)]
				   
	marksample touse
	
	
	**** check if both nochange and nolevels has been chosen ***
	
	
	*** check variable length ****
	
	foreach X in `varlist' {
		if length("`X'") > 20 {
			xtoaxaca_helper_Error  198	"xtoaxaca does not support variables with more than 20 characters. `X' is too long."
		}
		
	}

	
     **** SET DEFAULTS for OPTIONS ****
	

	if  "`change'" != "interventionist_twofold" & "`change'" != "interventionist" & "`change'" != "smithwelch" & "`change'" != "mpjd" & "`change'" != "wellington" & "`change'" != "ssm" & "`change'" != "kim" & "`change'" != "none" &  "`change'" != "" {
        xtoaxaca_helper_Error  198	"The change option allows only 'interventionist', 'mpjd', 'kim', 'ssm', 'smithwelch', 'interventionist_twofold', 'wellington', or 'none'."
    }
	
	if ("`change'" != "" & "`change'" != "none") & "`nochange'" == "nochange" {
		 xtoaxaca_helper_Error  198	"You cannot specify the 'change()' option and 'nochange' at the same time."
	}
	
	
	 if ("`change'" == "" | "`change'" == "none" | "`nochange'" == "nochange") & "`nolevels'" != "" {
        xtoaxaca_helper_Error  198	"You can only specify 'nolevels' if you have specified the 'change()' option with someting other than 'none'."
    }
	
	if "`change'" == "" | "`nochange'" == "nochange" {
		local change "none"
	}
	
	return local change = "`change'"
	
	
	**** check if weights variable exists ****
	
	if "`weights'" != "" {
		capture confirm numeric variable `weights'
	}
	

	if "`twofold'" != "weight" & "`twofold'" != "pooled" & "`twofold'" != "off" & "`twofold'" != ""  {
        xtoaxaca_helper_Error  198	"The twofold option allows only 'weight', 'pooled' or 'off'."
    }
	else if "`twofold'" == "pooled" |  "`twofold'" == "off" |  "`twofold'" == "" {
		if "`tfweight'" != "" {
			xtoaxaca_helper_Error  198	"The tfweight option can only be specified if twofold(weight) is specified as well."
		}
	}
	else if "`twofold'" == "weight" & "`tfweight'" != "" {
		if (ustrregexm("`tfweight'", "[0-9]") == 0 | ustrregexm("`tfweight'", "[a–z]") ==1 ) {
			xtoaxaca_helper_Error  126 "The weight needs to be a numeric value between 0 and 1."
		}
		else if `tfweight' < 0 | `tfweight' > 1 {
			xtoaxaca_helper_Error  125 "The weight needs to be a numeric value between 0 and 1."
		}	
	}
	

	*** save standard locals from both models ****
	forvalues Z = 1/2 {
			if "`model`Z''" != "" { 
				qui: est restore `model`Z''
				local cmdline`Z' = "`e(cmdline)'"
				local decompnumb`Z' = wordcount("cmdline`Z'")
				local reqs`Z': colnames e(b)
				local full_reqs`Z' : colfullnames e(b)
				tokenize "`cmdline`Z''"	
				local mod`Z'n = `e(N)'
				local cmd`Z'  "`e(cmd)'"
				local refe`Z'  "`e(model)'"
			}
            
    }
    

	* Check that data set is (approximately) the same as for estimation
    if "`forcesample'" != "forcesample" {			
        qui count if `touse'
        local sampleobs = `r(N)'
        
		if  `sampleobs' == 0 {
                xtoaxaca_helper_Error  198 "No observations in data set."
        }
        else if `r(N)' != 0 {		
            if `sampleobs' != `mod2n' {
                xtoaxaca_helper_Error  198	"Number of observations for xtoaxaca is not the same as in the regression model estimated. If you want to proceed with this approach, please use the [forcesample] option."
            }		
        }
        
		if "`model1'" != "" { 
		* Check that both models have the same number of observations
			if `mod1n' != `mod2n' {
				xtoaxaca_helper_Error  198	"Number of observations in the `baseline' model (`model1') and the decomposition model (`model2') are not the same. If you want to ignore this, please use the [forcesample] option. This is not recommended."
			}
		}
    }
	
	if "`model1'" != "" {
		**** check that both models used the same regression command ****
		if "`cmd1'" != "`cmd2'" {
			xtoaxaca_helper_Error  198	"The regression commands in the two models are not the same. '`model1'' uses '`cmd1'', while '`model2'' uses '`cmd2''."
		}
	}
	
	
	
	**** check for random effects estimation ***
			if "`cmd2'" == "xtreg" | "`cmd2'" == "mixed" | "`cmd2'" == "xtmixed" {
				if "`cmd2'" == "xtmixed" {
					xtoaxaca_helper_Error  198	"xtmixed is deprecated. Please use mixed."
				}
				return local reffects = "`cmd2'"
				if "`cmd2'" == "xtreg" {
					if "`refe2'" == "be" {
						xtoaxaca_helper_Error  198	"The between-estimator gives time constant estimates. It is not supported for decomposition over time."
					}
					else {
						return local refe = "`refe2'"
					}
				}
				else {
					return local refe = "re"
				}
			}
			else {
				return local reffects = ""
			}
	
	
    ******************************************
    ****** Check Dependencies ****************
    ******************************************
    cap which estout
    if _rc {
        xtoaxaca_helper_Error  198 "You must install estout. Pleast type 'ssc install estout'"
    }
	
	
	
	
    
    ******************************************
    ***** Check Normalize ********************
    ******************************************
	
	if "`change'" == "kim" {
			di as text "WARNING: The decomposition method based on Kim expects all categorical variables to be normalized. Normalization will be conducted on all categorical decomposition variables."
			local normalize ""
			foreach X in `varlist' {
				if ustrregexm("`reqs2'","[0-9]+b[/.]`X'") == 1 {
					local fv_`X' ="i"	
				}
				else {
					local fv_`X' ="c"	
				}
				
				if "`fv_`X''" == "i" {
					local normalize "`normalize' `X'"
				}		
			}
		}
	
    if "`normalize'" != "" {
        ***** check that dummies du be normalized are part of varlist of decomposition variables ***
        local numnorm = wordcount("`normalize'")
        local nn "`normalize'"
        forvalues X = 1/`numnorm' {
            gettoken nubnorm nn: nn
            if ustrregexm("`varlist'", "`nubnorm'") == 0 {
                xtoaxaca_helper_Error  198	"`nubnorm' is missing from the decomposition variables varlist. All variables specified in the normalize option need to be part of the varlist of decomposition variables."
            }
        }
        
		
        ***** check that only categorical variables are specified in normalize
        foreach varname in `normalize' {
                    **** determine whether decomp variable is categorical (factor variable)
                    if ustrregexm("`reqs2'","[0-9]+b[/.]`varname'") == 1 {
					}
					else {
							xtoaxaca_helper_Error  452	"`varname' is not a categorical factor variable. Only categorical factor variables may be specified in normalize()."
					}
                    
         }
		 

	}
	
	
    
	return local normalize = "`normalize'"
	
    ******************************************
    **** TIME VAR AND GROUP VAR **************
    ******************************************
    *** check that groupvar and timevar only contain one variable 
    foreach X in groupvar timevar {
        capture confirm numeric variable ``X''
        local varcount = wordcount("``X''")
        if `varcount' != 1 {
            xtoaxaca_helper_Error  103 "The option `X' can only contain one variable."
        }
    } 
    
    **** check that group and timevar are factor variables or give warning ****
    foreach varname in `groupvar' `timevar' {				
		if ustrregexm("`reqs2'","[0-9]+b[/.]`varname'") == 1 {
			local fv_`varname' ="i"	
		}
		else {
			local fv_`varname' ="c"	
		}
    }
    
	
		
	

    **** check that functional form of group and time is the same across models ****
    tokenize "`cmdline1'"
    
    if ustrregexm("`cmdline2'", "``cmdpos''") == 0 {
        di as text "WARNING: The functional form of time, the group variable and/or the basecontrol variables (atvars()) seem to differ over the models. Please ensure this is done intentional. This will probably lead to mistakes in the decomposition."
    }
    
    *** check that all decomp and basecontrols variables exist 
    *** and are part of the model
    foreach X in `atvars' `varlist' {
        capture confirm numeric variable ``X''
        if ustrregexm("`full_reqs2'", "`X'") == 0 {
            xtoaxaca_helper_Error  111 "`X' is not part of the estimated model."
        }		
    }
    
    foreach X in variable  `basecontrols' {
        capture confirm numeric variable ``X''
    }
    
    **** determine whether groupcat is part of group var and only contains 2 values ****
    foreach X in groupvar {
        capture confirm numeric variable ``X''
        if !_rc  {
        
            local numcats = wordcount("`groupcat'")
            if `numcats' != 2 {
                xtoaxaca_helper_Error  148 "groupcat needs to contain exactly 2 numerical values."
            }
            * Deparse the educational categories
            qui: gettoken catA catB: groupcat
            
            foreach Z in A B {
            qui count if ``X'' == `cat`Z''
                if `r(N)' ==0 {
                    xtoaxaca_helper_Error  175 "`cat`Z'' is not a category found in the group variable ``X''."
                }
            }
        }
        else  {
            xtoaxaca_helper_Error  108 "The group variable (``X'') needs to be a numeric variable."
        }
    }
	
	
	
	
	
	*** set default for timebandwidth == 0.1 for categorical variables ***
    if "`timebandwidth'" == "" {
        if "`fv_`timevar''" == "i" {
            local timebandwidth = 0.1
        }
        else if "`fv_`timevar''" == "c" {
            di as text "WARNING: `timevar' is specified as continuous, but timebandwidth() has not been used. The default of 0.5 is used."
            local timebandwidth = 0.5
        }
    
    }
    else if (ustrregexm("`timebandwidth'", "[0-9]") == 0 | ustrregexm("`timebandwidth'", "[a–z]") ==1) {	
            xtoaxaca_helper_Error  121 "The bandwidth for calculating the means (endowments) (timebandwidth) needs to be a numeric value."
    }
	return scalar tbw = `timebandwidth'
	
	
	*** checking that there are enough observations per group around each time point within the bandwidth
	
	
	foreach Z in A B {
                    
		    * Iterate over times
                    foreach M in `times' {	
                        
                        qui count if `groupvar' ==`cat`Z'' & (`timevar' > `M' - `timebandwidth') & (`timevar' <=`M' + `timebandwidth')  & `touse'
						
						if `r(N)' == 0 {
							xtoaxaca_helper_Error 2000 "There are no observations in the time bandwidth around time point `M' for the category `cat`Z'' of `groupvar'"
						}
						else if `r(N)' < 10 {
							di as text "There are fewer than 10 observations in the time bandwidth around time point `M' for the category `cat`Z'' of `groupvar'"	
						}

					}
                 
                    
    }
	
	
	
	
        

    *** make timeref optional an select first value of times as default ***
    if "`timeref'" == "" {
        gettoken timeref: times
        di as text "The reference time point is set to `timeref'. If you want to change this, please use the timeref() option."
		return local timeref = `timeref'
    }
    else if (ustrregexm("`timeref'", "[0-9]") == 0 | ustrregexm("`timeref'", "[a–z]") ==1) {
        xtoaxaca_helper_Error  121 "The reference time point (timeref) needs to be a numeric value."
    }
    else if ustrregexm("`times'", "`timeref'") == 0 {
        xtoaxaca_helper_Error  125 "The reference time point (timeref) needs to be part of the numlist in times()."
    }
	
	
	**** check format ****
	if "`fmt'" == "" {
		local fmt = 3 
	}
	else if (ustrregexm("`fmt'", "[0-9]") == 0 | ustrregexm("`fmt'", "[a–z]") ==1) {
        xtoaxaca_helper_Error  121 "The format needs to be a numeric value between 0 and 12."
    }
	return local fmt = `fmt'

    
    **** determine wheter timeref and times are within the range of observed values
    **** --> WARNING if parametric time modelling
    **** --> xtoaxaca_helper_Error  if non-parametric modelling
    
    capture confirm numeric variable `timevar'
    if !_rc  {
        
        *** check if parametric (c. or no prefix) or non-parametric (i. prefix) ***
        *** extract  regression command from model ***

        
        local timevarpos = strpos("`cmdline2'","`timevar'")
        *** non-parametric?
        if substr("`cmdline2'",`timevarpos'-2,1) == "i" | ustrregexm(substr("`cmdline2'",`timevarpos'-2,1), "[0-9]") == 1 | substr("`cmdline2'",`timevarpos'-2,1) == "b" {
            qui levelsof(`timevar'), local(obstime)
            foreach X in `times' {
                if ustrregexm("`obstime'","`X'") == 0 {
                    xtoaxaca_helper_Error  175 "Time point `X' is not observed in the data. The non-parametric form of time (i.) does not allow estimation for time points which are not observed."
                }
            }
        }
        else if substr("`cmdline2'",`timevarpos'-2,1) == "c" | substr("`cmdline2'",`timevarpos'-1,1) == " " {
            
            qui sum `timevar' if `touse'
            foreach X in `times' {
                if (`X' > `r(max)') | `X' < `r(min)' {
                    di as text "WARNING: Time point `X' is outside the observed range of values of `timevar'"						
                }
            }
        }
    }
    else {
        xtoaxaca_helper_Error  108 "The time variable (`timevar') needs to be a numeric variable."
    }
	
	
	
	*** check blocks ***
	
	if "`blocks'" != "" & "`resultsdata'" == ""  {
		xtoaxaca_helper_Error  108 "If you specify 'blocks()', you also need to specify resultsdata()."
	}
	
	
	**********************************************
	*** check if results file already exists *****
	**********************************************
		
		gettoken resultsdata resultsrep : resultsdata, parse(",")
		if  ustrregexm("`resultsrep'", "replace") == 1 {
			local resultsreplace = 1 
		}
		else if ustrregexm("`resultsrep'", "replace") == 0 {
			local resultsreplace = 0
		}

		
		if substr("`resultsdata'",-4,4) == ".dta" {
			local dta = ""
		}
		else if substr("`resultsdata'",-4,4) != ".dta" {
			local dta = ".dta"
		}
		
		if ("`bs'" == "" | "`bs'" == "0") & "`replay'" == "" {
			capture confirm file "`resultsdata'`dta'"
				if _rc==0  {
					if `resultsreplace' == 1  {
						erase "`resultsdata'`dta'"
					 }
					 else if `resultsreplace' == 0  {
						xtoaxaca_helper_Error  175 "File `resultsdata'`dta' already exists."
					}
				}
		}
		return local resultsdata = "`resultsdata'"	
	
	***********************************************************************************
	***** check if decomposition variables are interacted in the regression model *****
	***********************************************************************************
	local decvars ""
	foreach decvar1 in `varlist' {	
		foreach decvar2 in `varlist' {
			if (ustrregexm("`full_reqs2'","[0-9]*[bc]*[/.]`decvar1'#[0-9]*[bc]*[o]*[/.]`decvar2'") == 1) {
				xtoaxaca_helper_Error  198 "Factor variables for interactions of decomposition variables are not supported. Please construct interaction terms by hand and refer to the hlp for examples."
			}
		}
	}
	
	
	*** check whether basemodel and bootstrap are specified together ***
	if "`bs'" != "" & "`model1'" != "" {
		xtoaxaca_helper_Error  198	"The 'basemodel' option does not work together with the 'bootstrap' option."
	
	}
	
	* check if bootstrapping and detail is required --> resultsdata is then also required 
	if "`bs'" != "" & "`resultsdata'" == "" & "`detail'" != "" {
		xtoaxaca_helper_Error  198	"If you want 'detail' for bootstrap(#) results, you also need to specify 'resultsdata'"
	}
	
	
end


