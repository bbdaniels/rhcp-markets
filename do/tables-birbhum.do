// Figure
use "${git}/constructed/sp-birbhum.dta" , clear
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)

xtile x = irt1, n(20)
collapse (mean) irt1 irt2 irt , by(x treatment)

gen gain = irt2 - irt1
xtset x treatment
gen second = D.gain
gen itt = D.irt
tw (lfitci itt second)(scatter itt second)(lfit irt irt2)
-


// Figure X: Visual IV
use "${git}/constructed/sp-birbhum.dta" , clear
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)

  // ITT Increase in Knowledge
  reg time checklist1 prov_age prov_male i.case_code i.block if treatment == 0, cl(facilitycode)
    predict main
  reg time checklist1 prov_age prov_male i.case_code i.block if treatment == 1, cl(facilitycode)
    predict t

    gen marg_know = t - main
      drop t main

  // ITT Increase in Practice
  reg fee_total_usd checklist1 prov_age prov_male i.case_code i.block if treatment == 0, cl(facilitycode)
    predict main
  reg fee_total_usd checklist1 prov_age prov_male i.case_code i.block if treatment == 1, cl(facilitycode)
    predict t

    gen marg_do = t - main
      drop t main

  // 2SLS Treatment -> Knowledge -> Practice
  ivregress 2sls fee_total_usd (time =treatment  )  ///
                 prov_age prov_male i.case_code i.block , cl(facilitycode)
  local 2sls = _b[time]

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
----
    graph export "${git}/outputs/figX-birbhum-viv-checklist.png" , replace


----



    // Figure X: Visual IV
use "${git}/constructed/sp-birbhum.dta" , clear
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)

  gen gain = checklist2-checklist1

  // ITT Increase in Knowledge
  reg gain checklist1 prov_age prov_male i.case_code i.block if treatment == 0, cl(facilitycode)
    predict main
  reg gain checklist1 prov_age prov_male i.case_code i.block if treatment == 1, cl(facilitycode)
    predict t

    gen marg_know = t - main
      drop t main

  // ITT Increase in Practice
  reg checklist checklist1 prov_age prov_male i.case_code i.block if treatment == 0, cl(facilitycode)
    predict main
  reg checklist checklist1 prov_age prov_male i.case_code i.block if treatment == 1, cl(facilitycode)
    predict t

    gen marg_do = t - main
      drop t main

  // 2SLS Treatment -> Knowledge -> Practice
  ivregress 2sls checklist (gain=treatment  )  ///
                 prov_age prov_male i.case_code i.block , cl(facilitycode)
  local 2sls = _b[gain]

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
  reg irt irt1 prov_age prov_male i.block if treatment == 0, cl(facilitycode)
    predict main
  reg irt irt1 prov_age prov_male i.block if treatment == 1, cl(facilitycode)
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
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)

  cap mat drop results
  cap mat drop results_STARS

    reg irt treatment i.case_code i.block if case_code == 1, vce(robust)
      local b1 = _b[treatment]
      local se1 = _se[treatment]
      local r1 = e(r2_a)
      local n1 = e(N)

      local p = r(table)[4,1]
      local p1 0
      if `p' < 0.1 local p1 1
      if `p' < 0.05 local p1 2
      if `p' < 0.01 local p1 3

    ivregress 2sls irt (attendance = treatment) i.case_code i.block if case_code == 1, vce(robust)
      local b2= _b[attendance]
      local se2 = _se[attendance]
      local r2 = e(r2_a)
      local n2 = e(N)

      local p = r(table)[4,1]
      local p2 0
      if `p' < 0.1 local p2 1
      if `p' < 0.05 local p2 2
      if `p' < 0.01 local p2 3

    su irt if treatment == 1
      local mt = r(mean)
    su irt if treatment == 0
      local mc = r(mean)

    mat result = [`b1'] \ [`se1'] \ [`r1'] \ [`b2'] \ [`se2'] \ [`r2'] \ [`n1'] \ [`mc'] \ [`mt']
    mat result_STARS = [`p1'] \ [0] \ [0] \ [`p2'] \ [0] \ [0] \ [0] \ [0] \ [0]

    mat results = nullmat(results) , result
    mat results_STARS = nullmat(results_STARS) , result_STARS

    gen logp = log(fee_total_usd)
    gen fee0 = fee_total_usd if fee_total_usd > 0 & !missing(fee_total_usd)

  qui foreach var in checklist treat_correct time fee_total_usd fee0 logp {

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
  , replace format(%9.3f) colnames("IRT" "Checklist" "Correct" "Time (min)" "Cost (USD)" "Cost (ex zeros)" "Log Cost") ///
    rownames("Treated (ITT)" "SE" "R-Square" "Attendance (LATE)" "SE" "R-Square" "N" "Control Mean" "Treatment Mean")

  outwrite results using "${git}/outputs/tab6-birbhum-rct.tex" ///
  , replace format(%9.3f) colnames("IRT" "Checklist" "Correct" "Time (min)" "Cost (USD)" "Cost (ex zeros)" "Log Cost") ///
    rownames("Treated (ITT)" "SE" "R-Square" "Attendance (LATE)" "SE" "R-Square" "N" "Control Mean" "Treatment Mean")


// Table 7: RCT --> knowledge
use "${git}/constructed/sp-birbhum.dta" , clear
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)

  gen ability = .
  gen inter1i = .
  gen inter1 = .

  lab var treatment "Assigned Treatment"
  lab var attendance "Treatment Attendance"
  lab var ability "Baseline Ability"
  lab var inter1 "Ability x Treatment"
  lab var inter1i "Ability x Treatment"

  qui {

    // Checklist
    replace ability = checklist1
    replace inter1 = treatment*checklist1

    reg checklist2 treatment i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
      est sto check1
    ivregress 2sls checklist2 (attendance = treatment) i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
      est sto check2
    reg checklist2 treatment ability inter1 prov_age prov_male i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
      est sto check3

    replace inter1i = treatment*checklist1
    replace inter1 = attendance*checklist1

    ivregress 2sls checklist2 (attendance inter1 = treatment inter1i) ability prov_age prov_male i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
      est sto check4


    // Correct
    replace ability = vignette1
    replace inter1 = treatment*vignette1

    reg vignette2 treatment i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
      est sto corr1
    ivregress 2sls vignette2 (attendance = treatment) i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
      est sto corr2
    reg vignette2 treatment ability inter1 prov_age prov_male i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
      est sto corr3

    replace inter1i = treatment*vignette1
    replace inter1 = attendance*vignette1

    ivregress 2sls vignette2 (attendance inter1 = treatment inter1i) ability prov_age prov_male i.case_code i.block, vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))
      est sto corr4


    // IRT
    replace ability = irt1
    replace inter1 = treatment*irt1

    reg irt2 treatment i.block if case_code == 1, vce(robust)
      est sto irt1
    ivregress 2sls irt2 (attendance = treatment) i.block if case_code == 1, vce(robust)
      est sto irt2
    reg irt2 treatment ability inter1 prov_age prov_male i.block if case_code == 1, vce(robust)
      est sto irt3

    replace inter1i = treatment*irt1
    replace inter1 = attendance*irt1

    ivregress 2sls irt2 (attendance inter1 = treatment inter1i) ability prov_age prov_male i.block if case_code == 1, vce(robust)
      est sto irt4
  }

  su checklist2 if treatment == 1
    local ct = `r(mean)'
  su checklist2 if treatment == 0
    local cc = `r(mean)'
  su vignette2 if treatment == 1
    local vt = `r(mean)'
  su vignette2 if treatment == 0
    local vc = `r(mean)'
  su irt2 if treatment == 1
    local it = `r(mean)'
  su irt2 if treatment == 0
    local ic = `r(mean)'

  estadd scalar ct = `ct' : check1 check2 check3 check4
  estadd scalar cc = `cc' : check1 check2 check3 check4
  estadd scalar ct = `vt' : corr1 corr2 corr3 corr4
  estadd scalar cc = `vc' : corr1 corr2 corr3 corr4
  estadd scalar ct = `it' : irt1 irt2 irt3 irt4
  estadd scalar cc = `ic' : irt1 irt2 irt3 irt4

  outwrite irt1 irt2 irt3 irt4 check1 check2 check3 check4 corr1 corr2 corr3 corr4 ///
  using "${git}/outputs/tab7-birbhum-rct.xlsx" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male ) stats(N r2 cc ct) ///
    row("Assigned Treatment" "" "Treatment Attendance" "" "Baseline Ability" "" "Ability x Treatment" "" ///
        "Constant" "" "Observations" "R-Square" "Control Mean" "Treatment Mean") ///
    col("IRT" " " " " " " "Checklist" " " " " " " "Correct" " " " " " ")

  outwrite irt1 irt2 irt3 irt4 check1 check2 check3 check4 corr1 corr2 corr3 corr4 ///
  using "${git}/outputs/tab7-birbhum-rct.tex" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male ) stats(N r2 cc ct) ///
    row("Assigned Treatment" "" "Treatment Attendance" "" "Baseline Ability" "" "Ability x Treatment" "" ///
        "Constant" "" "Observations" "R-Square" "Control Mean" "Treatment Mean") ///
    col("IRT" " " " " " " "Checklist" " " " " " " "Correct" " " " " " ")

