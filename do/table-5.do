
// Table 5

use "${git}/constructed/pope-summary.dta" , clear

  pca po_time po_checklist
    predict effort
    lab var effort "Effort (PCA)"

  local varlist effort po_time po_checklist treat_correct po_meds po_refer po_adl po_assets

  local rows ""
  foreach var in `varlist' {
    local rows `" `rows' "`: var label `var''" "" "'
  }

  di `"`rows'"'

  levelsof study , local(levels)

  cap mat drop result
  cap mat drop result_STARS
  local cols ""
  foreach study in `levels' {

    local varlist effort po_time po_checklist treat_correct po_meds po_refer po_adl po_assets

    local cols `" `cols' "`study' \\ Binary" "`study' \\ Multiple" "`study' \\ Patient" "`study' \\ FE" "`study' \\ Patient" "`study' \\ FE" "'

    cap mat drop bresult
    cap mat drop bresult_STARS

    qui foreach var in `varlist' {
      local pn 0
      reg fee_total_usd `var ' if study == "`study'", vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
        local b = _b[`var']
        local se = _se[`var']

        local p = r(table)[4,1]
        if `p' < 0.1 local pn 1
        if `p' < 0.05 local pn 2
        if `p' < 0.01 local pn 3

      mat bresult = nullmat(bresult) \ [`b'] \ [`se']
      mat bresult_STARS = nullmat(bresult_STARS) \ [`pn'] \ [0]
    }

    local varlist po_time po_checklist treat_correct po_meds po_refer // po_adl po_assets
    qui reg fee_total_usd `varlist' ///
        if study == "`study'", vce(bootstrap, strata(study) cluster(facilitycode) reps(100))

    local x = 1
    cap mat drop mresult
    cap mat drop mresult_STARS
    foreach var in `varlist' {
      local pn 0
      local b = _b[`var']
      local se = _se[`var']

      local p = r(table)[4,`x']
      local ++x
      if `p' < 0.1 local pn 1
      if `p' < 0.05 local pn 2
      if `p' < 0.01 local pn 3

      mat mresult = nullmat(mresult) \ [`b'] \ [`se']
      mat mresult_STARS = nullmat(mresult_STARS) \ [`pn'] \ [0]
    }

    // Stats

      local r = e(r2_a)
      local n = e(N)

      su fee_total_usd if study == "`study'"

      local m = r(mean)
      local s= r(sd)

      mat bresult = bresult \ [.] \ [.] \ [.] \ [.]
      mat mresult = [.] \ [.] \ mresult \ [.] \ [.] \ [.] \ [.] \ [`r'] \ [`n'] \ [`m'] \ [`s']
      mat bresult_STARS = bresult_STARS \ [0] \ [0] \ [0] \ [0]
      mat mresult_STARS = [0] \ [0] \ mresult_STARS \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0]

    mat result = nullmat(result) , bresult , mresult
    mat result_STARS = nullmat(result_STARS) , bresult_STARS , mresult_STARS

    // Next two
    local varlist po_time po_checklist treat_correct po_meds po_refer po_adl po_assets

    cap mat drop bresult
    cap mat drop bresult_STARS

    qui reg fee_total_usd `varlist' ///
        if study == "`study'", vce(bootstrap, strata(study) cluster(facilitycode) reps(100))

    local x = 1
    foreach var in `varlist' {
      local pn 0
      local b = _b[`var']
      local se = _se[`var']

      local p = r(table)[4,`x']
      local ++x
      if `p' < 0.1 local pn 1
      if `p' < 0.05 local pn 2
      if `p' < 0.01 local pn 3

      mat bresult = nullmat(bresult) \ [`b'] \ [`se']
      mat bresult_STARS = nullmat(bresult_STARS) \ [`pn'] \ [0]
    }

    // Stats

      local r1 = e(r2_a)
      local n1 = e(N)

      su fee_total_usd if study == "`study'"

      local m1 = r(mean)
      local s1 = r(sd)

    qui reg fee_total_usd `varlist' ///
        if study == "`study'", a(facilitycode) vce(bootstrap, strata(study) cluster(facilitycode) reps(100))

    local x = 1
    cap mat drop mresult
    cap mat drop mresult_STARS
    foreach var in `varlist' {
      local pn 0
      local b = _b[`var']
      if `b' == 0 local b .
      local se = _se[`var']
      if `se' == 0 local se .

      local p = r(table)[4,`x']
      local ++x
      if `p' < 0.1 local pn 1
      if `p' < 0.05 local pn 2
      if `p' < 0.01 local pn 3

    mat mresult = nullmat(mresult) \ [`b'] \ [`se']
    mat mresult_STARS = nullmat(mresult_STARS) \ [`pn'] \ [0]
  }

    // Stats

      local r2 = e(r2_a)
      local n2 = e(N)

      su fee_total_usd if study == "`study'"

      local m2 = r(mean)
      local s2 = r(sd)

      mat bresult = [.] \ [.] \ bresult \ [`r1'] \ [`n1'] \ [`m1'] \ [`s1']
      mat mresult = [.] \ [.] \ mresult \ [`r2'] \ [`n2'] \ [`m2'] \ [`s2']
      mat bresult_STARS = [0] \ [0] \  bresult_STARS \ [0] \ [0] \ [0] \ [0]
      mat mresult_STARS = [0] \ [0] \ mresult_STARS \ [0] \ [0] \ [0] \ [0]

    mat result = nullmat(result) , bresult , mresult
    mat result_STARS = nullmat(result_STARS) , bresult_STARS , mresult_STARS


    // Last two
    preserve
    replace po_time = 1
    replace po_checklist = 1

    local varlist effort po_time po_checklist treat_correct po_meds po_refer po_adl po_assets

    cap mat drop bresult
    cap mat drop bresult_STARS

    qui reg fee_total_usd `varlist' ///
        if study == "`study'", a(study) vce(bootstrap, strata(study) cluster(facilitycode) reps(100))

    local x = 1
    foreach var in `varlist' {
      local pn 0
      local b = _b[`var']
      local se = _se[`var']

      local p = r(table)[4,`x']
      local ++x
      if `p' < 0.1 local pn 1
      if `p' < 0.05 local pn 2
      if `p' < 0.01 local pn 3

      mat bresult = nullmat(bresult) \ [`b'] \ [`se']
      mat bresult_STARS = nullmat(bresult_STARS) \ [`pn'] \ [0]

    }
    restore

    // Stats

      local r1 = e(r2_a)
      local n1 = e(N)

      su fee_total_usd if study == "`study'"

      local m1 = r(mean)
      local s1 = r(sd)

    preserve
    replace po_time = 1
    replace po_checklist = 1
    qui reg fee_total_usd `varlist' ///
        if study == "`study'", a(facilitycode) vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
    restore

    local x = 1
    cap mat drop mresult
    cap mat drop mresult_STARS
    foreach var in `varlist' {
      local pn 0
      local b = _b[`var']
      if `b' == 0 local b .
      local se = _se[`var']
      if `se' == 0 local se .

      local p = r(table)[4,`x']
      local ++x
      if `p' < 0.1 local pn 1
      if `p' < 0.05 local pn 2
      if `p' < 0.01 local pn 3

      mat mresult = nullmat(mresult) \ [`b'] \ [`se']
      mat mresult_STARS = nullmat(mresult_STARS) \ [`pn'] \ [0]
    }

    // Stats

      local r2 = e(r2_a)
      local n2 = e(N)

      su fee_total_usd if study == "`study'"

      local m2 = r(mean)
      local s2 = r(sd)

      mat bresult = bresult \ [`r1'] \ [`n1'] \ [`m1'] \ [`s1']
      mat mresult = mresult \ [`r2'] \ [`n2'] \ [`m2'] \ [`s2']
      mat bresult_STARS = bresult_STARS \ [0] \ [0] \ [0] \ [0]
      mat mresult_STARS = mresult_STARS \ [0] \ [0] \ [0] \ [0]


    mat result = nullmat(result) , bresult , mresult
    mat result_STARS = nullmat(result_STARS) , bresult_STARS , mresult_STARS


}

  outwrite result using "${git}/outputs/tab5-fees-po.tex" ///
    , replace format(%9.3f) colnames(`cols') ///
      rownames(`rows' "R-Square" "Observations" "Fees Mean (USD)" "Fees SD (USD)")

  outwrite result using "${git}/outputs/tab5-fees-po.xlsx" ///
    , replace format(%9.3f) colnames(`cols') ///
      rownames(`rows' "R-Square" "Observations" "Fees Mean (USD)" "Fees SD (USD)")
