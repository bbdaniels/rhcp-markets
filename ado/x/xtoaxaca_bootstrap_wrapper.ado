* ****************************************************************** *
* Bootstrap Wrapper for xtoaxaca *********************************** *
* ****************************************************************** *
/* This program is intended to run run xtoaxaxa_prog within bootstrap.
 * All it does is to run xtoaxaca_prog and makes its result ready 
   to be read by the bootstrap command.                             */
   
cap program drop xtoaxaca_bootstrap_wrapper
program define xtoaxaca_bootstrap_wrapper, eclass
	
	syntax varlist [if] [in], groupvar(varname) groupcat(string) timevar(varname) times(numlist) ///
                       [model1(name)] model2(name) [timebandwidth(string)] [timeref(string)] ///
                       [reffects(string)]  [nose]  ///
                       [change(string)] [forcesample] [muh] [normalize(varlist)] [NOISily] [DETail] ///
                       [twofold(string)] [tfweight(string)] [NOLEVels] [NOCHange] [decomp_levels(string)] ///
					   [decomp_change(string)] ///
                       [fmt(string)] [reffects(string)] ///
					   [resultsdata(string)] [bs(string)] [weights(string)]
	
	marksample touse
	
	
	if "`model1'" != "" {
		qui: est restore `model1'
		local m1 `e(cmdline)'
	}
	qui: est restore `model2'
	local m2 `e(cmdline)'
	
	tempname  cont mat_levels mat_change mat_reffects
	
	quietly {
		if "`model1'" != "" {
			tempname base
			eststo `base': `m1'
		}
		
				if "`e(cmd)'" == "xtreg" {
					qui xtset `e(ivar)'
				}
			
		
		eststo `cont': `m2'
		
		
		xtoaxaca_prog `varlist' if `touse', groupvar(`groupvar') groupcat(`groupcat') timevar(`timevar') times(`times') ///
                                 model1(`base') model2(`cont') timebandwidth(`timebandwidth') timeref(`timeref') ///
                                 `nose'  resultsdata(`resultsdata') ///
                                 change(`change') `forcesample' `muh' normalize(`normalize') `noisily' ///
                                 twofold(`twofold') tfweight(`tfweight') `nolevels' `nochange' `detail'  fmt(`fmt') bs(`bs') weights(`weights')
	}
				    		
	* Get results
	mat `mat_levels' = e(summary_levels)
	mat `mat_change' = e(summary_change)
		
	* Create scalars
	local n_times = wordcount("`times'")
	
	* Return coefficients
	forvalues i=1(1)`n_times' {	
		local counter1 1
		local counter2 1
		local time = word("`times'", `i')
		if "`decomp_levels'" != "" {
			foreach t of local decomp_levels {
				scalar levels_`t'_`time' = `mat_levels'[`counter1', `i']
				local counter1 = `counter1' + 1						
				if (levels_`t'_`time' == .) scalar levels_`t'_`time' = 0
				ereturn scalar levels_`t'_`time' = levels_`t'_`time'
			}
		}
		if "`decomp_change'" != "" {
			foreach t of local decomp_change {
				scalar change_`t'_`time' = `mat_change'[`counter2', `i']
				if (change_`t'_`time' == .) scalar change_`t'_`time' = 0
				local counter2 = `counter2' + 1
				ereturn scalar change_`t'_`time' = change_`t'_`time'
			}
		}
	}
	
end
