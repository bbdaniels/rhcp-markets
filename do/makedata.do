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

// Figure 2: Excess capacity

  use "${git}/data/MP_DataSet_EconPaper.dta", clear
    keep finprovid finclinid facilitycode
    tostring facilitycode, replace
    duplicates drop
    tempfile mpids
    save `mpids', replace

	use "${git}/data/maqari_pope.dta", clear
    keep if public == 0
    merge m:1 finprovid finclinid using `mpids'
    drop if _merge==2
    drop _merge
    tostring facilitycode, replace
    replace facilitycode = "MA_"+facilitycode

    gen n = 1

    collapse (sum) po_time n , by(facilitycode)
    gen study = 1
    save `mpids', replace

  use "${git}/data/Birbhum_pope.dta", clear
    gen n = 1
    collapse (sum) po_time = po_timetot n , by(providerid)
    ren providerid facilitycode
    tostring facilitycode, replace
    gen study = 2

    append using `mpids'

    lab def study 1 "Madhya Pradesh" 2 "Birbhum"
    lab val study study

    replace po_time = 1 if po_time < 1

  save "${git}/constructed/pope-time.dta", replace


// End
