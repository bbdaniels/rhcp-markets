// Table 1

  // Main Stats -- PRIVATE
  use "${git}/constructed/sp-summary.dta" , clear

    replace study = "MP Public" if study == "MP" & private == 0
    replace study = "Kenya Public" if study == "Kenya" & private == 0
    replace study = "ZKenya" if study == "Kenya" // Ordering

    drop if strpos(study,"Public") | strpos(study,"China")

    tabstat treat_any1 treat_correct1 treat_over1 treat_under1 ///
            med_anti_nodys med_steroid_noast treat_refer ///
    , by(study) save stats(mean sem n)

    cap mat drop result
    forv i = 1/6 {
      mat a = r(Stat`i')
      mat result = nullmat(result) \ a
    }

  mat result_STARS = J(rowsof(result),colsof(result),0)

  // Print Results
  outwrite result using "${git}/outputs/tab1-summary-1.tex" , replace ///
  rownames("Birbhum" "SE" "N" "Delhi" "SE" "N" "Madhya Pradesh" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N" "Kenya" "SE" "N") ///
    colnames("Any Correct" "Correct" "Overtreat" "Incorrect" "Antibiotics \\ (Ex. Diarrhea)" "Steroids \\ (Ex. Asthma)" "Refer")

  outwrite result using "${git}/outputs/tab1-summary-1.xlsx" , replace ///
  rownames("Birbhum" "SE" "N" "Delhi" "SE" "N" "Madhya Pradesh" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N" "Kenya" "SE" "N") ///
    colnames("Any Correct" "Correct" "Overtreat" "Incorrect" "Antibiotics \\ (Ex. Diarrhea)" "Steroids \\ (Ex. Asthma)" "Refer")

  // Main Stats -- PUBLIC
  use "${git}/constructed/sp-summary.dta" , clear

    replace study = "Madhya Pradesh Public" if study == "MP" & private == 0
    replace study = "ZKenya Public" if study == "Kenya" & private == 0

    keep if strpos(study,"Public") | strpos(study,"China")

    tabstat treat_any1 treat_correct1 treat_over1 treat_under1 ///
            med_anti_nodys med_steroid_noast treat_refer ///
    , by(study) save stats(mean sem n)

    cap mat drop result
    forv i = 1/3 {
      mat a = r(Stat`i')
      mat result = nullmat(result) \ a
    }

  mat result_STARS = J(rowsof(result),colsof(result),0)

  // Print Results
  outwrite result using "${git}/outputs/tab1-summary-2.tex" , replace ///
  rownames("China" "SE" "N" "Madhya Pradesh" "SE" "N" "Kenya" "SE" "N" ) ///
    colnames("Any Correct" "Correct" "Overtreat" "Incorrect" "Antibiotics \\ (Ex. Diarrhea)" "Steroids \\ (Ex. Asthma)" "Refer")

  outwrite result using "${git}/outputs/tab1-summary-2.xlsx" , replace ///
  rownames("China" "SE" "N" "Madhya Pradesh" "SE" "N" "Kenya" "SE" "N" ) ///
    colnames("Any Correct" "Correct" "Overtreat" "Incorrect" "Antibiotics \\ (Ex. Diarrhea)" "Steroids \\ (Ex. Asthma)" "Refer")


// Table 2
use "${git}/constructed/sp-summary.dta" , clear

  replace study = "MP Public" if study == "MP" & private == 0
  replace study = "ZKenya Public" if study == "Kenya" & private == 0
  replace study = "ZKenya" if study == "Kenya" // Ordering

  // Private
  tabstat cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd ///
          frac_avoid frac_avoid1 frac_avoid2 ///
    if !(strpos(study,"Public") | strpos(study,"China")) ///
  , by(study) save stats(mean sem n)

  cap mat drop result
  forv i = 1/6 {
    mat a = r(Stat`i')
    mat result = nullmat(result) \ a
  }
  mat result_STARS = J(rowsof(result),colsof(result),0)

  outwrite result using "${git}/outputs/tab2-costs-1.tex" , replace ///
  rownames("Birbhum" "SE" "N" "Delhi" "SE" "N" "Madhya Pradesh" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N" "Kenya" "SE" "N" ) ///
    colnames("Total Price \\ (USD)" "Consult \\ (USD)" "Medicine \\ (USD)" "Avoidable \\ (USD)" "Avoidable \\ Total (\%)" "Avoidable \\ Overtreatment (\%)" "Avoidable \\ Incorrect (\%)")

  outwrite result using "${git}/outputs/tab2-costs-1.xlsx" , replace ///
  rownames("Birbhum" "SE" "N" "Delhi" "SE" "N" "Madhya Pradesh" "SE" "N" "Mumbai" "SE" "N" "Patna" "SE" "N" "Kenya" "SE" "N" ) ///
    colnames("Total Price \\ (USD)" "Consult \\ (USD)" "Medicine \\ (USD)" "Avoidable \\ (USD)" "Avoidable \\ Total (%)" "Avoidable \\ Overtreatment (%)" "Avoidable \\ Incorrect (%)")

  // Public
  tabstat cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd ///
          frac_avoid frac_avoid1 frac_avoid2 ///
    if (strpos(study,"Public") | strpos(study,"China")) ///
  , by(study) save stats(mean sem n)

  cap mat drop result
  forv i = 1/3 {
    mat a = r(Stat`i')
    mat result = nullmat(result) \ a
  }
  mat result_STARS = J(rowsof(result),colsof(result),0)

  outwrite result using "${git}/outputs/tab2-costs-2.tex" , replace ///
  rownames("China" "SE" "N" "Madhya Pradesh" "SE" "N" "Kenya" "SE" "N" ) ///
    colnames("Total Price \\ (USD)" "Consult \\ (USD)" "Medicine \\ (USD)" "Avoidable \\ (USD)" "Avoidable \\ Total (\%)" "Avoidable \\ Overtreatment (\%)" "Avoidable \\ Incorrect (\%)")

  outwrite result using "${git}/outputs/tab2-costs-2.xlsx" , replace ///
  rownames("China" "SE" "N" "Madhya Pradesh" "SE" "N" "Kenya" "SE" "N" ) ///
    colnames("Total Price \\ (USD)" "Consult \\ (USD)" "Medicine \\ (USD)" "Avoidable \\ (USD)" "Avoidable \\ Total (%)" "Avoidable \\ Overtreatment (%)" "Avoidable \\ Incorrect (%)")

// Table 4

  use "${git}/constructed/sp-summary.dta" if private == 1, clear
  drop if study == "Kenya"
  drop if case_code > 4
  local regs ""

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
  local regs ""
  foreach study in `levels' {

    local cols `" `cols' "`study' \\ Bivariate" "`study' \\ Multiple" "'
    local regs "`regs' b`study' m`study' "

    bivreg fee_total_usd time checklist treat_correct med_n treat_refer prov_waiting_in ///
      if study == "`study'"  , c(i.case_code) vce(cluster facilitycode)

      est sto b`study'

    qui reg fee_total_usd time checklist treat_correct med_n treat_refer prov_waiting_in ///
        i.case_code if study == "`study'" , vce(cluster facilitycode)

        est sto m`study'

        qui su fee_total_usd if study == "`study'"

        estadd scalar m = r(mean) : m`study'
        estadd scalar s = r(sd) : m`study'

    if (("`study'" == "MP" ) | ("`study'" == "Birbhum")) {
      local cols `" `cols' "`study' \\ Restricted" "'
      local regs "`regs' r`study' "

      preserve
      use "${git}/constructed/sp-vignette.dta" ///
         if ((vignette1 == 1) | (vignette2 == 1)) & (study == "`study'" ) & (private == 1) , clear
         drop if case_code > 3

      qui reg fee_total_usd ///
        time checklist treat_correct med_n treat_refer prov_waiting_in ///
        i.case_code if study == "`study'", vce(cluster facilitycode)

      est sto r`study'

      qui su fee_total_usd

      estadd scalar m = r(mean) : r`study'
      estadd scalar s = r(sd) : r`study'
      restore
    }

  }

  outwrite bBirbhum mBirbhum rBirbhum bMP mMP rMP using "${git}/outputs/tab4-fees-sp-1.xlsx" ///
    , replace format(%9.3f) stats(N r2 m s) drop(i.case_code) ///
      colnames("Birbhum Bivariate" "Birbhum Multiple" "Birbhum Restricted" "MP Bivariate" "MP Multiple" "MP Restricted") ///
      rownames("Time (mins)" "" "Checklist (%)" "" "Correct" "" "Medicines" "" "Referral" "" "Patients Waiting" "" ///
         "Constant" "" "Observations"  "R-Square" "Fees Mean (USD)" "Fees SD (USD)")

  outwrite bBirbhum mBirbhum rBirbhum bMP mMP rMP using "${git}/outputs/tab4-fees-sp-1.tex" ///
    , replace format(%9.3f) stats(N r2 m s) drop(i.case_code) ///
      colnames("Birbhum Bivariate" "Birbhum Multiple" "Birbhum Restricted" "MP Bivariate" "MP Multiple" "MP Restricted") ///
      rownames("Time (mins)" "" "Checklist (\%)" "" "Correct" "" "Medicines" "" "Referral" "" "Patients Waiting" "" ///
         "Constant" "" "Observations"  "R-Square" "Fees Mean (USD)" "Fees SD (USD)")

  outwrite bDelhi mDelhi bMumbai mMumbai bPatna mPatna using "${git}/outputs/tab4-fees-sp-2.xlsx" ///
   , replace format(%9.3f) stats(N r2 m s) drop(i.case_code) ///
     colnames("Delhi Bivariate" "Delhi Multiple" "Mumbai Bivariate" "Mumbai Multiple" "Patna Bivariate" "Patna Multiple") ///
     rownames("Time (mins)" "" "Checklist (%)" "" "Correct" "" "Medicines" "" "Referral" "" "Patients Waiting" "" ///
        "Constant" "" "Observations"  "R-Square" "Fees Mean (USD)" "Fees SD (USD)")

        outwrite bDelhi mDelhi bMumbai mMumbai bPatna mPatna using "${git}/outputs/tab4-fees-sp-2.tex" ///
   , replace format(%9.3f) stats(N r2 m s) drop(i.case_code) ///
     colnames("Delhi Bivariate" "Delhi Multiple" "Mumbai Bivariate" "Mumbai Multiple" "Patna Bivariate" "Patna Multiple") ///
     rownames("Time (mins)" "" "Checklist (\%)" "" "Correct" "" "Medicines" "" "Referral" "" "Patients Waiting" "" ///
        "Constant" "" "Observations"  "R-Square" "Fees Mean (USD)" "Fees SD (USD)")

// Table 5

use "${git}/constructed/pope-summary.dta" , clear
 keep if study == "Birbhum"

 pca po_time po_exams po_questions
   predict effort
   lab var effort "Effort (PCA)"

 bivreg fee_total_usd ///
   effort po_time po_exams po_questions treat_correct po_meds po_refer po_adl po_assets ///
     , cl(facilitycode)
   est sto b1

 reg    fee_total_usd        po_time po_exams po_questions treat_correct po_meds po_refer  ///
     , cl(facilitycode)
   est sto b2

 reg    fee_total_usd        po_time po_exams po_questions treat_correct po_meds po_refer po_adl po_assets ///
     , cl(facilitycode)
   est sto b3

 reg    fee_total_usd effort                               treat_correct po_meds po_refer po_adl po_assets ///
     , cl(facilitycode)
   est sto b4

 reg    fee_total_usd        po_time po_exams po_questions               po_meds po_refer po_adl po_assets ///
     , cl(facilitycode) a(facilitycode)
   est sto b5

 reg    fee_total_usd effort                                             po_meds po_refer po_adl po_assets ///
     , cl(facilitycode) a(facilitycode)
   est sto b6

 su fee_total_usd
 estadd scalar m = r(mean) : b1 b2 b3 b4 b5 b6
 estadd scalar s = r(sd) : b1 b2 b3 b4 b5 b6

use "${git}/constructed/pope-summary.dta" , clear
 keep if study == "MP"

 pca po_time po_exams po_questions
   predict effort
   lab var effort "Effort (PCA)"

   bivreg fee_total_usd ///
     effort po_time po_exams po_questions treat_correct po_meds po_refer po_adl po_assets ///
       , cl(facilitycode)
     est sto m1

   reg    fee_total_usd        po_time po_exams po_questions treat_correct po_meds po_refer  ///
       , cl(facilitycode)
     est sto m2

   reg    fee_total_usd        po_time po_exams po_questions treat_correct po_meds po_refer po_adl po_assets ///
       , cl(facilitycode)
     est sto m3

   reg    fee_total_usd effort                               treat_correct po_meds po_refer po_adl po_assets ///
       , cl(facilitycode)
     est sto m4

   reg    fee_total_usd        po_time po_exams po_questions               po_meds po_refer po_adl po_assets ///
       , cl(facilitycode) a(facilitycode)
     est sto m5

   reg    fee_total_usd effort                                             po_meds po_refer po_adl po_assets ///
       , cl(facilitycode) a(facilitycode)
     est sto m6

 su fee_total_usd
 estadd scalar m = r(mean) : m1 m2 m3 m4 m5 m6
 estadd scalar s = r(sd) : m1 m2 m3 m4 m5 m6

  outwrite b1 b2 b3 b5 b4 b6 using "${git}/outputs/tab5-fees-po-1.tex" ///
   , replace format(%9.3f) stats(N r2 m s) ///
     colnames("Birbhum \\ Bivariate" "Birbhum \\ Multiple" "Birbhum \\ Patient" "Birbhum \\ FE"  "Birbhum \\ Effort" "Birbhum \\ Effort FE") ///
     rownames("Effort (PCA)" "" "Time with Patient (Min)" "" "Questions (N)" "" "Exams (N)" "" "Correct Vignettes (\%)" "" "Medications" "" ///
              "Referral" "" "Patient ADL"  "" "Patient Assets" "" "Constant" "" "Observations" "Regression R2" "Outcome Mean" "Outcome SD")

  outwrite b1 b2 b3 b5 b4 b6 using "${git}/outputs/tab5-fees-po-1.xlsx" ///
   , replace format(%9.3f) stats(N r2 m s) ///
   colnames("Birbhum \\ Bivariate" "Birbhum \\ Multiple" "Birbhum \\ Patient" "Birbhum \\ FE" "Birbhum \\ Effort" "Birbhum \\ Effort FE") ///
   rownames("Effort (PCA)" "" "Time with Patient (Min)" "" "Questions (N)" "" "Exams (N)" "" "Correct Vignettes (\%)" "" "Medications" ""  ///
            "Referral" "" "Patient ADL"  """Patient Assets" "" "Constant" "" "Observations" "Regression R2" "Outcome Mean" "Outcome SD")

  outwrite m1 m2 m3 m5 m4 m6 using "${git}/outputs/tab5-fees-po-2.tex" ///
    , replace format(%9.3f) stats(N r2 m s) ///
    colnames("MP \\ Bivariate" "MP \\ Multiple" "MP \\ Patient" "MP \\ FE" "MP \\ Effort" "MP \\ Effort FE") ///
      rownames("Effort (PCA)" "" "Time with Patient (Min)" "" "Questions (N)" "" "Exams (N)" "" "Correct Vignettes (\%)" "" "Medications" "" ///
               "Referral" "" "Patient ADL"  "" "Patient Assets" "" "Constant" "" "Observations" "Regression R2" "Outcome Mean" "Outcome SD")

  outwrite m1 m2 m3 m5 m4 m6 using "${git}/outputs/tab5-fees-po-2.xlsx" ///
    , replace format(%9.3f) stats(N r2 m s) ///
    colnames("MP \\ Bivariate" "MP \\ Multiple" "MP \\ Patient" "MP \\ FE" "MP \\ Effort" "MP \\ Effort FE") ///
    rownames("Effort (PCA)" "" "Time with Patient (Min)" "" "Questions (N)" "" "Exams (N)" "" "Correct Vignettes (\%)" "" "Medications" ""  ///
             "Referral" "" "Patient ADL"  """Patient Assets" "" "Constant" "" "Observations" "Regression R2" "Outcome Mean" "Outcome SD")


// End
