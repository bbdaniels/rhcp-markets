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

// MP Two Reports w/Checklist
cap mat drop results results_STARS
use "${git}/constructed/sp-vignette.dta" if study == "MP" & tworeports == 1 , clear

  // Full sample OLS
  reg treat_correct vignette2 i.case_code , vce(robust)
    regstack
    mat results = [`r(b)'] \ [`r(se)']
    mat results_STARS = [`r(p)'] \ [0]

  reg treat_correct avg i.case_code , vce(robust)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  reg treat_correct max i.case_code , vce(robust)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  reg treat_correct bol bol1 i.case_code , vce(robust)
    local n = e(N)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  // GMM
    gen case2 = case_code == 2
    gen case3 = case_code == 3
    gen anycov = vignette2

    global x "case2 case3" // Independent variables
  	global t "anycov" // Endogenous treatment
  	global z "vignette1" // Instrument
  	global y "treat_correct" // Outcome variable
  	global q=5 // Percentile for bounding
  	gen weight=1
  	global wt "weight"
  	global clust "facilitycode"

  	keep $x $t $z $y $wt $clust case_code  vignette2
  	qui do "${git}/do/fs-gmm.do"

      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  // IV Linear
  ivregress 2sls treat_correct (vignette2 = vignette1) i.case_code, vce(cluster facilitycode) first
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    estat firststage
    local f = r(singleresults)[1,4]

  reg vignette2 vignette1 i.case_code, vce(cluster facilitycode)
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


// Birbhum Two Reports w/Checklist
cap mat drop results results_STARS
use "${git}/constructed/sp-vignette.dta" if study == "Birbhum" & tworeports == 1 , clear

  // Full sample OLS
  reg treat_correct vignette2 i.case_code , vce(robust)
    regstack
    mat results = [`r(b)'] \ [`r(se)']
    mat results_STARS = [`r(p)'] \ [0]

  reg treat_correct avg i.case_code , vce(robust)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  reg treat_correct max i.case_code , vce(robust)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  reg treat_correct bol bol1 i.case_code , vce(robust)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  // GMM
    gen case2 = case_code == 2
    gen case3 = case_code == 3
    gen anycov = vignette2

    global x "case2 case3" // Independent variables
  	global t "anycov" // Endogenous treatment
  	global z "vignette1" // Instrument
  	global y "treat_correct" // Outcome variable
  	global q=5 // Percentile for bounding
  	gen weight=1
  	global wt "weight"
  	global clust "facilitycode"

  	keep $x $t $z $y $wt $clust case_code  vignette2
  	qui do "${git}/do/fs-gmm.do"

      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

  // IV Linear
  ivregress 2sls treat_correct (vignette2 = vignette1) i.case_code, vce(cluster facilitycode) first
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)']
    mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    estat firststage
    local f = r(singleresults)[1,4]

  reg vignette2 vignette1 i.case_code, vce(cluster facilitycode)
    regstack
    mat results = results \ [`r(b)'] \ [`r(se)'] \ [`f'] \ [e(N)]
    mat results_STARS = results_STARS \ [`r(p)'] \ [0] \ [0] \ [0]

  // Summary
  su treat_correct
    mat results = results \ [`r(mean)']
  su vignette2
    mat results = results \ [`r(mean)']
  mat results_STARS = results_STARS \ [0] \ [0]

  mat all = all , results
  mat all_STARS = all_STARS , results_STARS

// Export

  outwrite all using "${git}/outputs/tab3-gmm.xlsx" ///
  , replace format(%9.3f) ///
    colnames("MP (Second Report)" "Birbhum (Second Report)" ) ///
    rownames("OLS" "" "Average" "" "Maximum" "" "Bollinger" "" ///
             "GMM" "" ///
             "IV Linear" "" "IV First Stage" "" "IV F-Statistic" "Observations" ///
             "SP Correct Mean" "Endline Vignette Mean")

  outwrite all using "${git}/outputs/tab3-gmm.tex" ///
  , replace format(%9.3f) ///
    colnames("MP (Second Report)" "Birbhum (Second Report)" ) ///
    rownames("OLS" "" "Average" "" "Maximum" "" "Bollinger" "" ///
             "GMM" "" ///
             "IV Linear" "" "IV First Stage" "" "IV F-Statistic" "Observations" ///
             "SP Correct Mean" "Endline Vignette Mean")

//
