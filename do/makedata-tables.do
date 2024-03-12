// Table 1

  use "${git}/data/knowdo_data.dta" if type_code == 3, clear
    drop if study == "Birbhum T"
    replace study = "Birbhum" if strpos(study,"Birbhum" )
    replace study = "MP" if strpos(study,"Madhya" )

  // Categorize treatment results

    gen frac_avoid = cost_unnec1_usd/ cost_total_usd
    gen frac_avoid1 = cost_unnec1_usd/ cost_total_usd if treat_type1 == 2 // Overtreatment
    replace frac_avoid1=0 if frac_avoid1==. & frac_avoid!=.
    gen frac_avoid2 = cost_unnec1_usd/ cost_total_usd if treat_type1 == 0 // Undertreatment
    replace frac_avoid2=0 if frac_avoid2==. & frac_avoid!=.

    gen treat_correct = treat_type2
    recode treat_correct 1=1 2=1 0=0

  // Winsorize fees and time

    ren fee_total_usd temp1
  	gen fee_total_usd = .
  	ren time temp3
  	gen time = .
  	foreach s in 1 3 4 5 6 7 8{

		winsor temp1 if study_code == `s', gen(temp2) p(0.025) highonly
		replace fee_total_usd = temp2 if study_code == `s'
		drop temp2

		winsor temp3 if study_code == `s', gen(temp4) p(0.025) highonly
		replace time = temp4 if study_code == `s'
		drop temp4
		}

  // Clean up dataset for constructed version

    keep study treat_any1 treat_correct1 treat_over1 treat_under1 ///
         med_anti_nodys med_steroid_noast treat_refer ///
         cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd ///
         frac_avoid frac_avoid1 frac_avoid2 ///
         time checklist treat_correct med_n prov_waiting_in ///
         fee_total_usd case_code spid facilitycode private

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


  save "${git}/constructed/sp-summary.dta" , replace



// End