// Table 8
use "${git}/constructed/sp-birbhum.dta" , clear
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)

  gen ability = .
  gen inter = .

  lab var ability "Knowledge"
  lab var inter   "Knowledge x Treatment"

  replace ability = irt1
  replace inter   = irt1 * treatment

  reg irt ability i.block if treatment == 0 & case_code == 1 , vce(robust)
    est sto reg01
  reg irt ability i.block if treatment == 1 & case_code == 1 , vce(robust)
    est sto reg02
  reg irt ability i.block treatment inter if case_code == 1 , vce(robust)
    est sto reg03

  replace ability = checklist1
  replace inter   = checklist1 * treatment

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

  outwrite reg01 reg02 reg03 reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9  using "${git}/outputs/tab8-birbhum-rct.xlsx" ///
  , replace format(%9.3f) drop(i.case_code i.block ) stats(N r2) ///
    row("Knowledge" "" "Treatment" "" "Knowledge x Treatment" "" ///
        "Constant" "" "Observations" "R-Square") ///
    col("IRT Control" "IRT Treatment" "IRT" "Checklist Control" "Checklist Treatment" "Checklist" "Correct Control" "Correct Treatment" "Correct" "Checklist Control" "Checklist Treatment" "Checklist" )

  outwrite reg01 reg02 reg03  reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9  using "${git}/outputs/tab8-birbhum-rct.tex" ///
  , replace format(%9.3f) drop(i.case_code i.block ) stats(N r2) ///
    row("Knowledge" "" "Treatment" "" "Knowledge x Treatment" "" ///
        "Constant" "" "Observations" "R-Square") ///
    col("IRT Control" "IRT Treatment" "IRT" "Checklist Control" "Checklist Treatment" "Checklist" "Correct Control" "Correct Treatment" "Correct" "Checklist Control" "Checklist Treatment" "Checklist" )

// End
