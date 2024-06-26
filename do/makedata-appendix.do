use "${git}/data/knowdo_data.dta" if type_code == 3, clear
  replace study = "MP" if strpos(study,"Madhya" )

  lab def p  0 "Public" 1 "Private"
    lab val private p
  lab def pq 0 "Unqualified" 1 "Qualified"
    lab val prov_qual pq
  egen type2 = group(private prov_qual) , label
    replace type2 = 0 if private == 0
    lab def type2 0 "Public" , modify

    // Remove refusals and reclassify correct referrals
    bys study_code case_code: egen check_std = std(checklist)

    gen treat_correct = treat_type1
    recode treat_correct 1=1 2=1 0=0

      // REFUSALS = CORRECT
      replace cost_unnec1_usd = 0 if treat_refer  == 1 & check_std < -1.2 & treat_correct == 0

      replace cost_unnec1_usd = cost_total_usd if treat_type1 == 0
      replace cost_unnec1_usd = cost_meds_usd if treat_refer  == 1 & check_std > -1.2 & treat_correct == 0 // Referrals

      replace treat_correct = 1 if treat_refer  == 1 & check_std > -1.2 & treat_correct == 0
      replace treat_type1 = 2 if treat_refer  == 1 & check_std > -1.2 & treat_type1 == 0

      replace cost_unnec1_usd = 0 if treat_type1 == 1
      replace cost_unnec1_usd = cost_unnec1_usd if treat_type1 == 2

    // Categorize treatment results

      gen frac_avoid = cost_unnec1_usd / cost_total_usd
      replace frac_avoid=0 if frac_avoid==. & cost_unnec1_usd != .
      gen frac_avoid1 = cost_unnec1_usd/ cost_total_usd if treat_type1 == 2 // Overtreatment
      replace frac_avoid1=0 if frac_avoid1==. & cost_unnec1_usd != .
      gen frac_avoid2 = cost_unnec1_usd/ cost_total_usd if treat_type1 == 0 // Undertreatment
      replace frac_avoid2=0 if frac_avoid2==. & cost_unnec1_usd != .

  // Clean up dataset for constructed version

    keep study treat_any1 treat_correct1 treat_over1 treat_under1 ///
         med_anti_nodys med_steroid_noast treat_refer ///
         cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd ///
         frac_avoid frac_avoid1 frac_avoid2 ///
         time checklist treat_correct med_n prov_waiting_in ///
         fee_total_usd case_code spid facilitycode private ///
         block attendance prov_age prov_male type2

      lab var treat_any1 "Any Correct"
      lab var treat_correct1 "Correct"
      lab var treat_over1 "Overtreat"
      lab var treat_under1 "Incorrect"
      lab var med_anti_nodys "Antibiotics"
      lab var med_steroid_noast "Steroids"
      lab var treat_refer "Referred"

      lab var cost_total_usd "Cost"
      lab var cost_consult_usd "Consult"
      lab var cost_meds_usd "Medicine"
      lab var cost_unnec1_usd "Avoidable"
      lab var frac_avoid "Total"
      lab var frac_avoid1 "Overtreatment"
      lab var frac_avoid2 "Incorrect"

      lab var time "Time spent with SPs (mins)"
      lab var checklist "Checklist completed (percent)"
      lab var treat_correct "Any correct treatment"
      lab var med_n "Number of medicines"
      lab var prov_waiting_in "Number of patients waiting"
      lab var fee_total_usd "USD Fee Total"
      lab var case_code "SP Case
      lab var facilitycode "Facility ID"
      lab var private "Private Facility"
      lab var type2 "Qualification Type"

  preserve
    drop block attendance prov_age prov_male
    drop if study == "Birbhum T"
    replace study = "Birbhum" if strpos(study,"Birbhum" )
    save "${git}/constructed/sp-summary-ax1.dta" , replace
  restore

//

