* ********************************** *
* Output for Wellington ************ *
* ********************************** *
cap program drop xtoaxaca_output_wl
program define xtoaxaca_output_wl, eclass
    syntax, var_names(string) times(numlist) tableoptions(string) wl_1(name) wl_2(name) pwl_1(name) pwl_2(name) ///
	        change_y_emp(name) change_y_base(name) [NOISily]  ///
		   fmt(string) drefmat(name) pdrefmat(name) reffects(string)  [resultsdata(string)] [refe(string)] [bs(string)] [NOLevels] ///
		   [model1(string)]

    tempname summary
	
    * Notes
    local note_wl1 "1 - The portion of the change in the gap which can be accounted for by changes in the means if the returns to the independent variables were constant at t (not baseline)."
    local note_wl2 "2 - The portion of the change in the gap that can be explained by changes in the coefficients (including the constant term) over the period, evaluated at the groups' baseline (s) means."

	* Create summary matrix 
	local rows = rowsof(`wl_1')
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
						mat `summary' = (`change_y_emp'[3, 1...] \ `drefmat'[1,1...] \ `change_y_base'[3, 1...] \ `change_y_base'[3, 1...] + `drefmat'[1,1...] \ `wl_1'[`rows', 1...] \ `wl_2'[`rows', 1...] \ `drefmat'[2,1...] \ `drefmat'[2,1...] +`wl_1'[`rows', 1...] + `wl_2'[`rows', 1...] \ `pwl_1'[`rows', 1...] \ `pwl_2'[`rows', 1...] \ `pdrefmat'[2,1...] \ `pdrefmat'[2,1...] + `pwl_1'[`rows', 1...] + `pwl_2'[`rows', 1...] )
						
									mat rown `summary' = "Change:non-parametric" "Change diff:`RE' (base)" "Change diff:Prediction" "Change diff:Base" "Decomp:1" "Decomp:2" "Decomp:`RE'" "Decomp:Total" "Decomp %:1" "Decomp %:2" "Decomp %:`RE'" "Decomp %:Total"
			}
			else {
							mat `summary' = (`change_y_emp'[3, 1...]  \ `wl_1'[`rows', 1...] \ `wl_2'[`rows', 1...] \ `drefmat'[2,1...] \ `drefmat'[2,1...] +`wl_1'[`rows', 1...] + `wl_2'[`rows', 1...] \ `pwl_1'[`rows', 1...] \ `pwl_2'[`rows', 1...] \ `pdrefmat'[2,1...] \ `pdrefmat'[2,1...] + `pwl_1'[`rows', 1...] + `pwl_2'[`rows', 1...] )
							
							mat rown `summary' = "Change:non-parametric"  "Decomp:1" "Decomp:2" "Decomp:`RE'" "Decomp:Total" "Decomp %:1" "Decomp %:2" "Decomp %:`RE'" "Decomp %:Total"
							
			}
			
			
		
			
			
		}
		else if "`reffects'" == "." {
		
					if "`model1'" != "" {
						mat `summary' = (`change_y_emp'[3, 1...] \ `change_y_base'[3, 1...] \ `wl_1'[`rows', 1...] \ `wl_2'[`rows', 1...] \ `wl_1'[`rows', 1...] + `wl_2'[`rows', 1...] \ `pwl_1'[`rows', 1...] \ `pwl_2'[`rows', 1...] \ `pwl_1'[`rows', 1...] + `pwl_2'[`rows', 1...] )
			mat rown `summary' = "Change:non-parametric" "Change diff:Base" "Decomp:1" "Decomp:2" "Decomp:Total" "Decomp %:1" "Decomp %:2" "Decomp %:Total"
			}
			else {
							mat `summary' = (`change_y_emp'[3, 1...]  \ `wl_1'[`rows', 1...] \ `wl_2'[`rows', 1...] \ `wl_1'[`rows', 1...] + `wl_2'[`rows', 1...] \ `pwl_1'[`rows', 1...] \ `pwl_2'[`rows', 1...] \ `pwl_1'[`rows', 1...] + `pwl_2'[`rows', 1...] )
			mat rown `summary' = "Change:non-parametric" "Decomp:1" "Decomp:2" "Decomp:Total" "Decomp %:1" "Decomp %:2" "Decomp %:Total"
							
			}
		
		
			
		}
	
	mat coln `summary' = `times'


	* Display summary matrix
	di _newline
    di as text "{bf:{ul:Decomposition of Change}}"
	estout matrix(`summary', fmt(%12.`fmt'fc)), title(Summary of changes in the outcome) `tableoptions' note("`renote'")
	
	foreach Z in 1 2 { 
			mat coln `wl_`Z'' = `times'
			mat rown `wl_`Z'' = `var_names'
			mat coln `pwl_`Z'' = `times'
			mat rown `pwl_`Z'' = `var_names'
        }
	*** results data file ***
		if "`resultsdata'" != "" {
			xtoaxaca_helper_results_data `wl_1' `wl_2' `drefmat', components("1 2 re") resultsdata(`resultsdata') type("wellington") percentage("no")  refe("`refe'") bs(`bs') `nolevels'
			xtoaxaca_helper_results_data `pwl_1' `pwl_2' `pdrefmat', components("1 2 re") resultsdata(`resultsdata') type("wellington") percentage("yes") 	 refe("`refe'") bs(`bs') `nolevels'
		}
	
	
	* Display detailed matrices
    local MM = "p"
    foreach M in N MM  {
        if "``M''" == "p" {
        local PP = "Percentages"
        local ffm = ",fmt(%9.`fmt'fc)"
        }
        else {
        local PP = ""
        }
        
		foreach Z in 1 2 { 
			mat coln ```M''wl_`Z'' = `times'
			mat rown ```M''wl_`Z'' = `var_names'
				
			if ("`noisily'" != "")  estout matrix(```M''wl_`Z'' `ffm'), title(Total `PP' of change: Part `Z' ) `tableoptions' note(`note_wl`Z'')
			ereturn matrix ``M''wl_`Z' =  ```M''wl_`Z''
        }
    }
    ereturn local matrices = "wl_1 wl_2 pwl_1 pwl_2"
	
    di as text "For an explanation of this change decomposition, please see:"
    di as text "{bf:Wellington, A. J. (1993). Changes in the Male/Female Wage Gap, 1976-85. The Journal of Human Resources, 28(2), 383.}"
    di _newline
	
	ereturn matrix summary_change = `summary'	
end
