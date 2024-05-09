// Tables Using SPs

  use "${git}/data/knowdo_data.dta" if type_code == 3, clear
    replace study = "MP" if strpos(study,"Madhya" )

  // Categorize treatment results

    gen frac_avoid = cost_unnec1_usd/ cost_total_usd
    gen frac_avoid1 = cost_unnec1_usd/ cost_total_usd if treat_type1 == 2 // Overtreatment
    replace frac_avoid1=0 if frac_avoid1==. & frac_avoid!=.
    gen frac_avoid2 = cost_unnec1_usd/ cost_total_usd if treat_type1 == 0 // Undertreatment
    replace frac_avoid2=0 if frac_avoid2==. & frac_avoid!=.

    gen treat_correct = treat_type1
    recode treat_correct 1=1 2=1 0=0

  // Remove refusals and reclassify correct referrals
  bys study_code case_code: egen check_std = std(checklist)

    drop if treat_refer  == 1 & check_std < -1.2 & treat_correct == 0
    replace treat_correct = 1 if treat_refer  == 1 & check_std > -1.2 & treat_correct == 0

  // Clean up dataset for constructed version

    keep study treat_any1 treat_correct1 treat_over1 treat_under1 ///
         med_anti_nodys med_steroid_noast treat_refer ///
         cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd ///
         frac_avoid frac_avoid1 frac_avoid2 ///
         time checklist treat_correct med_n prov_waiting_in ///
         fee_total_usd case_code spid facilitycode private ///
         block attendance prov_age prov_male

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

  preserve
    drop block attendance prov_age prov_male
    drop if study == "Birbhum T"
    replace study = "Birbhum" if strpos(study,"Birbhum" )
    save "${git}/constructed/sp-summary.dta" , replace
  restore

// Birbhum RCT

  keep if strpos(study,"Birbhum" )
  gen treatment = study == "Birbhum T"
    lab var treatment "Treatment"

  ren block temp
  encode temp, gen(block)

  keep block attendance prov_age prov_male ///
       checklist treat_correct time fee_total_usd med_n ///
       case_code facilitycode study treatment treat_refer ///
       frac_avoid frac_avoid1 frac_avoid2 ///
       cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd

    preserve
      use "${git}/data/knowdo_data.dta" if type_code != 3, clear

      keep if strpos(study,"Birbhum")
      gen vignette = treat_type1
      recode vignette 1=1 2=1 0=0

        // Remove refusals and reclassify correct referrals
        bys study_code case_code: egen check_std = std(checklist)

          // drop if treat_refer == 1 & check_std < -1.2 & treat_correct == 0 // Don't drop in vignettes
          replace vignette = 1 if treat_refer  == 1 & check_std > -1.2 & vignette == 0

      keep vignette checklist case_code facilitycode type
      encode type , gen(baseline)
        drop type
      reshape wide vignette checklist , j(baseline) i(case_code facilitycode)
        lab var vignette1 "Baseline Vignette Correct"
        lab var vignette2 "Endline Vignette Correct"
        lab var checklist1 "Baseline Vignette Checklist"
        lab var checklist2 "Endline Vignette Checklist"
        tempfile vignette
        save `vignette' , replace
    restore

   merge 1:1 case_code facilitycode using `vignette' , keep(3) nogen

  save "${git}/constructed/sp-birbhum.dta" , replace

// Tables using Vignettes

use "${git}/data/knowdo_data.dta" if type_code != 3, clear
  replace study = "MP" if strpos(study,"Madhya" )
  drop if study == "Birbhum T"

  gen vignette = treat_type1
  recode vignette 1=1 2=1 0=0

  // Remove refusals and reclassify correct referrals
  bys study_code case_code: egen check_std = std(checklist)

    // drop if treat_refer == 1 & check_std < -1.2 & treat_correct == 0 // Don't drop in vignettes
    replace vignette = 1 if treat_refer  == 1 & check_std > -1.2 & vignette == 0
    ren vignette treat_correct

    save "${git}/constructed/vig_checklist_all.dta", replace
    ren treat_correct vignette

  // Set up dataset
  keep vignette checklist case_code facilitycode type
  encode type , gen(baseline)
    drop type
  reshape wide vignette checklist , j(baseline) i(case_code facilitycode)
    lab var vignette1 "Baseline Vignette Correct"
    lab var vignette2 "Endline Vignette Correct"
    lab var checklist1 "Baseline Vignette Checklist"
    lab var checklist2 "Endline Vignette Checklist"

  gen tempa = checklist2 if checklist1 == .
  gen tempb = vignette2 if vignette1 == .
  replace checklist1 = tempa if checklist1 == .
  replace vignette1 = tempb if vignette1 == .
  replace checklist2 = . if tempa != .
  replace vignette2 = . if tempb != .
  drop tempa tempb

  gen tworeports = (checklist1 != . & checklist2 != .)
    lab var tworeports "Two Vignette Sample"
  gen max = max(vignette1,vignette2) if vignette2 !=.
    lab var tworeports "Max Correct"
  egen avg = rowmean(vignette1 vignette2) if vignette2 !=.
    lab var tworeports "Mean Correct"
  gen bol = (avg==1) if vignette2 !=.
    lab var tworeports "Both Correct"
  gen bol1  = (vignette1 == 1 & vignette2 == 0)| (vignette1 == 0 & vignette2 == 1)
    lab var bol1 "Bollinger Control"

