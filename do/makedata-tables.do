// Tables Using SPs

  use "${git}/data/knowdo_data.dta" if type_code == 3, clear
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

  preserve
    drop if study == "Birbhum T"
    replace study = "Birbhum" if strpos(study,"Birbhum" )
    save "${git}/constructed/sp-summary.dta" , replace
  restore

// Birbhum RCT

  keep if strpos(study,"Birbhum" )


// Tables Using PO

  use "${git}/data/knowdo_data.dta", clear

    keep if inlist(type_code,1) // Vignettes Only
    keep if inlist(study_code,1,6) // Madhya Pradesh and Birbhum only
    drop if private == 0 // Drop public providers
    ta study_code
    gen check_win = .
    gen check_std = .
    cap: drop treat_correct
    gen treat_correct = treat_type2
    recode treat_correct 2=1

    foreach i in 1 6 {

      winsor checklist if study_code==`i', gen(temp3) p(0.01) highonly
      egen temp4 = std(checklist) if study_code==`i', mean(0) std(1)
      replace check_win = temp3 if study_code==`i'
      replace check_std = temp4 if study_code==`i'
      drop temp3 temp4

      }

    collapse (mean) check_std check_win checklist treat_correct, by(study_code facilitycode)

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

  	foreach var in po_checklist po_time po_price{
  		ren `var' temp
  		winsor temp, gen(`var') p(0.01) highonly
  		drop temp
  		}

  	egen temp1 = std(po_checklist), mean(0) std(1)
  	gen po_check_std = temp1
  	drop temp1

  	egen temp1 = std(po_price), mean(0) std(1)
  	gen po_price_std = temp1
  	drop temp1

  	egen temp1 = std(po_time), mean(0) std(1)
  	gen po_time_std = temp1
  	drop temp1

  	keep facilitycode po_price po_time po_questions po_exams po_checklist po_refer po_meds po_adl po_assets po_check_std po_price_std po_time_std
  	gen study_code = 1

	tempfile birbhum
	save `birbhum', replace

	* Madhya Pradesh IDs for PO Data
	use "${git}/data/MP_DataSet_EconPaper.dta", clear
  	keep finprovid finclinid facilitycode
  	tostring facilitycode, replace
  	duplicates drop
	tempfile mpids
	save `mpids', replace

	* MP Data
	use "${git}/data/maqari_pope.dta", clear
  	keep if public == 0
  	merge m:1 finprovid finclinid using `mpids'
  	drop if _merge==2
  	drop _merge
  	tostring facilitycode, replace
  	replace facilitycode = "MA_"+facilitycode

  	* facilitycode po_time po_refer po_meds po_adl po_assets
  	ren po_checklist_n po_questions
  	ren po_exam po_exams
  	egen po_checklist = rowtotal(po_questions po_exams)

  	foreach var in po_checklist po_time po_price{
  		ren `var' temp
  		winsor temp, gen(`var') p(0.01) highonly
  		drop temp
  		}

  	egen temp1 = std(po_checklist), mean(0) std(1)
  	gen po_check_std = temp1
  	drop temp1

  	egen temp1 = std(po_price), mean(0) std(1)
  	gen po_price_std = temp1
  	drop temp1

  	egen temp1 = std(po_time), mean(0) std(1)
  	gen po_time_std = temp1
  	drop temp1

  	keep facilitycode po_price po_time po_questions po_exams po_checklist po_refer po_meds po_adl po_assets po_check_std po_price_std po_time_std
  	gen study_code = 6

	tempfile mp
	save `mp', replace
	append using `birbhum'

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
