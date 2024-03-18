//

cap mat drop all all_STARS


cap prog drop regstack
prog def regstack , rclass

syntax
  mat xx = r(table)
    return scalar b = xx[1,1]
    return scalar se = xx[2,1]
    local p = xx[4,1]
      local p2 0
      if `p' < 0.1 local p2 1
      if `p' < 0.05 local p2 2
      if `p' < 0.01 local p2 3
    return scalar p = `p2'
end

cap mat drop results results_STARS

// MP Full Sample
use "${git}/constructed/sp-vignette.dta" if study == "MP" , clear

  // Full sample OLS
  reg treat_correct vignette1 i.case_code , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
    regstack

    mat results = [`r(b)'] \ [`r(se)'] \ [.] \ [.] \ [.] \ [.] \ [.] \ [.] \ [e(N)]
    mat results_STARS = [`r(p)'] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0]

  // GMM
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
  	global clust "facilitycode"

  	keep $x $t $z $y $wt $clust case_code  vignette1
  	qui do "${git}/do/fs-gmm.do"

      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

      local b = ols[1,2]
      local se = ols[2,2]
      local p = ols[4,2]
        local p2 0
        if `p' < 0.1 local p2 1
        if `p' < 0.05 local p2 2
        if `p' < 0.01 local p2 3

        mat results = results \ [`b'] \ [`se']
        mat results_STARS = results_STARS \ [`p2'] \ [0]

      local b = iv[1,2]
      local se = iv[2,2]
      local p = iv[4,2]
        local p2 0
        if `p' < 0.1 local p2 1
        if `p' < 0.05 local p2 2
        if `p' < 0.01 local p2 3

      reg treat_correct vignette1

        mat results = results \ [`b'] \ [`se'] \ [e(N)]
        mat results_STARS = results_STARS \ [`p2'] \ [0] \ [0]

  // IV Linear
  ivregress 2sls treat_correct (vignette1 = checklist1) i.case_code, vce(cluster facilitycode) first
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    estat firststage
    local f = r(singleresults)[1,4]

  reg vignette1 checklist1 i.case_code, vce(cluster facilitycode)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)'] \ [`f'] \ [e(N)]
    mat results_STARS = results_STARS \ [`r(p)'] \ [0] \ [0] \ [0]

  // Summary
  su treat_correct
    mat results = results \ [`r(mean)']
  su vignette1
    mat results = results \ [`r(mean)']
  mat results_STARS = results_STARS \ [0] \ [0]

  mat all = results
  mat all_STARS = results_STARS


// MP Two Reports w/Checklist
cap mat drop results results_STARS
use "${git}/constructed/sp-vignette.dta" if study == "MP" & tworeports == 1 , clear

  // Full sample OLS
  reg treat_correct vignette1 i.case_code , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
    regstack
    mat results = [`r(b)'] \ [`r(se)']
    mat results_STARS = [`r(p)'] \ [0]

  reg treat_correct avg i.case_code , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  reg treat_correct max i.case_code , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  reg treat_correct bol bol1 i.case_code , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
    local n = e(N)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)'] \ [`n']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]  \ [0]

  // GMM
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
  	global clust "facilitycode"

  	keep $x $t $z $y $wt $clust case_code  vignette1
  	qui do "${git}/do/fs-gmm.do"

      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

      local b = ols[1,2]
      local se = ols[2,2]
      local p = ols[4,2]
        local p2 0
        if `p' < 0.1 local p2 1
        if `p' < 0.05 local p2 2
        if `p' < 0.01 local p2 3

        mat results = results \ [`b'] \ [`se']
        mat results_STARS = results_STARS \ [`p2'] \ [0]

      local b = iv[1,2]
      local se = iv[2,2]
      local p = iv[4,2]
        local p2 0
        if `p' < 0.1 local p2 1
        if `p' < 0.05 local p2 2
        if `p' < 0.01 local p2 3

      reg treat_correct vignette1

        mat results = results \ [`b'] \ [`se'] \ [e(N)]
        mat results_STARS = results_STARS \ [`p2'] \ [0] \ [0]

  // IV Linear
  ivregress 2sls treat_correct (vignette1 = checklist1) i.case_code, vce(cluster facilitycode) first
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    estat firststage
    local f = r(singleresults)[1,4]

  reg vignette1 checklist1 i.case_code, vce(cluster facilitycode)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)'] \ [`f'] \ [e(N)]
    mat results_STARS = results_STARS \ [`r(p)'] \ [0] \ [0] \ [0]

  // Summary
  su treat_correct
    mat results = results \ [`r(mean)']
  su vignette1
    mat results = results \ [`r(mean)']
  mat results_STARS = results_STARS \ [0] \ [0]

  mat all = all , results
  mat all_STARS = all_STARS , results_STARS

// MP Two Reports w/Correct
cap mat drop results results_STARS
use "${git}/constructed/sp-vignette.dta" if study == "MP" & tworeports == 1 , clear

  // Full sample OLS
  mat results = [.] \ [.] \ [.] \ [.] \ [.] \ [.] \ [.] \ [.] \ [.]
  mat results_STARS = [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0]

  // GMM
    gen case2 = case_code == 2
    gen case3 = case_code == 3
    gen anycov = vignette1

    global x "case2 case3" // Independent variables
  	global t "anycov" // Endogenous treatment
  	global z "vignette2" // Instrument
  	global y "treat_correct" // Outcome variable
  	global q=5 // Percentile for bounding
  	gen weight=1
  	global wt "weight"
  	global clust "facilitycode"

  	keep $x $t $z $y $wt $clust case_code  vignette1
  	qui do "${git}/do/fs-gmm.do"

      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

      local b = ols[1,2]
      local se = ols[2,2]
      local p = ols[4,2]
        local p2 0
        if `p' < 0.1 local p2 1
        if `p' < 0.05 local p2 2
        if `p' < 0.01 local p2 3

        mat results = results \ [`b'] \ [`se']
        mat results_STARS = results_STARS \ [`p2'] \ [0]

      local b = iv[1,2]
      local se = iv[2,2]
      local p = iv[4,2]
        local p2 0
        if `p' < 0.1 local p2 1
        if `p' < 0.05 local p2 2
        if `p' < 0.01 local p2 3

      reg treat_correct vignette1

        mat results = results \ [`b'] \ [`se'] \ [e(N)]
        mat results_STARS = results_STARS \ [`p2'] \ [0] \ [0]

  // IV Linear
  ivregress 2sls treat_correct (vignette1 = vignette2) i.case_code, vce(cluster facilitycode) first
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    estat firststage
    local f = r(singleresults)[1,4]

  reg vignette1 vignette2 i.case_code, vce(cluster facilitycode)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)'] \ [`f'] \ [e(N)]
    mat results_STARS = results_STARS \ [`r(p)'] \ [0] \ [0] \ [0]

  // Summary
  su treat_correct
    mat results = results \ [`r(mean)']
  su vignette1
    mat results = results \ [`r(mean)']
  mat results_STARS = results_STARS \ [0] \ [0]

  mat all = all , results
  mat all_STARS = all_STARS , results_STARS

// Birbhum Two Reports w/Checklist
cap mat drop results results_STARS
use "${git}/constructed/sp-vignette.dta" if study == "Birbhum" & tworeports == 1 , clear

  // Full sample OLS
  reg treat_correct vignette1 i.case_code , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
    regstack
    mat results = [`r(b)'] \ [`r(se)']
    mat results_STARS = [`r(p)'] \ [0]

  reg treat_correct avg i.case_code , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  reg treat_correct max i.case_code , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  reg treat_correct bol bol1 i.case_code , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
    local n = e(N)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)'] \ [`n']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]  \ [0]

  // GMM
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
  	global clust "facilitycode"

  	keep $x $t $z $y $wt $clust case_code  vignette1
  	qui do "${git}/do/fs-gmm.do"

      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

      local b = ols[1,2]
      local se = ols[2,2]
      local p = ols[4,2]
        local p2 0
        if `p' < 0.1 local p2 1
        if `p' < 0.05 local p2 2
        if `p' < 0.01 local p2 3

        mat results = results \ [`b'] \ [`se']
        mat results_STARS = results_STARS \ [`p2'] \ [0]

      local b = iv[1,2]
      local se = iv[2,2]
      local p = iv[4,2]
        local p2 0
        if `p' < 0.1 local p2 1
        if `p' < 0.05 local p2 2
        if `p' < 0.01 local p2 3

      reg treat_correct vignette1

        mat results = results \ [`b'] \ [`se'] \ [e(N)]
        mat results_STARS = results_STARS \ [`p2'] \ [0] \ [0]

  // IV Linear
  ivregress 2sls treat_correct (vignette1 = checklist1) i.case_code, vce(cluster facilitycode) first
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    estat firststage
    local f = r(singleresults)[1,4]

  reg vignette1 checklist1 i.case_code, vce(cluster facilitycode)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)'] \ [`f'] \ [e(N)]
    mat results_STARS = results_STARS \ [`r(p)'] \ [0] \ [0] \ [0]

  // Summary
  su treat_correct
    mat results = results \ [`r(mean)']
  su vignette1
    mat results = results \ [`r(mean)']
  mat results_STARS = results_STARS \ [0] \ [0]

  mat all = all , results
  mat all_STARS = all_STARS , results_STARS

// Birbhum Two Reports w/Correct
cap mat drop results results_STARS
use "${git}/constructed/sp-vignette.dta" if study == "Birbhum" & tworeports == 1 , clear

  // Full sample OLS
  mat results = [.] \ [.] \ [.] \ [.] \ [.] \ [.] \ [.] \ [.] \ [.]
  mat results_STARS = [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0]

  // GMM
    gen case2 = case_code == 2
    gen case3 = case_code == 3
    gen anycov = vignette1

    global x "case2 case3" // Independent variables
  	global t "anycov" // Endogenous treatment
  	global z "vignette2" // Instrument
  	global y "treat_correct" // Outcome variable
  	global q=5 // Percentile for bounding
  	gen weight=1
  	global wt "weight"
  	global clust "facilitycode"

  	keep $x $t $z $y $wt $clust case_code  vignette1
  	qui do "${git}/do/fs-gmm.do"

      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

      local b = ols[1,2]
      local se = ols[2,2]
      local p = ols[4,2]
        local p2 0
        if `p' < 0.1 local p2 1
        if `p' < 0.05 local p2 2
        if `p' < 0.01 local p2 3

        mat results = results \ [`b'] \ [`se']
        mat results_STARS = results_STARS \ [`p2'] \ [0]

      local b = iv[1,2]
      local se = iv[2,2]
      local p = iv[4,2]
        local p2 0
        if `p' < 0.1 local p2 1
        if `p' < 0.05 local p2 2
        if `p' < 0.01 local p2 3

      reg treat_correct vignette1

        mat results = results \ [`b'] \ [`se'] \ [e(N)]
        mat results_STARS = results_STARS \ [`p2'] \ [0] \ [0]

  // IV Linear
  ivregress 2sls treat_correct (vignette1 = vignette2) i.case_code, vce(cluster facilitycode) first
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    estat firststage
    local f = r(singleresults)[1,4]

  reg vignette1 vignette2 i.case_code, vce(cluster facilitycode)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)'] \ [`f'] \ [e(N)]
    mat results_STARS = results_STARS \ [`r(p)'] \ [0] \ [0] \ [0]

  // Summary
  su treat_correct
    mat results = results \ [`r(mean)']
  su vignette1
    mat results = results \ [`r(mean)']
  mat results_STARS = results_STARS \ [0] \ [0]

  mat all = all , results
  mat all_STARS = all_STARS , results_STARS

// Delhi
cap mat drop results results_STARS
use "${git}/constructed/sp-vignette.dta" if study == "Delhi"  , clear

    // Full sample OLS
    reg treat_correct vignette1 i.case_code , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
      regstack
      mat results = [`r(b)'] \ [`r(se)'] \ [.] \ [.] \ [.] \ [.] \ [.] \ [.] \ [e(N)] \[.] \ [.] \ [.] \ [.] \ [.] \ [.] \ [.]
      mat results_STARS = [`r(p)'] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0]

  // NO GMM

  // IV Linear
  ivregress 2sls treat_correct (vignette1 = checklist1) i.case_code, vce(cluster facilitycode) first
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    estat firststage
    local f = r(singleresults)[1,4]

  reg vignette1 checklist1 i.case_code, vce(cluster facilitycode)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)'] \ [`f'] \ [e(N)]
    mat results_STARS = results_STARS \ [`r(p)'] \ [0] \ [0] \ [0]

  // Summary
  su treat_correct
    mat results = results \ [`r(mean)']
  su vignette1
    mat results = results \ [`r(mean)']
  mat results_STARS = results_STARS \ [0] \ [0]

  mat all = all , results
  mat all_STARS = all_STARS , results_STARS

// China
cap mat drop results results_STARS
use "${git}/constructed/sp-vignette.dta" if study == "China"  , clear

    // Full sample OLS
    reg treat_correct vignette1 i.case_code , vce(bootstrap, strata(study) cluster(facilitycode) reps(100))
      regstack
      mat results = [`r(b)'] \ [`r(se)'] \ [.] \ [.] \ [.] \ [.] \ [.] \ [.] \ [e(N)] \[.] \ [.] \ [.] \ [.] \ [.] \ [.] \ [.]
      mat results_STARS = [`r(p)'] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0] \ [0]

  // NO GMM

  // IV Linear
  ivregress 2sls treat_correct (vignette1 = checklist1) i.case_code, vce(cluster facilitycode) first
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    estat firststage
    local f = r(singleresults)[1,4]

  reg vignette1 checklist1 i.case_code, vce(cluster facilitycode)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)'] \ [`f'] \ [e(N)]
    mat results_STARS = results_STARS \ [`r(p)'] \ [0] \ [0] \ [0]

  // Summary
  su treat_correct
    mat results = results \ [`r(mean)']
  su vignette1
    mat results = results \ [`r(mean)']
  mat results_STARS = results_STARS \ [0] \ [0]

  mat all = all , results
  mat all_STARS = all_STARS , results_STARS

// Export

  outwrite all using "${git}/outputs/tab3-gmm.xlsx" ///
  , replace format(%9.3f) ///
    colnames("MP \\ Full Sample" "MP \\ Two Reports \\ (Checklist)" "MP \\ Two Reports \\ (Second Report)" ///
             "Birbhum \\ (Checklist)" "Birbhum \\ (Second Report)" "Delhi" "China") ///
    rownames("OLS" "" "Average" "" "Maximum" "" "Bollinger" "" "N" ///
             "GMM" "" "OLS (Lower)" "" "IV (Upper)" "" "N" ///
             "IV Linear" "" "First Stage" "" "F-Statistic" "N" ///
             "SP Mean" "Vignette Mean")

//
