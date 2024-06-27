// Produces formatted Bivariate regression tables.

cap prog drop bivreg
prog def bivreg , eclass

syntax varlist [if] [in], * [Controls(string asis)]

  marksample touse

  tempname mb
  tempname mv

  cap mat drop `mb' `mv'

  local depvar : word 1 of `varlist'
  local varlist = subinstr("`varlist'","`depvar'","",1)

  local v : word count `varlist'
  mat `mv' = J(`v',`v',0)
  local x = 0
  qui foreach var in `varlist' {
    local ++x
    reg `depvar' `var' `controls' if `touse' , `options'
    mat `mb' = nullmat(`mb') , _b[`var']
    mat `mv'[`x',`x'] =  e(V)[1,1]
  }

  mat colnames `mb' = `varlist'
  mat colnames `mv' = `varlist'
  mat rownames `mv' = `varlist'
  ereturn clear

  qui reg `depvar' `varlist' if `touse' , nocons
  ereturn repost b = `mb' V = `mv' , rename
  ereturn scalar r2 = .
  ereturn scalar r2_a = .

end

// End
