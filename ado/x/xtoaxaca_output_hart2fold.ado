* ********************************** *
* Output for Hartmann 2-fold ******* *
* ********************************** *
cap program drop xtoaxaca_output_hart2fold
program define xtoaxaca_output_hart2fold, eclass
    syntax, var_names(string) times(numlist) tableoptions(string) change(string) ///
             de(name) du(name)  pde(name) pdu(name)  ///
			change_y_emp(name) change_y_base(name) [NOISily]  ///
			drefmat(name) pdrefmat(name) reffects(string) ///
		   fmt(string) [resultsdata(string)] [refe(string)] [bs(string)] [nolevels] ///
		   [model1(string)]
        
    tempname summary
		
    * Notes

        local h_e "Note: Change in group differences over time if only the groups' endowments had changed and both groups had the same coefficient at time s."
        local h_u "Note: Unexplained part."

    
    * Label matrices rows and columns
    foreach X in de du {
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
					mat `summary' = (`change_y_emp'[3, 1...] \ `drefmat'[1,1...] \ `change_y_base'[3, 1...] \ `change_y_base'[3, 1...] + `drefmat'[1,1...] \ `de'["Total", 1...] \ `du'["Total", 1...]  \ `drefmat'[2,1...] \ `de'["Total", 1...] + `du'["Total", 1...]  + `drefmat'[2,1...] \ `pde'["Total", 1...] \ `pdu'["Total", 1...]  \ `pdrefmat'[2,1...] \ `pdrefmat'[2,1...] + `pde'["Total", 1...] + `pdu'["Total", 1...])
			mat rown `summary' = "Change diff:Observed" "Change diff:`RE' (base)" "Change diff:Prediction" "Change diff:Base" "Decomp:Endowments" "Decomp:Unexplained" "Decomp:`RE'" "Decomp:Total" "Decomp %:Endowments" "Decomp %:Unexplained" "Decomp %:`RE'" "Decomp %:Total"	
			}
			else {
									mat `summary' = (`change_y_emp'[3, 1...] \ `de'["Total", 1...] \ `du'["Total", 1...]  \ `drefmat'[2,1...] \ `de'["Total", 1...] + `du'["Total", 1...]  + `drefmat'[2,1...] \ `pde'["Total", 1...] \ `pdu'["Total", 1...]  \ `pdrefmat'[2,1...] \ `pdrefmat'[2,1...] + `pde'["Total", 1...] + `pdu'["Total", 1...])
			mat rown `summary' = "Change diff:Observed" "Decomp:Endowments" "Decomp:Unexplained" "Decomp:`RE'" "Decomp:Total" "Decomp %:Endowments" "Decomp %:Unexplained" "Decomp %:`RE'" "Decomp %:Total"	
			}
			
		
		}
		else if "`reffects'" == "." {
		
		
			if "`model1'" != "" {
					mat `summary' = (`change_y_emp'[3, 1...] \ `change_y_base'[3, 1...] \ `de'["Total", 1...] \ `du'["Total", 1...]  \ `de'["Total", 1...] + `du'["Total", 1...]  \ `pde'["Total", 1...] \ `pdu'["Total", 1...]  \ `pde'["Total", 1...] + `pdu'["Total", 1...] )
			mat rown `summary' = "Change diff:Observed" "Change diff:Base" "Decomp:Endowments" "Decomp:Unexplained"  "Decomp:Total" "Decomp %:Endowments" "Decomp %:Unexplained"  "Decomp %:Total"
			}
			else {
									mat `summary' = (`change_y_emp'[3, 1...]  \ `de'["Total", 1...] \ `du'["Total", 1...]  \ `de'["Total", 1...] + `du'["Total", 1...]  \ `pde'["Total", 1...] \ `pdu'["Total", 1...]  \ `pde'["Total", 1...] + `pdu'["Total", 1...] )
			mat rown `summary' = "Change diff:Observed"  "Decomp:Endowments" "Decomp:Unexplained"  "Decomp:Total" "Decomp %:Endowments" "Decomp %:Unexplained"  "Decomp %:Total"
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
	    estout matrix(`du',fmt(%12.`fmt'fc)), title(Total change: Coefficients) `tableoptions' note(`h_c')
	   

		di _newline
		estout matrix(`pde',fmt(%12.`fmt'fc)), title(Total Percentages of change: Endowments) `tableoptions'
		estout matrix(`pdu',fmt(%12.`fmt'fc)), title(Total Percentages of change: Coefficients) `tableoptions'
	
		
		if "`change'" == "interventionist" {
			di as text "For an explanation of this change decomposition, please see:"
			di as text "{bf:Kröger, H., & Hartmann, J. (2020). xtoaxaca - Extending the Kitagawa-Oaxaca-Blinder Decomposition Approach to Panel Data. https://doi.org/10.31235/osf.io/egj79.}"
		}
    }


	
	if "`resultsdata'" != "" {
		xtoaxaca_helper_results_data `de' `du'    `drefmat', components("e u re") resultsdata(`resultsdata') type("`change'") percentage("no") refe("`refe'") bs(`bs') `nolevels'
		xtoaxaca_helper_results_data `pde' `pdu' `pdrefmat', components("e u re") resultsdata(`resultsdata') type("`change'") percentage("yes")	 refe("`refe'") bs(`bs') `nolevels'
	}
		**** RETURN CHANGE ***
	ereturn matrix dE = `de'
	ereturn matrix dU = `du'

	ereturn matrix pdE = `pde'
	ereturn matrix pdU = `pdu'

	ereturn matrix summary_change = `summary'
	
end


