// Produces formatted Binary regression tables.

cap prog drop bivreg
prog def bivreg , eclass

syntax varlist [if] [in], Indepvar(varlist) *

  marksample touse

  tempname mb
  tempname mv

  cap mat drop `mb' `mv'

  local v : word count `varlist'
  mat `mv' = J(`v',`v',0)
  local x = 0
  qui foreach var in `varlist' {
    local ++x
    reg `indepvar' `var' if `touse' , `options'
    mat `mb' = nullmat(`mb') , _b[`var']
    mat `mv'[`x',`x'] =  e(V)[1,1]
  }

  mat colnames `mb' = `varlist'
  mat colnames `mv' = `varlist'
  mat rownames `mv' = `varlist'
  ereturn clear

  ereturn post `mb' `mv' , esample(`touse')

end

// End
