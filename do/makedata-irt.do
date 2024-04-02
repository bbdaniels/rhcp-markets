//

use "${git}/data/birbhum_sp.dta" , clear
append using "${git}/data/birbhum_vig.dta"
  gen tc = 1 if strpos(type,"Baseline")
  replace tc = 2 if strpos(type,"Endline")
  replace tc = 3 if tc == .

  keep tc providerid sp_??_?? sp_??_???
   drop sp_dy_ors sp_mi_e7 sp_mi_e8 sp_dy_h15 sp_dy_h16 sp_as_e8

  collapse (firstnm) sp* , by(tc providerid)

  irt 2pl sp*

  predict irt, latent

  keep irt providerid tc
  reshape wide irt , i(providerid) j(tc)

  gen facilitycode = "BI_" + string(providerid)
  ren irt3 irt

  save "${git}/constructed/birbhum_irt.dta" , replace




//
