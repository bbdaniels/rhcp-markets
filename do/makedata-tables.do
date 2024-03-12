// Table 1

  use "${git}/data/knowdo_data.dta" if type_code == 3, clear
    drop if study == "Birbhum T"
    replace study = "Birbhum" if strpos(study,"Birbhum" )
    replace study = "MP" if strpos(study,"Madhya" )

    keep study treat_any1 treat_correct1 treat_over1 treat_under1 med_anti_nodys med_steroid_noast treat_refer
      lab var treat_any1 "Any Correct"
      lab var treat_correct1 "Correct"
      lab var treat_over1 "Overtreat"
      lab var treat_under1 "Incorrect"
      lab var med_anti_nodys "Antibiotics"
      lab var med_steroid_noast "Steroids"
      lab var treat_refer "Referred"

  save "${git}/constructed/sp-summary.dta" , replace



// End
