

* ****************************************************************** *
* xtoaxaca bootstrap  container file ******************************* *
* ****************************************************************** *
* For more information on the actual decomposition, see xtoaxaca_prog
*! version 0.12.0 January 5, 2020
cap program drop xtoaxaca
program define xtoaxaca, eclass
	version 14.1

	syntax [varlist] [if] [in], [groupvar(varname)]       ///
                                [groupcat(string)]        ///
                                [timevar(varname)]        ///
                                [times(numlist)]          ///
                                [timeref(string)]         ///
                                [timebandwidth(string)]   ///
                                [model(name)]             ///
                                [basemodel(name)]         ///
                                [weights(string)]         ///
                                [change(string)]          ///
                                [normalize(varlist)]      ///
                                [NOISily]                 ///
                                [DETail]                  ///
                                [forcesample]             ///
                                [twofold(string)]         ///
                                [resultsdata(string)]     ///
								[blocks(string)]          ///
                                [tfweight(string)]        ///
                                [fmt(string)]             ///
                                [NOLEVels] [NOCHange]     ///
                                [seed(string)]            ///
                                [bootstrap(string)]  
	
	tempname b V bb VV dec_b dec_V decomp_levels decomp_change decomp_names varlabel_levels varlabel_change refcat_levels refcat_change
	                   
    di as text "{bf:WARNING:} This is a beta version. Please check the results carefully"
	di as text "         and report bugs and suggestions to hkroeger@diw.de"
	  
	  
	  
	  ****  checking if replay is asked *****
		
	  if "`0'" == "" {
			local replay = "replay"
			foreach X in varlist groupvar groupcat timevar times model basemodel timebandwidth timeref  change forcesample normalize noisily twofold ///
			             tfweight nolevels nochange bootstrap detail fmt  seed weights resultsdata blocks {
							local `X' = e(`X')
							if "``X''" == "." {
								local `X' = ""
							}
			}
			tempname touse
			qui gen `touse' = e(sample)
			
	  }
	  else {
		marksample touse
	  }
	  
	  
	  if "`blocks'" != "" & "`detail'" == "" & "`noisily'" == "" {
		local detail "detail"
	  }
	  
	* With no bootstrap, run xtoaxaca and return estimates
	if ("`bootstrap'" == "") {
	
		
		
		
		
        xtoaxaca_prog `varlist' if `touse', groupvar(`groupvar') groupcat(`groupcat') timevar(`timevar') times(`times') ///
                                 model1(`basemodel') model2(`model') timebandwidth(`timebandwidth') timeref(`timeref') ///
                                   `nose'  resultsdata(`resultsdata') ///
                                 change(`change') `forcesample' `muh' normalize(`normalize') `noisily' ///
                                 twofold(`twofold') tfweight(`tfweight') `nolevels' `nochange' `detail'  fmt(`fmt') weights(`weights')	///
								 replay(`replay') blocks(`blocks')
	}
	
	* When bootstrap SE's are requested
	else if ("`bootstrap'" != "") {
		if "`replay'" == "" {
			dis as text "{bf:WARNING:} Bootrapping requires the original data set for estimation and the regressions need to be repeated `bootstrap' times. This may take some time."
			* Silently run bootstrap to get estimates
			
			
			
		
			
			quietly{
				xtoaxaca_prog `varlist' if `touse', groupvar(`groupvar') groupcat(`groupcat') timevar(`timevar') times(`times') ///
									 model1(`basemodel') model2(`model') timebandwidth(`timebandwidth') timeref(`timeref') ///
									  `nose'  resultsdata(`resultsdata') ///
									 change(`change') `forcesample' `muh' normalize(`normalize') `noisily' ///
									 twofold(`twofold') tfweight(`tfweight') `nolevels' `nochange' `detail'  fmt(`fmt') bs(0) weights(`weights') 
									 
			}
			
		
			local fmt = e(fmt)
			local refe = e(refe)
			foreach X in nolevels nochange {
				local `X' = e(`X')
				if ("``X''" == ".") {
					local `X' ""
				}
			}
			
			
			
			
			
			
			if ("`refe'" == "fe") {
				local RE "FE"
				local reff reffects
				local preff preffects
				local REFF RE
				local pREFF pRE
				local dREFF dRE
				local dpREFF dpRE
			}
			else if ("`refe'" == "re") {
				local RE "RE"
				local reff reffects
				local preff preffects
				local REFF RE
				local pREFF pRE
				local dREFF dRE
				local dpREFF dpRE
			}
			else {
				local RE ""
				local reff ""
				local preff ""
				local REFF ""
				local pREFF ""
				local dREFF ""
				local dpREFF ""
			}
	}	
			
			
		
		
			* Prepare the decomposition types for bootstrapping
			* The decomp_levels and change_levels control what appears inside the output tables
			* Attention: the order of effects matters! 
			if "`nolevels'" == "" {
				local `decomp_levels' Yobs E C CE `reff' Total pE pC pCE `preff' pTotal 

				local `varlabel_levels' Yobs "Observed" `reff' `RE' Pred "Prediction" Ym1 "Base" E "Endowments" C "Coefficients" CE "Interactions"  Total "Total" pE "Endowments" pC "Coefficients" pCE "Interactions" `preff' `RE'  pTotal "Total" 
				local `refcat_levels' Yobs "{bf:Outcome}" E "{bf:Decomp}" pE "{bf:Decomp%}", label(" ")
			}
			if ("`change'" == "interventionist") {
				
				local `decomp_mat' dE dC dCE pdE pdC pdCE
				local `decomp_change' Yobs E C CE `REFF' Total pE pC pCE `pREFF' pTotal
				local `varlabel_change' dYobs "Observed" dE "Endowments" dC "Coefficients" dCE "Interactions" `dREFF' `RE' dTotal "Total" dpE "Endowments" dpC "Coefficients" dpCE "Interactions" `dpREFF' `RE' dpTotal "Total"
				local `refcat_change' dYobs "{bf:Outcome}" dE "{bf:Decomp}" dpE "{bf:Decomp%}", label(" ")	
				
			}
			else if ("`change'" == "mpjd") {
				local `decomp_mat' mpjd_E_pure mpjd_E_price mpjd_E_total mpjd_U_pure mpjd_U_price mpjd_U_total   pmpjd_E_pure pmpjd_E_price pmpjd_E_total pmpjd_U_pure pmpjd_U_price pmpjd_U_total
				local `decomp_change' Yobs Epure Eprice ETotal Upure Uprice UTotal `REFF' Total pEpure pEprice pETotal pUpure pUprice pUTotal `pREFF' pTotal
				local `varlabel_change' dYobs "Observed" dEpure "pure" dEprice "price" dETotal "Total" dUpure "pure" dUprice "price" dUTotal "Total" `dREFF' `RE' dTotal "Total" dpEpure "pure" dpEprice "price" dpETotal "Total" dpUpure "pure" dpUprice "price" dpUTotal "Total" `dpREFF' `RE' dpTotal "Total"
					
				local `refcat_change' dYobs "{bf:Outcome}" dEpure "{bf:Expl.}" dUpure "{bf:Unexp.}" dpEpure "{bf:Expl %}" dpUpure "{bf:Unexp %}", label(" ")			
			}
			else if ("`change'" == "smithwelch") {
				local `decomp_mat' sw_i sw_ii sw_iii sw_iv psw_i psw_ii psw_iii psw_iv
				local `decomp_change' Yobs i ii iii iv `REFF' Total pi pii piii piv `pREFF' pTotal
				local `varlabel_change' dYobs "Observed" di "i" dii "ii" diii "iii" div "iv" `dREFF' `RE' dTotal "Total" dpi "i" dpii "ii" dpiii "iii" dpiv "iv" `dpREFF' `RE' dpTotal "Total"
				local `refcat_change' dYobs "{bf:Outcome}" di "{bf:Decomp}" dpi "{bf:Decomp%}", label(" ")
			}
			else if ("`change'" == "wellington") {
			    local `decomp_mat' wl_1 wl_2 pwl_1 p_wl2
				local `decomp_change' Yobs w1 w2 `REFF' wTotal pw1 pw2 `pREFF' pwTotal
				local `varlabel_change' dYobs "Observed" dw1 "1" dw2 "2" `dREFF' `RE' dwTotal "Total" dpw1 "1" dpw2 "2" `dpREFF' `RE' dpwTotal "Total"
				local `refcat_change' dYobs "{bf:Outcome}" dw1 "{bf:Decomp}" dpw1 "{bf:Decomp%}", label(" ")
			}
			
			else if ("`change'" == "kim") {
			    local `decomp_mat' kim_D1 kim_D2 kim_D3 kim_D4 kim_D5 pkim_D1 pkim_D2 pkim_D3 pkim_D4 pkim_D5
				local `decomp_change' Yobs kim_D1 kim_D2 kim_D3 kim_D4 kim_D5 `REFF' dTotal pkim_D1 pkim_D2 pkim_D3 pkim_D4 pkim_D5 `pREFF' pdTotal
				local `varlabel_change' dYobs "Observed" dkim_D1 "D1" dkim_D2 "D2" dkim_D3 "D3" dkim_D4 "D4" dkim_D5 "D5" `dREFF' `RE' ddTotal "Total" dpkim_D1 "D1" dpkim_D2 "D2" dpkim_D3 "D3" dpkim_D4 "D4" dpkim_D5 "D5" `dpREFF' `RE' dpdTotal "Total"
				local `refcat_change' dYobs "{bf:Outcome}" dkim_D1 "{bf:Decomp}" dpkim_D1 "{bf:Decomp%}", label(" ")
			}
					
			else if ("`change'" == "ssm") {
				local `decomp_mat' dE dC dCE pdE pdC pdCE
				local `decomp_change' Yobs E C CE `REFF' Total pE pC pEC `pREFF' pTotal
				local `varlabel_change' dYobs "Observed" dE "Endowments" dC "Coefficients" dCE "Interactions" `dREFF' `RE' dTotal "Total" dpE "Endowments" dpC "Coefficients" dpEC "Interactions" `dpREFF' `RE' dpTotal "Total"
				local `refcat_change' dYobs "{bf:Outcome}" dE "{bf:Decomp}" dpE "{bf:Decomp%}", label(" ")
			}
			
			
			qui: gettoken catA catB: groupcat
		
			local catB = subinstr("`catB'"," ","",1)
			local cat1 = `catA'
			local cat2 = `catB'
			
			if ("`detail'" != "")  {
				di "{hline}"
				di as text "Group variable:" _col(30) as input "`groupvar' (`catA',`catB')"
				di as text "Decomposition variables: " _col(30) as input "`varlist'"
				di as text "Times: " _col(30) as input "`timevar' (`times')"
				di "{hline}" _newline
			}
			
			* Return e results from xtoaxaca
			
			local matrices ``decomp_mat'' pCE CE pC C pE E summary_levels summary_change change_model  change_observed means_model means_observed drefmat pdrefmat cat`catA'_endow_mean cat`catB'_endow_mean cat`catA'_coef_mean cat`catB'_coef_mean refmat

			foreach m of local matrices {
				tempname `m'
				mat ``m'' = e(`m')
			}
			
			
	if "`replay'" == "" {
			* Generate scalars to be bootstrapped
			local scalars
			foreach tok of local `decomp_levels' {
				foreach time of local times {
					local scalars `scalars' levels_`tok'_`time'=e(levels_`tok'_`time')
				}
			}
			foreach tok of local `decomp_change' {
				foreach time of local times {
					local scalars `scalars' change_`tok'_`time'=e(change_`tok'_`time') 
				}
			}
			
			if "`seed'" == "" {
				local seed = c(rngstate)
			}
			
			
			
			**** sampling on panel, not observation if this is a panel regression ****
			
			if "`refe'" != "." {
				if "`e(cmd)'" == "xtreg" {
					local cluster_id `e(ivar)'
				}
				else if "`e(cmd)'" == "mixed" {
					local cluster_id `e(ivars)'
				}
				tempname cluster_id_new
				local cluster_option "cluster(`cluster_id') idcluster(`cluster_id_new')"
			}
			else {
				local cluster_option ""
			}
			
			
		
			* Run bootstrap		
			bootstrap `scalars', reps(`bootstrap') force seed(`seed') notable noheader `cluster_option' : ///
				xtoaxaca_bootstrap_wrapper `varlist' if `touse', groupvar(`groupvar') groupcat(`groupcat') timevar(`timevar') times(`times') ///
									 model1(`basemodel') model2(`model') timebandwidth(`timebandwidth') timeref(`timeref') ///
									  `nose'  resultsdata(`resultsdata') ///
									 change(`change') `forcesample' `muh' normalize(`normalize') `noisily' ///
									 twofold(`twofold') tfweight(`tfweight') `nolevels' `nochange' `detail'  fmt(`fmt') weights(`weights') ///
									 decomp_levels(``decomp_levels'') decomp_change(``decomp_change'') bs("more")
			
			
			
			
			mat `b' = e(b)
			mat `V' = e(V)
			
		}
		
		if "`replay'" == "replay" {
			* Generate output
			mat `bb' = e(dec_b)
			mat `VV' = e(dec_V)
			mat `b' = e(dec_b)
			mat `V' = e(dec_V)
			ereturn post  `bb' `VV',
		}
		
		

		xtoaxaca_helper_write_estimates, mat_b(`b') mat_v(`V') times(`times') decomp_levels(``decomp_levels'') decomp_change(``decomp_change'')
		
		
		if "``decomp_change''" != "" {
			local `decomp_names'
			foreach v of local `decomp_change' {
				local `decomp_names' ``decomp_names'' d`v'
			}
		}
		
		
		*** detail results ***
		
		* Display means and coefs matrices
    if ("`noisily'" != "" | "`detail'" != "") {
        di "{hline}"
        di "{bf:{ul:Outcome}}"
		if "`model1'" != "" & "`model1'" != "." {
			estout matrix(`means_y_base'), mlabels(Time) title("Mean predicted outcome differences between the groups (base model)") 
		}
		
		estout matrix(`means_model'), mlabels(Time) title("Mean predicted outcome differences between the groups") 
		estout matrix(`means_observed'), mlabels(Time) title("Mean predicted outcome differences between the groups (empirical values)") 
			
		di ""
		di "{bf:{ul:Endowments}}"	
		estout matrix(`cat`catA'_endow_mean'), mlabels(Time) title("Endowment means for each time (Group (`groupvar') `catA'," "variables: `varlist')") 
		estout matrix(`cat`catB'_endow_mean'), mlabels(Time) title("Endowment means for each time (Group (`groupvar') `catB'," "variables: `varlist')") 
			
		di ""
		di "{bf:{ul:Coefficients}}"
		local var_names "``varlistdetail''"
		estout matrix(`cat`catA'_endow_mean'), mlabels(Time) title("Group A coefficients") 
		estout matrix(`cat`catB'_endow_mean'), mlabels(Time) title("Group B coefficients") 
    } 
		
		
		
		gettoken resultsdata resultsrep : resultsdata, parse(",")
				if  ustrregexm("`resultsrep'", "replace") == 1 {
					local resultsreplace = 1 
				}
				else if ustrregexm("`resultsrep'", "replace") == 0 {
					local resultsreplace = 0
				}

				
				if substr("`resultsdata'",-4,4) == ".dta" {
					local dta = ""
				}
				else if substr("`resultsdata'",-4,4) != ".dta" {
					local dta = ".dta"
				}
		
		
	
		*** Display tables ***
		if "`nolevels'" != "nolevels" {
			di as text "" _newline
			di as text "{bf:{ul:Decomposition of Levels}}"
		
			estout, cells(b(star fmt(%12.`fmt'fc))  se(par)) unstack mlabel("`timevar'") order(``decomp_levels'') keep(``decomp_levels'') varlabel(``varlabel_levels'') refcat(``refcat_levels'')
			
		
		
		
		
		
			*** display detailed level tables ***
			

			
			if "`detail'" != "" {
				
				
				
				
				
				preserve
					foreach type in "level"   {
						di as text "" _newline
						di as text "{bf:{ul:Detailed Decomposition of Levels}}"
						xtoaxaca_helper_detail_bs , timeref(`timeref') type(`type') times(`times') ///
						resultsdata("`resultsdata'") fmt(`fmt') model(`model')
						di as text "" _newline
						di as text "{bf:{ul:Detailed Decomposition of Levels - Variable Blocks}}"
						xtoaxaca_helper_detail_bs , timeref(`timeref') type(`type') times(`times') ///
						resultsdata("`resultsdata'") fmt(`fmt') model(`model') blocks(`blocks')
						
						
					}
				restore  
				
				xtoaxaca_helper_write_estimates, mat_b(`b') mat_v(`V') times(`times') decomp_levels(``decomp_levels'') decomp_change(``decomp_change'')
			}
			
		}
		
		
		if "`nochange'" != "nochange" & "`change'" != "none" {
		
			
			di as text "" _newline
			di as text "{bf:{ul:Decomposition of Change}}"
		
			estout, cells(b(star fmt(%12.`fmt'fc)) se(par)) unstack mlabel("`timevar'") order(``decomp_change'') keep(``decomp_names'') varlabel(``varlabel_change'') refcat(``refcat_change'') note(`change_note')
			
			di as text "For an explanation of this change decomposition, please see:"
			if "`change'" == "interventionist"  {
				di as text "{bf:Kröger, H., & Hartmann, J. (2020). xtoaxaca - Extending the Kitagawa-Oaxaca-Blinder Decomposition Approach to Panel Data. https://doi.org/10.31235/osf.io/egj79}"
			}
			else if  "`change'" == "ssm" {
				di as text "{bf:Kim C. Decomposing the Change in the Wage Gap Between White and Black Men Over Time, 1980-2005: An Extension of the Blinder-Oaxaca Decomposition Method. Sociol Methods Res 2010; 38: 619–51.}"
			}
			else if  "`change'" == "smithwelch" {
				di as text "{bf:Smith JP, Welch FR. Black economic progress after Myrdal. J Econ Lit 1989; 27: 519–64.}"
				di _newline
				di as text  "i - Main Effect"
				di as text  "ii - Group Interaction"
				di as text  "iii - Time Interaction"
				di as text  "iv - Group-Time Interaction"
			}
			else if  "`change'" == "wellington" {
				di as text "{bf:Wellington, A. J. (1993). Changes in the Male/Female Wage Gap, 1976-85. The Journal of Human Resources, 28(2), 383.}"
			}
			else if  "`change'" == "mpjd" {
				di as text "{bf:Makepeace G, Paci P, Joshi H, Dolton P. How Unequally Has Equal Pay Progressed since the 1970s? A Study of Two British Cohorts. J Hum Resour 1999; 34: 534.}"
			}
			else if  "`change'" == "kim" {
				di as text "{bf:Kim C. Decomposing the Change in the Wage Gap Between White and Black Men Over Time, 1980-2005: An Extension of the Blinder-Oaxaca Decomposition Method. Sociol Methods Res 2010; 38: 619–51.}"
				di as text "D1 - Intercept Effect"
				di as text "D2 - Pure Coefficient Effect"
				di as text "D3 - Coefficient Interaction Effect"
				di as text "D4 - Pure Endowment Effect"
				di as text "D5 - Endowment Interaction Effect"
			}
			
			
			
			
			if "`detail'" != "" {
			
			
			
				*** Display detailed change tables ***
				
				preserve
					foreach type in "`change'"  {
						di as text "" _newline
						di as text "{bf:{ul:Detailed Decomposition of Change}}"
						xtoaxaca_helper_detail_bs , timeref(`timeref') type(`type') times(`times') ///
						resultsdata("`resultsdata'") fmt(`fmt') model(`model') 
						di as text "" _newline
						di as text "{bf:{ul:Detailed Decomposition of Change - Variable Blocks}}"
					
						xtoaxaca_helper_detail_bs , timeref(`timeref') type(`type') times(`times') ///
						resultsdata("`resultsdata'") fmt(`fmt') model(`model') blocks(`blocks')
					}
				restore  		 
			}
			
		}
		
		
		*** add blocks to resultsdata
		if "`blocks'" != "" {
			preserve
				qui use "`resultsdata'", clear
				xtoaxaca_helper_blocks, blocks("`blocks'") model(`model') save
				qui save "`resultsdata'", replace
			restore
		
		}
		
		
		qui est restore `model'
		
	
			foreach m of local matrices {
				ereturn mat `m' = ``m''
			}	
				ereturn mat dec_V = `V'
				ereturn mat dec_b = `b'
			
			**** return input and options ****
			foreach X in varlist groupvar groupcat timevar times model basemodel timebandwidth timeref  change forcesample normalize noisily twofold ///
							 tfweight nolevels nochange bootstrap detail fmt resultsdata seed weights blocks {
								ereturn local `X' "``X''"
			}
			ereturn local model = "`model'"
		
		
		
		
		
	}

end

