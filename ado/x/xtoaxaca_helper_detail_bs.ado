
* program that gives output from saved results from bootstrap

cap program drop xtoaxaca_helper_detail_bs
program define xtoaxaca_helper_detail_bs, eclass
syntax, timeref(numlist) type(string) times(numlist) resultsdata(string) fmt(string) [blocks(string)] model(name) [NOBs]
	
	tempname b VCE
	
	
							if "`type'" == "level" {
								local lvltext "Level"
							}
							else if "`type'" != "level" {
								local lvltext "Change"
							}
	
	foreach perc in no yes  {
							preserve 
								qui use "`resultsdata'", clear
								
								if "`blocks'" != "" {
									xtoaxaca_helper_blocks, blocks("`blocks'") model(`model')
								}
								
								
								
								if "`perc'" == "yes" {
									local perctext "Percentages of"
								}
								else if "`perc'" == "yes" {
									local perctext ""
								}
								
								
								
								qui drop if component == "RE" | component == "FE"
								qui keep if type == "`type'" & percentage == "`perc'"
								
								qui levelsof component
								qui local comps "`r(levels)'"
								
						
								foreach comp in `comps' {
									local mods ""
									
									foreach time in `times' {
										
										tempname `type'_`perc'_`comp'_`time'
										
											order  Intercept Total time component percentage type
												qui: ds
												local nnn "`r(varlist)'"
												local vvv ""
												foreach X in `nnn' {
													if  substr("`X'",1,1) != "_" & "`X'" != "Intercept" & "`X'" != "Total" & "`X'" != "time" & "`X'" != "component"  & "`X'" != "percentage"  & "`X'" != "type"  & "`X'" != "re"  & "`X'" != "fe"  & "`X'" != "bs" {
														local vvv "`vvv' `X'"
														move `X' Intercept
													}
												}
												gettoken first : vvv, parse(" ")
												
												if "`nobs'" == "" {
													if `time' == `timeref' & "`type'" != "level"  {
														local varcount = wordcount("`vvv'") +2
														mat `b' = J(1,`varcount',0)
														mat `VCE' = J(`varcount',`varcount',0)
														matrix colnames `b' = `vvv' Intercept Total
														matrix colnames `VCE' = `vvv' Intercept Total
														matrix rownames `VCE' = `vvv' Intercept Total
													}
													else {
														qui:  cor `vvv' Intercept Total if bs >1 & type == "`type'" & percentage == "`perc'" & component == "`comp'" & time == `time' , cov
														mat `VCE' = r(C)
														mkmat `vvv' Intercept Total if bs ==1 & type == "`type'" & percentage == "`perc'" & component == "`comp'" & time == `time', mat(`b')
													}
													
													if "`comp'" == "D1" & "`type'" == "kim" {
														qui replace Intercept = 0 if component == "D1" & percentage == "yes" & type == "kim" & time ==`timeref'
														qui:  cap cor  Intercept if bs >1 , cov
														mat `VCE' = r(C)
														mkmat Intercept  if bs ==1 & `touse', mat(`b')
													}
													
													
													ereturn clear
													ereturn post  `b'  `VCE',
													ereturn local cmd "xtoaxaca_detail_bs"										 
													
													est store ``type'_`perc'_`comp'_`time''
													local mods "`mods' ``type'_`perc'_`comp'_`time''"
												}
												else if "`nobs'" == "nobs" {
													tempname b`time'
													if `time' == `timeref' & "`type'" != "level"  {
														local varcount = wordcount("`vvv'") +2
														
														mat `b`time'' = J(1,`varcount',0)
														matrix colnames `b`time'' = `vvv' Intercept Total
													}
													else {
														mkmat `vvv' Intercept Total if  type == "`type'" & percentage == "`perc'" & component == "`comp'" & time == `time', mat(`b`time'')
													}
													
													if "`comp'" == "D1" & "`type'" == "kim" {
														qui replace Intercept = 0 if component == "D1" & percentage == "yes" & type == "kim" & time ==`timeref'
														mkmat Intercept  if  `touse', mat(`b`time'')
													}
													
													if "`mods'" != "" {
														local mods "`mods' , `b`time'''"
													}
													else if "`mods'" == "" {
														local mods "`b`time'''"
													}
													
												}
									 
									}
									
									if "`nobs'" == "" {
										estout `mods', cells(b(star fmt(%12.`fmt'fc)) se(par)) mlabels(`times') nonumbers ///
										title(`perctext' `lvltext' Component: `comp') 
									}
									else if "`nobs'" == "nobs" {
										tempname allb
										mat `allb' = `mods'
										mat colnames `allb' = `times'
										estout matrix(`allb',fmt(%12.`fmt'fc)), mlabels(time) nonumbers ///
										title(`perctext' `lvltext' Component: `comp') 
									}
									
									
								}
						restore
		}
	
	
	
end 
