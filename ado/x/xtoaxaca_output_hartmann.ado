* ********************************** *
* Output for Hartmann 3-fold ******* *
* ********************************** *
cap program drop xtoaxaca_output_hartmann
program define xtoaxaca_output_hartmann, eclass
    syntax, var_names(string) times(numlist) tableoptions(string) change(string) ///
            c(name) e(name) ce(name) de(name) dc(name) dce(name) pde(name) pdc(name) pdce(name) ///
			change_y_emp(name) change_y_base(name) [NOISily]  ///
			drefmat(name) pdrefmat(name) reffects(string) ///
		   fmt(string) [resultsdata(string)] [refe(string)] [bs(string)] [NOLevels] [model1(string)]
        
    tempname summary
	
	
    * Notes
    if "`change'" == "interventionist" |  "`change'" == "hartmann" {
        local h_e "Note: Change in group differences over time if only the groups' endowments had changed."
        local h_c "Note: Change in group differences over time if only the groups' coefficients had changed."
        local h_i "Note: Change in group differences over time attributable to the interaction of change in endowments and change in coefficients."
    }
    else if  "`change'" == "ssm" {
        local h_e "Note: Change in the endowment decomposition component."
        local h_c "Note: Change in the coefficient decomposition component."
        local h_i "Note: Change in the interaction decomposition component."
    }
    
    * Label matrices rows and columns
    foreach X in de dc dce {
        mat coln ``X'' = `times'
        mat rown ``X'' = `var_names'
             
        mat coln `p`X'' = `times'
        mat rown `p`X'' = `var_names'
    }
    
	* Create summary matrix 
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
							mat `summary' = (`change_y_emp'[3, 1...] \ `drefmat'[1,1...] \ `change_y_base'[3, 1...] \ `change_y_base'[3, 1...] + `drefmat'[1,1...] \ `de'["Total", 1...] \ `dc'["Total", 1...] \ `dce'["Total", 1...] \ `drefmat'[2,1...] \ `de'["Total", 1...] + `dc'["Total", 1...] + `dce'["Total", 1...] + `drefmat'[2,1...] \ `pde'["Total", 1...] \ `pdc'["Total", 1...] \ `pdce'["Total", 1...] \ `pdrefmat'[2,1...] \ `pdrefmat'[2,1...] + `pde'["Total", 1...] + `pdc'["Total", 1...] + `pdce'["Total", 1...])
			}
			else {
							mat `summary' = (`change_y_emp'[3, 1...]  \ `de'["Total", 1...] \ `dc'["Total", 1...] \ `dce'["Total", 1...] \ `drefmat'[2,1...] \ `de'["Total", 1...] + `dc'["Total", 1...] + `dce'["Total", 1...] + `drefmat'[2,1...] \ `pde'["Total", 1...] \ `pdc'["Total", 1...] \ `pdce'["Total", 1...] \ `pdrefmat'[2,1...] \ `pdrefmat'[2,1...] + `pde'["Total", 1...] + `pdc'["Total", 1...] + `pdce'["Total", 1...])
			}
			
			if "`model1'" != "" {
							mat rown `summary' = "Change:non-parametric" "Change diff:`RE' (base)" "Change diff:Prediction" "Change diff:Base" "Decomp:Endowments" "Decomp:Coefficients" "Decomp:Interactions" "Decomp:`RE'" "Decomp:Total" "Decomp %:Endowments" "Decomp %:Coefficients" "Decomp %:Interactions" "Decomp %:`RE'" "Decomp %:Total"	
			}
			else {
							mat rown `summary' = "Change:non-parametric" "Decomp:Endowments" "Decomp:Coefficients" "Decomp:Interactions" "Decomp:`RE'" "Decomp:Total" "Decomp %:Endowments" "Decomp %:Coefficients" "Decomp %:Interactions" "Decomp %:`RE'" "Decomp %:Total"	
			}
			

		}
		else if "`reffects'" == "." {
		
			if "`model1'" != "" {
										mat `summary' = (`change_y_emp'[3, 1...] \ `change_y_base'[3, 1...] \ `de'["Total", 1...] \ `dc'["Total", 1...] \ `dce'["Total", 1...] \ `de'["Total", 1...] + `dc'["Total", 1...] + `dce'["Total", 1...] \ `pde'["Total", 1...] \ `pdc'["Total", 1...] \ `pdce'["Total", 1...] \ `pde'["Total", 1...] + `pdc'["Total", 1...] + `pdce'["Total", 1...])
			}
			else {
										mat `summary' = (`change_y_emp'[3, 1...] \ `de'["Total", 1...] \ `dc'["Total", 1...] \ `dce'["Total", 1...] \ `de'["Total", 1...] + `dc'["Total", 1...] + `dce'["Total", 1...] \ `pde'["Total", 1...] \ `pdc'["Total", 1...] \ `pdce'["Total", 1...] \ `pde'["Total", 1...] + `pdc'["Total", 1...] + `pdce'["Total", 1...])
			}

			
			
			if "`model1'" != "" {
								mat rown `summary' = "Change:non-parametric" "Change diff:Base" "Decomp:Endowments" "Decomp:Coefficients" "Decomp:Interactions" "Decomp:Total" "Decomp %:Endowments" "Decomp %:Coefficients" "Decomp %:Interactions" "Decomp %:Total"
			}
			else {
								mat rown `summary' = "Change:non-parametric" "Decomp:Endowments" "Decomp:Coefficients" "Decomp:Interactions" "Decomp:Total" "Decomp %:Endowments" "Decomp %:Coefficients" "Decomp %:Interactions" "Decomp %:Total"
			}
			
			
	
		}
		
	
    
	mat coln `summary' = `times'
	
	* Display summary matrix
	di _newline
    di as text "{bf:{ul:Decomposition of Change}}"
	estout matrix(`summary', fmt(%12.`fmt'fc)), title(Summary of changes in the outcome) `tableoptions' note("`renote'")
	
	* Display detailed matrices
	if ("`noisily'" != "" ) {
	    estout matrix(`de',fmt(%12.`fmt'fc)), title(Total change: Endowments) `tableoptions' note(`h_e')
	    estout matrix(`dc',fmt(%12.`fmt'fc)), title(Total change: Coefficients) `tableoptions' note(`h_c')
	    estout matrix(`dce',fmt(%12.`fmt'fc)), title(Total change: Interactions) `tableoptions' note(`h_i')

		di _newline
		estout matrix(`pde',fmt(%12.`fmt'fc)), title(Total Percentages of change: Endowments) `tableoptions'
		estout matrix(`pdc',fmt(%12.`fmt'fc)), title(Total Percentages of change: Coefficients) `tableoptions'
		estout matrix(`pdce',fmt(%12.`fmt'fc)), title(Total Percentages of change: Interactions) `tableoptions'
		
		
    }
	if "`change'" == "interventionist" |  "`change'" == "hartmann" {
			di as text "For an explanation of this change decomposition, please see:"
			di as text "{bf:Kröger, H., & Hartmann, J. (2020). xtoaxaca - Extending the Kitagawa-Oaxaca-Blinder Decomposition Approach to Panel Data. https://doi.org/10.31235/osf.io/egj79}"
		}
		else if  "`change'" == "ssm" {
			di as text "For an explanation of this change decomposition, please see:"
			di as text "{bf:Kim C. Decomposing the Change in the Wage Gap Between White and Black Men Over Time, 1980-2005: An Extension of the Blinder-Oaxaca Decomposition Method. Sociol Methods Res 2010; 38: 619–51.}"
		}


	
	if "`resultsdata'" != "" {
		xtoaxaca_helper_results_data `de' `dc' `dce' `drefmat', components("E C CE RE") resultsdata(`resultsdata') type("`change'") percentage("no") refe("`refe'") bs(`bs') `nolevels'
		xtoaxaca_helper_results_data `pde' `pdc' `pdce' `pdrefmat', components("E C CE RE") resultsdata(`resultsdata') type("`change'") percentage("yes")	 refe("`refe'") bs(`bs') `nolevels'
	}
		**** RETURN CHANGE ***
	ereturn matrix dE = `de'
	ereturn matrix dC = `dc'
	ereturn matrix dCE = `dce'
	ereturn matrix pdE = `pde'
	ereturn matrix pdC = `pdc'
    ereturn matrix pdCE = `pdce'
	ereturn matrix summary_change = `summary'
	
end

