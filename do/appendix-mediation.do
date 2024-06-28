
// Table X: Mediation and Decomposition
cap mat drop results1
cap mat drop results1_STARS
cap mat drop results2
cap mat drop results2_STARS
cap mat drop results
cap mat drop results_STARS

use "${git}/constructed/sp-birbhum.dta" , clear

  drop if case_code > 3

  gen control = 1 - treatment

  // Correct
  foreach var in checklist time {

    mediate (treat_correct i.case_code i.block prov_age prov_male) ///
            (`var' i.case_code i.block prov_age prov_male) ///
            (treatment) , vce(cluster facilitycode)

      local b = r(table)[1,3]
      local se = r(table)[2,3]
      local p = r(table)[4,3]
        local p1 0
        if `p' < 0.1 local p1 1
        if `p' < 0.05 local p1 2
        if `p' < 0.01 local p1 3
      local e = r(table)[1,1]
      local ese = r(table)[2,1]
      local ep = r(table)[4,1]
        local p2 0
        if `ep' < 0.1 local p2 1
        if `ep' < 0.05 local p2 2
        if `ep' < 0.01 local p2 3
      local c = r(table)[1,2]
      local cse = r(table)[2,2]
      local cp = r(table)[4,2]
        local p3 0
        if `cp' < 0.1 local p3 1
        if `cp' < 0.05 local p3 2
        if `cp' < 0.01 local p3 3

      mat results1 = nullmat(results1) \ [`b',`se',`e',`ese',`c',`cse']
      mat results1_STARS = nullmat(results1_STARS) \ [`p1',0,`p2',0,`p3',0]

    xi: oaxaca treat_correct `var' ///
      i.case_code i.block prov_age prov_male ///
      , by(control) cluster(facilitycode) relax

      local b = r(table)[1,3]
      local se = r(table)[2,3]
      local p = r(table)[4,3]
        local p1 0
        if `p' < 0.1 local p1 1
        if `p' < 0.05 local p1 2
        if `p' < 0.01 local p1 3
      local e = r(table)[1,7]
      local ese = r(table)[2,7]
      local ep = r(table)[4,7]
        local p2 0
        if `ep' < 0.1 local p2 1
        if `ep' < 0.05 local p2 2
        if `ep' < 0.01 local p2 3
      local c = r(table)[1,14]
      local cse = r(table)[2,14]
      local cp = r(table)[4,14]
        local p3 0
        if `cp' < 0.1 local p3 1
        if `cp' < 0.05 local p3 2
        if `cp' < 0.01 local p3 3

      mat results2 = nullmat(results2) \ [`b',`se',`e',`ese',`c',`cse']
      mat results2_STARS = nullmat(results2_STARS) \ [`p1',0,`p2',0,`p3',0]

  }

  // Price
  foreach var in checklist time {

    mediate (fee_total_usd i.case_code i.block prov_age prov_male) ///
            (`var' i.case_code i.block prov_age prov_male) ///
            (treatment) , vce(cluster facilitycode)

      local b = r(table)[1,3]
      local se = r(table)[2,3]
      local p = r(table)[4,3]
        local p1 0
        if `p' < 0.1 local p1 1
        if `p' < 0.05 local p1 2
        if `p' < 0.01 local p1 3
      local e = r(table)[1,1]
      local ese = r(table)[2,1]
      local ep = r(table)[4,1]
        local p2 0
        if `ep' < 0.1 local p2 1
        if `ep' < 0.05 local p2 2
        if `ep' < 0.01 local p2 3
      local c = r(table)[1,2]
      local cse = r(table)[2,2]
      local cp = r(table)[4,2]
        local p3 0
        if `cp' < 0.1 local p3 1
        if `cp' < 0.05 local p3 2
        if `cp' < 0.01 local p3 3

      mat results1 = nullmat(results1) \ [`b',`se',`e',`ese',`c',`cse']
      mat results1_STARS = nullmat(results1_STARS) \ [`p1',0,`p2',0,`p3',0]

    xi: oaxaca fee_total_usd `var' ///
      i.case_code i.block prov_age prov_male ///
      , by(control) cluster(facilitycode) relax

      local b = r(table)[1,3]
      local se = r(table)[2,3]
      local p = r(table)[4,3]
        local p1 0
        if `p' < 0.1 local p1 1
        if `p' < 0.05 local p1 2
        if `p' < 0.01 local p1 3
      local e = r(table)[1,7]
      local ese = r(table)[2,7]
      local ep = r(table)[4,7]
        local p2 0
        if `ep' < 0.1 local p2 1
        if `ep' < 0.05 local p2 2
        if `ep' < 0.01 local p2 3
      local c = r(table)[1,14]
      local cse = r(table)[2,14]
      local cp = r(table)[4,14]
        local p3 0
        if `cp' < 0.1 local p3 1
        if `cp' < 0.05 local p3 2
        if `cp' < 0.01 local p3 3

      mat results2 = nullmat(results2) \ [`b',`se',`e',`ese',`c',`cse']
      mat results2_STARS = nullmat(results2_STARS) \ [`p1',0,`p2',0,`p3',0]

  }


mat results = results1' \ results2'
mat results_STARS = results1_STARS' \ results2_STARS'

outwrite results using "${git}/outputs/a-mediation.xlsx" , replace ///
  rownames("Total Effect" " " "Mediated" " " "Remainder" " " "Oaxaca Difference" " " "From Endowment Change" " " "From Coefficient Change" " ") ///
  colnames("Correct \\ via Checklist" "Correct \\ via Time" ///
           "Fees (USD) \\ via Checklist" "Fees (USD) \\ via Time" )

outwrite results using "${git}/outputs/a-mediation.tex" , replace ///
 rownames("Total Effect" " " "Mediated" " " "Remainder" " " "Oaxaca Difference" " " "From Endowment Change" " " "From Coefficient Change" " ") ///
 colnames("Correct \\ via Checklist" "Correct \\ via Time" ///
          "Fees (USD) \\ via Checklist" "Fees (USD) \\ via Time" )

// End
