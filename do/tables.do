// Table 1

  use "${git}/constructed/sp-summary.dta" , clear

  collect: table study, ///
    statistic(mean  treat_any1 treat_correct1 treat_over1 treat_under1 ///
                    med_anti_nodys med_steroid_noast treat_refer) ///
    statistic(freq) nformat(%9.0f freq) nformat(%9.3f mean)

  collect export "${git}/outputs/tab1-summary.tex", replace tableonly
  collect export "${git}/outputs/tab1-summary.pdf", replace

// Table 2

  use "${git}/constructed/sp-summary.dta" , clear

  collect: table study, ///
    statistic(mean  cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd ///
                    frac_avoid frac_avoid1 frac_avoid2) ///
    statistic(freq) nformat(%9.0f freq) nformat(%9.3f mean)

  collect export "${git}/outputs/tab2-costs.tex", replace tableonly
  collect export "${git}/outputs/tab2-costs.pdf", replace

// Table 4

  use "${git}/constructed/sp-summary.dta" if private == 1, clear

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
      reg fee_total_usd `var ' i.case_code i.spid if study == "`study'", cl(facilitycode) r
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
        i.case_code i.spid if study == "`study'", cl(facilitycode) r

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



// End
