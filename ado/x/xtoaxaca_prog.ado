

***************************************
****** STRUCTURE of the program *******
***************************************


* 0. Checking input
* 1. Calculation of edowments
* 2. Outcome differences by time (R_t) as the differences to be explained
* 3. Calculate coefficients per group and time (beta_gt)
* 4. Implement the decomposition equations for levels and change
* 5. Generate the output





capture program drop xtoaxaca_prog
program xtoaxaca_prog, eclass

version 14.1

syntax [varlist] [if] [in], [groupvar(varname)] [groupcat(string)] [timevar(varname)] [times(numlist)] ///
                    [model1(name)] [model2(name)] [timebandwidth(string)] [timeref(string)] ///
                    [nose]  ///
                   [change(string)] [forcesample] [muh] [normalize(varlist)] [NOISily] ///
                   [twofold(string)] [tfweight(string)] [NOLEVels] [NOCHange] [DETail]  ///
				   [fmt(string)] [resultsdata(string)] [reffects(string)] [bs(string)] [weights(string)] ///
				   [replay(string)] [BLOcks(string)]
                   
		marksample touse
		
		local n_decvars2 = wordcount("`varlist'")
		local n_timepoints = wordcount("`times'")
		
		qui: gettoken catA catB: groupcat
		
		local catB = subinstr("`catB'"," ","",1)
		local cat1 = `catA'
		local cat2 = `catB'
		
		
		* ********************************************************************************** *
		* Initialize temporary names ******************************************************* *
		* ********************************************************************************** *    
		tempname means_`catA' means_`catB' means_`catA'_var means_`catB'_var ///
				 coefs_`catA' coefs_`catB' coefs_`catA'_var coefs_`catB'_var ///
				 baseline basediff baseline_var basediff_var ///
				 intercept interceptdiff intercept_var interceptdiff_var ///
				 helper helper_var helper_SD A unity meansat_`catA' meansat_`catB' ///
				 E  pE  E_var W means_`catA'_SD means_`catB'_SD varlistdetail ///
				 means_y_base means_y_control means_y_emp means_y_empA means_y_empB ///
				 change_y_emp change_y_base change_y_control basechange change_y ///
				 refmat prefmat drefmat pdrefmat
				 
				 tempname U U_var pU
				 tempname C CE pC pCE C_var CE_var
				
			   
				   
	***** check if replay or true run of the program ****			   
	if "`replay'" == "replay" {
	
		
		if "`change'" ==  "interventionist" | "`change'" == "ssm" | "`change'" == "hartmann" {
				
				foreach X in dE dC dCE pdE pdC pdCE {
					tempname `X'
					mat ``X'' = e(`X')
				}
		}
		else if "`change'" == "kim" {
				foreach X in kim_D1 kim_D2 kim_D3 kim_D4 kim_D5 ///
						pkim_D1 pkim_D2 pkim_D3 pkim_D4 pkim_D5 {
					tempname `X'
					mat ``X'' = e(`X')
				}
		}
		else if "`change'" == "smithwelch" {
				foreach X in sw_i sw_ii sw_iii sw_iv ///
						psw_i psw_ii psw_iii psw_iv {
					tempname `X'
					mat ``X'' = e(`X')
				}
		}
		else if "`change'" == "mpjd" {
				foreach X in mpjd_E_pure mpjd_E_price mpjd_E_total mpjd_U_pure mpjd_U_price mpjd_U_total ///
						pmpjd_E_pure pmpjd_E_price pmpjd_E_total pmpjd_U_pure pmpjd_U_price pmpjd_U_total {
						tempname `X'
						mat ``X'' = e(`X')
				} 
		}
		else if "`change'" == "wellington" {
				foreach X in  wl_1 wl_2 ///
						pwl_1 pwl_2 {
						tempname `X'
						mat ``X'' = e(`X')
				} 
		}
		else if "`change'" == "interventionist_twofold" {
				foreach X in  dE dU pdE pdU {
						tempname `X'
						mat ``X'' = e(`X')
				} 
		}
		
		if "`twofold'" == "" & "`change'" == "interventionist_twofold" {
			mat `U'   			= e(U)
			mat `pU'   			= e(pU)
		}
		else if "`twofold'" == "weight" {
			mat `U'   			= e(U)
			mat `pU'  			= e(pU)
		}
		else if "`twofold'" == "pooled" {
			mat `U'   			= e(U)
			mat `pU'  			= e(pU)
		}
	

						   
		mat `E'   			= e(E) 
		mat `C'   			= e(C)
		mat `CE'  			= e(CE)
		
		
		mat `pE'  			= e(pE)
		mat `pC'  			= e(pC)
		mat `pCE' 			= e(pCE)

		mat `means_y_base' 	   = e(means_base) 
		mat `means_y_emp'  	   = e(means_observed)
		
		
		if "`change'" != "" {
		
			mat `drefmat'       = e(drefmat)
			mat `pdrefmat'         = e(pdrefmat) 
			mat `change_y_base'    = e(change_base) 
			mat `change_y_emp'     = e(change_observed) 
			mat `change_y_control' = e(change_model) 
		
		
		}
		
		
		mat `refmat'       	   = e(refmat)
		mat `prefmat'          = e(prefmat) 
		
		
		mat `means_`catA''    = e(cat`catA'_endow_mean)
		mat `means_`catB''    = e(cat`catB'_endow_mean)
		mat `coefs_`catA''    = e(cat`catA'_coef_mean)
		mat `coefs_`catB''    = e(cat`catB'_coef_mean)
		

	
	
	
	}
				   
   
                   
    * *********************************************************** *
    * 0. program part checking all the input ******************** *
    * *********************************************************** *		   
    
	
	
	
		
		******************************************		   
		****** program checking all the input ****
		******************************************
		

		

		xtoaxaca_check_input `varlist'  if `touse',groupvar(`groupvar') groupcat(`groupcat') timevar(`timevar') times(`times') ///
									 model1(`model1') model2(`model2') timebandwidth(`timebandwidth') timeref(`timeref') ///
									  `nose'  ///
									 change(`change') `forcesample' `muh' normalize(`normalize') `noisily' ///
									 twofold(`twofold') tfweight(`tfweight') `nolevels'   fmt(`fmt') ///
									 resultsdata(`resultsdata') bs(`bs') `nochange' replay(`replay') blocks(`blocks')

		
	
		
		local timebandwidth = r(tbw)
		local reffects = r(reffects)
		local fmt = r(fmt)
		local refe = r(refe)
		local change = r(change)
		local normalize = r(normalize)
		if "`normalize'" == "." {
			local normalize = ""
		}
		if "`timeref'" == "" {
			local timeref = r(timeref)
		}
		***reference time point ****
		local posofreftime : list posof "`timeref'" in times
		if "`resultsdata'" != "" {
			local resultsdata = r(resultsdata)
		}
		if "`detail'" == "detail" & "`noisily'" == "" {
			local noisily = "noisily"
		}
		
		
		************************************************
		****** Substantive part of xtoaxaca starts *****
		************************************************
		* Display command arguments
		if ("`detail'" != "") & "`bs'" == "" {
			di "{hline}"
			di as text "Group variable:" _col(30) as input "`groupvar' (`catA',`catB')"
			di as text "Decomposition variables: " _col(30) as input "`varlist'"
			di as text "Times: " _col(30) as input "`timevar' (`times')"
			di "{hline}" _newline
		}


		
		
			
		
		
		**######################################**		   
		**### 								 ###**
		**### xtoaxaca_helpers.ado           ###**
		**### 								 ###**
		**######################################**
		
		qui: xtoaxaca_helper_create_varlist `varlist' if `touse', model(`model2')
		local `varlistdetail' = r(variables)
		local n_decvars = wordcount("``varlistdetail''") 

	if "`replay'" == "" {
	
	
	
	
	if "`change'" ==  "interventionist" | "`change'" == "ssm"  {
				
				foreach X in dE dC dCE pdE pdC pdCE {
					tempname `X'
				}
		}
		else if "`change'" == "kim" {
				foreach X in kim_D1 kim_D2 kim_D3 kim_D4 kim_D5 ///
						pkim_D1 pkim_D2 pkim_D3 pkim_D4 pkim_D5 {
					tempname `X'
				}
		}
		else if "`change'" == "smithwelch" {
				tempname sw_i sw_ii sw_iii sw_iv ///
						psw_i psw_ii psw_iii psw_iv
		}
		else if "`change'" == "mpjd" {
				tempname mpjd_E_pure mpjd_E_price mpjd_E_total mpjd_U_pure mpjd_U_price mpjd_U_total ///
						pmpjd_E_pure pmpjd_E_price pmpjd_E_total pmpjd_U_pure pmpjd_U_price pmpjd_U_total
		}
		else if "`change'" == "wellington" {
				tempname wl_1 wl_2 ///
						pwl_1 pwl_2
		}
		else if "`change'" == "interventionist_twofold" {
				tempname dE dU pdE pdU 
		}
		
		if "`twofold'" == "" & "`change'" == "interventionist_twofold" {
			local tfweight = 0.5
			local twofold "weight"
			
			di as text "twofold() not specified. Default is 'weight' with a value of 0.5 for all variables and timepoints is used."
		}
		else if "`twofold'" == "" & "`change'" != "interventionist_twofold" {
			local tfweight = .
		}
		else if "`twofold'" == "weight" {
			if "`tfweight'" == "" {
				local tfweight = 0.5
				di as text "tfweight() not specified. Default value 0.5 for all variables and timepoints is used."
			}
		}
		else if "`twofold'" == "pooled" {
			local tfweight = .
		}
	
	
		* ********************************************************************************** *
		* 1. Endowments: Calculate means for each time and decomposition variable by group * *
		* ********************************************************************************** *
		if ("`noisily'" != "") di as text ""
		if ("`noisily'" != "") di as text "[ Progress ] Calculating endowment means for each time ..."
		
		**######################################**		   
		**### 								 ###**
		**### xtoaxaca_calc_means.ado        ###**
		**### 								 ###**
		**######################################**
		
		* Calculate means from observed values for all composition variables by group and time
		xtoaxaca_calc_means `varlist' if `touse', model(`model2') times(`times') groupvar(`groupvar') varlistdetail(``varlistdetail'') timevar(`timevar') ///
		groupcat(`groupcat') timebandwidth(`timebandwidth')   weights(`weights')
		
		foreach X in `varlist' {
			local `X'_colrange1 = r(`X'_colrange1)
			local `X'_colrange2 = r(`X'_colrange2)
		}
		
		
		
		
		mat `means_`catA'' = r(meansA)
		mat `means_`catB'' = r(meansB)
		mat `means_`catA'_var' = r(meansA_var)
		mat `means_`catB'_var' = r(meansB_var)
		mat `means_`catA'_SD' = r(meansA_SD)
		mat `means_`catB'_SD' = r(meansB_SD)
		
		* Save decomposition variable means in locals for each level of the groupvar to set margins to a specific value later
		foreach X in ``varlistdetail'' {
			* group specific varmeans *
			foreach Z in A B {
				qui: sum `X' if `groupvar' == `cat`Z'' 	& `touse'    
				qui: local varmeans`Z' "`varmeans`Z'' `X'=`r(mean)'"			
			}
		}
		
		foreach X in `atvars' {
				qui: sum `X' 	if `touse'	    
				qui: local atvarmeans "`atvarmeans' `X'=`r(mean)'"			    
		}
		
		* ********************************************************************************** *
		* 2. Predict outcome differences by year according to the base and control model *** *
		* ********************************************************************************** *
		if ("`noisily'" != "") di as text "[ Progress ] Calculating mean outcomes ..."
		
		tempname is_pooled
		if ("`twofold'" == "pooled") local `is_pooled' = "pooled"
		
		**######################################**		   
		**### 								 ###**
		**### xtoaxaca_calc_outcome.ado      ###**
		**### 								 ###**
		**######################################**
		* Means based on base model
		
		if "`model1'" != "" {
			xtoaxaca_predict_outcome_means if `touse', model(`model1') timevar(`timevar') times(`times') groupvar(`groupvar') groupcat(`groupcat') ///
								   atvarmeans(`atvarmeans') nose(`nose') `noisily' 

			mat `means_y_base' = (r(baseline) \ r(basediff))
			mat rown `means_y_base' = "Group A" "Group B" "Diff"
		}
		
			

		* Means based on empirical outcomes
		qui: est restore `model2'
		local depvar `e(depvar)'
		**######################################**		   
		**### 								 ###**
		**### xtoaxaca_calc_means.ado        ###**
		**### 								 ###**
		**######################################**
		qui: xtoaxaca_calc_means `e(depvar)' if `touse', model(`model2') times(`times') groupvar(`groupvar') varlistdetail(outcome) /// 
		timevar(`timevar') groupcat(`groupcat') timebandwidth(`timebandwidth') 
		mat `means_y_empA' = r(meansA)
		mat `means_y_empB' = r(meansB)
		mat `means_y_emp' = (`means_y_empA'[1,1...] \ `means_y_empB'[1,1...] \ `means_y_empA'[1,1...] - `means_y_empB'[1,1...])
		mat rown `means_y_emp' = "Group A" "Group B" "Diff" 
		

		* Change matrices
		local n_timepoints = wordcount("`times'")
		
		if "`model1'" != "" {
			local matrices emp base

			foreach mat of local matrices {
			
				mat `change_y_`mat'' = J(1, `n_timepoints', `means_y_`mat''[1,`posofreftime'])
				forvalues i=2(1)3 {
					mat `change_y_`mat'' = (`change_y_`mat'' \ J(1, `n_timepoints', `means_y_`mat''[`i',`posofreftime']))
				}
				mat `change_y_`mat'' = `means_y_`mat'' - `change_y_`mat''
				mat rown `change_y_`mat'' = "Group A" "Group B" "Diff"
				mat coln `change_y_`mat'' = `times'
			}
			
			mat `change_y' = (`change_y_emp' \ `change_y_base' )
			mat rown `change_y' = "Observed:Group A" "Observed:Group B" "Observed:Total" "Base:Group A" "Base:Group B" "Base:Total" 
			mat coln `change_y' = `times'
		}
		else {
			local matrices emp 

			foreach mat of local matrices {
			
				mat `change_y_`mat'' = J(1, `n_timepoints', `means_y_`mat''[1,`posofreftime'])
				forvalues i=2(1)3 {
					mat `change_y_`mat'' = (`change_y_`mat'' \ J(1, `n_timepoints', `means_y_`mat''[`i',`posofreftime']))
				}
				mat `change_y_`mat'' = `means_y_`mat'' - `change_y_`mat''
				mat rown `change_y_`mat'' = "Group A" "Group B" "Diff"
				mat coln `change_y_`mat'' = `times'
			}
			
			mat `change_y' = (`change_y_emp'  )
			mat rown `change_y' = "Observed:Group A" "Observed:Group B" "Observed:Total" 
			mat coln `change_y' = `times'
		}
		
		**######################################**		   
		**### 								 ###**
		**### xtoaxaca_predict_reffects.ado  ###**
		**### 								 ###**
		**######################################**
		
		
		**********************************************************************
		***** differences in random effects (xtreg, mixed) are calculated ****
		**********************************************************************
		if "`reffects'" != "." {
			xtoaxaca_predict_reffects if `touse', model1(`model1') model2(`model2') timevar(`timevar') times(`times') groupvar(`groupvar') groupcat(`groupcat') ///
							   atvarmeans(`atvarmeans') nose(`nose') `noisily'  reffects(`reffects') timebandwidth(`timebandwidth')
			mat `refmat' = r(refmat)
			
			mat  rownames `refmat' = `refe'1 `refe'
		}
		else if "`reffects'" == "." {
			mat `refmat' = J(2,`n_timepoints',0)
			mat  rownames `refmat' = re1 re
	
		}
		
		mat  colnames `refmat'  = `times'
	
	
		
		
		
		* ********************************************************************************** *
		* 3. Unexplained Part: Calculate marginal coefficients for each group ************** *
		* ********************************************************************************** *

		if ("`noisily'" != "") di as text "[ Progress ] Calculating coefficients ..."
		
		**######################################**		   
		**### 								 ###**
		**### xtoaxaca_calc_coefficients.ado ###**
		**### 								 ###**
		**######################################**
		
		xtoaxaca_calc_coefficients `varlist' if `touse', model(`model2') groupvar(`groupvar') groupcat(`groupcat') timevar(`timevar') ///
		times(`times') varlistdetail(``varlistdetail'')  `noisily'  atvars("`atvars'")  ///
		atvarmeans("`atvarmeans'") 
		mat `coefs_`catA'' = r(coefsA)
		mat `coefs_`catB'' = r(coefsB)
		
					 
		
	
		
		
	
		
		* ********************************************************************************** *
		* 4. Normalization after Yun (2005) ************************************************ *
		* ********************************************************************************** *
		*** change(kim) expects normalized categorical variables ****
		*** this set in check_input file ***
		
		if "`normalize'" != "" {
			*** calcualte mean of the dummy coefficients by variable ***
			foreach varname in `normalize' {
				**** identify position/colrange of the specific categorical variables ***		
				foreach Z in `groupcat' {
					mata: xtoaxaca_mata_normalize("`coefs_`Z''", ``varname'_colrange1',``varname'_colrange2',`n_decvars')
				}
			}
			mat coln `coefs_`catA'' = ``varlistdetail'' Intercept
			mat coln `coefs_`catB'' = ``varlistdetail'' Intercept
		}
		
		
		* ********************************************************************************** *
		* 5. Decompose levels over time **************************************************** *
		* ********************************************************************************** *
		* Take observed empirical outcome difference as reference for percentages
		if ("`noisily'" != "") di ""
		if ("`noisily'" != "") di as text "[ Progress ] Running level decomposition ..."

		
		**######################################**		   
		**### 								 ###**
		**### xtoaxaca_mata.ado   		     ###**
		**### 								 ###**
		**######################################**
		mata: xtoaxaca_mata_levels("`means_`catA''","`means_`catB''","`coefs_`catA''","`coefs_`catB''", ///
		 ///
		"`E'","`C'","`CE'","`pE'","`pC'","`pCE'", "`basediff'", ///
		"`twofold'",`tfweight',"`means_`catA'_SD'","`means_`catB'_SD'","`U'","`pU'","`refmat'","`prefmat'")   
		mat  colnames `prefmat' = `times'
		mat  rownames `prefmat' =  `refe' 
		else if "`reffects'" == "." {
			mat `prefmat' = J(2,`n_timepoints',0)
			mat  rownames `prefmat' = re1 re
		}
		
		mat  colnames `refmat'  = `times'
		mat  colnames `prefmat' = `times'

		
		* ********************************************************************************** *
		* 6. Decompose change over time **************************************************** *
		* ********************************************************************************** *
		if "`change'" != "none" {
			**** we need to define 
			****                   a) the reference time point (s) and
			****                   b) destination time point (t)
			****
			**** all time points which are defined are taken; the refage is taken as a constant vector 
			**** position of `timeref' in `times' is determined, then extracted from the E/C/CE vector/matrix

			
			if "`change'" == "interventionist" {
				******************************************
				**** HARTMANN DECOMPOSITION of CHANGE ****
				******************************************
				if ("`noisily'" != "") di as text "[ Progress ] Running Interventionist decomposition ..."
				
				**######################################**		   
				**### 								 ###**
				**### xtoaxaca_mata.ado   		     ###**
				**### 								 ###**
				**######################################**

					mata: xtoaxaca_mata_hartmann("`means_`catA''","`means_`catB''","`coefs_`catA''","`coefs_`catB''", ///
											 ///
											"`dE'","`dC'","`dCE'","`pdE'","`pdC'","`pdCE'", `posofreftime', "`basediff'", "`basechange'", ///
											"`refmat'","`prefmat'","`drefmat'","`pdrefmat'")		
				
			}
			else if "`change'" == "interventionist_twofold" {
					mata: xtoaxaca_mata_hart2fold("`means_`catA''","`means_`catB''","`coefs_`catA''","`coefs_`catB''", ///
											 ///
											"`dE'","`dC'","`dCE'","`pdE'","`pdC'","`pdCE'", `posofreftime', "`basediff'", "`basechange'", ///
											"`twofold'",`tfweight',"`means_`catA'_SD'","`means_`catB'_SD'","`dU'","`pdU'","`refmat'","`prefmat'","`drefmat'","`pdrefmat'")
			
			}
			else if "`change'" == "kim" {
				******************************************
				**** KIM DECOMPOSITION of CHANGE      ****
				******************************************
				* Kim C. Decomposing the Change in the Wage Gap Between White and Black Men Over Time, 1980-2005: An Extension of the Blinder-Oaxaca Decomposition Method. Sociol Methods Res 2010; 38: 619–51.
				* page: 629, equation (6)
						*** has 5 components:
						/*
				D1 "Intercept Effect"
				D2 "Pure Coefficient Effect"
				D3 "Coefficient Interaction Effect"
				D4 "Pure Endowment Effect"
				D5 "Endowment Interaction Effect"
				*/
				if ("`noisily'" != "") di as text "[ Progress ] Running Kim decomposition ..."
				**######################################**		   
				**### 								 ###**
				**### xtoaxaca_mata.ado   		     ###**
				**### 								 ###**
				**######################################**
				mata: xtoaxaca_mata_kim("`means_`catA''","`means_`catB''","`coefs_`catA''","`coefs_`catB''", ///
				 ///
				"`kim_D1'","`kim_D2'","`kim_D3'","`kim_D4'","`kim_D5'", ///
				"`pkim_D1'","`pkim_D2'","`pkim_D3'","`pkim_D4'","`pkim_D5'", ///
				`posofreftime',`n_decvars', "`basediff'","`refmat'","`prefmat'","`drefmat'","`pdrefmat'")
			}
			else if "`change'" == "smithwelch" {
				****************************************************
				**** Smith & Welch DECOMPOSITION of CHANGE      ****
				****************************************************
				*  Smith JP, Welch FR. Black economic progress after Myrdal. J Econ Lit 1989; 27: 519–64.
				* page: 529, equation 1
				
				*** has 4 components:
						/*
				1.i   "Main Effect"            "effect, measures the predicted change in black-white weekly wages that occurs be- cause black and white men are becoming more similar in attributes that are valued at base-year white parameter values.'"
				1.ii  "Group Interaction"      "If blacks are paid less than whites for a given characteristic [(b3- b4) < 0], then blacks will lose relative to whites when mean attribute levels rise. For ex- ample, racially equal secular growth in levels of schooling favors whites if the income benefits from an additional year of schooling are higher for whites than for blacks."
				1.iii "Time interaction"       "If the estimated coefficient attached to a characteristic increases over time [(b2- b4) > 0], black/white wages will decline if blacks have less of the charac- teristic than whites. For example, if the income benefits from schooling rose be- tween two Censuses, white men benefit more than black men because they have more schooling."
					1.iv  "Group-Time interaction" "If racial differences in estimated coefficients become smaller [(b, - b2) - (b3 - b4)] > 0) over time, black wages will rise relative to whites. This term would capture the positive rel- ative wage benefits accruing to blacks as race differences in schooling coefficients have declined"
				*/
				*** Smith/Welch terminology: subscript 1: group A at time t (dynamic)
				***                          subscript 2: group B at time t
				***                          subscript 3: group A at time s (`posofreftime' - reftimepoint position within the columns)
				***                          subscript 4: group B at time s
				* "The subscripts 1 and 3 refer to current- year and base-year black male values, while 2 and 4 denote a corresponding index for whites"
				
				*** x1b4 - x2b4 - x3b4 + x4b4 [4] +
				*** x1b3 - x1b4 - x3b3[3] + x3b4 +
				*** x1b2 - x1b4 - x2b2 [2] + x2b4 +
				*** x1b1 [1]  - x1b2 - x1b3 + x1b4

				* =DR = (x1b1-x2b2)-(x3b3-x4b4) 
			if ("`noisily'" != "") di as text "[ Progress ] Running Smith-Welch decomposition ..."
				
				**######################################**		   
				**### 								 ###**
				**### xtoaxaca_mata.ado   		     ###**
				**### 								 ###**
				**######################################**
				mata: xtoaxaca_mata_sw("`means_`catA''","`means_`catB''","`coefs_`catA''","`coefs_`catB''", ///
				 ///
				"`sw_i'","`sw_ii'","`sw_iii'","`sw_iv'", ///
				"`psw_i'","`psw_ii'","`psw_iii'","`psw_iv'", ///
				`posofreftime',`n_decvars', "`basediff'", "`basechange'","`refmat'","`prefmat'","`drefmat'","`pdrefmat'")
			}
			else if "`change'" == "mpjd" {
					
				*****************************************************************************
				**** Makepeace & Paci, Joshi, Dolton (MPJD) DECOMPOSITION of CHANGE      ****
				*****************************************************************************
				*  Makepeace G, Paci P, Joshi H, Dolton P. How Unequally Has Equal Pay Progressed since the 1970s? A Study of Two British Cohorts. J Hum Resour 1999; 34: 534.
				* p. 539, equations (4) and (5)
				
				* MRC  = s
				* NCDS = t
				* m    = A
				* w    = B
				
				*****************************************
				**** Its a 2x2 decomposition into    ****
				****  1) explained   - pure          ****
				****  2) explained   - price         ****
				****  3) unexplained - pure          ****
				****  4) unexplained - price         ****
				*****************************************
				if ("`noisily'" != "") di as text "[ Progress ] Running Makepeace et al. decomposition ..."
				**######################################**		   
				**### 								 ###**
				**### xtoaxaca_mata.ado   		     ###**
				**### 								 ###**
				**######################################**
				mata: xtoaxaca_mata_mpjd("`means_`catA''","`means_`catB''","`coefs_`catA''","`coefs_`catB''", ///
				 ///
				"`mpjd_E_pure'","`mpjd_E_price'","`mpjd_E_total'","`mpjd_U_pure'","`mpjd_U_price'","`mpjd_U_total'", /// 
				"`pmpjd_E_pure'","`pmpjd_E_price'","`pmpjd_E_total'","`pmpjd_U_pure'","`pmpjd_U_price'","`pmpjd_U_total'", /// 
				`posofreftime',`n_decvars', "`basediff'", "`basechange'","`refmat'","`prefmat'","`drefmat'","`pdrefmat'")
			}
			else if "`change'" == "wellington" {
				***********************************************************************
				**** Wellington DECOMPOSITION of CHANGE  (similar to Hartmann)     ****
				***********************************************************************
				*   Wellington, A. J. (1993). Changes in the Male/Female Wage Gap, 1976-85. The Journal of Human Resources, 28(2), 383. https://doi.org/10.2307/146209
				* p. 393, equation (2)
				if ("`noisily'" != "") di as text "[ Progress ] Running Wellington decomposition ..."
				**######################################**		   
				**### 								 ###**
				**### xtoaxaca_mata.ado   		     ###**
				**### 								 ###**
				**######################################**
				mata: xtoaxaca_mata_wl("`means_`catA''","`means_`catB''","`coefs_`catA''","`coefs_`catB''", ///
				 ///
				"`wl_1'","`wl_2'", /// 
				"`pwl_1'","`pwl_2'", /// 
				`posofreftime',`n_decvars', "`basediff'", "`basechange'","`refmat'","`prefmat'","`drefmat'","`pdrefmat'")
			}
			else if "`change'" == "ssm" {
				******************************************************************
				**** Simple substraction method (SSM) DECOMPOSITION of CHANGE ****
				******************************************************************
				**######################################**		   
				**### 								 ###**
				**### xtoaxaca_mata.ado   		     ###**
				**### 								 ###**
				**######################################**
				
				mata: xtoaxaca_mata_ssm("`means_`catA''","`means_`catB''","`coefs_`catA''","`coefs_`catB''", ///
				 ///
				"`dE'","`dC'","`dCE'","`pdE'","`pdC'","`pdCE'", ///
				`posofreftime', "`basediff'","`refmat'","`prefmat'","`drefmat'","`pdrefmat'")

			}
			
		}
		
		if "`nochange'" == "" & "`change'" != "none" {
			mat  colnames `drefmat' = `times'
			mat  rownames `drefmat' = `refe'1 `refe'
			mat  colnames `pdrefmat' = `times'
			mat  rownames `pdrefmat' = `refe'1 `refe'
			if "`reffects'" == "." {
				mat `pdrefmat' = J(2,`n_timepoints',0)
				mat  rownames `pdrefmat' = re1 re
				mat  colnames `pdrefmat' = `times'
				mat `drefmat' = J(2,`n_timepoints',0)
				mat  rownames `drefmat' = re1 re
				mat  colnames `drefmat'  = `times'
				
			}
		}

	
		

			
	
	***** END: check if replay or true run of the program ****
	}
	
			

	
	
    
    * ********************************************************************************** *
    * 7. Output ************************************************************************ *
    * ********************************************************************************** *
    if ("`noisily'" != "") di ""
    if ("`noisily'" != "") di as text "[ Progress ] Display output ..."
	
	local varlabels "``varlistdetail'' Intercept Total"
    
  
    if "`twofold'" == "" {
        local varcomp "E C CE"
    }
    else if "`twofold'" != "" {
        local varcomp "E U"
    } 

    local table_options mlabels(`timevar')

    di ""
 
    * Display means and coefs matrices
    if ("`noisily'" != "") {
        di "{hline}"
        di "{bf:{ul:Outcome}}"
		if "`model1'" != "" {
			estout matrix(`means_y_base'), mlabels(Time) title("Mean predicted outcome differences between the groups (base model)") 
		}
		
		estout matrix(`means_y_emp'), mlabels(Time) title("Mean predicted outcome differences between the groups (empirical values)") 
			
		di ""
		di "{bf:{ul:Endowments}}"	
		estout matrix(`means_`catA''), mlabels(Time) title("Endowment means for each time (Group (`groupvar') `catA'," "variables: `varlist')") 
		estout matrix(`means_`catB''), mlabels(Time) title("Endowment means for each time (Group (`groupvar') `catB'," "variables: `varlist')") 
			
		di ""
		di "{bf:{ul:Coefficients}}"
		local var_names "``varlistdetail''"
		tempname t_coefs_`catA' t_coefs_`catB'
		mat `t_coefs_`catA'' = `coefs_`catA'''
		mat `t_coefs_`catB'' = `coefs_`catB'''
		estout matrix(`t_coefs_`catA''), mlabels(Time) title("Group A coefficients") 
		estout matrix(`t_coefs_`catB''), mlabels(Time) title("Group B coefficients") 
    } 
	
	*** throw out unnecessary estimation results from margins ****
	ereturn clear
	qui est restore `model2'
	

    * Display output for levels
    if ("`nolevels'" == "") {
		**######################################**		   
		**### 								 ###**
		**### xtoaxaca_output.ado   		 ###**
		**### 								 ###**
		**######################################**
		if "`reffects'" == "" {
			mat `refmat' = J(4,1,.)
		}
	    xtoaxaca_output_levels, var_names(`varlabels') times(`times') tableoptions(`table_options') varcomp(`varcomp') twofold("`twofold'") ///
	                   e(`E') c(`C') ce(`CE') u(`U') pe(`pE') pc(`pC') pce(`pCE') pu(`pU') ///
                       means_y_base(`means_y_base') means_y_emp(`means_y_emp') `noisily'  reffects(`reffects') ///
					   refmat(`refmat') prefmat(`prefmat') fmt(`fmt') resultsdata(`resultsdata') refe(`refe') bs(`bs') `nolevels' ///
					   model1(`model1')
		
		if "`blocks'" != "" {
			
			*** blocks results ***
			di as text "" _newline
			di as text "{bf:{ul:Detailed Decomposition of Levels - Variable Blocks}}"
			xtoaxaca_helper_detail_bs , timeref(`timeref') type("level") times(`times') ///
			resultsdata("`resultsdata'") fmt(`fmt') model(`model2') blocks(`blocks') nobs
		}
    }
    
    * Display output for change
    if ("`nochange'" == "" | "`change'" != "none") {
	    if ("`change'" == "interventionist" | "`change'" == "ssm")	{
			**######################################**		   
			**### 								 ###**
			**### xtoaxaca_output.ado   		 ###**
			**### 								 ###**
			**######################################**

				xtoaxaca_output_hartmann, var_names(`varlabels') times(`times') tableoptions(`table_options') change(`change') ///
			                 c(`C') e(`E') ce(`CE')  ///
							 de(`dE') dc(`dC') dce(`dCE') pde(`pdE') pdc(`pdC') pdce(`pdCE') ///
							 change_y_emp(`change_y_emp') change_y_base(`change_y_base') `noisily'  ///
							 drefmat(`drefmat') pdrefmat(`pdrefmat') reffects(`reffects') fmt(`fmt') ///
							 resultsdata(`resultsdata') refe(`refe') bs(`bs') `nolevels' model1(`model1')
			
			if "`blocks'" != "" {
			
				*** blocks results ***
				di as text "" _newline
				di as text "{bf:{ul:Detailed Decomposition of Levels - Variable Blocks}}"
				xtoaxaca_helper_detail_bs , timeref(`timeref') type("`change'") times(`times') ///
				resultsdata("`resultsdata'") fmt(`fmt') model(`model2') blocks(`blocks') nobs
			}
							 
        }
		else if ("`change'" == "interventionist_twofold") {
				xtoaxaca_output_hart2fold, var_names(`varlabels') times(`times') tableoptions(`table_options') change(`change') ///
			                   ///
							 de(`dE') du(`dU')  pde(`pdE') pdu(`pdU')  ///
							 change_y_emp(`change_y_emp') change_y_base(`change_y_base') `noisily'  ///
							 drefmat(`drefmat') pdrefmat(`pdrefmat') reffects(`reffects') fmt(`fmt') ///
							 resultsdata(`resultsdata') refe(`refe') bs(`bs') `nolevels'  model1(`model1')
							 
			if "`blocks'" != "" {
			
				*** blocks results ***
				di as text "" _newline
				di as text "{bf:{ul:Detailed Decomposition of Levels - Variable Blocks}}"
				xtoaxaca_helper_detail_bs , timeref(`timeref') type("`change'") times(`times') ///
				resultsdata("`resultsdata'") fmt(`fmt') model(`model2') blocks(`blocks') nobs
			}
		}
	    else if ("`change'" == "mpjd") {
			**######################################**		   
			**### 								 ###**
			**### xtoaxaca_output.ado   		 ###**
			**### 								 ###**
			**######################################**
		    xtoaxaca_output_mpjd, var_names(`varlabels') times(`times') tableoptions(`table_options') mpjd_U_total(`mpjd_U_total') ///
			             mpjd_U_pure(`mpjd_U_pure') mpjd_U_price(`mpjd_U_price') mpjd_E_total(`mpjd_E_total') mpjd_E_pure(`mpjd_E_pure') ///
						 mpjd_E_price(`mpjd_E_price') pmpjd_U_total(`pmpjd_U_total') pmpjd_U_pure(`pmpjd_U_pure') pmpjd_U_price(`pmpjd_U_price') ///
						 pmpjd_E_total(`pmpjd_E_total') pmpjd_E_pure(`pmpjd_E_pure') pmpjd_E_price(`pmpjd_E_price') ///
						 change_y_emp(`change_y_emp') change_y_base(`change_y_base') `noisily'  fmt(`fmt') ///
						 drefmat(`drefmat')  pdrefmat(`pdrefmat') reffects(`reffects')  resultsdata(`resultsdata') refe(`refe') bs(`bs') `nolevels' ///
						  model1(`model1')
						  
			if "`blocks'" != "" {
			
				*** blocks results ***
				di as text "" _newline
				di as text "{bf:{ul:Detailed Decomposition of Levels - Variable Blocks}}"
				xtoaxaca_helper_detail_bs , timeref(`timeref') type("`change'") times(`times') ///
				resultsdata("`resultsdata'") fmt(`fmt') model(`model2') blocks(`blocks') nobs
			}
        }

		else if ("`change'" == "kim")  {
			**######################################**		   
			**### 								 ###**
			**### xtoaxaca_output.ado   		 ###**
			**### 								 ###**
			**######################################**
            xtoaxaca_output_kim, var_names(`varlabels') times(`times') tableoptions(`table_options') ///
			             kim_D1(`kim_D1') kim_D2(`kim_D2') kim_D3(`kim_D3') kim_D4(`kim_D4') kim_D5(`kim_D5') ///
						 pkim_D1(`pkim_D1') pkim_D2(`pkim_D2') pkim_D3(`pkim_D3') pkim_D4(`pkim_D4') pkim_D5(`pkim_D5') drefmat(`drefmat')  pdrefmat(`pdrefmat') ///
						 change_y_emp(`change_y_emp') change_y_base(`change_y_base') `noisily'  ///
						  reffects(`reffects') fmt(`fmt')  resultsdata(`resultsdata') refe(`refe') bs(`bs') `nolevels' ///
						   model1(`model1')
						   
			if "`blocks'" != "" {
			
				*** blocks results ***
				di as text "" _newline
				di as text "{bf:{ul:Detailed Decomposition of Levels - Variable Blocks}}"
				xtoaxaca_helper_detail_bs , timeref(`timeref') type("`change'") times(`times') ///
				resultsdata("`resultsdata'") fmt(`fmt') model(`model2') blocks(`blocks') nobs
			}
	    }
		
		else if ("`change'" == "smithwelch") {
			**######################################**		   
			**### 								 ###**
			**### xtoaxaca_output.ado   		 ###**
			**### 								 ###**
			**######################################**
		    xtoaxaca_output_sw, var_names(`varlabels') times(`times') tableoptions(`table_options') ///
                          sw_i(`sw_i')   sw_ii(`sw_ii')   sw_iii(`sw_iii')   sw_iv(`sw_iv')  ///
						  psw_i(`psw_i') psw_ii(`psw_ii') psw_iii(`psw_iii') psw_iv(`psw_iv') /// 
						  change_y_emp(`change_y_emp') change_y_base(`change_y_base') `noisily'  fmt(`fmt')	 ///
						  drefmat(`drefmat')  pdrefmat(`pdrefmat') reffects(`reffects')  resultsdata(`resultsdata') refe(`refe') bs(`bs') `nolevels' ///
						   model1(`model1')
						   
			if "`blocks'" != "" {
			
				*** blocks results ***
				di as text "" _newline
				di as text "{bf:{ul:Detailed Decomposition of Levels - Variable Blocks}}"
				xtoaxaca_helper_detail_bs , timeref(`timeref') type("`change'") times(`times') ///
				resultsdata("`resultsdata'") fmt(`fmt') model(`model2') blocks(`blocks') nobs
			}
		}
		
	    else if ("`change'" == "wellington") {
			**######################################**		   
			**### 								 ###**
			**### xtoaxaca_output.ado   		 ###**
			**### 								 ###**
			**######################################**
		    xtoaxaca_output_wl, var_names(`varlabels') times(`times') tableoptions(`table_options') ///
			                   wl_1(`wl_1') wl_2(`wl_2') pwl_1(`pwl_1') pwl_2(`pwl_2') ///
							   change_y_emp(`change_y_emp') change_y_base(`change_y_base') `noisily'  fmt(`fmt') ///
							   drefmat(`drefmat')  pdrefmat(`pdrefmat') reffects(`reffects')  resultsdata(`resultsdata') refe(`refe') bs(`bs') `nolevels' ///
							   model1(`model1')
							   
			if "`blocks'" != "" {
			
				*** blocks results ***
				di as text "" _newline
				di as text "{bf:{ul:Detailed Decomposition of Levels - Variable Blocks}}"
				xtoaxaca_helper_detail_bs , timeref(`timeref') type("`change'") times(`times') ///
				resultsdata("`resultsdata'") fmt(`fmt') model(`model2') blocks(`blocks') nobs
			}
        }			
	    
    }
	
	
	
	*** add blocks to resultsdata
		if "`blocks'" != "" {
			preserve
				qui use "`resultsdata'", clear
				xtoaxaca_helper_blocks, blocks("`blocks'") model(`model2') save
				qui save "`resultsdata'", replace
			restore
		
		}
	
	**** return input and options ****
	foreach X in varlist groupvar groupcat timevar times model basemodel timebandwidth timeref  change forcesample normalize noisily twofold ///
			             tfweight nolevels nochange bootstrap detail fmt resultsdata seed weights blocks {
							ereturn local `X' "``X''"
	}
	ereturn local model = "`model2'"
			
	

	* Return helper matrices
	ereturn mat cat`catA'_endow_mean = `means_`catA''
	ereturn mat cat`catB'_endow_mean = `means_`catB''
		
	ereturn mat cat`catA'_coef_mean = `coefs_`catA''
	ereturn mat cat`catB'_coef_mean = `coefs_`catB''
	
	ereturn mat refmat  = `refmat'
	ereturn mat prefmat = `prefmat'

	if "`nochange'" == "" & "`change'" != "none" {
		ereturn mat drefmat  = `drefmat'
		ereturn mat pdrefmat = `pdrefmat'
	}

	if "`model1'" != "" {
		ereturn mat means_base  = `means_y_base'
		ereturn mat change_base = `change_y_base'
		ereturn local basemodel = "`model1'"
	}
	ereturn mat means_observed  = `means_y_emp'
	
	ereturn mat change_observed = `change_y_emp'
	
	
	ereturn local refe = "`refe'"
	ereturn local reffects = "`reffects'"
	ereturn local fmt = "`fmt'"
end


