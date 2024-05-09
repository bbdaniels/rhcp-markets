// Table 0 -- referral/refusal
use "${git}/constructed/sp_checklist_all.dta", clear

  ren treat_refer refer
  clonevar correct = treat_correct

  drop type
  gen type = .
    replace type = 1 if refer == 0 & correct == 0
    replace type = 2 if refer == 0 & correct == 1
    replace type = 3 if refer == 1 & check_std < -1.2 & correct == 0
    replace type = 4 if refer == 1 & check_std > -1.2 & correct == 0
    replace type = 5 if refer == 1 & correct == 1

  lab def type ///
    1 "Incorrect" ///
    2 "Correct" ///
    3 "Refusal" ///
    4 "Referral" ///
    5 "Correct and Referral"

  lab val type type

  ta type study_code , col matcell(mat)

  outwrite mat using "${git}/outputs/tab-refer-sp.xlsx" ///
    , replace format(%9.0f) colnames("Birbhum C" "Birbhum T" "Delhi" "Kenya" "MP" "Mumbai" "Patna") ///
      rownames("Incorrect" "Correct" "Refusal" "Referral" "Correct and Refer")

// Table 0 -- referral/refusal
use "${git}/constructed/vig_checklist_all.dta", clear

  ren treat_refer refer
  clonevar correct = treat_correct

  drop type

  gen type = .
    replace type = 1 if refer == 0 & correct == 0
    replace type = 2 if refer == 0 & correct == 1
    replace type = 3 if refer == 1 & check_std < -1.2 & correct == 0
    replace type = 4 if refer == 1 & check_std > -1.2 & correct == 0
    replace type = 5 if refer == 1 & correct == 1

  lab def type ///
    1 "Incorrect" ///
    2 "Correct" ///
    3 "Refusal" ///
    4 "Referral" ///
    5 "Correct and Referral"

  lab val type type

  ta type study_code , col matcell(mat)

  outwrite mat using "${git}/outputs/tab-refer-vig.xlsx" ///
    , replace format(%9.0f) colnames("Birbhum C" "China" "Delhi" "MP") ///
      rownames("Incorrect" "Correct" "Refusal" "Correct and Refer")

