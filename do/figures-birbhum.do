
	global wd "/Users/devakid/Library/CloudStorage/Box-Box/Jishnu/Health/rhcp-markets"
	global constructed "$wd/constructed"
	global figures "$wd/outputs"
	global do "$wd/do"
	
	use "$constructed/birbhum-endline-exit.dta", clear
	
	merge m:1 providerid using "$constructed/birbhum-balance.dta", keep(3) nogen
	
// Construct and clean key variables 

	gen noschool = pe_s1q4 == 1			// no school 
	gen grade5plus = pe_s1q4 > 2 		// grade 5 or more 
	gen attendcollege = pe_s1q4 == 5	// some college 
	
	lab var noschool 						"No formal schooling"
	lab var grade5plus 						"Has attended grade 5 or higher"
	lab var attendcollege					"Has attended college"
	
	gen outsidevillage = pe_s1q7 == 2
	lab var outsidevillage					"Patient from outside the village"
	
	gen arrivebyfoot = pe_s1q8 == 3
	gen arriveownvehicle = pe_s1q8 == 2
	
	replace arrivebyfoot = . if pe_s1q8 == -99
	replace arriveownvehicle = . if pe_s1q8 == -99
	
	lab var arrivebyfoot 					"Patient arrived by foot"
	lab var arriveownvehicle				"Patient arrive on own vehicle"
	
	pca pe_s4*
	predict pca_hh_assets 
	
	lab var pca_hh_assets						"Wealth index"
	
	foreach var in a b c d {
		
		gen docomfortably_`var' = pe_s3q2_adl_`var' == 1 ///
			if !missing(pe_s3q2_adl_`var') & pe_s3q2_adl_`var' != 0 
		
	}
	
	lab var docomfortably_a						"Can comfortably dress themselves"
	lab var docomfortably_b						"Can comfortably complete light work"
	lab var docomfortably_c						"Can comfortably lift 5kg and walk 100m"
	lab var docomfortably_d						"Can comfortably walk 200-300m"
	

// Regression on patient demographics 

	eststo clear
	
	foreach var in pe_s1q3 noschool grade5plus attendcollege pe_s1q6 ///
		outsidevillage arrivebyfoot arriveownvehicle pca_hh_assets pe_s1q2 {
			
			reg `var' treatment i.pe_block, cl(providerid)
			eststo `var'
			
		}
			
	coefplot ///
		(pe_s1q2, label(Patient age)) ///
		(arrivebyfoot, label(Arrived to clinic by foot)) ///
		(noschool, label(No formal schooling)) ///
		(pe_s1q6, label(Number of family members)) ///
		(attendcollege, label(Has attended college)) ///
		(outsidevillage, label(Patient from outside village)) ///
		(grade5plus , label(Has attended grade 5)) ///
		(arriveownvehicle, label(Arrived to clinic on own vehicle)) ///
		(pe_s1q3, label(Male)) ///
		(pca_hh_assets, label(Househosld wealth index)) ///
		, drop(_cons 1b.pe_block 2.pe_block 3.pe_block) ///
		xline(0) ///
		xlabel(-2.5(0.5)2.5) ///
		scheme(stmono1) ///
		coeflabels(treatment = " ") ///
		xtitle("Treatment Effect") ///
		ciopts(recast(rcap)) ///
		recast(bar) ///
		citop barwidt(0.05) ///
		addplot(scatter @at @ul, ms(i) mlabel(@b) mlabformat("%9.2f") ///
		mlabcolor(black) mlabpos(2)) ///
		title("Birbhum Exit Survey: Patient Demographics" ///
			, size(medium))
		
	graph export "$figures/figX-birbhumexit-dem.png" ///
		, as(png) name("exit-dem") replace 
	
		
// Regression on ADL 

	foreach var in docomfortably_a docomfortably_b docomfortably_c docomfortably_d {
			
			reg `var' treatment i.pe_block, cl(providerid)
			eststo `var'
			
		}
   
	coefplot ///
		(docomfortably_d, label(Comfortably walk 200-300m)) ///
		(docomfortably_b, label(Comfortably do light work)) ///
		(docomfortably_c, label(Comfortably lift 5kg + walk 100m)) ///
		(docomfortably_a, label(Comfortably Dress themselves)) ///
		, drop(_cons 1b.pe_block 2.pe_block 3.pe_block) ///
		xline(0) ///
		scheme(stmono1) ///
		coeflabels(treatment = " ") ///
		xtitle("Treatment Effect") ///
		ciopts(recast(rcap)) ///
		recast(bar) ///
		citop barwidt(0.05) ///
		addplot(scatter @at @ul, ms(i) mlabel(@b) mlabformat("%9.2f") ///
		mlabcolor(black) mlabpos(2)) ///
		title("Birbhum Exit Survey: Patient Activities of Daily Life" ///
			, size(medium))
		
	graph export "$figures/figX-birbhum-exit-ADL.png" ///
		, as(png) name("exit-ADL") replace 
		

// Regression on nature of complaint 


	foreach var in pe_s2q1 pe_s2q2 pe_s2q3 pe_s2q4 pe_s2q5 pe_s2q6 pe_s2q7 ///
		pe_s2q8 pe_s2q9 {
			
			reg `var' treatment i.pe_block, cl(providerid)
			eststo `var'
			
		}
   
	coefplot ///
		(pe_s2q2, label(Complaint - Cold/Cough)) ///
		(pe_s2q4, label(Complaint - Weakness)) ///
		(pe_s2q1, label(Complaint - Fever)) ///
		(pe_s2q7, label(Complaint - Dermatological)) ///
		(pe_s2q9, label(Complaint - Pain)) ///
		(pe_s2q5, label(Complaint - Injury)) ///
		(pe_s2q8, label(Complaint - Pregnancy)) ///
		(pe_s2q6, label(Complaint - Vomiting)) ///
		(pe_s2q3, label(Complaint - Diarrhoea)) ///
		, drop(_cons 1b.pe_block 2.pe_block 3.pe_block) ///
		xline(0) ///
		scheme(stmono1) ///
		coeflabels(treatment = " ") ///
		xtitle("Treatment Effect") ///
		ciopts(recast(rcap)) ///
		recast(bar) ///
		citop barwidt(0.05) ///
		addplot(scatter @at @ul, ms(i) mlabel(@b) mlabformat("%9.2f") ///
		mlabcolor(black) mlabpos(2)) ///
		title("Birbhum Exit Survey: Patient Complaints" ///
			, size(medium)) 

	graph export "$figures/figX-birbhumexit-complaints.png" ///
		, as(png) name("exit-comp") replace 

	