save "${git}/constructed/vignette-summary.dta" , replace

use "${git}/constructed/sp-summary.dta" , clear
  merge 1:1 facilitycode case_code ///
    using "${git}/constructed/vignette-summary.dta" , keep(3)

    save "${git}/constructed/sp-vignette.dta" , replace

// Tables Using PO

  use "${git}/data/knowdo_data.dta", clear

    keep if inlist(type_code,1) // Vignettes Only
    keep if inlist(study_code,1,6) // Madhya Pradesh and Birbhum only
    drop if private == 0 // Drop public providers
    ta study_code
    cap: drop treat_correct
    gen treat_correct = treat_type1
    recode treat_correct 2=1

    bys study_code case_code: egen check_std = std(checklist)

    collapse (mean) check_std checklist treat_correct, by(study_code facilitycode)

    tempfile know
	save `know', replace

	* Birbhum Data

	use "${git}/data/Birbhum_pope.dta", clear
  	keep if treatment == 0
  	tostring providerid, replace
  	replace providerid = "BI_"+providerid
  	ren providerid facilitycode
  	ren po_timetot po_time
  	ren po_s3q2 po_questions
  	ta po_exams
  	egen po_checklist = rowtotal(po_questions po_exams)
  	ren po_s6q13 po_refer
  	egen po_meds = rownonmiss(po_med_code_?)
  	egen po_adl = rowtotal(pe_s3q2_adl_?), missing
  	egen po_assets = rowtotal(pe_s4q*)

  	keep facilitycode po_price po_time po_questions po_exams po_checklist po_refer po_meds po_adl po_assets
  	gen study_code = 1

	tempfile birbhum
	save `birbhum', replace

	* Madhya Pradesh IDs for PO Data
	use "${git}/data/MP_DataSet_EconPaper.dta", clear
  	keep finprovid finclinid facilitycode public
  	tostring facilitycode, replace
  	duplicates drop
	tempfile mpids
	save `mpids', replace

	* MP Data
	use "${git}/data/maqari_pope.dta", clear
  	merge m:1 finprovid finclinid using `mpids'
    keep if public == 0

  	drop if _merge==2
  	drop _merge
  	tostring facilitycode, replace
  	replace facilitycode = "MA_"+facilitycode

  	* facilitycode po_time po_refer po_meds po_adl po_assets
  	ren po_checklist_n po_questions
  	ren po_exam po_exams
  	egen po_checklist = rowtotal(po_questions po_exams)

  	keep facilitycode po_price po_time po_questions po_exams po_checklist po_refer po_meds po_adl po_assets
  	gen study_code = 6

	tempfile mp
	save `mp', replace
	append using `birbhum'

  bys study_code: egen po_price_std = std(po_price)
  bys study_code: egen po_check_std = std(po_checklist)
  bys study_code: egen po_time_std = std(po_time)

	* Get Know values
	merge m:1 facilitycode using `know'
	drop if _merge==2
	cap: drop _merge
	replace po_price = po_price/67.24 // Converting to US dollars - might need to update to current rates

  gen study = "Birbhum"
  replace study = "MP" if study_code == 6

  keep study facilitycode po_price po_time po_checklist treat_correct po_meds po_refer po_adl po_assets

  ren po_price fee_total_usd

  lab var study "Study"
  lab var fee_total_usd "Price (USD)"
  lab var po_time "Time spent with patient (mins)"
  lab var po_checklist "Total questions and exams"
  lab var treat_correct "Correct management in vignettes"
  lab var po_meds "Number of medicines"
  lab var po_refer "Referred patient"
  lab var po_adl "Patient ADL score"
  lab var po_assets "Patient assets score"


  save "${git}/constructed/pope-summary.dta", replace

// End
