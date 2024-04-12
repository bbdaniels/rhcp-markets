* ********************************** *
* Output for Kim ******************* *
* ********************************** *
cap program drop xtoaxaca_output_kim
program define xtoaxaca_output_kim, eclass
    syntax, var_names(string) times(numlist) tableoptions(string) kim_D1(name) kim_D2(name) kim_D3(name) kim_D4(name) kim_D5(name) [NOISily] ///
	        pkim_D1(name) pkim_D2(name) pkim_D3(name) pkim_D4(name) pkim_D5(name) change_y_emp(name) change_y_base(name) ///
			drefmat(name) pdrefmat(name) reffects(string) fmt(string)   [resultsdata(string)] [refe(string)] [bs(string)] [NOLevels] ///
			[model1(string)]

    tempname summary
	
    * Notes
	local note_kim1 "D1 - Intercept Effect."
	local note_kim2 "D2 - Pure Coefficient Effect: captures the change in the outcome gap uniquely attributable to the coefficient changes between the groups and times."
	local note_kim3 "D3 - Coefficient Interaction Effect: measures an interaction effect between the mean coefficient difference and the endowment changes."
	local note_kim4 "D4 - Pure Endowment Effect: captures the change in the outcome gap uniquely attributable to the endowment changes between the groups and times."
	local note_kim5 "D5 - Endowment Interaction Effect: measures an interaction effect between the mean endowment difference and the coefficient changes."

	* Create summary matrix
	local rows = rowsof(`kim_D2')
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
						mat `summary' = (`change_y_emp'[3, 1...] \ `drefmat'[1,1...] \ `change_y_base'[3, 1...] \ `change_y_base'[3, 1...] + `drefmat'[1,1...] \ `kim_D1'[1, 1...] \ `kim_D2'[`rows', 1...] \ `kim_D3'[`rows', 1...] \ `kim_D4'[`rows', 1...] \ `kim_D5'[`rows', 1...] \ `drefmat'[2,1...]  \  `drefmat'[2,1...] + `kim_D1'[1, 1...] + `kim_D2'[`rows', 1...] + `kim_D3'[`rows', 1...] + `kim_D4'[`rows', 1...] + `kim_D5'[`rows', 1...]  \ `pkim_D1'[1, 1...] \ `pkim_D2'[`rows', 1...] \ `pkim_D3'[`rows', 1...] \ `pkim_D4'[`rows', 1...] \ `pkim_D5'[`rows', 1...] \ `pdrefmat'[2,1...]  \  `pdrefmat'[2,1...] + `pkim_D1'[1, 1...] + `pkim_D2'[`rows', 1...] + `pkim_D3'[`rows', 1...] + `pkim_D4'[`rows', 1...] + `pkim_D5'[`rows', 1...])
			mat rown `summary' = "Change:non-parametric" "Change diff:`RE' (base)" "Change diff:Prediction" "Change diff:Base" "Decomp:D1" "Decomp:D2" "Decomp:D3" "Decomp:D4" "Decomp:D5" "Decomp:`RE'" "Decomp:Total" "Decomp %:D1" "Decomp %:D2" "Decomp %:D3" "Decomp %:D4" "Decomp %:D5" "Decomp %:`RE'" "Decomp %:Total"
			}
			else {
							mat `summary' = (`change_y_emp'[3, 1...]  \ `kim_D1'[1, 1...] \ `kim_D2'[`rows', 1...] \ `kim_D3'[`rows', 1...] \ `kim_D4'[`rows', 1...] \ `kim_D5'[`rows', 1...] \ `drefmat'[2,1...]  \  `drefmat'[2,1...] + `kim_D1'[1, 1...] + `kim_D2'[`rows', 1...] + `kim_D3'[`rows', 1...] + `kim_D4'[`rows', 1...] + `kim_D5'[`rows', 1...]  \ `pkim_D1'[1, 1...] \ `pkim_D2'[`rows', 1...] \ `pkim_D3'[`rows', 1...] \ `pkim_D4'[`rows', 1...] \ `pkim_D5'[`rows', 1...] \ `pdrefmat'[2,1...]  \  `pdrefmat'[2,1...] + `pkim_D1'[1, 1...] + `pkim_D2'[`rows', 1...] + `pkim_D3'[`rows', 1...] + `pkim_D4'[`rows', 1...] + `pkim_D5'[`rows', 1...])
			mat rown `summary' = "Change:non-parametric"  "Decomp:D1" "Decomp:D2" "Decomp:D3" "Decomp:D4" "Decomp:D5" "Decomp:`RE'" "Decomp:Total" "Decomp %:D1" "Decomp %:D2" "Decomp %:D3" "Decomp %:D4" "Decomp %:D5" "Decomp %:`RE'" "Decomp %:Total"
							
			}
			
			
			
		}
		else if "`reffects'" == "." {
		
		
			if "`model1'" != "" {
					mat `summary' = (`change_y_emp'[3, 1...] \ `change_y_base'[3, 1...] \ `kim_D1'[1, 1...] \ `kim_D2'[`rows', 1...] \ `kim_D3'[`rows', 1...] \ `kim_D4'[`rows', 1...] \ `kim_D5'[`rows', 1...]  \ `kim_D1'[1, 1...] + `kim_D2'[`rows', 1...] + `kim_D3'[`rows', 1...] + `kim_D4'[`rows', 1...] + `kim_D5'[`rows', 1...]  \ `pkim_D1'[1, 1...] \ `pkim_D2'[`rows', 1...] \ `pkim_D3'[`rows', 1...] \ `pkim_D4'[`rows', 1...] \ `pkim_D5'[`rows', 1...] \ `pkim_D1'[1, 1...] + `pkim_D2'[`rows', 1...] + `pkim_D3'[`rows', 1...] + `pkim_D4'[`rows', 1...] + `pkim_D5'[`rows', 1...])
			mat rown `summary' = "Change:non-parametric" "Change diff:Base" "Decomp:D1" "Decomp:D2" "Decomp:D3" "Decomp:D4" "Decomp:D5" "Decomp:Total" "Decomp %:D1" "Decomp %:D2" "Decomp %:D3" "Decomp %:D4" "Decomp %:D5" "Decomp %:Total"
			}
			else {
									mat `summary' = (`change_y_emp'[3, 1...]  \ `kim_D1'[1, 1...] \ `kim_D2'[`rows', 1...] \ `kim_D3'[`rows', 1...] \ `kim_D4'[`rows', 1...] \ `kim_D5'[`rows', 1...]  \ `kim_D1'[1, 1...] + `kim_D2'[`rows', 1...] + `kim_D3'[`rows', 1...] + `kim_D4'[`rows', 1...] + `kim_D5'[`rows', 1...]  \ `pkim_D1'[1, 1...] \ `pkim_D2'[`rows', 1...] \ `pkim_D3'[`rows', 1...] \ `pkim_D4'[`rows', 1...] \ `pkim_D5'[`rows', 1...] \ `pkim_D1'[1, 1...] + `pkim_D2'[`rows', 1...] + `pkim_D3'[`rows', 1...] + `pkim_D4'[`rows', 1...] + `pkim_D5'[`rows', 1...])
			mat rown `summary' = "Change:non-parametric"  "Decomp:D1" "Decomp:D2" "Decomp:D3" "Decomp:D4" "Decomp:D5" "Decomp:Total" "Decomp %:D1" "Decomp %:D2" "Decomp %:D3" "Decomp %:D4" "Decomp %:D5" "Decomp %:Total"
							
			}
		
		

		}
		
	
	mat coln `summary' = `times'

	
	* Display summary matrix
	di _newline
    di as text "{bf:{ul:Decomposition of Change}}"
	
	estout matrix(`summary', fmt(%12.`fmt'fc)), title(Summary of changes in the outcome) `tableoptions' note("`renote'")
	
	
	foreach Z in 1 2 3 4 5 { 		
				if ("`Z'" != "1") {
					mat coln `kim_D`Z'' = `times'
					mat rown `kim_D`Z'' = `var_names'
					mat coln `pkim_D`Z'' = `times'
					mat rown `pkim_D`Z'' = `var_names'
				}
				else if ("`Z'" == "1") {
					mat coln `kim_D`Z'' = `times'
					mat rown `kim_D`Z'' = "Intercept"
					mat coln `pkim_D`Z'' = `times'
					mat rown `pkim_D`Z'' = "Intercept"
				}
			}
	
	
	*** results data file ***
	if "`resultsdata'" != "" {
		xtoaxaca_helper_results_data `kim_D1' `kim_D2' `kim_D3' `kim_D4' `kim_D5' `drefmat', components("D1 D2 D3 D4 D5 re") resultsdata(`resultsdata') type("kim") percentage("no") refe("`refe'") bs(`bs') `nolevels'
		xtoaxaca_helper_results_data `pkim_D1' `pkim_D2' `pkim_D3' `pkim_D4' `pkim_D5' `pdrefmat', components("D1 D2 D3 D4 D5 re") resultsdata(`resultsdata') type("kim") percentage("yes") 	 refe("`refe'") bs(`bs') `nolevels'
	}
	
	* Display detailed matrices
	di _newline
		
	local MM = "p"
	foreach M in N MM  {
		if "``M''" == "p" {
			local PP = "Percentages"
			local ffm = ",fmt(%9.`fmt'fc)"
		}
		else {
			local PP = ""
		}

		if ("`noisily'" != "") di as text "{bf:{ul:Total `PP' of Change - Kim (2010)}}"
		foreach X in D {
			foreach Z in 1 2 3 4 5 { 

				
				if ("`Z'" != "1") {
					mat coln ```M''kim_`X'`Z'' = `times'
				}
				else if ("`Z'" == "1") {
					mat coln ```M''kim_`X'`Z'' = `times'
				}
				if ("`noisily'" != "") {
				    estout matrix(```M''kim_`X'`Z'' `ffm'), title(Total `PP' of change: `X'`Z' ) `tableoptions' note(`note_kim`Z'')
				}
				ereturn matrix ``M''kim_`X'`Z' =  ```M''kim_`X'`Z''
			}
		}
	}
	di as text "For an explanation of this change decomposition, please see:"
	di as text "{bf:Kim C. Decomposing the Change in the Wage Gap Between White and Black Men Over Time, 1980-2005: An Extension of the Blinder-Oaxaca Decomposition Method. Sociol Methods Res 2010; 38: 619–51.}"
	di as text "D1 - Intercept Effect"
	di as text "D2 - Pure Coefficient Effect"
	di as text "D3 - Coefficient Interaction Effect"
	di as text "D4 - Pure Endowment Effect"
	di as text "D5 - Endowment Interaction Effect"
	
    ereturn matrix summary_change = `summary'
end
