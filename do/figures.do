
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

// Figure 6-7

  use "${git}/constructed/sp_checklist.dta" if study_code < 3 , clear


  tw ///
  (histogram checklist if study_code == 1, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(gs14) lc(none)) ///
  (histogram checklist if study_code == 2, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(none) lc(black) lp(dash)) ///
  (lfit correct checklist if study_code == 1, lc(black) ) ///
  (lfit correct checklist if study_code == 2, lc(black) lp(dash)) ///
  , yscale(alt) yscale(alt axis(2)) ylab(${pct}) ytit("Correct Treatment Frequency") ///
    ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%", axis(2)) ///
    ytit("Distribution (Histogram)" , axis(2)) ///
    xlab(${pct}) xtit("SP Checklist Completion") ///
    legend(on order(3 "Birbhum Control" 4 "Birbhum Treatment") r(1) pos(12) region(lc(none)))

    graph export "${git}/outputs/fig6-birbhum-correct.png" , replace

  tw ///
  (histogram checklist if study_code == 1, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(gs14) lc(none)) ///
  (histogram checklist if study_code == 2, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(none) lc(black) lp(dash)) ///
  (lfit fee_total_usd checklist if study_code == 1, lc(black) ) ///
  (lfit fee_total_usd checklist if study_code == 2, lc(black) lp(dash) ) ///
  , yscale(alt) yscale(alt axis(2)) ytit("Total Cost to SP (USD)") ///
    ylab(0 "Zero" 0.5 "$0.50" 1 "$1.00" 1.5 "$1.50") ///
    ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%", axis(2)) ///
    ytit("Distribution (Histogram)" , axis(2)) ///
    xlab(${pct}) xtit("SP Checklist Completion") ///
    legend(on order(3 "Birbhum Control" 4 "Birbhum Treatment") r(1) pos(12) region(lc(none)))

    graph export "${git}/outputs/fig7-birbhum-fees.png" , replace

  tw ///
  (histogram checklist if study_code == 1, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(gs14) lc(none)) ///
  (histogram checklist if study_code == 2, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(none) lc(black) lp(dash)) ///
  (lfit time checklist if study_code == 1, lc(black))  ///
  (lfit time checklist if study_code == 2, lc(black) lp(dash))  ///
  , yscale(alt) yscale(alt axis(2)) ytit("Time With SP") ///
    ylab(0 "Zero" 1 "1 Minute" 2 "2 Minutes" 3 "3 Minutes" 4 "4 Minutes" 5 "5 Minutes") ///
    ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%", axis(2)) ///
    ytit("Distribution (Histogram)" , axis(2)) ///
    xlab(${pct}) xtit("SP Checklist Completion") ///
    legend(on order(3 "Birbhum Control" 4 "Birbhum Treatment") r(1) pos(12) region(lc(none)))

    graph export "${git}/outputs/figX-birbhum-time.png" , replace

  gen t2 = floor(time)

  tw ///
  (histogram t2 if study_code == 1, frac s(0) w(1) yaxis(2) barwidth(0.9) fc(gs14) lc(none)) ///
  (histogram t2 if study_code == 2, frac s(0) w(1) yaxis(2) barwidth(0.9) fc(none) lc(black) lp(dash)) ///
  (lfit correct time if study_code == 1, lc(black) ) ///
  (lfit correct time if study_code == 2, lc(black) lp(dash) ) ///
  , yscale(alt) yscale(alt axis(2)) ytit("Correct Treatment Frequency") ///
    ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%", axis(2)) ///
    ytit("Distribution (Histogram)" , axis(2)) ///
    ylab(${pct}) xtit("Time with SP (Minutes)") ///
    legend(on order(3 "Birbhum Control" 4 "Birbhum Treatment") r(1) pos(12) region(lc(none)))

    graph export "${git}/outputs/figX-birbhum-time-c.png" , replace

  tw ///
  (histogram t2 if study_code == 1, frac s(0) w(1) yaxis(2) barwidth(0.9) fc(gs14) lc(none)) ///
  (histogram t2 if study_code == 2, frac s(0) w(1) yaxis(2) barwidth(0.9) fc(none) lc(black) lp(dash)) ///
  (lfit fee_total_usd time if study_code == 1, lc(black))  ///
  (lfit fee_total_usd time if study_code == 2, lc(black) lp(dash) ) ///
  , yscale(alt) yscale(alt axis(2)) ytit("Total Cost to SP (USD)") ///
    ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%", axis(2)) ///
    ytit("Distribution (Histogram)" , axis(2)) ///
    ylab(0 "Zero" 0.5 "$0.50" 1 "$1.00" 1.5 "$1.50" 2 "$2.00" 2.5 "$2.50") xtit("Time with SP (Minutes)") ///
    legend(on order(3 "Birbhum Control" 4 "Birbhum Treatment") r(1) pos(12) region(lc(none)))

    graph export "${git}/outputs/figX-birbhum-time-p.png" , replace

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
