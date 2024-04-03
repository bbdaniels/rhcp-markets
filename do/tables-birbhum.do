// Figure X: Visual IV
use "${git}/constructed/sp-birbhum.dta" , clear
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta"

  // ITT Increase in Knowledge
  reg checklist2 checklist1 prov_age prov_male i.case_code i.block if treatment == 0, cl(facilitycode)
    predict main
  reg checklist2 checklist1 prov_age prov_male i.case_code i.block if treatment == 1, cl(facilitycode)
    predict t

    gen marg_know = t - main
      drop t main

  // ITT Increase in Practice
  reg checklist checklist2 prov_age prov_male i.case_code i.block if treatment == 0, cl(facilitycode)
    predict main
  reg checklist checklist2 prov_age prov_male i.case_code i.block if treatment == 1, cl(facilitycode)
    predict t

    gen marg_do = t - main
      drop t main

  // 2SLS Treatment -> Knowledge -> Practice
  ivregress 2sls checklist (checklist2=treatment  )  ///
                 prov_age prov_male i.case_code i.block , cl(facilitycode)
  local 2sls = _b[checklist2]

  su marg_know
    local min = r(min)
    local max = r(max)

  keep if treatment == 1

  tw ///
     (lfitci marg_do marg_know , estopts(cl(facilitycode)) lw(none) alw(none) fc(black%50)) ///
     (scatter marg_do marg_know , mc(black) m(X) mlw(thin)) ///
     (function `2sls'*x , range(`min' `max') lc(red)) ///
  , xtit("Marginal Increase in Endline Vignette Checklist") ///
    ytit("Marginal Increase in Endline SP Checklist") ///
    legend(on pos(12) r(1) ring(1) size(vsmall) symxsize(medium) region(lw(none)) ///
      order(3 "ITT Increase In Treatment Group"  1 "Best Fit ITT CI" 4 "2SLS Second Stage")) ///
      xline(0 , lc(black) lw(thin)) yline(0 , lc(black) lw(thin)) ///
    xlab(-0.02 "-2%" 0 "Zero" 0.02 "+2%" 0.04 "+4%" 0.06 "+6%") ///
    ylab(-0.05 "-5%" 0 "Zero" 0.05 "+5%" 0.10 "+10%" 0.15 "+15%")

    graph export "${git}/outputs/figX-birbhum-viv-checklist.png" , replace


