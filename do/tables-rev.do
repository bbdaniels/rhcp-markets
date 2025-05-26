************************************************************************
* do file : tab1_excel.do
* Purpose : Build Table 1 Panels A & B in one Excel with:
*           – one row per site
*           – N as its own column
*           – cells formatted as mean (SE)
*           – includes Refusal and Refer columns
************************************************************************

* 0) define paths ================================================


*========================================================================*
* PANEL A: Private sector → sheet "Private"                             *
*========================================================================*

***** A.2) Main sample **************************************************
use "/Users/devakid/Library/CloudStorage/Box-Box/Jishnu/Health/rhcp-markets/constructed/sp-summary.dta", clear

   replace study = "MP Public" if study == "MP" & private == 0
   replace study = "Kenya Public" if study == "Kenya" & private == 0

    drop if strpos(study,"Public") | strpos(study,"China")
	
	replace study = "Madhya Pradesh" if study == "MP"

  *– collapse main stats –*
  collapse                                 ///
     (mean)   m_any    = treat_any1       ///
     (sd)     sd_any   = treat_any1       ///
     (mean)   m_corr   = treat_correct1   ///
     (sd)     sd_corr  = treat_correct1   ///
     (mean)   m_over   = treat_over1      ///
     (sd)     sd_over  = treat_over1      ///
     (mean)   m_inc    = treat_under1     ///
     (sd)     sd_inc   = treat_under1     ///
     (mean)   m_ref    = treat_refer      ///
     (sd)     sd_ref   = treat_refer      ///
     (mean)   m_anti   = med_anti_nodys   ///
     (sd)     sd_anti  = med_anti_nodys   ///
     (mean)   m_ster   = med_steroid_noast ///
     (sd)     sd_ster  = med_steroid_noast ///
     (count)  N        = treat_any1       ///
	 (count)  N_anti   = med_anti_nodys	  ///
	 (count)  N_ster   = med_steroid_noast ///
	 (count)  N_refer  = treat_refer		///
    , by(study)

  *– compute SEs –*
  foreach v in any corr over inc {
      gen se_`v' = sd_`v' / sqrt(N)
  }
  
  gen se_anti = sd_anti / sqrt(N_anti)
  gen se_ster = sd_ster / sqrt(N_ster)
  gen se_ref = sd_ref / sqrt(N_refer)
    
