* ********************************** *
* Program for getting scales ******* *
* ********************************** *
capture program drop xtoaxaca_helper_get_scales
program xtoaxaca_helper_get_scales, rclass
    syntax varlist, reqs2(string)
    
    local var_factors ""
    local var_metrics ""
    
    foreach varname in `varlist' {
    
        if regexm("`reqs2'","[0-9]+b[/.]`varname'") == 1 {
            local var_factors `var_factors' `varname'
        }
        else {
            **** if variable is not a categorical factor variable, it is treated as continuous
            local fv_`varname' ="c"
                                                
            if regexm("`reqs2'","[/.]`varname'") == 0 &  regexm("`reqs2'","#`varname'") == 0 {
                di as text "WARNING: `varname' does not seem to specified as a factor variable. It is treated as continuous. The use of factor variables for all (decomposition, time and group) variables in the models is highly recommended."
                local fv_`varname' ="none"
            }	
            local var_metrics `var_metrics' `varname'
        }
        if ("`noisily'" != "") dis "`fv_`varname''"
        if ("`noisily'" != "") dis "`fv_`varname'_refcat'"
    }						
    
    return local factors "`var_factors'"
    return local metrics "`var_metrics'"
    
    
end
