* ********************************** *
* Output levels ******************** *
* ********************************** *
cap program drop xtoaxaca_output_levels
program define xtoaxaca_output_levels, eclass
    syntax, var_names(string) times(numlist) tableoptions(string) varcomp(string) [twofold(string)] ///
            e(name) [c(name)] [ce(name)] [u(name)] pe(name) [pc(name)] [pce(name)] [pu(name)] ///
	       [means_y_emp(name)] [means_y_base(name)] [NOISily]  [reffects(string)] [refmat(name)] [prefmat(name)] ///
		   fmt(string) [resultsdata(string)] [refe(string)] [bs(string)] [NOLevels] [model1(string)]
    
    di as text "" _newline
    di as text "{bf:{ul:Decomposition of Levels}}"
	
	tempname summary
    
    foreach X in `varcomp' {
		tempname Y_`X'  PY_`X' 
		
	    local m = strlower("`X'")
	    mat `Y_`X'' = ``m''
	    mat `PY_`X'' = `p`m''
		
		mat coln ``m'' = `times'
	    mat rown ``m'' = `var_names'
		mat coln `p`m'' = `times'
	    mat rown `p`m'' = `var_names'
	    
	    mat coln `Y_`X'' = `times'
	    mat rown `Y_`X'' = `var_names'
	     
	    mat coln `PY_`X'' = `times'
	    mat rown `PY_`X'' = `var_names'
    }

    
    
    local rows = rowsof(`Y_E')
	
	***************************
    * Threefold levels output *
	***************************
    if "`twofold'" == "" {
		
	    if "`reffects'" != "." {
			if "`refe'" == "fe"  {
				local RE "FE"
				local renote "FE = fixed effects."
			}
			else if "`refe'" == "re" | "`reffects'" == "mixed" {
				local RE "RE"
				local renote "RE = random effects."
			}
			
			if "`model1'" != "" {
				mat `summary' = (`means_y_emp'[3, 1...] \ `refmat'[1,1...] \ `means_y_base'[3, 1...]  \ `means_y_base'[3, 1...] + `refmat'[1,1...] )
			}
			else {
				mat `summary' = (`means_y_emp'[3, 1...] )
			}
			
			mat `summary' = (`summary' \ `Y_E'[`rows', 1...] \ `Y_C'[`rows',1...] \ `Y_CE'[`rows', 1...] \ `refmat'[2,1...] \ `refmat'[2,1...]+ `Y_E'[`rows', 1...] + `Y_C'[`rows',1...] + `Y_CE'[`rows', 1...] \ `PY_E'[`rows', 1...] \ `PY_C'[`rows',1...] \ `PY_CE'[`rows', 1...] \ `prefmat' \ `prefmat' + `PY_E'[`rows', 1...] + `PY_C'[`rows',1...] + `PY_CE'[`rows', 1...])
			
			if "`model1'" != "" {
				mat rown `summary'= "Level:non-parametric" "Outcome diff:`RE' (base)" "Outcome diff:Prediction" "Outcome diff:Base" "Decomp:Endowments" "Decomp:Coefficients" "Decomp:Interaction" "Decomp:`RE'" "Decomp:Total" "Decomp %:Endowments" "Decomp %:Coefficients" "Decomp %:Interaction" "Decomp %:`RE'" "Decomp %:Total"
			}
			else {
				mat rown `summary'= "Level:non-parametric"  "Decomp:Endowments" "Decomp:Coefficients" "Decomp:Interaction" "Decomp:`RE'" "Decomp:Total" "Decomp %:Endowments" "Decomp %:Coefficients" "Decomp %:Interaction" "Decomp %:`RE'" "Decomp %:Total"
			}
			
		}
		else if "`reffects'" == "." {
			if "`model1'" != "" {
				mat `summary' = (`means_y_emp'[3, 1...] \  `means_y_base'[3, 1...] )
			}
			else {
				mat `summary' = (`means_y_emp'[3, 1...] )
			}
			
			mat `summary' = (`summary' \ `Y_E'[`rows', 1...] \ `Y_C'[`rows',1...] \ `Y_CE'[`rows', 1...] \  `Y_E'[`rows', 1...] + `Y_C'[`rows',1...] + `Y_CE'[`rows', 1...] \ `PY_E'[`rows', 1...] \ `PY_C'[`rows',1...] \ `PY_CE'[`rows', 1...]  \ `PY_E'[`rows', 1...] + `PY_C'[`rows',1...] + `PY_CE'[`rows', 1...])
			
			if "`model1'" != "" {
				mat rown `summary'= "Level:non-parametric" "Outcome diff:Base" "Decomp:Endowments" "Decomp:Coefficients" "Decomp:Interaction" "Decomp:Total" "Decomp %:Endowments" "Decomp %:Coefficients" "Decomp %:Interaction" "Decomp %:Total"
			}
			else {
				mat rown `summary'= "Level:non-parametric" "Decomp:Endowments" "Decomp:Coefficients" "Decomp:Interaction" "Decomp:Total" "Decomp %:Endowments" "Decomp %:Coefficients" "Decomp %:Interaction" "Decomp %:Total"
			}
			
			local renote ""
		}
		
		
	    mat coln `summary' = `times'
	
		estout matrix(`summary', fmt(%12.`fmt'f)), title(Summary of level decomposition) `tableoptions' note("`renote'" )
		
		* Detailed variables output
		if ("`noisily'" != "" ) {
			estout matrix(`Y_E',fmt(%12.`fmt'fc)), title(Total: Endowments) `tableoptions' /// 
			note("The E component measures the expected change in group B’s mean outcome if group B had group A’s predictor levels.")
			estout matrix(`Y_C',fmt(%12.`fmt'fc)), title(Total: Coefficients) `tableoptions' ///
			note("The C component measures the expected change in group B’s mean outcome if group B had group A’s coefficients.")
			estout matrix(`Y_CE',fmt(%12.`fmt'fc)), title(Total: Interactions) `tableoptions'
		}
		
		
    }
	
	
    *************************
    * Twofold levels output *
	*************************
    else if "`twofold'" != "" {
		if "`reffects'" != "." {
			if "`refe'" == "fe" {
				local RE "FE"
				local renote "FE = fixed effects."
			}
			else if "`refe'" == "re" | "`reffects'" == "mixed" {
				local RE "RE"
				local renote "RE = random effects."
			}
			
			if "`model1'" != "" {
				mat `summary' = (`means_y_emp'[3, 1...] \ `refmat'[1,1...]\ `means_y_base'[3, 1...] \   `means_y_base'[3, 1...] + `refmat'[1,1...] )
			}
			else {
				mat `summary' = (`means_y_emp'[3, 1...] )
			}
			
			
			mat `summary' = (`summary' \ `Y_E'[`rows', 1...] \ `Y_U'[`rows',1...] \ `refmat'[2,1...] \ `refmat'[2,1...] + `Y_E'[`rows', 1...] + `Y_U'[`rows',1...] \ `PY_E'[`rows', 1...] \ `PY_U'[`rows',1...] \ `prefmat' \ `prefmat' + `PY_E'[`rows', 1...] + `PY_U'[`rows', 1...])
			
			
			if "`model1'" != "" {
				mat rown `summary'= "Outcome diff:Observed" "Outcome diff:`RE' (base)" "Outcome diff:Prediction" "Outcome diff:Base" "Decomp:Explained" "Decomp:Unexplained" "Decomp:`RE'" "Decomp:Total" "Decomp %:Explained" "Decomp %:Unexplained" "Decomp %:`RE'" "Decomp %: Total"
			}
			else {
				mat rown `summary'= "Outcome diff:Observed" "Decomp:Explained" "Decomp:Unexplained" "Decomp:`RE'" "Decomp:Total" "Decomp %:Explained" "Decomp %:Unexplained" "Decomp %:`RE'" "Decomp %: Total"
			}
			
			
			
		}
		else if "`reffects'" == "." {
		
			if "`model1'" != "" {
				mat `summary' = (`means_y_emp'[3, 1...] \  `means_y_base'[3, 1...] )
			}
			else {
				mat `summary' = (`means_y_emp'[3, 1...])
			}
		
			
			mat `summary' = (`summary' \ `Y_E'[`rows', 1...] \ `Y_U'[`rows',1...] \ `Y_E'[`rows', 1...] + `Y_U'[`rows',1...] \ `PY_E'[`rows', 1...] \ `PY_U'[`rows',1...] \ `PY_E'[`rows', 1...] + `PY_U'[`rows', 1...])
			
			
			
			if "`model1'" != "" {
				mat rown `summary'= "Outcome diff:observed" "Outcome diff:Base" "Decomp:Explained" "Decomp:Unexplained" "Decomp:Total" "Decomp %:Explained" "Decomp %:Unexplained" "Decomp %: Total"
			}
			else {
				mat rown `summary'= "Outcome diff:observed" "Decomp:Explained" "Decomp:Unexplained" "Decomp:Total" "Decomp %:Explained" "Decomp %:Unexplained" "Decomp %: Total"
			}
			
			
		}
		
		mat coln `summary' = `times'

        estout matrix(`summary', fmt(%12.`fmt'f)), title(Summary of level decomposition) `tableoptions' note("`renote'")
        
		* Detailed variables output
		if("`noisily'" != "" ) {
			estout matrix(`Y_E',fmt(%12.`fmt'fc)), title(Total: Endowments) `tableoptions' /// 
			note("The E component measures the expected change in group B’s mean outcome if group B had group A’s predictor levels.")
			estout matrix(`Y_U',fmt(%12.`fmt'fc)), title(Total: Unexplained) `tableoptions' ///
			note("The U component measures the part not explained by differences in endowments")
		}
    } 

	********************************
    * Threefold percentages output *
	********************************
    if "`twofold'" == "" {
		if ("`noisily'" != "" ) {
			estout matrix(`PY_E',fmt(%12.`fmt'fc)), title(Total Percentages: Endowments) `tableoptions' 
			estout matrix(`PY_C',fmt(%12.`fmt'fc)), title(Total Percentages: Coefficients) `tableoptions'
			estout matrix(`PY_CE',fmt(%12.`fmt'fc)), title(Total Percentages: Interactions) `tableoptions'
		}
		if "`resultsdata'" != "" {
			xtoaxaca_helper_results_data `e' `c' `ce' `refmat', components("E C CE RE") resultsdata(`resultsdata') type("level") percentage("no") refe("`refe'") bs(`bs') `nolevels'
			xtoaxaca_helper_results_data `pe' `pc' `pce' `prefmat', components("E C CE RE") resultsdata(`resultsdata') type("level") percentage("yes")	refe("`refe'") bs(`bs') `nolevels'
		}
    }
    
	******************************
    * Twofold percentages output *
	******************************
    else if "`twofold'" != "" {
		if ("`noisily'" != "" ) {
			estout matrix(`PY_E',fmt(%12.`fmt'fc)), title(Total Percentages: Endowments) `tableoptions' 
			estout matrix(`PY_U',fmt(%12.`fmt'fc)), title(Total Percentages: Unexplained) `tableoptions'
		}
		if "`resultsdata'" != "" {
			xtoaxaca_helper_results_data `e' `u'  `refmat', components("E U RE") resultsdata(`resultsdata') type("level") percentage("no") refe("`refe'") bs(`bs') `nolevels'
			xtoaxaca_helper_results_data `pe' `pu'  `prefmat', components("E U RE") resultsdata(`resultsdata') type("level") percentage("yes")	refe("`refe'") bs(`bs') `nolevels'
		}
    }

	

    foreach X in `varcomp' {  
        ereturn matrix `X'  = `Y_`X''
        ereturn matrix p`X' = `PY_`X''
    }
	
	ereturn matrix summary_levels = `summary'

end
