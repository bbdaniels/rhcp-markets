// vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))

// Table 6: RCT
use "${git}/constructed/sp-birbhum.dta" , clear
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3) nogen
keep if case_code < 4

  cap mat drop results
  cap mat drop results_STARS

    egen tag = tag(facilitycode study)
    replace irt2 = . if tag == 0
    replace irt = . if tag == 0

  qui foreach var in irt2 checklist2  vignette2 irt checklist treat_correct time  {

      reg `var' treatment i.case_code i.block, vce(robust)
        local b1 = _b[treatment]
        local se1 = _se[treatment]
        local r1 = e(r2_a)
        local n1 = e(N)

        local p = r(table)[4,1]
        local p1 0
        if `p' < 0.1 local p1 1
        if `p' < 0.05 local p1 2
        if `p' < 0.01 local p1 3

      ivregress 2sls `var' (attendance = treatment) i.case_code i.block, vce(robust)
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

      mat result = [`b1'] \ [`se1'] \ [`r1'] \ [`b2'] \ [`se2'] \ [`r2'] \ [`n1'] \ [`mc']
      mat result_STARS = [`p1'] \ [0] \ [0] \ [`p2'] \ [0] \ [0] \ [0] \ [0]

      mat results = nullmat(results) , result
      mat results_STARS = nullmat(results_STARS) , result_STARS

  }

  outwrite results using "${git}/outputs/tab6-birbhum-rct.xlsx" ///
  , replace format(%9.3f) colnames("Vignette \\ IRT" "Vignette \\ Checklist" "Vignette \\ Correct" "SP \\ IRT" "SP \\ Checklist" "SP \\ Correct" "SP \\ Time (min)" ) ///
    rownames("Treated (ITT)" "SE" "R-Square" "Attendance (LATE)" "SE" "R-Square" "N" "Control Mean")

  outwrite results using "${git}/outputs/tab6-birbhum-rct.tex" ///
  , replace format(%9.3f) colnames("Vignette \\ IRT" "Vignette \\ Checklist" "Vignette \\ Correct" "SP \\ IRT" "SP \\ Checklist" "SP \\ Correct" "SP \\ Time (min)" ) ///
    rownames("Treated (ITT)" "SE" "R-Square" "Attendance (LATE)" "SE" "R-Square" "N" "Control Mean")