// Figure X2: Visual IV (IRT)
use "${git}/constructed/sp-birbhum.dta" , clear
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)

  duplicates drop facilitycode, force

  // ITT Increase in Knowledge
  reg irt2 irt1 prov_age prov_male i.block if treatment == 0, cl(facilitycode)
    predict main
  reg irt2 irt1 prov_age prov_male i.block if treatment == 1, cl(facilitycode)
    predict t

    gen marg_know = t - main
      drop t main

  // ITT Increase in Practice
  reg irt irt2 prov_age prov_male i.block if treatment == 0, cl(facilitycode)
    predict main
  reg irt irt2 prov_age prov_male i.block if treatment == 1, cl(facilitycode)
    predict t

    gen marg_do = t - main
      drop t main

  // 2SLS Treatment -> Knowledge -> Practice
  ivregress 2sls irt (irt2=treatment  )  ///
                 prov_age prov_male i.case_code i.block , cl(facilitycode)
  local 2sls = _b[irt2]

  su marg_know
    local min = r(min)
    local max = r(max)

  keep if treatment == 1

  tw ///
     (lfitci marg_do marg_know , estopts(cl(facilitycode)) lw(none) alw(none) fc(black%50)) ///
     (scatter marg_do marg_know , mc(black) m(X) mlw(thin)) ///
     (function `2sls'*x , range(`min' `max') lc(red)) ///
  , xtit("Marginal Increase in Endline Vignettes (IRT)") ///
    ytit("Marginal Increase in Endline SPs (IRT)") ///
    legend(on pos(12) r(1) ring(1) size(vsmall) symxsize(medium) region(lw(none)) ///
      order(3 "ITT Increase In Treatment Group"  1 "Best Fit ITT CI" 4 "2SLS Second Stage")) ///
      xline(0 , lc(black) lw(thin)) yline(0 , lc(black) lw(thin))

  graph export "${git}/outputs/figX-birbhum-viv-irt.png" , replace


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

  qui {
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
  }

  su checklist2 if treatment == 1
    local ct = `r(mean)'
  su checklist2 if treatment == 0
    local cc = `r(mean)'
  su vignette2 if treatment == 1
    local vt = `r(mean)'
  su vignette2 if treatment == 0
    local vc = `r(mean)'

  estadd scalar ct = `ct' : itt1 itt2 lat1 lat2
  estadd scalar cc = `cc' : itt1 itt2 lat1 lat2
  estadd scalar ct = `vt' : itt3 itt4 lat3 lat4
  estadd scalar cc = `vc' : itt3 itt4 lat3 lat4

  outwrite itt1 lat1 itt2 lat2 itt3 lat3 itt4 lat4 using "${git}/outputs/tab7-birbhum-rct.xlsx" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male ) stats(N r2 cc ct) ///
    row("Assigned Treatment" "" "Treatment Attendance" "" "Baseline Ability" "" "Ability x Treatment" "" ///
        "Constant" "" "Observations" "R-Square" "Control Mean" "Treatment Mean") ///
    col("Checklist" "Checklist" "Checklist" "Checklist" "Correct" "Correct" "Correct" "Correct")

  outwrite itt1 lat1 itt2 lat2 itt3 lat3 itt4 lat4 using "${git}/outputs/tab7-birbhum-rct.tex" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male ) stats(N r2 cc ct) ///
    row("Assigned Treatment" "" "Treatment Attendance" "" "Baseline Ability" "" "Ability x Treatment" "" ///
        "Constant" "" "Observations" "R-Square" "Control Mean" "Treatment Mean") ///
    col("Checklist" "Checklist" "Checklist" "Checklist" "Correct" "Correct" "Correct" "Correct")

// Table 8
use "${git}/constructed/sp-birbhum.dta" , clear

  gen ability = checklist1
  gen inter   = checklist1 * treatment
  lab var ability "Knowledge"
  lab var inter   "Knowledge x Treatment"

  reg checklist ability i.case_code i.block if treatment == 0, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto reg1
  reg checklist ability i.case_code i.block if treatment == 1, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto reg2
  reg checklist ability i.case_code i.block treatment inter, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto reg3

  replace ability = vignette1
  replace inter   = vignette1 * treatment

  reg treat_correct ability i.case_code i.block if treatment == 0, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto reg4
  reg treat_correct ability i.case_code i.block if treatment == 1, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto reg5
  reg treat_correct ability i.case_code i.block treatment inter, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto reg6

  replace ability = checklist2
  replace inter   = checklist2 * treatment

  reg checklist ability i.case_code i.block if treatment == 0, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto reg7
  reg checklist ability i.case_code i.block if treatment == 1, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto reg8
  reg checklist ability i.case_code i.block treatment inter, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
    est sto reg9

  outwrite reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9  using "${git}/outputs/tab8-birbhum-rct.xlsx" ///
  , replace format(%9.3f) drop(i.case_code i.block ) stats(N r2) ///
    row("Knowledge" "" "Treatment" "" "Knowledge x Treatment" "" ///
        "Constant" "" "Observations" "R-Square") ///
    col("Checklist Control" "Checklist Treatment" "Checklist" "Correct Control" "Correct Treatment" "Correct" "Checklist Control" "Checklist Treatment" "Checklist" )

  outwrite reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9  using "${git}/outputs/tab8-birbhum-rct.tex" ///
  , replace format(%9.3f) drop(i.case_code i.block ) stats(N r2) ///
    row("Knowledge" "" "Treatment" "" "Knowledge x Treatment" "" ///
        "Constant" "" "Observations" "R-Square") ///
    col("Checklist Control" "Checklist Treatment" "Checklist" "Correct Control" "Correct Treatment" "Correct" "Checklist Control" "Checklist Treatment" "Checklist" )

// End
