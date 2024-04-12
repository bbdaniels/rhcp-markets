* ********************************** *
* Output for Makepeace ************* *
* ********************************** *
cap program drop xtoaxaca_output_mpjd
program define xtoaxaca_output_mpjd, eclass
    syntax, var_names(string) times(numlist) tableoptions(string) mpjd_U_total(name) mpjd_U_pure(name) mpjd_U_price(name) [NOISily] ///
	        mpjd_E_total(name) mpjd_E_pure(name) mpjd_E_price(name) pmpjd_U_total(name) pmpjd_U_pure(name) pmpjd_U_price(name) ///
            pmpjd_E_total(name) pmpjd_E_pure(name) pmpjd_E_price(name) change_y_emp(name) change_y_base(name)  ///
		   fmt(string) drefmat(name) pdrefmat(name) reffects(string)  [resultsdata(string)] [refe(string)] [bs(string)] [NOLevels] ///
		   [model1(string)]
    
	tempname summary
	
	* Notes               
    local make_Epure  "Note: Effect of changing characteristics over time."
    local make_Eprice "Note: Measure of changing returns to a group's characteristics over time."
    local make_Upure  "Note: Effect of changing coefficients over time."
    local make_Uprice "Note: Effect of changing group characteristics over time weighted by the initial difference of coefficients."
	
	* Create summary matrix 
	local rows = rowsof(`mpjd_E_pure')
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
				mat `summary' = (`change_y_emp'[3, 1...] \ `drefmat'[1,1...] \ `change_y_base'[3, 1...] \ `change_y_base'[3, 1...] + `drefmat'[1,1...] \ `mpjd_E_pure'[`rows', 1...] \ `mpjd_E_price'[`rows', 1...] \ `mpjd_E_total'[`rows', 1...] \ `mpjd_U_pure'[`rows', 1...] \ `mpjd_U_price'[`rows', 1...] \ `mpjd_U_total'[`rows', 1...] \ `drefmat'[2,1...] \ `drefmat'[2,1...] + `mpjd_E_total'[`rows', 1...] + `mpjd_U_total'[`rows', 1...] \ `pmpjd_E_pure'[`rows', 1...] \ `pmpjd_E_price'[`rows', 1...] \ `pmpjd_E_total'[`rows', 1...] \ `pmpjd_U_pure'[`rows', 1...] \ `pmpjd_U_price'[`rows', 1...] \ `pmpjd_U_total'[`rows', 1...] \ `pdrefmat'[2,1...] \ `pdrefmat'[2,1...] + `pmpjd_E_total'[`rows', 1...] + `pmpjd_U_total'[`rows', 1...] )
			mat rown `summary' = "Change:non-parametric" "Change diff:`RE' (base)" "Change diff:Prediction" "Change diff:Base" "Explained:pure" "Explained:price" "Explained:total" "Unexplained:pure" "Unexplained:price" "Unexplained:total" "Decomp:`RE'" "Decomp:Total" "Explained %:pure" "Explained %:price" "Explained %:total" "Unexplained %:pure" "Unexplained %:price" "Unexplained %:total" "Decomp %:`RE'" "Decomp %:Total"
			}
			else {
				mat `summary' = (`change_y_emp'[3, 1...]  \ `mpjd_E_pure'[`rows', 1...] \ `mpjd_E_price'[`rows', 1...] \ `mpjd_E_total'[`rows', 1...] \ `mpjd_U_pure'[`rows', 1...] \ `mpjd_U_price'[`rows', 1...] \ `mpjd_U_total'[`rows', 1...] \ `drefmat'[2,1...] \ `drefmat'[2,1...] + `mpjd_E_total'[`rows', 1...] + `mpjd_U_total'[`rows', 1...] \ `pmpjd_E_pure'[`rows', 1...] \ `pmpjd_E_price'[`rows', 1...] \ `pmpjd_E_total'[`rows', 1...] \ `pmpjd_U_pure'[`rows', 1...] \ `pmpjd_U_price'[`rows', 1...] \ `pmpjd_U_total'[`rows', 1...] \ `pdrefmat'[2,1...] \ `pdrefmat'[2,1...] + `pmpjd_E_total'[`rows', 1...] + `pmpjd_U_total'[`rows', 1...] )
			mat rown `summary' = "Change:non-parametric"  "Explained:pure" "Explained:price" "Explained:total" "Unexplained:pure" "Unexplained:price" "Unexplained:total" "Decomp:`RE'" "Decomp:Total" "Explained %:pure" "Explained %:price" "Explained %:total" "Unexplained %:pure" "Unexplained %:price" "Unexplained %:total" "Decomp %:`RE'" "Decomp %:Total"
			}
			
			
			
		}
		else if "`reffects'" == "." {
		
		
		
					if "`model1'" != "" {
				mat `summary' = (`change_y_emp'[3, 1...] \ `change_y_base'[3, 1...] \ `mpjd_E_pure'[`rows', 1...] \ `mpjd_E_price'[`rows', 1...] \ `mpjd_E_total'[`rows', 1...] \ `mpjd_U_pure'[`rows', 1...] \ `mpjd_U_price'[`rows', 1...] \ `mpjd_U_total'[`rows', 1...] \ `mpjd_E_total'[`rows', 1...] + `mpjd_U_total'[`rows', 1...] \ `pmpjd_E_pure'[`rows', 1...] \ `pmpjd_E_price'[`rows', 1...] \ `pmpjd_E_total'[`rows', 1...] \ `pmpjd_U_pure'[`rows', 1...] \ `pmpjd_U_price'[`rows', 1...] \ `pmpjd_U_total'[`rows', 1...] \ `pmpjd_E_total'[`rows', 1...] + `pmpjd_U_total'[`rows', 1...] )
			mat rown `summary' = "Change:non-parametric" "Change diff:Base" "Explained:pure" "Explained:price" "Explained:total" "Unexplained:pure" "Unexplained:price" "Unexplained:total" "Decomp:Total" "Explained %:pure" "Explained %:price" "Explained %:total" "Unexplained %:pure" "Unexplained %:price" "Unexplained %:total" "Decomp %:Total"
			}
			else {
				mat `summary' = (`change_y_emp'[3, 1...]  \ `mpjd_E_pure'[`rows', 1...] \ `mpjd_E_price'[`rows', 1...] \ `mpjd_E_total'[`rows', 1...] \ `mpjd_U_pure'[`rows', 1...] \ `mpjd_U_price'[`rows', 1...] \ `mpjd_U_total'[`rows', 1...] \ `mpjd_E_total'[`rows', 1...] + `mpjd_U_total'[`rows', 1...] \ `pmpjd_E_pure'[`rows', 1...] \ `pmpjd_E_price'[`rows', 1...] \ `pmpjd_E_total'[`rows', 1...] \ `pmpjd_U_pure'[`rows', 1...] \ `pmpjd_U_price'[`rows', 1...] \ `pmpjd_U_total'[`rows', 1...] \ `pmpjd_E_total'[`rows', 1...] + `pmpjd_U_total'[`rows', 1...] )
			mat rown `summary' = "Change:non-parametric"  "Explained:pure" "Explained:price" "Explained:total" "Unexplained:pure" "Unexplained:price" "Unexplained:total" "Decomp:Total" "Explained %:pure" "Explained %:price" "Explained %:total" "Unexplained %:pure" "Unexplained %:price" "Unexplained %:total" "Decomp %:Total"
			}
		
		
			
		}
	
	mat coln `summary' = `times'
	

	
	* Display summary matrix
	di _newline
    di as text "{bf:{ul:Decomposition of Change}}"
	estout matrix(`summary', fmt(%12.`fmt'fc)), title(Summary of changes in the outcome) `tableoptions' note("`renote'")
	
	foreach X in E U {
		foreach Z in price pure total { 
			mat coln `mpjd_`X'_`Z'' = `times'
			mat rown `mpjd_`X'_`Z'' = `var_names'
			mat coln `pmpjd_`X'_`Z'' = `times'
			mat rown `pmpjd_`X'_`Z'' = `var_names'
		}
	}
	
	*** results data file ***
	if "`resultsdata'" != "" {
		xtoaxaca_helper_results_data `mpjd_E_pure' `mpjd_E_price' `mpjd_E_total' `mpjd_U_pure' `mpjd_U_price' `mpjd_U_total' `drefmat', components("E_pure E_price E_total U_pure U_price U_total re") resultsdata(`resultsdata') type("mpjd") percentage("no") refe("`refe'")
		xtoaxaca_helper_results_data `pmpjd_E_pure' `pmpjd_E_price' `pmpjd_E_total' `pmpjd_U_pure' `pmpjd_U_price' `pmpjd_U_total' `pdrefmat', components("E_pure E_price E_total U_pure U_price U_total re") resultsdata(`resultsdata') type("mpjd") percentage("yes") 	 refe("`refe'")
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
				
		foreach X in E U {
			foreach Z in price pure total { 
		mat coln ```M''mpjd_`X'_`Z'' = `times'
		mat rown ```M''mpjd_`X'_`Z'' = `var_names'
		
				if "`X'" == "U" {
					local www = "Unexplained"
				}
				else if "`X'" == "E" {
					local www = "Explained"
				}
				
				if ("`noisily'" != "" ) {	
					estout matrix(```M''mpjd_`X'_`Z'' `ffm'), title(Total `PP' of change: `www' `Z' ) `tableoptions' note(`make_`X'`Z'')
				}
				ereturn matrix ``M''mpjd_`X'_`Z' =  ```M''mpjd_`X'_`Z''
			}
		}
	}
	di as text "For an explanation of this change decomposition, please see:"
	di as text "{bf:Makepeace G, Paci P, Joshi H, Dolton P. How Unequally Has Equal Pay Progressed since the 1970s? A Study of Two British Cohorts. J Hum Resour 1999; 34: 534.}"
	
	ereturn matrix summary_change = `summary'
end
