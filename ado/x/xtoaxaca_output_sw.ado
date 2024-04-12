* ********************************** *
* Output for Smith-Welch *********** *
* ********************************** *
cap program drop xtoaxaca_output_sw
program define xtoaxaca_output_sw, eclass
    syntax, var_names(string) times(numlist) tableoptions(string) sw_i(name) sw_ii(name) sw_iii(name) sw_iv(name) ///
	        psw_i(name) psw_ii(name) psw_iii(name) psw_iv(name) change_y_emp(name) change_y_base(name) [NOISily]  ///
		   fmt(string) drefmat(name) pdrefmat(name) reffects(string) [resultsdata(string)] [refe(string)] [bs(string)] [NOLevels] ///
		   [model1(string)]

        tempname summary
		
        * Notes
        local note_smithi "i - Main effect: measures the predicted change in the outcome gap that occurs because the groups are becoming more similar in."
        local note_smithii "ii - Group Interaction: the effect of changing endowments together with the group-specific coefficients."
        local note_smithiii "iii - Time Interaction: the effect of changing coefficients over time given the group's endowments."
        local note_smithiv "iv - Group-Time Interaction: the effect of changing coefficient differences between the groups over time."

		* Create summary matrix 
		local rows = rowsof(`sw_i')
		if "`reffects'" != "." {
			if "`refe'" == "fe" | "`reffects'" == "mixed" {
				local RE "FE"
				local renote "FE = fixed effects."
			}
			else if "`refe'" == "re" | "`reffects'" == "mixed" {
				local RE "RE"
				local renote "RE = random effects."
			}
			
			
			
			if "`model1'" != "" {
						mat `summary' = (`change_y_emp'[3, 1...] \ `drefmat'[1,1...] \ `change_y_base'[3, 1...] \ `change_y_base'[3, 1...] + `drefmat'[1,1...] \ `sw_i'[`rows', 1...] \ `sw_ii'[`rows', 1...] \ `sw_iii'[`rows', 1...] \ `sw_iv'[`rows', 1...] \ `drefmat'[2,1...] \  `drefmat'[2,1...] + `sw_i'[`rows', 1...] + `sw_ii'[`rows', 1...] + `sw_iii'[`rows', 1...] + `sw_iv'[`rows', 1...] \ `psw_i'[`rows', 1...] \ `psw_ii'[`rows', 1...] \ `psw_iii'[`rows', 1...] \ `psw_iv'[`rows', 1...] \ `pdrefmat'[2,1...] \ `pdrefmat'[2,1...] +`psw_i'[`rows', 1...] + `psw_ii'[`rows', 1...] + `psw_iii'[`rows', 1...] + `psw_iv'[`rows', 1...])
			mat rown `summary' = "Change:non-parametric" "Change diff:`RE' (base)" "Change diff:Prediction" "Change diff:Base" "Decomp:i" "Decomp:ii" "Decomp:iii" "Decomp:iv" "Decomp:`RE'" "Decomp:Total" "Decomp %:i" "Decomp %:ii" "Decomp %:iii" "Decomp %:iv" "Decomp %:`RE'" "Decomp %:Total"
			}
			else {
							mat `summary' = (`change_y_emp'[3, 1...]  \ `sw_i'[`rows', 1...] \ `sw_ii'[`rows', 1...] \ `sw_iii'[`rows', 1...] \ `sw_iv'[`rows', 1...] \ `drefmat'[2,1...] \  `drefmat'[2,1...] + `sw_i'[`rows', 1...] + `sw_ii'[`rows', 1...] + `sw_iii'[`rows', 1...] + `sw_iv'[`rows', 1...] \ `psw_i'[`rows', 1...] \ `psw_ii'[`rows', 1...] \ `psw_iii'[`rows', 1...] \ `psw_iv'[`rows', 1...] \ `pdrefmat'[2,1...] \ `pdrefmat'[2,1...] +`psw_i'[`rows', 1...] + `psw_ii'[`rows', 1...] + `psw_iii'[`rows', 1...] + `psw_iv'[`rows', 1...])
			mat rown `summary' = "Change:non-parametric"  "Decomp:i" "Decomp:ii" "Decomp:iii" "Decomp:iv" "Decomp:`RE'" "Decomp:Total" "Decomp %:i" "Decomp %:ii" "Decomp %:iii" "Decomp %:iv" "Decomp %:`RE'" "Decomp %:Total"
							
			}
			
			
			
		}
		else if "`reffects'" == "." {
		
		
		
					if "`model1'" != "" {
						mat `summary' = (`change_y_emp'[3, 1...] \ `change_y_base'[3, 1...] \ `sw_i'[`rows', 1...] \ `sw_ii'[`rows', 1...] \ `sw_iii'[`rows', 1...] \ `sw_iv'[`rows', 1...] \ `sw_i'[`rows', 1...] + `sw_ii'[`rows', 1...] + `sw_iii'[`rows', 1...] + `sw_iv'[`rows', 1...] \ `psw_i'[`rows', 1...] \ `psw_ii'[`rows', 1...] \ `psw_iii'[`rows', 1...] \ `psw_iv'[`rows', 1...] \ `psw_i'[`rows', 1...] + `psw_ii'[`rows', 1...] + `psw_iii'[`rows', 1...] + `psw_iv'[`rows', 1...])
		mat rown `summary' = "Change:non-parametric" "Change diff:Base" "Decomp:i" "Decomp:ii" "Decomp:iii" "Decomp:iv" "Decomp:Total" "Decomp %:i" "Decomp %:ii" "Decomp %:iii" "Decomp %:iv" "Decomp %:Total"
			}
			else {
													mat `summary' = (`change_y_emp'[3, 1...]  \ `sw_i'[`rows', 1...] \ `sw_ii'[`rows', 1...] \ `sw_iii'[`rows', 1...] \ `sw_iv'[`rows', 1...] \ `sw_i'[`rows', 1...] + `sw_ii'[`rows', 1...] + `sw_iii'[`rows', 1...] + `sw_iv'[`rows', 1...] \ `psw_i'[`rows', 1...] \ `psw_ii'[`rows', 1...] \ `psw_iii'[`rows', 1...] \ `psw_iv'[`rows', 1...] \ `psw_i'[`rows', 1...] + `psw_ii'[`rows', 1...] + `psw_iii'[`rows', 1...] + `psw_iv'[`rows', 1...])
		mat rown `summary' = "Change:non-parametric"  "Decomp:i" "Decomp:ii" "Decomp:iii" "Decomp:iv" "Decomp:Total" "Decomp %:i" "Decomp %:ii" "Decomp %:iii" "Decomp %:iv" "Decomp %:Total"
							
			}
		
		
			
		}
		
		mat coln `summary' = `times'

		
		
		
		* Display summary matrix
		di _newline
        di as text "{bf:{ul:Decomposition of Change}}"
		estout matrix(`summary', fmt(%12.`fmt'fc)), title(Summary of changes in the outcome) `tableoptions' note("`renote'")
		
		
		foreach Z in i ii iii iv { 
            mat coln `sw_`Z'' = `times'
            mat rown `sw_`Z'' = `var_names'
			mat coln `psw_`Z'' = `times'
            mat rown `psw_`Z'' = `var_names'
        }
		
		
		*** results data file ***
		if "`resultsdata'" != "" {
			xtoaxaca_helper_results_data `sw_i' `sw_ii' `sw_iii' `sw_iv' `drefmat', components("i ii iii iv re") resultsdata(`resultsdata') type("smithwelch") percentage("no")  refe("`refe'") bs(`bs') `nolevels'
			xtoaxaca_helper_results_data `psw_i' `psw_ii' `psw_iii' `psw_iv' `pdrefmat', components("i ii iii iv re") resultsdata(`resultsdata') type("smithwelch") percentage("yes")  refe("`refe'")	 bs(`bs') `nolevels'
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
            
            if ("`noisily'" != "" )  di as text "{bf:{ul:Total `PP' of Change - Smith & Welch (1989)}}"
            foreach Z in i ii iii iv { 
            mat coln ```M''sw_`Z'' = `times'
            mat rown ```M''sw_`Z'' = `var_names'
        
                if ("`noisily'" != "" ) estout matrix(```M''sw_`Z'' `ffm'), title(Total `PP' of change: `Z' ) `tableoptions' note(`note_smith`Z'')
                ereturn matrix ``M''sw_`Z' =  ```M''sw_`Z''
            }
        }

        di _newline
        di as text "For an explanation of this change decomposition, please see:"
        di as text "{bf:Smith JP, Welch FR. Black economic progress after Myrdal. J Econ Lit 1989; 27: 519–64.}"
        di _newline
        di as text  "i - Main Effect"
        di as text  "ii - Group Interaction"
        di as text  "iii - Time Interaction"
        di as text  "iv - Group-Time Interaction"
			
	    ereturn matrix summary_change = `summary'
end
