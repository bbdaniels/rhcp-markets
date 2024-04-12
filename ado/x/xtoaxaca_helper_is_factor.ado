* ********************************** *
* Check if variable is a factor **** *
* ********************************** *
cap program drop xtoaxaca_helper_is_factor
program define xtoaxaca_helper_is_factor, rclass
    syntax , reqs(string) variable(string)
    
    local is_factor = 0

    * Iterate over result column names
		* When we find one factor return it
		if (ustrregexm("`reqs'","[0-9]+b[/.]`variable'") == 1) {
			                    
			
			if ustrregexm(ustrregexs(0),"[0-9]+b.") == 1 {
                    if ustrregexm(ustrregexs(0),"[0-9]+") ==1 {
                        local fv_`variable'_refcat = ustrregexs(0)
                    }
            }
				local is_factor = 1
			
		}
		else  {
			
			local fv_`variable'_refcat = 0
		} 
	 

	 
	 
    return local varname = "`variable'"
    return local reqs = "`reqs'"
    return scalar is_factor = `is_factor'
	return scalar fv_`variable'_refcat = `fv_`variable'_refcat'
end

