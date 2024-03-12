// Table 1

  use "${git}/constructed/sp-summary.dta" , clear

  collect: table study, ///
    statistic(mean  treat_any1 treat_correct1 treat_over1 treat_under1 med_anti_nodys med_steroid_noast treat_refer) ///
    statistic(freq) nformat(%9.0f freq) nformat(%9.3f mean)

  collect export "${git}/outputs/tab1-summary.tex", replace tableonly
  collect export "${git}/outputs/tab1-summary.pdf", replace 



// End
