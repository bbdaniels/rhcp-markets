* ****************************************************************** *
* Post estimates to e store **************************************** *
* ****************************************************************** *
cap program drop xtoaxaca_helper_write_estimates
program define xtoaxaca_helper_write_estimates, eclass
	syntax, mat_b(name) mat_v(name) times(numlist) [decomp_levels(string)] [decomp_change(string)]
     
	ereturn clear

	matrix b = `mat_b'
	matrix V = `mat_v'
	
	* Create column names with equations
	local n_times = wordcount("`times'")
	local colnames
	
	foreach tok of local decomp_levels {
		foreach time of local times {
			local colnames "`colnames' `time':`tok'"
		}
	}
	foreach tok of local decomp_change {
		foreach time of local times {
			local colnames "`colnames' `time':d`tok'"
		}
	}	
	
	* Name rows and columns
	mat coln b = `colnames'
	mat coln V = `colnames'
	mat rown V = `colnames'
	
	* Return
	ereturn post b V
end

