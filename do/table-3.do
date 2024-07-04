//

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

// OLS
use "${git}/constructed/sp-vignette.dta" , clear

  replace vignette1 = vignette2 if vignette2 != .

  reg treat_correct vignette1 i.case_code if study == "MP" & tworeports == 1 , cl(facilitycode)
    est sto mp
    su treat_correct if e(sample)
      estadd scalar sp = r(mean) : mp
    su vignette1 if e(sample)
      estadd scalar vig = r(mean) : mp

  reg treat_correct vignette1 i.case_code if study == "Birbhum" & tworeports == 1 , cl(facilitycode)
    est sto bi
    su treat_correct if e(sample)
      estadd scalar sp = r(mean) : bi
    su vignette1 if e(sample)
      estadd scalar vig = r(mean) : bi

  reg treat_correct vignette1 if study == "Delhi" , cl(facilitycode)
    est sto de
    su treat_correct if e(sample)
      estadd scalar sp = r(mean) : de
    su vignette1 if e(sample)
      estadd scalar vig = r(mean) : de

  reg treat_correct vignette1  if study == "China" , cl(facilitycode)
    est sto ch
    su treat_correct if e(sample)
      estadd scalar sp = r(mean) : ch
    su vignette1 if e(sample)
      estadd scalar vig = r(mean) : ch

  outwrite mp bi de ch using "${git}/outputs/tab3-gmm-1.tex" ///
  , replace format(%9.3f) stats(N r2 sp vig) drop(i.case_code) ///
    colnames("Madhya Pradesh" "Birbhum" "Delhi" "China") ///
    rownames("Most Recent Vignette" "" "Constant" "" "Observations" "Regression R2" "SP Correct Mean" "Vignettes Correct Mean")

// Nonparametric

  // Clear matrices

  cap mat drop results results_STARS result result_STARS

  // MP Two Reports w/Checklist
  cap mat drop results results_STARS
  use "${git}/constructed/sp-vignette.dta" if study == "MP" & tworeports == 1 , clear

    reg treat_correct avg i.case_code , cl(facilitycode)
      regstack
      mat results = [`r(b)'] \ [`r(se)']
      mat results_STARS = [`r(p)'] \ [0]

    reg treat_correct max i.case_code , cl(facilitycode)
      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    reg treat_correct bol bol1 i.case_code , cl(facilitycode)
      local n = e(N)
      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

      mat result = results
      mat result_STARS = results

  // Birbhum Two Reports w/Checklist
  cap mat drop results results_STARS
  use "${git}/constructed/sp-vignette.dta" if study == "Birbhum" & tworeports == 1 , clear

    // Full sample OLS

    reg treat_correct avg i.case_code , vce(robust)
      regstack
      mat results = [`r(b)'] \ [`r(se)']
      mat results_STARS = [`r(p)'] \ [0]

    reg treat_correct max i.case_code , vce(robust)
      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    reg treat_correct bol bol1 i.case_code , vce(robust)
      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

    mat result = result,results
    mat result_STARS = result_STARS,results_STARS

      mat x1 = J(rowsof(result),colsof(result),.)
      mat x2 = J(rowsof(result),colsof(result),0)

      mat result = result,x1
      mat result_STARS = result_STARS,x2

    outwrite result using "${git}/outputs/tab3-gmm-2.tex" ///
    , replace format(%9.3f) ///
      colnames("Madhya Pradesh" "Birbhum" "" "") ///
      rownames("Average Vignette" "" "Maximum Vignette" "" "Both Vignettes Correct" "")

// Nonparametric

  // Clear matrices

  cap mat drop results results_STARS result result_STARS

  // MP Two Reports w/Checklist
    cap mat drop results results_STARS
    use "${git}/constructed/sp-vignette.dta" if study == "MP" & tworeports == 1 , clear

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
        mat results = [`r(b)'] \ [`r(se)']
        mat results_STARS = [`r(p)'] \ [0]

    // IV Linear
    ivregress 2sls treat_correct (vignette2 = vignette1) i.case_code, vce(cluster facilitycode) first
      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

      estat firststage
      local f = r(singleresults)[1,4]

    reg vignette2 vignette1 i.case_code, vce(cluster facilitycode)
      regstack
      mat results = results \ [`r(b)'] \ [`r(se)'] \ [`f']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0] \ [0]

    // Summary

    mat result = results
    mat result_STARS = results_STARS

  // Birbhum Two Reports w/Checklist
  cap mat drop results results_STARS
  use "${git}/constructed/sp-vignette.dta" if study == "Birbhum" & tworeports == 1 , clear

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
        mat results = [`r(b)'] \ [`r(se)']
        mat results_STARS = [`r(p)'] \ [0]

    // IV Linear
    ivregress 2sls treat_correct (vignette2 = vignette1) i.case_code, vce(cluster facilitycode) first
      regstack
      mat results = results \ [`r(b)'] \ [`r(se)']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0]

      estat firststage
      local f = r(singleresults)[1,4]

    reg vignette2 vignette1 i.case_code, vce(cluster facilitycode)
      regstack
      mat results = results \ [`r(b)'] \ [`r(se)'] \ [`f']
      mat results_STARS = results_STARS \ [`r(p)'] \ [0] \ [0]

    // Summary

    mat result = result , results
    mat result_STARS = result_STARS , results_STARS

    mat x1 = J(rowsof(result),colsof(result),.)
    mat x2 = J(rowsof(result),colsof(result),0)

    mat result = result,x1
    mat result_STARS = result_STARS,x2

// Export

  outwrite result using "${git}/outputs/tab3-gmm-3.tex" ///
  , replace format(%9.3f) ///
    colnames("Madhya Pradesh" "Birbhum" "" "") ///
    rownames("GMM Two Vignettes" "" ///
             "IV First Vignette" "" "IV First Stage" "" "IV F-Statistic")

//
