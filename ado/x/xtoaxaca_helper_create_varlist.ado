* ********************************** *
* Program for varlist ************** *
* ********************************** *
cap program drop xtoaxaca_helper_create_varlist
program define xtoaxaca_helper_create_varlist, rclass
    syntax varlist [if], model(name)
    marksample touse
    tempname levels variables
    
    qui: est restore `model'
    local reqs : colnames(e(b))
    
    local `variables'
    
    foreach var of local varlist {
        xtoaxaca_helper_is_factor , reqs(`reqs') variable(`var')
	
		if(r(is_factor) == 0) {
			local `variables' "``variables'' `var'"
		}
		else {
			qui: levelsof `var' if `touse', local(`levels')
				foreach l of local `levels' {
					local `variables' "``variables'' `l'.`var'"
			}
		}
    }
    
    return local variables = "``variables''"
end
