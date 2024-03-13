// Table 6: RCT

  use "${git}/constructed/sp-birbhum.dta" , clear

  cap mat drop results
  cap mat drop results_STARS

  qui foreach var in checklist treat_correct time fee_total_usd {

      reg `var' treatment i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
        local b1 = _b[treatment]
        local se1 = _se[treatment]
        local r1 = e(r2_a)
        local n1 = e(N)

        local p = r(table)[4,1]
        local p1 0
        if `p' < 0.1 local p1 1
        if `p' < 0.05 local p1 2
        if `p' < 0.01 local p1 3

      ivregress 2sls `var' (attendance = treatment) i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
        local b2= _b[attendance]
        local se2 = _se[attendance]
        local r2 = e(r2_a)
        local n2 = e(N)

        local p = r(table)[4,1]
        local p2 0
        if `p' < 0.1 local p2 1
        if `p' < 0.05 local p2 2
        if `p' < 0.01 local p2 3

      su `var' if treatment == 1
        local mt = r(mean)
      su `var' if treatment == 0
        local mc = r(mean)

      mat result = [`b1'] \ [`se1'] \ [`r1'] \ [`b2'] \ [`se2'] \ [`r2'] \ [`n1'] \ [`mc'] \ [`mt']
      mat result_STARS = [`p1'] \ [0] \ [0] \ [`p2'] \ [0] \ [0] \ [0] \ [0] \ [0]

      mat results = nullmat(results) , result
      mat results_STARS = nullmat(results_STARS) , result_STARS

  }

  outwrite results using "${git}/outputs/tab6-birbhum-rct.xlsx" ///
    , replace format(%9.3f) colnames("Checklist" "Correct" "Time (min)" "Cost (USD)") ///
      rownames("Treated (ITT)" "SE" "R-Square" "Attendance (LATE)" "SE" "R-Square" "N" "Control Mean" "Treatment Mean")

  outwrite results using "${git}/outputs/tab6-birbhum-rct.tex" ///
    , replace format(%9.3f) colnames("Checklist" "Correct" "Time (min)" "Cost (USD)") ///
      rownames("Treated (ITT)" "SE" "R-Square" "Attendance (LATE)" "SE" "R-Square" "N" "Control Mean" "Treatment Mean")


// Table 7: RCT --> knowledge
use "${git}/constructed/sp-birbhum.dta" , clear

  gen ability = checklist1
  gen inter1i = .
  gen inter1 = treatment*checklist1

  lab var treatment "Assigned Treatment"
  lab var attendance "Treatment Attendance"
  lab var ability "Baseline Ability"
  lab var inter1 "Ability x Treatment"
  lab var inter1i "Ability x Treatment"

  su checklist2 if treatment == 1
    local ct = `r(mean)'
  su checklist2 if treatment == 0
    local cc = `r(mean)'
  su vignette2 if treatment == 1
    local vt = `r(mean)'
  su vignette2 if treatment == 0
    local vc = `r(mean)'

  reg checklist2 treatment i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto itt1

  reg checklist2 treatment ability inter1 prov_age prov_male i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto itt2

  replace inter1 = treatment*vignette1

  replace ability = vignette1

  reg vignette2 treatment i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto itt3
  reg vignette2 treatment ability inter1 prov_age prov_male i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto itt4

  replace inter1i = treatment*checklist1
  replace inter1 = attendance*checklist1

  replace ability = checklist1

  ivregress 2sls checklist2 (attendance = treatment) i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto lat1
  ivregress 2sls checklist2 (attendance inter1 = treatment inter1i) ability prov_age prov_male i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto lat2

  replace inter1i = treatment*vignette1
  replace inter1 = attendance*vignette1

  replace ability = vignette1


  ivregress 2sls vignette2 (attendance = treatment) i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto lat3
  ivregress 2sls vignette2 (attendance inter1 = treatment inter1i) ability prov_age prov_male i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto lat4

    estadd scalar ct = `ct' : itt1 itt2 lat1 lat2
    estadd scalar cc = `cc' : itt1 itt2 lat1 lat2
    estadd scalar ct = `vt' : itt3 itt4 lat3 lat4
    estadd scalar cc = `vc' : itt3 itt4 lat3 lat4

    outwrite itt1 lat1 itt2 lat2 itt3 lat3 itt4 lat4 using "${git}/outputs/tab6-birbhum-rct.xlsx" ///
      , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male ) stats(N r2 cc ct) ///
        row("Assigned Treatment" "" "Treatment Attendance" "" "Baseline Ability" "" "Ability x Treatment" "" ///
            "Constant" "" "Observations" "R-Square" "Control Mean" "Treatment Mean") ///
        col("Checklist" "Checklist" "Checklist" "Checklist" "Correct" "Correct" "Correct" "Correct")

// End
