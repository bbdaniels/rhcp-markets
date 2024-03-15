//

use "${git}/constructed/sp-summary.dta" , clear
  merge 1:1 facilitycode case_code ///
        using "${git}/constructed/vignette-summary.dta" , keep(3)

// MP

  // Full sample OLS
  reg treat_correct vignette1 i.case_code if study == "MP" , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))

  // Two reports
  reg treat_correct vignette1 i.case_code if study == "MP" & tworeports == 1, vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
  reg treat_correct avg i.case_code if study == "MP" & tworeports == 1, vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
  reg treat_correct max i.case_code if study == "MP" & tworeports == 1, vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
  reg treat_correct bol bol1  i.case_code if study == "MP" & tworeports == 1, vce(bootstrap, strata(study) cluster(facilitycode) reps(100))

  // IV Linear
  ivregress 2sls treat_correct (vignette1 = checklist1) i.case_code if study == "MP", vce(cluster facilitycode)
  reg vignette1 checklist1 i.case_code if e(sample)==1, cl(facilitycode)
  ivregress 2sls treat_correct (vignette1 = checklist1) i.case_code if study == "MP" & tworeports == 1, vce(cluster facilitycode)

  // GMM
  // preserve
  keep if study == "MP"
    gen case2 = case_code == 2
    gen case3 = case_code == 3
    gen anycov = vignette1

    global x "case2 case3" // Independent variables
  	global t "anycov" // Endogenous treatment
  	global z "checklist1" // Instrument
  	global y "treat_correct" // Outcome variable
  	global q=5 // Percentile for bounding
  	gen weight=1
  	global wt "weight"
  	//gen temp = _n
  	global clust "facilitycode"

  	keep $x $t $z $y $wt $clust
  	do "${git}/do/fs-gmm.do"
-

// Birbhum

  // Two reports
  reg treat_correct vignette1 i.case_code if study == "Birbhum" & tworeports == 1, vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
  reg treat_correct avg i.case_code if study == "Birbhum" & tworeports == 1, vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
  reg treat_correct max i.case_code if study == "Birbhum" & tworeports == 1, vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
  reg treat_correct bol bol1  i.case_code if study == "Birbhum" & tworeports == 1, vce(bootstrap, strata(study) cluster(facilitycode) reps(100))

// Delhi

  // Full sample OLS
  reg treat_correct vignette1 i.case_code if study == "Delhi" , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))

// China

  // Full sample OLS
  reg treat_correct vignette1 i.case_code if study == "China" , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))


//