// Table 7: RCT --> knowledge
use "${git}/constructed/sp-birbhum.dta" , clear
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)

  drop if case_code > 3
  bys facilitycode: egen htype = min(vignette1)
  gen inter = htype * treatment

  lab var htype "H-Type"
  lab var inter   "H-Type x Treatment"

  egen tag = tag(facilitycode study)
  replace irt2 = . if tag == 0

  qui {

    // Checklist
    reg checklist2 treatment i.case_code i.block prov_age prov_male ///
        if htype == 1 , vce(cluster facilitycode)
        est sto check1

        su checklist2 if treatment == 1 & e(sample) == 1
          estadd scalar tm = `r(mean)' : check1
        su checklist2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : check1

    reg checklist2 treatment i.case_code i.block prov_age prov_male ///
        if htype == 0 , vce(cluster facilitycode)
        est sto check2

        su checklist2 if treatment == 1 & e(sample) == 1
          estadd scalar tm = `r(mean)' : check2
        su checklist2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : check2

    reg checklist2 treatment inter htype i.case_code i.block prov_age prov_male ///
        , vce(cluster facilitycode)
        est sto check3

        su checklist2 if treatment == 1 & e(sample) == 1
          estadd scalar tm = `r(mean)' : check3
        su checklist2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : check3

    // Correct
    reg vignette2 treatment i.case_code i.block prov_age prov_male ///
        if htype == 1 , vce(cluster facilitycode)
        est sto vig1

        su vignette2 if treatment == 1 & e(sample) == 1
          estadd scalar tm = `r(mean)' : vig1
        su vignette2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : vig1

    reg vignette2 treatment i.case_code i.block prov_age prov_male ///
        if htype == 0 , vce(cluster facilitycode)
        est sto vig2

        su vignette2 if treatment == 1 & e(sample) == 1
          estadd scalar tm = `r(mean)' : vig2
        su vignette2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : vig2

    reg vignette2 treatment inter htype i.case_code i.block prov_age prov_male ///
        , vce(cluster facilitycode)
        est sto vig3

        su vignette2 if treatment == 1 & e(sample) == 1
          estadd scalar tm = `r(mean)' : vig3
        su vignette2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : vig3

    // IRT
    reg irt2 treatment i.block prov_age prov_male ///
        if htype == 1 , vce(cluster facilitycode)
        est sto irt1

        su irt2 if treatment == 1 & e(sample) == 1
          estadd scalar tm = `r(mean)' : irt1
        su irt2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : irt1

    reg irt2 treatment i.block prov_age prov_male ///
        if htype == 0 , vce(cluster facilitycode)
        est sto irt2

        su irt2 if treatment == 1 & e(sample) == 1
          estadd scalar tm = `r(mean)' : irt2
        su irt2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : irt2

    reg irt2 treatment inter htype i.block prov_age prov_male ///
        , vce(cluster facilitycode)
        est sto irt3

        su irt2 if treatment == 1 & e(sample) == 1
          estadd scalar tm = `r(mean)' : irt3
        su irt2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : irt3
  }

  outwrite irt1 irt2 irt3 check1 check2 check3 vig1 vig2 vig3 ///
  using "${git}/outputs/tab7-birbhum-rct.xlsx" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male ) stats(N r2 cm) ///
    row("Assigned Treatment" "" "Treated H-Type" "" "H-Type" "" ///
        "Constant" "" "Observations" "R-Square" "Control Mean" ) ///
    col("IRT H" "IRT L" "IRT" "Checklist H" "Checklist L" "Checklist" "Correct H" "Correct L" "Correct" )

  outwrite irt1 irt2 irt3 check1 check2 check3 vig1 vig2 vig3 ///
  using "${git}/outputs/tab7-birbhum-rct.tex" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male ) stats(N r2 tm cm) ///
    row("Assigned Treatment" "" "Treated H-Type" "" "H-Type" "" ///
        "Constant" "" "Observations" "R-Square" "Control Mean" ) ///
    col("IRT H" "IRT L" "IRT" "Checklist H" "Checklist L" "Checklist" "Correct H" "Correct L" "Correct" )


// Table 8
use "${git}/constructed/sp-birbhum.dta" , clear
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)
  drop if case_code > 3
  bys facilitycode: egen htype = min(vignette1)

  gen inter = htype * treatment

  lab var htype "H-Type"
  lab var inter   "H-Type x Treatment"

  egen tag = tag(facilitycode study)

  reg attendance inter  prov_age prov_male i.block if tag == 1 & treatment == 1, vce(robust)
    est sto reg01

  reg irt treatment prov_age prov_male i.block if htype == 1 & case_code == 1, vce(robust)
    est sto reg1
  reg irt treatment prov_age prov_male i.block if htype == 0 & case_code == 1, vce(robust)
    est sto reg2
  reg irt inter treatment htype  prov_age prov_male i.block if case_code == 1, vce(robust)
    est sto reg3

  reg checklist treatment prov_age prov_male i.case_code i.block if htype == 1 , vce(cluster facilitycode)
    est sto reg4
  reg checklist treatment prov_age prov_male i.case_code i.block if htype == 0 , vce(cluster facilitycode)
    est sto reg5
  reg checklist inter treatment htype  prov_age prov_male i.case_code i.block , vce(cluster facilitycode)
    est sto reg6

  reg treat_correct treatment prov_age prov_male i.case_code i.block if htype == 1 , vce(cluster facilitycode)
    est sto reg7
  reg treat_correct treatment prov_age prov_male i.case_code i.block if htype == 0 , vce(cluster facilitycode)
    est sto reg8
  reg treat_correct inter treatment htype  prov_age prov_male i.case_code i.block , vce(cluster facilitycode)
    est sto reg9

  reg cost_total_usd treatment prov_age prov_male i.case_code i.block if htype == 1 , vce(cluster facilitycode)
    est sto reg10
  reg cost_total_usd treatment prov_age prov_male i.case_code i.block if htype == 0 , vce(cluster facilitycode)
    est sto reg11
  reg cost_total_usd inter treatment htype  prov_age prov_male i.case_code i.block , vce(cluster facilitycode)
    est sto reg12

  outwrite reg01 reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 reg12  ///
    using "${git}/outputs/tab8-birbhum-rct.xlsx" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male) stats(N r2) ///
    row("Treated H-Type" ""  "Assigned Treatment" "" "H-Type" "" ///
        "Constant" "" "Observations" "R-Square") ///
    col("Attendance" "IRT H" "IRT L" "IRT" "Checklist H" "Checklist L" "Checklist" ///
        "Correct H" "Correct L" "Correct" "Price H" "Price L" "Price")

  outwrite reg01 reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 reg12  ///
    using "${git}/outputs/tab8-birbhum-rct.tex" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male) stats(N r2) ///
    row("Treated H-Type" ""  "Assigned Treatment" "" "H-Type" "" ///
        "Constant" "" "Observations" "R-Square") ///
    col("Attendance" "IRT H" "IRT L" "IRT" "Checklist H" "Checklist L" "Checklist" ///
        "Correct H" "Correct L" "Correct" "Price H" "Price L" "Price")
// End