use "${git}/data/knowdo_data.dta" if type_code == 3, clear
  replace study = "MP" if strpos(study,"Madhya" )

  lab def p  0 "Public" 1 "Private"
    lab val private p
  lab def pq 0 "Unqualified" 1 "Qualified"
    lab val prov_qual pq
  egen type2 = group(private prov_qual) , label
    replace type2 = 0 if private == 0
    lab def type2 0 "Public" , modify

    // Remove refusals and reclassify correct referrals
    bys study_code case_code: egen check_std = std(checklist)

    gen treat_correct = treat_type1
    recode treat_correct 1=1 2=1 0=0

      // REFUSALS = INCORRECT
      replace cost_unnec1_usd = cost_total_usd if treat_refer  == 1 & check_std < -1.2 & treat_correct == 0

      replace cost_unnec1_usd = cost_total_usd if treat_type1 == 0
      replace cost_unnec1_usd = cost_meds_usd if treat_refer  == 1 & check_std > -1.2 & treat_correct == 0 // Referrals

      replace treat_correct = 1 if treat_refer  == 1 & check_std > -1.2 & treat_correct == 0
      replace treat_type1 = 2 if treat_refer  == 1 & check_std > -1.2 & treat_type1 == 0

      replace cost_unnec1_usd = 0 if treat_type1 == 1
      replace cost_unnec1_usd = cost_unnec1_usd if treat_type1 == 2

    // Categorize treatment results

      gen frac_avoid = cost_unnec1_usd / cost_total_usd
      replace frac_avoid=0 if frac_avoid==. & cost_unnec1_usd != .
      gen frac_avoid1 = cost_unnec1_usd/ cost_total_usd if treat_type1 == 2 // Overtreatment
      replace frac_avoid1=0 if frac_avoid1==. & cost_unnec1_usd != .
      gen frac_avoid2 = cost_unnec1_usd/ cost_total_usd if treat_type1 == 0 // Undertreatment
      replace frac_avoid2=0 if frac_avoid2==. & cost_unnec1_usd != .

  // Clean up dataset for constructed version

    keep study treat_any1 treat_correct1 treat_over1 treat_under1 ///
         med_anti_nodys med_steroid_noast treat_refer ///
         cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd ///
         frac_avoid frac_avoid1 frac_avoid2 ///
         time checklist treat_correct med_n prov_waiting_in ///
         fee_total_usd case_code spid facilitycode private ///
         block attendance prov_age prov_male type2

      lab var treat_any1 "Any Correct"
      lab var treat_correct1 "Correct"
      lab var treat_over1 "Overtreat"
      lab var treat_under1 "Incorrect"
      lab var med_anti_nodys "Antibiotics"
      lab var med_steroid_noast "Steroids"
      lab var treat_refer "Referred"

      lab var cost_total_usd "Cost"
      lab var cost_consult_usd "Consult"
      lab var cost_meds_usd "Medicine"
      lab var cost_unnec1_usd "Avoidable"
      lab var frac_avoid "Total"
      lab var frac_avoid1 "Overtreatment"
      lab var frac_avoid2 "Incorrect"

      lab var time "Time spent with SPs (mins)"
      lab var checklist "Checklist completed (percent)"
      lab var treat_correct "Any correct treatment"
      lab var med_n "Number of medicines"
      lab var prov_waiting_in "Number of patients waiting"
      lab var fee_total_usd "USD Fee Total"
      lab var case_code "SP Case
      lab var facilitycode "Facility ID"
      lab var private "Private Facility"
      lab var type2 "Qualification Type"

  preserve
    drop block attendance prov_age prov_male
    drop if study == "Birbhum T"
    replace study = "Birbhum" if strpos(study,"Birbhum" )
    save "${git}/constructed/sp-summary-ax2.dta" , replace
  restore

// Universe

    use "${git}/data/knowdo_data.dta", clear

    replace study = "Birbhum Control" if study == "Birbhum C"
    replace study = "Birbhum Treatment" if study == "Birbhum T"

    keep facilitycode study ///
         prov_male prov_qual prov_age prov_waiting_in private

    collapse (mean) prov_male prov_qual prov_age prov_waiting_in private , ///
      by(study facilitycode)

      replace prov_age = . if prov_age < 5
   save "${git}/constructed/sam-summary-ax.dta" , replace
  -

//