// Table 1
use "${git}/constructed/sp-summary.dta" , clear

  replace study = "MP Public" if study == "MP" & private == 0
  replace study = "Kenya Public" if study == "Kenya" & private == 0

  tabstat treat_any1 treat_correct1 treat_over1 treat_under1 ///
          med_anti_nodys med_steroid_noast treat_refer ///
  , by(study) save stats(mean n)

  cap mat drop result
  forv i = 1/9 {
    mat a = r(Stat`i')
    mat result = nullmat(result) \ a
  }
  mat result_STARS = J(rowsof(result),colsof(result),0)

  outwrite result using "${git}/outputs/tab1-summary.tex" , replace ///
    rownames("Birbhum" "N" "China" "N" "Delhi" "N" "Kenya" "N" "Kenya Public" "N" "MP" "N" "MP Public" "N" "Mumbai" "N" "Patna" "N") ///
    colnames("Any Correct" "Correct" "Overtreat" "Incorrect" "Antibiotics \\ (Ex. Diarrhea)" "Steroids \\ (Ex. Asthma)" "Refer")

  outwrite result using "${git}/outputs/tab1-summary.xlsx" , replace ///
    rownames("Birbhum" "N" "China" "N" "Delhi" "N" "Kenya" "N" "Kenya Public" "N" "MP" "N" "MP Public" "N" "Mumbai" "N" "Patna" "N") ///
    colnames("Any Correct" "Correct" "Overtreat" "Incorrect" "Antibiotics \\ (Ex. Diarrhea)" "Steroids \\ (Ex. Asthma)" "Refer")

// Table 2
use "${git}/constructed/sp-summary.dta" , clear


  replace study = "MP Public" if study == "MP" & private == 0
  replace study = "Kenya Public" if study == "Kenya" & private == 0

  tabstat cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd ///
          frac_avoid frac_avoid1 frac_avoid2 ///
  , by(study) save stats(mean n)

  cap mat drop result
  forv i = 1/9 {
    mat a = r(Stat`i')
    mat result = nullmat(result) \ a
  }
  mat result_STARS = J(rowsof(result),colsof(result),0)

  outwrite result using "${git}/outputs/tab2-costs.tex" , replace ///
  rownames("Birbhum" "N" "China" "N" "Delhi" "N" "Kenya" "N" "Kenya Public" "N" "MP" "N" "MP Public" "N" "Mumbai" "N" "Patna" "N") ///
    colnames("Cost" "Consult" "Medicine" "Avoidable" "Avoidable \\ Total" "Avoidable \\ Overtreatment" "Avoidable \\ Incorrect")

  outwrite result using "${git}/outputs/tab2-costs.xlsx" , replace ///
  rownames("Birbhum" "N" "China" "N" "Delhi" "N" "Kenya" "N" "Kenya Public" "N" "MP" "N" "MP Public" "N" "Mumbai" "N" "Patna" "N") ///
    colnames("Cost" "Consult" "Medicine" "Avoidable" "Avoidable \\ Total" "Avoidable \\ Overtreatment" "Avoidable \\ Incorrect")

// Table 4

  use "${git}/constructed/sp-summary.dta" if private == 1, clear

  drop if fee_total_usd == 0 & treat_refer == 1

  local varlist time checklist treat_correct med_n treat_refer prov_waiting_in

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

    local cols `" `cols' "`study' \\ Binary" "`study' \\ Multiple" "'

    cap mat drop bresult
    cap mat drop bresult_STARS

    qui foreach var in `varlist' {
      local pn 0
      reg fee_total_usd `var ' i.case_code i.spid if study == "`study'", vce(cluster facilitycode)
        local b = _b[`var']
        local se = _se[`var']

        local p = r(table)[4,1]
        if `p' < 0.1 local pn 1
        if `p' < 0.05 local pn 2
        if `p' < 0.01 local pn 3

      mat bresult = nullmat(bresult) \ [`b'] \ [`se']
      mat bresult_STARS = nullmat(bresult_STARS) \ [`pn'] \ [0]
    }

    qui reg fee_total_usd `varlist' ///
        i.case_code i.spid if study == "`study'", vce(cluster facilitycode)

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
      mat mresult = mresult \ [`r'] \ [`n'] \ [`m'] \ [`s']
      mat bresult_STARS = bresult_STARS \ [0] \ [0] \ [0] \ [0]
      mat mresult_STARS = mresult_STARS \ [0] \ [0] \ [0] \ [0]


    mat result = nullmat(result) , bresult , mresult
    mat result_STARS = nullmat(result_STARS) , bresult_STARS , mresult_STARS

  }

  outwrite result using "${git}/outputs/tab4-fees-sp.tex" ///
    , replace format(%9.3f) colnames(`cols') ///
      rownames(`rows' "R-Square" "Observations" "Fees Mean (USD)" "Fees SD (USD)")

  outwrite result using "${git}/outputs/tab4-fees-sp.xlsx" ///
    , replace format(%9.3f) colnames(`cols') ///
      rownames(`rows' "R-Square" "Observations" "Fees Mean (USD)" "Fees SD (USD)")

// Table 5

use "${git}/constructed/pope-summary.dta" , clear

  local varlist po_time po_checklist treat_correct po_meds po_refer po_adl po_assets

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

    local cols `" `cols' "`study' \\ Binary" "`study' \\ Multiple" "'

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
      mat mresult = mresult \ [`r'] \ [`n'] \ [`m'] \ [`s']
      mat bresult_STARS = bresult_STARS \ [0] \ [0] \ [0] \ [0]
      mat mresult_STARS = mresult_STARS \ [0] \ [0] \ [0] \ [0]


    mat result = nullmat(result) , bresult , mresult
    mat result_STARS = nullmat(result_STARS) , bresult_STARS , mresult_STARS

  }

  foreach study in `levels' {

    local cols `" `cols' "`study' (FE) \\ Binary" "`study' (FE) \\ Multiple" "'

    cap mat drop bresult
    cap mat drop bresult_STARS

    qui foreach var in `varlist' {
      local pn 0
      reg fee_total_usd `var ' if study == "`study'", a(facilitycode) vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
        local b = _b[`var']
        if `b' == 0 local b .
        local se = _se[`var']
        if `se' == 0 local se .

        local p = r(table)[4,1]
        if `p' < 0.1 local pn 1
        if `p' < 0.05 local pn 2
        if `p' < 0.01 local pn 3

      mat bresult = nullmat(bresult) \ [`b'] \ [`se']
      mat bresult_STARS = nullmat(bresult_STARS) \ [`pn'] \ [0]
    }

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

      local r = e(r2_a)
      local n = e(N)

      su fee_total_usd if study == "`study'"

      local m = r(mean)
      local s= r(sd)

      mat bresult = bresult \ [.] \ [.] \ [.] \ [.]
      mat mresult = mresult \ [`r'] \ [`n'] \ [`m'] \ [`s']
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

// End
