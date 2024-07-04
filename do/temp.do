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