foreach v in any corr over inc ref anti ster {
  gen str cell_`v' = ///
    string(round(m_`v',.01),"%4.2f") + char(13)+char(10) + ///
    "(" + string(round(se_`v',.01),"%4.2f") + ")"
}


  tempfile mainA
  save "`mainA'", replace


***** A.3) Merge + export to Excel – sheet "Private" *********************
use "`mainA'", clear
* merge 1:1 study using "`refA'"
* assert _merge==3
* drop _merge sd_* n_refuse

*– keep & order –*
keep study N cell_any cell_corr cell_over cell_inc cell_anti cell_ster cell_ref
order study N cell_any cell_corr cell_over cell_inc cell_anti cell_ster cell_ref


*– write sheet "Private" –*
putexcel set "/Users/devakid/Desktop/tab1.xlsx", replace sheet("Private")
putexcel A1=("Site") B1=("N")     ///
         C1=("Any Correct") D1=("Correct") E1=("Overtreat") ///
         F1=("Incorrect")   G1=("Refer") H1=("Antibiotics (Ex. Diarrhea)") ///
         I1=("Steroids (Ex. Asthma)")

local n = _N
forvalues i = 1/`n' {
    local row = `i' + 1
    putexcel A`row'=study[`i']       B`row'=N[`i']         ///
             C`row'=cell_any[`i'] D`row'=cell_corr[`i'] ///
             E`row'=cell_over[`i']   F`row'=cell_inc[`i'] ///
             G`row'=cell_ref[`i']    H`row'=cell_anti[`i'] ///
             I`row'=cell_ster[`i']  
}

*========================================================================*
* PANEL B: Public sector & China → sheet "Public"                        *
*========================================================================*

***** B.2) Main sample ***********************************************
use "/Users/devakid/Library/CloudStorage/Box-Box/Jishnu/Health/rhcp-markets/constructed/sp-summary.dta", clear

    replace study = "MP Public" if study == "MP" & private == 0
    replace study = "Kenya Public" if study == "Kenya" & private == 0

    keep if strpos(study,"Public") | strpos(study,"China")
	
	replace study = "Kenya" if study == "Kenya Public"
	replace study = "Madhya Pradesh" if study == "MP Public"

  collapse                                 ///
     (mean)   m_any    = treat_any1       ///
     (sd)     sd_any   = treat_any1       ///
     (mean)   m_corr   = treat_correct1   ///
     (sd)     sd_corr  = treat_correct1   ///
     (mean)   m_over   = treat_over1      ///
     (sd)     sd_over  = treat_over1      ///
     (mean)   m_inc    = treat_under1     ///
     (sd)     sd_inc   = treat_under1     ///
     (mean)   m_ref    = treat_refer      ///
     (sd)     sd_ref   = treat_refer      ///
     (mean)   m_anti   = med_anti_nodys   ///
     (sd)     sd_anti  = med_anti_nodys   ///
     (mean)   m_ster   = med_steroid_noast ///
     (sd)     sd_ster  = med_steroid_noast ///
     (count)  N        = treat_any1       ///
	 (count)  N_anti   = med_anti_nodys	  ///
	 (count)  N_ster   = med_steroid_noast ///
	 (count)  N_refer  = treat_refer		///
    , by(study)

  *– compute SEs –*
  foreach v in any corr over inc {
      gen se_`v' = sd_`v' / sqrt(N)
  }
  
  gen se_anti = sd_anti / sqrt(N_anti)
  gen se_ster = sd_ster / sqrt(N_ster)
  gen se_ref = sd_ref / sqrt(N_refer)

  foreach v in any corr over inc ref anti ster {
      gen str cell_`v' = ///
          string(round(m_`v', .01), "%4.2f") + " (" + ///
          string(round(se_`v', .01), "%4.2f") + ")"
  }
  tempfile mainB
  save "`mainB'", replace


***** B.3) Merge + export to Excel – sheet "Public" ******************
use "`mainB'", clear
*merge 1:1 study using "`refB'"
*assert _merge==3
*drop _merge sd_* n_refuse

keep study N cell_any cell_corr cell_over cell_inc cell_anti cell_ster cell_ref
order study N cell_any cell_corr cell_over cell_inc cell_anti cell_ster cell_ref

putexcel set "/Users/devakid/Desktop/tab1.xlsx", modify sheet("Public")
putexcel A1=("Site")     B1=("N")  C1=("Any Correct") D1=("Correct") ///
		 E1=("Overtreat") F1=("Incorrect") G1=("Refer")  ///
		 H1=("Antibiotics (Ex. Diarrhea)") I1=("Steroids (Ex. Asthma)") 

forvalues i = 1/`=_N' {
    local row = `i' + 1
    putexcel A`row'=study[`i']       B`row'=N[`i']         ///
             C`row'=cell_any[`i'] ///
             D`row'=cell_corr[`i']   E`row'=cell_over[`i'] ///
             F`row'=cell_inc[`i']    G`row'=cell_ref[`i'] ///
			 H`row'=cell_anti[`i']   I`row'=cell_ster[`i']   
}

************************************************************************
* End of tab1-rev.do
************************************************************************

************************************************************************
* Start of tab2-rev.do
************************************************************************

*========================================================================*
* PANEL A: Private sector → sheet "Private"                             *
*========================================================================*

	use "/Users/devakid/Library/CloudStorage/Box-Box/Jishnu/Health/rhcp-markets/constructed/sp-summary.dta", clear

	replace study = "MP Public" if study == "MP" & private == 0
	replace study = "Kenya Public" if study == "Kenya" & private == 0
  
	drop if strpos(study,"Public") | strpos(study,"China")
   
	replace study = "Madhya Pradesh" if study == "MP Public"

  *– collapse main stats –*
  collapse                                 ///
     (mean)   m_tot    = cost_total_usd       ///
     (sd)     sd_tot   = cost_total_usd       ///
     (mean)   m_cons   = cost_consult_usd   ///
     (sd)     sd_cons  = cost_consult_usd   ///
     (mean)   m_meds   = cost_meds_usd      ///
     (sd)     sd_meds  = cost_meds_usd      ///
     (mean)   m_unnec  = cost_unnec1_usd     ///
     (sd)     sd_unnec = cost_unnec1_usd     ///
     (mean)   m_f_a    = frac_avoid      ///
     (sd)     sd_f_a   = frac_avoid      ///
     (mean)   m_f_a1   = frac_avoid1   ///
     (sd)     sd_f_a1   = frac_avoid1   ///
     (mean)   m_f_a2   = frac_avoid2 ///
     (sd)     sd_f_a2   = frac_avoid2 ///
     (count)  N_tot    = cost_total_usd       ///
	 (count)  N_cons   = cost_consult_usd	  ///
	 (count)  N_meds   = cost_meds_usd ///
	 (count)  N_unnec  = cost_unnec1_usd		///
	 (count)  N_f_a    = frac_avoid	  ///
	 (count)  N_f_a1   = frac_avoid1 ///
	 (count)  N_f_a2   = frac_avoid2 ///
		, by(study)	
	
	gen se_tot   = sd_tot   / sqrt(N_tot)
	gen se_cons = sd_cons / sqrt(N_cons)
	gen se_meds    = sd_meds    / sqrt(N_meds)
	gen se_unnec   = sd_unnec   / sqrt(N_unnec)
	gen se_f_a  = sd_f_a   / sqrt(N_f_a)
	gen se_f_a1  = sd_f_a1  / sqrt(N_f_a1)
	gen se_f_a2  = sd_f_a2  / sqrt(N_f_a2)
	
  foreach v in tot cons meds unnec f_a f_a1 f_a2 {
    gen str cell_`v' = ///
      string(round(m_`v',.01),"%4.2f") + char(13)+char(10) + ///
      "(" + string(round(se_`v',.01),"%4.2f") + ")"
  }

  tempfile mainA
  save "`mainA'", replace

*— Export Private panel to Excel ——————————————————————*
use "`mainA'", clear
putexcel set "/Users/devakid/Desktop/tab2.xlsx", replace sheet("Private")
putexcel A1=("Site")         B1=("N")          ///
         C1=("Total Price (USD)")    D1=("Consult (USD)") ///
         E1=("Medicine (USD)")      F1=("Avoidable (USD)")  ///
         G1=("Avoidable Total (%)")       H1=("Avoidable Overtreatment (%)") ///
         I1=("Avoidable Incorrect (%)")

local rows = _N
forvalues i = 1/`rows' {
  local r = `i' + 1
  putexcel A`r'=study[`i']        B`r'=N_tot[`i']      ///
           C`r'=cell_tot[`i']  D`r'=cell_cons[`i'] ///
           E`r'=cell_meds[`i']    F`r'=cell_unnec[`i']   ///
           G`r'=cell_f_a[`i']   H`r'=cell_f_a1[`i']  ///
           I`r'=cell_f_a2[`i']
}
  
*========================================================================*
* PANEL B: Public sector → sheet "Public"                             *
*========================================================================*

	use "/Users/devakid/Library/CloudStorage/Box-Box/Jishnu/Health/rhcp-markets/constructed/sp-summary.dta", clear

	replace study = "MP Public" if study == "MP" & private == 0
	replace study = "Kenya Public" if study == "Kenya" & private == 0
  
	keep if strpos(study,"Public") | strpos(study,"China")
   
	replace study = "Madhya Pradesh" if study == "MP Public"
	replace study = "Kenya" if study == "Kenya Public"

  *– collapse main stats –*
  collapse                                 ///
     (mean)   m_tot    = cost_total_usd       ///
     (sd)     sd_tot   = cost_total_usd       ///
     (mean)   m_cons   = cost_consult_usd   ///
     (sd)     sd_cons  = cost_consult_usd   ///
     (mean)   m_meds   = cost_meds_usd      ///
     (sd)     sd_meds  = cost_meds_usd      ///
     (mean)   m_unnec  = cost_unnec1_usd     ///
     (sd)     sd_unnec = cost_unnec1_usd     ///
     (mean)   m_f_a    = frac_avoid      ///
     (sd)     sd_f_a   = frac_avoid      ///
     (mean)   m_f_a1   = frac_avoid1   ///
     (sd)     sd_f_a1   = frac_avoid1   ///
     (mean)   m_f_a2   = frac_avoid2 ///
     (sd)     sd_f_a2   = frac_avoid2 ///
     (count)  N_tot    = cost_total_usd       ///
	 (count)  N_cons   = cost_consult_usd	  ///
	 (count)  N_meds   = cost_meds_usd ///
	 (count)  N_unnec  = cost_unnec1_usd		///
	 (count)  N_f_a    = frac_avoid	  ///
	 (count)  N_f_a1   = frac_avoid1 ///
	 (count)  N_f_a2   = frac_avoid2 ///
		, by(study)	
	
	gen se_tot   = sd_tot   / sqrt(N_tot)
	gen se_cons = sd_cons / sqrt(N_cons)
	gen se_meds    = sd_meds    / sqrt(N_meds)
	gen se_unnec   = sd_unnec   / sqrt(N_unnec)
	gen se_f_a  = sd_f_a   / sqrt(N_f_a)
	gen se_f_a1  = sd_f_a1  / sqrt(N_f_a1)
	gen se_f_a2  = sd_f_a2  / sqrt(N_f_a2)
	
  foreach v in tot cons meds unnec f_a f_a1 f_a2 {
    gen str cell_`v' = ///
      string(round(m_`v',.01),"%4.2f") + char(13)+char(10) + ///
      "(" + string(round(se_`v',.01),"%4.2f") + ")"
  }

  tempfile mainA
  save "`mainA'", replace

*— Export Private panel to Excel ——————————————————————*
use "`mainA'", clear
putexcel set "/Users/devakid/Desktop/tab2.xlsx", modify sheet("Public")
putexcel A1=("Site")         B1=("N")          ///
         C1=("Total Price (USD)")    D1=("Consult (USD)") ///
         E1=("Medicine (USD)")      F1=("Avoidable (USD)")  ///
         G1=("Avoidable Total (%)")       H1=("Avoidable Overtreatment (%)") ///
         I1=("Avoidable Incorrect (%)")

local rows = _N
forvalues i = 1/`rows' {
  local r = `i' + 1
  putexcel A`r'=study[`i']        B`r'=N_tot[`i']      ///
           C`r'=cell_tot[`i']  D`r'=cell_cons[`i'] ///
           E`r'=cell_meds[`i']    F`r'=cell_unnec[`i']   ///
           G`r'=cell_f_a[`i']   H`r'=cell_f_a1[`i']  ///
           I`r'=cell_f_a2[`i']
}
 