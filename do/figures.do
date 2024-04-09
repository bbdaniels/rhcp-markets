
// Figure 1: Know-do gaps

  use "${git}/constructed/knowdo.dta", clear

    betterbarci correct, bar pct xlab(${pct}) xoverhang ///
      over(sp) legend(on pos(12) region(lc(none))) by(strata) ///
      barc(gs6 gs10)

      graph export "${git}/outputs/fig1-knowdo.png" , replace

// Figure 2: Excess Capacity

  use "${git}/constructed/pope-time.dta" , clear

  keep if po_time < 180

  su po_time if study == 1
    local mp = `r(mean)'
  su po_time if study == 2
    local bi = `r(mean)'

  tw ///
    (kdensity po_time if study == 1 , lw(thick) lc(black)) ///
    (kdensity po_time if study == 2 , lw(thick) lc(black) lp(dash)) ///
  , legend(on order(1 "Madhya Pradesh" 2 "Birbhum") pos(1) ring(0) c(1) region(lc(none))) ///
    xtit("") xoverhang ytit("Density") ///
    xline(`mp' , lw(thin) lc(black)) xline(`bi' , lw(thin) lc(black) lp(dash)) ///
    xlab(0 `""Daily Time {&rarr}" "With Patients""' 30 "0:30" 60 "1 Hour" 90 "1:30" 120 "2 Hours" 150 "2:30" 180 "3 Hours")

    graph export "${git}/outputs/fig2-capacity.png" , replace

// Figure 3-4-5: Checklist-time-correct

  // Figure 3
  use "${git}/constructed/sp_checklist.dta" if study_code !=2  , clear

    expand 2 , gen(fake)
    replace study_code = 10 if fake == 1

    binsreg check_std time_std ///
    , by(study_code) bysymbols(o o o o o o o o o o ) ///
      bycolors(blue%50 cranberry%50 dkgreen%50 dkorange%50 lavender%50 maroon%50 black) ///
      polyreg(1) legend(on c(1) pos(5) ring(0) region(lc(none) fc(none))) ///
      legend(size(small) order(2 "Birbhum"  4 "Delhi" ///
          6 "Kenya"  8 "Madhya Pradesh"  10 "Mumbai"  12 "Patna" 14 "Total")) ///
      xtit("Standardized Time with SP") ytit("Standardized Checklist Completion") ///
      plotxrange(-2 3) plotyrange(-2 2)

    graph export "${git}/outputs/fig3-time-checklist.png" , replace

  // Figure 4
  use "${git}/constructed/sp_checklist.dta" if study_code !=2 , clear

    expand 2 , gen(fake)
    replace study_code = 10 if fake == 1

    replace check_std = check_std + rnormal()/1000

    binsreg correct check_std ///
    , by(study_code) bysymbols(o o o o o o o o o o ) ///
    bycolors(blue%50 cranberry%50 dkgreen%50 dkorange%50 lavender%50 maroon%50 black) ///
      polyreg(1) legend(on c(2) pos(11) ring(0)) ///
      legend(size(small) order(2 "Birbhum"  4 "Delhi" ///
          6 "Kenya"  8 "Madhya Pradesh"  10 "Mumbai"  12 "Patna" 14 "Total")) ///
      ytit("Correct Treatment Frequency") xtit("Standardized Checklist Completion") ///
      plotxrange(-2 3) plotyrange(-2 2) ylab(${pct})

    graph export "${git}/outputs/fig4-correct-checklist.png" , replace

  // Figure 5
  use "${git}/constructed/sp_checklist.dta" if study_code !=2  , clear

    expand 2 , gen(fake)
    replace study_code = 10 if fake == 1

    binsreg cost_std time_std ///
    , by(study_code) bysymbols(o o o o o o o o o o ) ///
    bycolors(blue%50 cranberry%50 dkgreen%50 dkorange%50 lavender%50 maroon%50 black) ///
      polyreg(1) legend(on c(2) pos(5) ring(0)) ///
      legend(size(small) order(2 "Birbhum"  4 "Delhi" ///
          6 "Kenya"  8 "Madhya Pradesh"  10 "Mumbai"  12 "Patna" 14 "Total")) ///
      xtit("Standardized Time with SP") ytit("Standardized Cost to SP") ///
      plotxrange(-2 3) plotyrange(-2 2)

    graph export "${git}/outputs/fig5-price-time.png" , replace

  // Figure 5+
  use "${git}/constructed/sp_checklist.dta" if study_code !=2 , clear

    expand 2 , gen(fake)
    replace study_code = 10 if fake == 1

    replace check_std = check_std + rnormal()/1000

    binsreg cost_std check_std ///
    , by(study_code) bysymbols(o o o o o o o o o o ) ///
    bycolors(blue%50 cranberry%50 dkgreen%50 dkorange%50 lavender%50 maroon%50 black) ///
      polyreg(1) legend(on c(2) pos(5) ring(0)) ///
      legend(size(small) order(2 "Birbhum"  4 "Delhi" ///
          6 "Kenya"  8 "Madhya Pradesh"  10 "Mumbai"  12 "Patna" 14 "Total")) ///
      xtit("Standardized SP Checklist Completion") ytit("Standardized Cost to SP") ///
      plotxrange(-2 3) plotyrange(-2 2)

    graph export "${git}/outputs/fig5-price-checklist.png" , replace

// Figures 6

  // Correct-Checklist
  use "${git}/constructed/sp_checklist.dta" if study_code < 3 , clear

  binsreg correct checklist  ///
  , polyreg(1) by(study_code) ylab(${pct}) ///
    cb(1) plotyrange(0 1) ///
    savedata(${git}/outputs/temp) replace

    append using "${git}/outputs/temp.dta"
    replace CB_l = 0 if CB_l < 0

    twoway ///
    (histogram checklist if study_code == 1, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(gs14) lc(none)) ///
    (histogram checklist if study_code == 2, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(none) lc(black)) ///
    ///
      (rarea CB_l CB_r CB_x if (CB_r<=1|CB_r==.) & study_code == 1, ///
        sort cmissing(n) lcolor(none%0) fcolor(black%50) fintensity(50) ) ///
      (scatter dots_fit dots_x if dots_fit>=0 &dots_fit<=1  & study_code == 1, ///
        mcolor(black) msymbol(O) msize(large))  ///
      (line poly_fit poly_x if poly_fit>=0 ///
        & poly_fit<=1  & study_code == 1, sort lcolor(navy) lpattern(solid) lc(black) lw(thick) ) ///
    ///
      /// (rarea CB_l CB_r CB_x if (CB_r<=1|CB_r==.) & study_code == 2, ///
      ///  sort cmissing(n) lcolor(none%0) fcolor(navy%50) fintensity(50) ) ///
      (scatter dots_fit dots_x if dots_fit>=0 &dots_fit<=1  & study_code == 2, ///
        mcolor(black) msymbol(Oh) msize(large)) ///
      (line poly_fit poly_x if poly_fit>=0 ///
        & poly_fit<=1  & study_code == 2, sort lcolor(navy) lpattern(dash) lc(black) lw(thick) ) ///
    , yscale(alt) yscale(alt axis(2)) ylab(${pct}) ytit("Correct Treatment Frequency") ///
      ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%", axis(2)) ///
      ytit("Distribution (Histogram)" , axis(2)) ///
      xlab(${pct}) xtit("SP Checklist Completion") ///
      legend(on order(0 "Control:" 4 " "  5 " " 1 " " 3 " " 0 "Treatment:"  6 " " 7 " " 2 " " 0 " ") r(2) pos(12) region(lc(none)))

    graph export "${git}/outputs/fig6-birbhum-correct-checklist.png" , replace

  // Cost-Checklist
  use "${git}/constructed/sp_checklist.dta" if study_code < 3 , clear

  binsreg fee_total_usd checklist  ///
  , polyreg(1) by(study_code) ylab(${pct}) ///
    cb(1)  ///
    savedata(${git}/outputs/temp) replace

    append using "${git}/outputs/temp.dta"
    replace CB_l = 0 if CB_l < 0

    twoway ///
    (histogram checklist if study_code == 1, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(gs14) lc(none)) ///
    (histogram checklist if study_code == 2, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(none) lc(black)) ///
    ///
      (rarea CB_l CB_r CB_x if study_code == 1, ///
        sort cmissing(n) lcolor(none%0) fcolor(black%50) fintensity(50) ) ///
      (scatter dots_fit dots_x if study_code == 1, ///
        mcolor(black) msymbol(O) msize(large))  ///
      (line poly_fit poly_x if poly_fit>=0 ///
        & study_code == 1, sort lcolor(navy) lpattern(solid) lc(black) lw(thick) ) ///
    ///
      /// (rarea CB_l CB_r CB_x if (CB_r<=1|CB_r==.) & study_code == 2, ///
      ///  sort cmissing(n) lcolor(none%0) fcolor(navy%50) fintensity(50) ) ///
      (scatter dots_fit dots_x if study_code == 2, ///
        mcolor(black) msymbol(Oh) msize(large)) ///
      (line poly_fit poly_x if poly_fit>=0 ///
        & study_code == 2, sort lcolor(navy) lpattern(dash) lc(black) lw(thick) ) ///
    , yscale(alt) yscale(alt axis(2)) ylab(0 "Zero" 0.5 "$0.50" 1 "$1.00" 1.5 "$1.50") ///
      ytit("Total Cost to SP (USD)") ///
      ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%", axis(2)) ///
      ytit("Distribution (Histogram)" , axis(2)) ///
      xlab(${pct}) xtit("SP Checklist Completion") ///
      legend(on order(0 "Control:" 4 " "  5 " " 1 " " 3 " " 0 "Treatment:"  6 " " 7 " " 2 " " 0 " ") r(2) pos(12) region(lc(none)))

    graph export "${git}/outputs/fig6-birbhum-cost-checklist.png" , replace

  // Cost-Time
  use "${git}/constructed/sp_checklist.dta" if study_code < 3 , clear

  replace time = 10.1 if time > 10

  binsreg fee_total_usd time  ///
  , polyreg(1) by(study_code) ylab(${pct}) ///
    cb(1)  ///
    savedata(${git}/outputs/temp) replace

    append using "${git}/outputs/temp.dta"
    replace CB_l = 0 if CB_l < 0
    replace CB_r = 2 if CB_r > 2 & !missing(CB_r)

    gen t2 = floor(time)

    twoway ///
    (histogram t2 if study_code == 1, disc frac s(0) w(0.1) yaxis(2) barwidth(0.9) fc(gs14) lc(none)) ///
    (histogram t2 if study_code == 2, disc frac s(0) w(0.1) yaxis(2) barwidth(0.9) fc(none) lc(black)) ///
    ///
      (rarea CB_l CB_r CB_x if study_code == 1, ///
        sort cmissing(n) lcolor(none%0) fcolor(black%50) fintensity(50) ) ///
      (scatter dots_fit dots_x if study_code == 1, ///
        mcolor(black) msymbol(O) msize(large))  ///
      (line poly_fit poly_x if poly_fit>=0 ///
        & study_code == 1, sort lcolor(navy) lpattern(solid) lc(black) lw(thick) ) ///
    ///
      /// (rarea CB_l CB_r CB_x if (CB_r<=1|CB_r==.) & study_code == 2, ///
      ///  sort cmissing(n) lcolor(none%0) fcolor(navy%50) fintensity(50) ) ///
      (scatter dots_fit dots_x if study_code == 2, ///
        mcolor(black) msymbol(Oh) msize(large)) ///
      (line poly_fit poly_x if poly_fit>=0 ///
        & study_code == 2, sort lcolor(navy) lpattern(dash) lc(black) lw(thick) ) ///
    , yscale(alt) yscale(alt axis(2)) ylab(0 "Zero" 0.5 "$0.50" 1 "$1.00" 1.5 "$1.50" 2 "$2.00") ///
      ytit("Total Cost to SP (USD)") ///
      ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%", axis(2)) ///
      ytit("Distribution (Histogram)" , axis(2)) ///
      xtit("Time with SP (Minutes)") ///
      legend(on order(0 "Control:" 4 " "  5 " " 1 " " 3 " " 0 "Treatment:"  6 " " 7 " " 2 " " 0 " ") r(2) pos(12) region(lc(none)))

    graph export "${git}/outputs/fig6-birbhum-cost-checklist.png" , replace

// Figure 8 to replace Table 9

use "${git}/constructed/sp-birbhum.dta" , clear
  betterbarci ///
    cost_total_usd cost_consult_usd cost_meds_usd cost_unnec1_usd, over(treatment) ///
      legend(on order(2 "Treatment" 1 "Control") ring(1) pos(12) region(lc(none))) ///
      barlab ylab(0 "$0.00" 0.5 "$0.50" 1 "$1.00") xoverhang v xscale(reverse) yscale(noline) ///
      title("Average Costs to Patient")

      graph save "${git}/outputs/fig8-birbhum-fees-1.gph" , replace

  betterbarci ///
    frac_avoid frac_avoid1 frac_avoid2 , over(treatment) ///
      legend(on order(2 "Treatment" 1 "Control") ring(1) pos(12) region(lc(none))) ///
      barlab ylab(0 "0%" 0.5 "50%" 1 "100%") xoverhang pct v xscale(reverse) yscale(noline) ///
      title("Unnecessary Share of Costs")

      graph save "${git}/outputs/fig8-birbhum-fees-2.gph" , replace

  graph combine ///
    "${git}/outputs/fig8-birbhum-fees-1.gph" ///
    "${git}/outputs/fig8-birbhum-fees-2.gph" ///
  , r(1) ycom

  graph export "${git}/outputs/fig8-birbhum-fees.png" , replace

// End
