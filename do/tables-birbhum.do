// vce(bootstrap, strata(treatment) cluster(facilitycode) reps(100))

// Table 6: RCT
use "${git}/constructed/sp-birbhum.dta" , clear
  merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3) nogen
  keep if case_code < 4

  egen tag = tag(facilitycode study)
  replace irt2 = . if tag == 0
  replace irt = . if tag == 0

  local ols ""
  local ivs ""
  qui foreach var in irt checklist treat_correct time cost_total_usd irt2 checklist2 vignette2 {

    local ols = "`ols' `var'_ols"
    local ivs = "`ivs' `var'_ivs"

      reg `var' treatment i.case_code i.block prov_age prov_male, cl(facilitycode)
        est sto `var'_ols

      ivregress 2sls `var' (attendance = treatment) i.case_code i.block prov_age prov_male, cl(facilitycode)
        est sto `var'_ivs

      estat firststage
        local f = r(singleresults)[1,4]
        estadd scalar f = `f' : `var'_ivs

      su `var' if e(sample) == 1 & treatment == 0
        estadd scalar cm = `r(mean)' : `var'_ivs

  }


  outwrite `ols' using "${git}/outputs/tab6-birbhum-rct-1.tex" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male) stats(N r2) ///
    colnames("Endline SP IRT"  "Endline SP Checklist" "Endline SP Correct" "Endline SP Time (min)" "Endline SP Price (USD)" ///
            "Endline Vignette IRT" "Endline Vignette Checklist" "Endline Vignette Correct") ///
    rownames("Assigned Treatment" "" "Constant" "" "Observations" "Regression R2" )

  outwrite `ivs' using "${git}/outputs/tab6-birbhum-rct-2.tex" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male) stats(f cm N r2) ///
    colnames("Endline SP IRT"  "Endline SP Checklist" "Endline SP Correct" "Endline SP Time (min)" "Endline SP Price (USD)" ///
            "Endline Vignette IRT" "Endline Vignette Checklist" "Endline Vignette Correct") ///
    rownames("Attendance (LATE)" "" "Constant" "" "IV F-Statistic" "Control Mean" "Observations" "Regression R2" )


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

        su checklist2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : check1

    reg checklist2 treatment i.case_code i.block prov_age prov_male ///
        if htype == 0 , vce(cluster facilitycode)
        est sto check2

        su checklist2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : check2

    reg checklist2 treatment inter htype i.case_code i.block prov_age prov_male ///
        , vce(cluster facilitycode)
        est sto check3

        su checklist2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : check3

    // Correct
    reg vignette2 treatment i.case_code i.block prov_age prov_male ///
        if htype == 1 , vce(cluster facilitycode)
        est sto vig1

        su vignette2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : vig1

    reg vignette2 treatment i.case_code i.block prov_age prov_male ///
        if htype == 0 , vce(cluster facilitycode)
        est sto vig2

        su vignette2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : vig2

    reg vignette2 treatment inter htype i.case_code i.block prov_age prov_male ///
        , vce(cluster facilitycode)
        est sto vig3

        su vignette2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : vig3

    // IRT
    reg irt2 treatment i.block prov_age prov_male ///
        if htype == 1 , vce(robust)
        est sto irt1

        su irt2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : irt1

    reg irt2 treatment i.block prov_age prov_male ///
        if htype == 0 , vce(robust)
        est sto irt2

        su irt2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : irt2

    reg irt2 treatment inter htype i.block prov_age prov_male ///
        , vce(robust)
        est sto irt3

        su irt2 if treatment == 0 & e(sample) == 1
          estadd scalar cm = `r(mean)' : irt3
  }

  outwrite irt1 irt2 irt3 check1 check2 check3 vig1 vig2 vig3 ///
  using "${git}/outputs/tab7-birbhum-rct-1.xlsx" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male ) stats(cm N r2) ///
    row("Assigned Treatment" "" "H-Type x Treatment" "" "H-Type" "" ///
        "Constant" ""  "Control Mean" "Observations" "Regression R2" ) ///
    col("IRT H" "IRT L" "IRT" "Checklist H" "Checklist L" "Checklist" "Correct H" "Correct L" "Correct" )

  outwrite irt1 irt2 irt3 check1 check2 check3 vig1 vig2 vig3 ///
  using "${git}/outputs/tab7-birbhum-rct-1.tex" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male ) stats(cm N r2) ///
    row("Assigned Treatment" "" "H-Type x Treatment" "" "H-Type" "" ///
        "Constant" "" "Control Mean" "Observations" "Regression R2" ) ///
    col("IRT H" "IRT L" "IRT" "Checklist H" "Checklist L" "Checklist" "Correct H" "Correct L" "Correct" )

  // 2SLS
  use "${git}/constructed/sp-birbhum.dta" , clear
  merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)

    drop if case_code > 3
    bys facilitycode: egen htype = min(vignette1)
    gen inter = htype * treatment
    gen i = htype * attendance

    lab var htype "H-Type"
    lab var inter   "H-Type x Treatment"

    egen tag = tag(facilitycode study)
    replace irt2 = . if tag == 0

    qui {

      // Checklist
      ivregress 2sls checklist2 (attendance = treatment) i.case_code i.block prov_age prov_male ///
          if htype == 1 , vce(cluster facilitycode)
          est sto check1

          su checklist2 if treatment == 0 & e(sample) == 1
            estadd scalar cm = `r(mean)' : check1

          estat firststage
            local f = r(singleresults)[1,4]
            estadd scalar f = `f' : check1

      ivregress 2sls checklist2 (attendance = treatment) i.case_code i.block prov_age prov_male ///
          if htype == 0 , vce(cluster facilitycode)
          est sto check2

          su checklist2 if treatment == 0 & e(sample) == 1
            estadd scalar cm = `r(mean)' : check2

            estat firststage
              local f = r(singleresults)[1,4]
              estadd scalar f = `f' : check2

      ivregress 2sls checklist2 (attendance i = treatment inter)  htype i.case_code i.block prov_age prov_male ///
          , vce(cluster facilitycode)
          est sto check3

          su checklist2 if treatment == 0 & e(sample) == 1
            estadd scalar cm = `r(mean)' : check3

      // Correct
      ivregress 2sls vignette2 (attendance = treatment) i.case_code i.block prov_age prov_male ///
          if htype == 1 , vce(cluster facilitycode)
          est sto vig1

          su vignette2 if treatment == 0 & e(sample) == 1
            estadd scalar cm = `r(mean)' : vig1

            estat firststage
              local f = r(singleresults)[1,4]
              estadd scalar f = `f' : vig1

      ivregress 2sls vignette2 (attendance = treatment) i.case_code i.block prov_age prov_male ///
          if htype == 0 , vce(cluster facilitycode)
          est sto vig2

          su vignette2 if treatment == 0 & e(sample) == 1
            estadd scalar cm = `r(mean)' : vig2

            estat firststage
              local f = r(singleresults)[1,4]
              estadd scalar f = `f' : vig2

      ivregress 2sls vignette2 (attendance i = treatment inter) htype i.case_code i.block prov_age prov_male ///
          , vce(cluster facilitycode)
          est sto vig3

          su vignette2 if treatment == 0 & e(sample) == 1
            estadd scalar cm = `r(mean)' : vig3

      // IRT
      ivregress 2sls irt2 (attendance = treatment) i.block prov_age prov_male ///
          if htype == 1 , vce(robust)
          est sto irt1

          su irt2 if treatment == 0 & e(sample) == 1
            estadd scalar cm = `r(mean)' : irt1

            estat firststage
              local f = r(singleresults)[1,4]
              estadd scalar f = `f' : irt1

      ivregress 2sls irt2 (attendance = treatment) i.block prov_age prov_male ///
          if htype == 0 , vce(robust)
          est sto irt2

          su irt2 if treatment == 0 & e(sample) == 1
            estadd scalar cm = `r(mean)' : irt2

            estat firststage
              local f = r(singleresults)[1,4]
              estadd scalar f = `f' : irt2

      ivregress 2sls irt2 (attendance i = treatment inter)  htype i.block prov_age prov_male ///
          , vce(robust)
          est sto irt3

          su irt2 if treatment == 0 & e(sample) == 1
            estadd scalar cm = `r(mean)' : irt3
    }

    reg attendance htype prov_age prov_male i.block if tag == 1 & treatment == 1, vce(robust)
      estadd scalar ht = r(table)[1,1] : irt1 irt2 irt3 check1 check2 check3 vig1 vig2 vig3


    outwrite irt1 irt2 irt3 check1 check2 check3 vig1 vig2 vig3 ///
    using "${git}/outputs/tab7-birbhum-rct-2.xlsx" ///
    , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male ) stats(f ht cm N r2) ///
      row("Attendance (LATE)" "" "H-Type xAttendance" "" "H-Type" "" ///
          "Constant" "" "IV F-Statistic" "H-Type Attendance \$\beta\$" "Control Mean" "Observations" "Regression R2") ///
      col("IRT H" "IRT L" "IRT" "Checklist H" "Checklist L" "Checklist" "Correct H" "Correct L" "Correct" )

    outwrite irt1 irt2 irt3 check1 check2 check3 vig1 vig2 vig3 ///
    using "${git}/outputs/tab7-birbhum-rct-2.tex" ///
    , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male ) stats(f ht cm N r2) ///
      row("Attendance (LATE)" "" "H-Type x Attendance" "" "H-Type" "" ///
          "Constant" "" "IV F-Statistic" "H-Type Attendance \$\beta\$" "Control Mean"  "Observations" "Regression R2") ///
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

  reg irt treatment prov_age prov_male i.block if htype == 1 & case_code == 1, vce(robust)
    est sto reg1
    su irt if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg1
  reg irt treatment prov_age prov_male i.block if htype == 0 & case_code == 1, vce(robust)
    est sto reg2
    su irt if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg2
  reg irt inter treatment htype  prov_age prov_male i.block if case_code == 1, vce(robust)
    est sto reg3
    su irt if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg3

  reg checklist treatment prov_age prov_male i.case_code i.block if htype == 1 , vce(cluster facilitycode)
    est sto reg4
    su checklist if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg4
  reg checklist treatment prov_age prov_male i.case_code i.block if htype == 0 , vce(cluster facilitycode)
    est sto reg5
    su checklist if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg5
  reg checklist inter treatment htype  prov_age prov_male i.case_code i.block , vce(cluster facilitycode)
    est sto reg6
    su checklist if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg6

  reg treat_correct treatment prov_age prov_male i.case_code i.block if htype == 1 , vce(cluster facilitycode)
    est sto reg7
    su treat_correct if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg7
  reg treat_correct treatment prov_age prov_male i.case_code i.block if htype == 0 , vce(cluster facilitycode)
    est sto reg8
    su treat_correct if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg8
  reg treat_correct inter treatment htype  prov_age prov_male i.case_code i.block , vce(cluster facilitycode)
    est sto reg9
    su treat_correct if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg9

  reg cost_total_usd treatment prov_age prov_male i.case_code i.block if htype == 1 , vce(cluster facilitycode)
    est sto reg10
    su cost_total_usd if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg10
  reg cost_total_usd treatment prov_age prov_male i.case_code i.block if htype == 0 , vce(cluster facilitycode)
    est sto reg11
    su cost_total_usd if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg11
  reg cost_total_usd inter treatment htype  prov_age prov_male i.case_code i.block , vce(cluster facilitycode)
    est sto reg12
    su cost_total_usd if treatment == 0 & e(sample) == 1
      estadd scalar cm = `r(mean)' : reg12

  outwrite reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 reg12  ///
    using "${git}/outputs/tab8-birbhum-rct-1.xlsx" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male) stats(cm N r2) ///
    row("Assigned Treatment" "" "H-Type x Treatment" "" "H-Type" "" ///
        "Constant" "" "Control Mean" "Observations" "Regression R2") ///
    col("IRT H" "IRT L" "IRT" "Checklist H" "Checklist L" "Checklist" ///
        "Correct H" "Correct L" "Correct" "Price H" "Price L" "Price")

  outwrite reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 reg12  ///
    using "${git}/outputs/tab8-birbhum-rct-1.tex" ///
  , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male) stats(cm N r2) ///
    row("Assigned Treatment" "" "H-Type x Treatment" "" "H-Type" "" ///
        "Constant" "" "Control Mean" "Observations" "Regression R2") ///
    col("IRT H" "IRT L" "IRT" "Checklist H" "Checklist L" "Checklist" ///
        "Correct H" "Correct L" "Correct" "Price H" "Price L" "Price")

  // IV
  use "${git}/constructed/sp-birbhum.dta" , clear
  merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)
    drop if case_code > 3
    bys facilitycode: egen htype = min(vignette1)

    gen inter = htype * treatment
    gen i = htype * attendance

    lab var htype "H-Type"
    lab var inter   "H-Type x Treatment"

    egen tag = tag(facilitycode study)

    ivregress 2sls irt (attendance = treatment) prov_age prov_male i.block if htype == 1 & case_code == 1, vce(robust)
      est sto reg1
      su irt if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg1

        estat firststage
          local f = r(singleresults)[1,4]
          estadd scalar f = `f' : reg1
    ivregress 2sls irt (attendance = treatment) prov_age prov_male i.block if htype == 0 & case_code == 1, vce(robust)
      est sto reg2
      su irt if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg2

        estat firststage
          local f = r(singleresults)[1,4]
          estadd scalar f = `f' : reg2
    ivregress 2sls irt (attendance i = treatment inter) htype  prov_age prov_male i.block if case_code == 1, vce(robust)
      est sto reg3
      su irt if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg3

    ivregress 2sls checklist (attendance = treatment)  prov_age prov_male i.case_code i.block if htype == 1 , vce(cluster facilitycode)
      est sto reg4
      su checklist if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg4

        estat firststage
          local f = r(singleresults)[1,4]
          estadd scalar f = `f' : reg4
    ivregress 2sls checklist (attendance = treatment) prov_age prov_male i.case_code i.block if htype == 0 , vce(cluster facilitycode)
      est sto reg5
      su checklist if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg5

        estat firststage
          local f = r(singleresults)[1,4]
          estadd scalar f = `f' : reg5
    ivregress 2sls checklist (attendance i = treatment inter) htype  prov_age prov_male i.case_code i.block , vce(cluster facilitycode)
      est sto reg6
      su checklist if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg6

    ivregress 2sls treat_correct (attendance = treatment) prov_age prov_male i.case_code i.block if htype == 1 , vce(cluster facilitycode)
      est sto reg7
      su treat_correct if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg7

        estat firststage
          local f = r(singleresults)[1,4]
          estadd scalar f = `f' : reg7
    ivregress 2sls treat_correct (attendance = treatment) prov_age prov_male i.case_code i.block if htype == 0 , vce(cluster facilitycode)
      est sto reg8
      su treat_correct if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg8

        estat firststage
          local f = r(singleresults)[1,4]
          estadd scalar f = `f' : reg8
    ivregress 2sls treat_correct (attendance i = treatment inter) htype  prov_age prov_male i.case_code i.block , vce(cluster facilitycode)
      est sto reg9
      su treat_correct if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg9

    ivregress 2sls cost_total_usd (attendance = treatment) prov_age prov_male i.case_code i.block if htype == 1 , vce(cluster facilitycode)
      est sto reg10
      su cost_total_usd if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg10

        estat firststage
          local f = r(singleresults)[1,4]
          estadd scalar f = `f' : reg10
    ivregress 2sls cost_total_usd (attendance = treatment) prov_age prov_male i.case_code i.block if htype == 0 , vce(cluster facilitycode)
      est sto reg11
      su cost_total_usd if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg11

        estat firststage
          local f = r(singleresults)[1,4]
          estadd scalar f = `f' : reg11
    ivregress 2sls cost_total_usd (attendance i = treatment inter) htype  prov_age prov_male i.case_code i.block , vce(cluster facilitycode)
      est sto reg12
      su cost_total_usd if treatment == 0 & e(sample) == 1
        estadd scalar cm = `r(mean)' : reg12

    reg attendance htype prov_age prov_male i.block if tag == 1 & treatment == 1, vce(robust)
      estadd scalar ht = r(table)[1,1] : reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 reg12

    outwrite reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 reg12  ///
      using "${git}/outputs/tab8-birbhum-rct-2.xlsx" ///
    , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male) stats(f ht cm N r2) ///
      row("Assigned Treatment" "" "H-Type x Treatment" "" "H-Type" "" ///
          "Constant" "" "IV F-Statistic" "H-Type Attendance \$\beta\$" "Control Mean" "Observations" "Regression R2") ///
      col("IRT H" "IRT L" "IRT" "Checklist H" "Checklist L" "Checklist" ///
          "Correct H" "Correct L" "Correct" "Price H" "Price L" "Price")

    outwrite reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 reg10 reg11 reg12  ///
      using "${git}/outputs/tab8-birbhum-rct-2.tex" ///
    , replace format(%9.3f) drop(i.case_code i.block prov_age prov_male) stats(f ht cm N r2) ///
      row("Assigned Treatment" "" "H-Type x Treatment" "" "H-Type" "" ///
          "Constant" "" "IV F-Statistic" "H-Type Attendance \$\beta\$" "Control Mean" "Observations" "Regression R2") ///
      col("IRT H" "IRT L" "IRT" "Checklist H" "Checklist L" "Checklist" ///
          "Correct H" "Correct L" "Correct" "Price H" "Price L" "Price")

// End
