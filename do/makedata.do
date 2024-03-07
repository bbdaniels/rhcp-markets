// Figure 1: know-do gaps

use "${git}/data/knowdo_data.dta", clear
replace type_code = 1 if type_code == 2 & inlist(study_code, 3,4)
drop if type_code == 2
keep if inlist(study_code, 1,3,4,6)
  gen vignette = type_code != 1
  lab def vignette 1 "Do (SP)" 0 "Know (Vignette)"
  lab val vignette vignette


gen st = 1 if study_code == 6 // "Madhya Pradesh"
replace st = 2 if study_code == 1 // "Birbhum C"
replace st = 3 if study_code == 4 //"Delhi"
replace st = 4 if study_code == 3 // "China"
la def slab 1 "Madhya Pradesh" 2 "Birbhum" 3 "Delhi" 4 "China"
la val st slab

gen correct = (treat_type1 == 1 | treat_type1 == 2)
  lab def correct 0 "Incorrect" 1 "Correct"
  lab val correct correct


gen s = 1 if st == 1 & private == 0 // MP Public
replace s = 2 if st == 1 & private == 1 & prov_qual == 0 // MP Private unqualified
replace s = 3 if st == 1 & private == 1 & prov_qual == 1 // MP Private unqualified
replace s = 4 if st == 2 // Birbhum
replace s = 5 if st == 3 & private == 1 & prov_qual == 0 // Delhi Private unqualified
replace s = 6 if st == 3 & private == 1 & prov_qual == 1 // Delhi Private qualified
replace s = 7 if st == 4 // China

lab def s ///
  1 "MP Public" ///
  2 "MP Private Untrained" ///
  3 "MP Private Trained" ///
  4 "Birbhum Private Untrained" ///
  5 "Delhi Private Untrained" ///
  6 "Delhi Private Trained" ///
  7 "China Public"

  lab val s s
  ren s strata

  keep strata correct vignette

  save "${git}/constructed/knowdo.dta", replace




// End
