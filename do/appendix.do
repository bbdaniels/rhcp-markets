// Table A2

use "${git}/constructed/sp-summary.dta" , clear


  replace study = "MP Public" if study == "MP" & private == 0
  replace study = "Kenya Public" if study == "Kenya" & private == 0

  tabstat cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd ///
          frac_avoid frac_avoid1 frac_avoid2 ///
  , by(study) save stats(mean sem n)

  cap mat drop result
  forv i = 1/9 {
    mat a = r(Stat`i')
    mat result = nullmat(result) \ a
  }
  mat result_STARS = J(rowsof(result),colsof(result),0)

  outwrite result using "${git}/outputs/tab2-costs.tex" , replace ///
  rownames("Birbhum" "SE" "N" "China" "SE" "N" "Delhi" "SE" "N" "Kenya" "SE" "N" "Kenya Public" "SE" "N" "MP" "SE" "N" "MP Public" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N") ///
    colnames("Total Cost \\ (USD)" "Consult \\ (USD)" "Medicine \\ (USD)" "Avoidable \\ (USD)" "Avoidable \\ Total (\%)" "Avoidable \\ Overtreatment (\%)" "Avoidable \\ Incorrect (\%)")





// Table A3
use "${git}/constructed/sp-summary.dta" , clear

  ren study s
  egen study = group(s type2) , label

  tabstat treat_any1 treat_correct1 treat_over1 treat_under1 ///
          med_anti_nodys med_steroid_noast treat_refer ///
  , by(study) save stats(mean sem n)

  cap mat drop result
  forv i = 1/13 {
    mat a = r(Stat`i')
    mat result = nullmat(result) \ a
  }

  // Refusal Sample
  use "${git}/constructed/sp_checklist_all_ref.dta", clear

    drop if study == "Birbhum T"
    replace study = "Birbhum" if study == "Birbhum C"

    ren study s
    egen study = group(s type2) , label

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
    gen refuse = (type==3)

    tabstat refuse ///
    , by(study) save stats(mean sem n)

      cap mat drop refuse
      forv i = 1/13 {
        mat a = r(Stat`i')
        mat refuse = nullmat(refuse) \ a
      }

      mat result =  refuse , result

  mat result_STARS = J(rowsof(result),colsof(result),0)

  local rows ""
  forv i = 1/13 {
    local rows `" `rows' "`r(name`i')'" "SE" "N" "'
  }

  // Print Results
  outwrite result using "${git}/outputs/a-summary.tex" , replace ///
    rownames(`rows') ///
    colnames("Refusal" "Any Correct" "Correct" "Overtreat" "Incorrect" "Antibiotics \\ (Ex. Diarrhea)" "Steroids \\ (Ex. Asthma)" "Refer")

  outwrite result using "${git}/outputs/a-summary.xlsx" , replace ///
  rownames(`rows') ///
    colnames("Refusal" "Any Correct" "Correct" "Overtreat" "Incorrect" "Antibiotics \\ (Ex. Diarrhea)" "Steroids \\ (Ex. Asthma)" "Refer")

// PO BI Treatment regressions
use "${git}/constructed/pope-summary-bi.dta" , clear

  egen tag = tag(facilitycode study)
  replace n = . if tag == 0
  encode block , gen(block_code)
  local ols ""
  local iv ""

  qui foreach var of varlist po_time po_checklist po_questions po_exams po_meds fee_total_usd n {
    reg `var' treatment i.block_code prov_age prov_male , cl(facilitycode)
      est sto `var'_ols
      local ols "`ols' `var'_ols "

    ivregress 2sls `var' (attendance = treatment) i.block_code prov_age prov_male , cl(facilitycode)
      est sto `var'_iv
      local iv "`iv' `var'_iv "

    su `var'
      estadd scalar m = `r(mean)' : `var'_ols `var'_iv
      estadd scalar s = `r(sd)'   : `var'_ols `var'_iv
  }

  outwrite `ols' using "${git}/outputs/a-birbhum-po1.xlsx" , replace ///
    rownames("Treatment" "" "Constant" "" "Observations" "Regression R2" "Outcome Mean" "Outcome SD") ///
    drop(i.block_code prov_age prov_male) stats(N r2 m s)  ///
    colnames("Time" "Checklist" "Questions" "Exams" "Meds" "Cost (USD)" "Patients")

  outwrite `ols' using "${git}/outputs/a-birbhum-po1.tex" , replace ///
    rownames("Treatment" "" "Constant" "" "Observations" "Regression R2" "Outcome Mean" "Outcome SD") ///
    drop(i.block_code prov_age prov_male) stats(N r2 m s)  ///
    colnames("Time" "Checklist" "Questions" "Exams" "Meds" "Cost (USD)" "Patients")

  outwrite `iv' using "${git}/outputs/a-birbhum-po2.xlsx" , replace ///
    rownames("Attendance" "" "Constant" "" "Observations" "Regression R2" "Outcome Mean" "Outcome SD") ///
    drop(i.block_code prov_age prov_male) stats(N r2 m s)  ///
    colnames("Time" "Checklist" "Questions" "Exams" "Meds" "Cost (USD)" "Patients")

  outwrite `iv' using "${git}/outputs/a-birbhum-po2.tex" , replace ///
    rownames("Attendance" "" "Constant" "" "Observations" "Regression R2" "Outcome Mean" "Outcome SD") ///
    drop(i.block_code prov_age prov_male) stats(N r2 m s)  ///
    colnames("Time" "Checklist" "Questions" "Exams" "Meds" "Cost (USD)" "Patients")

// Continuous ability treatment mediator

use "${git}/constructed/sp-birbhum.dta" , clear
merge m:1 facilitycode using "${git}/constructed/birbhum_irt.dta" , keep(3)

  drop if case_code > 3
  bys facilitycode: egen htype = mean(vignette1)
  gen inter = htype * treatment

  lab var htype "Baseline Vignettes Correct"
  lab var inter   "Ability x Treatment"

  local regs ""

  foreach var of varlist checklist2 vignette2 checklist treat_correct  cost_total_usd {
    regress `var' treatment inter htype i.case_code i.block prov_age prov_male ///
        , vce(cluster facilitycode)
      est sto `var'
      local regs "`regs' `var'"

      su `var'
        estadd scalar m = `r(mean)' : `var'
        estadd scalar s = `r(sd)'   : `var'
  }

  outwrite `regs' using "${git}/outputs/a-birbhum-ability.xlsx" , replace ///
    rownames("Treatment" "" "Ability x Treatment" "" "Baseline Ability" "" "Constant" "" "Observations" "Regression R2" "Outcome Mean" "Outcome SD") ///
    drop(i.case_code i.block prov_age prov_male) stats(N r2 m s)  ///
    colnames("Vignette \\ Checklist" "Vignette \\ Correct" "SP \\ Checklist" "SP \\ Correct" "Cost (USD)")

  outwrite `regs' using "${git}/outputs/a-birbhum-ability.tex" , replace ///
    rownames("Treatment" "" "Ability x Treatment" "" "Baseline Ability" "" "Constant" "" "Observations" "Regression R2" "Outcome Mean" "Outcome SD") ///
    drop(i.case_code i.block prov_age prov_male) stats(N r2 m s)  ///
    colnames("Vignette \\ Checklist" "Vignette \\ Correct" "SP \\ Checklist" "SP \\ Correct" "Cost (USD)")


// ATX: Table 2 remakes
  // Refusals correct

  use "${git}/constructed/sp-summary-ax1.dta" , clear

  replace study = "MP Public" if study == "MP" & private == 0
  replace study = "Kenya Public" if study == "Kenya" & private == 0

  tabstat cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd ///
          frac_avoid frac_avoid1 frac_avoid2 ///
  , by(study) save stats(mean sem n)

  cap mat drop result
  forv i = 1/9 {
    mat a = r(Stat`i')
    mat result = nullmat(result) \ a
  }
  mat result_STARS = J(rowsof(result),colsof(result),0)

  outwrite result using "${git}/outputs/a-costs-rc.tex" , replace ///
  rownames("Birbhum" "SE" "N" "China" "SE" "N" "Delhi" "SE" "N" "Kenya" "SE" "N" "Kenya Public" "SE" "N" "MP" "SE" "N" "MP Public" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N") ///
    colnames("Total Cost \\ (USD)" "Consult \\ (USD)" "Medicine \\ (USD)" "Avoidable \\ (USD)" "Avoidable \\ Total (\%)" "Avoidable \\ Overtreatment (\%)" "Avoidable \\ Incorrect (\%)")

  outwrite result using "${git}/outputs/a-costs-rc.xlsx" , replace ///
  rownames("Birbhum" "SE" "N" "China" "SE" "N" "Delhi" "SE" "N" "Kenya" "SE" "N" "Kenya Public" "SE" "N" "MP" "SE" "N" "MP Public" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N") ///
    colnames("Total Cost \\ (USD)" "Consult \\ (USD)" "Medicine \\ (USD)" "Avoidable \\ (USD)" "Avoidable \\ Total (%)" "Avoidable \\ Overtreatment (%)" "Avoidable \\ Incorrect (%)")

  // Refusals incorrect

  use "${git}/constructed/sp-summary-ax2.dta" , clear

  replace study = "MP Public" if study == "MP" & private == 0
  replace study = "Kenya Public" if study == "Kenya" & private == 0

  tabstat cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd ///
          frac_avoid frac_avoid1 frac_avoid2 ///
  , by(study) save stats(mean sem n)

  cap mat drop result
  forv i = 1/9 {
    mat a = r(Stat`i')
    mat result = nullmat(result) \ a
  }
  mat result_STARS = J(rowsof(result),colsof(result),0)

  outwrite result using "${git}/outputs/a-costs-ric.tex" , replace ///
  rownames("Birbhum" "SE" "N" "China" "SE" "N" "Delhi" "SE" "N" "Kenya" "SE" "N" "Kenya Public" "SE" "N" "MP" "SE" "N" "MP Public" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N") ///
    colnames("Total Cost \\ (USD)" "Consult \\ (USD)" "Medicine \\ (USD)" "Avoidable \\ (USD)" "Avoidable \\ Total (\%)" "Avoidable \\ Overtreatment (\%)" "Avoidable \\ Incorrect (\%)")

  outwrite result using "${git}/outputs/a-costs-ric.xlsx" , replace ///
  rownames("Birbhum" "SE" "N" "China" "SE" "N" "Delhi" "SE" "N" "Kenya" "SE" "N" "Kenya Public" "SE" "N" "MP" "SE" "N" "MP Public" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N") ///
    colnames("Total Cost \\ (USD)" "Consult \\ (USD)" "Medicine \\ (USD)" "Avoidable \\ (USD)" "Avoidable \\ Total (%)" "Avoidable \\ Overtreatment (%)" "Avoidable \\ Incorrect (%)")

// ATX: Sample


  use "${git}/constructed/sam-summary-ax.dta", clear

    tabstat prov_male private prov_qual prov_age prov_waiting_in  ///
    , by(study) save stats(mean sem n)

    cap mat drop result
    forv i = 1/8 {
      mat a = r(Stat`i')
      mat result = nullmat(result) \ a
    }
    mat result_STARS = J(rowsof(result),colsof(result),0)


    outwrite result using "${git}/outputs/aaa.xlsx" , replace ///
    rownames("Birbhum" "SE" "N" "China" "SE" "N" "Delhi" "SE" "N" "Kenya" "SE" "N" "Kenya Public" "SE" "N" "MP" "SE" "N" "MP Public" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N") ///
      colnames("Total Cost \\ (USD)" "Consult \\ (USD)" "Medicine \\ (USD)" "Avoidable \\ (USD)" "Avoidable \\ Total (%)" "Avoidable \\ Overtreatment (%)" "Avoidable \\ Incorrect (%)")



-
    outwrite result using "${git}/outputs/a-asdff.xlsx" , replace ///
    rownames("Birbhum Control" "SE" "N" "Birbhum Treatment" "SE" "N" "China" "SE" "N"  "Delhi" "SE" "N" "Kenya" "SE" "N" "MP" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N") ///
      colnames("Male" "Private" "Fully Qualified" "Mean Age" "Patients Waiting in SPs")

    outwrite result using "${git}/outputs/a-sample.tex" , replace ///
    rownames("Birbhum Control" "SE" "N" "Birbhum Treatment" "SE" "N" "China" "SE" "N"  "Delhi" "SE" "N" "Kenya" "SE" "N" "MP" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N") ///
      colnames("Male" "Private""Fully Qualified" "Mean Age" "Patients Waiting in SPs")

// End
