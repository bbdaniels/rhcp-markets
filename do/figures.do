
// Figure 1: Know-do gaps

  use "${git}/constructed/knowdo.dta", clear

    betterbarci correct, bar pct xlab(${pct}) xoverhang ///
      over(vignette) legend(on pos(12) region(lc(none))) by(strata) ///
      barc(gs6 gs10)

      graph export "${git}/outputs/fig1-knowdo.png" , replace

// Figure 2: Excess Capacity

  use "${git}/constructed/pope-time.dta" , clear

  gen po_timeperpatient = po_time/n

  tw ///
    (function 15/x  , range(1 25) lc(gs14)) ///
    (function 30/x  , range(2 50) lc(gs11)) ///
    (function 60/x  , range(4 50) lc(gs8)) ///
    (function 120/x , range(8 50) lc(gs5)) ///
    (function 240/x , range(16 50) lc(gs2)) ///
    (scatter po_timeperpatient n if study == 1, m(Oh) mlc(black) mfc(none) mlw(thin) jitter(1)) ///
    (scatter po_timeperpatient n if study == 2, m(X) mlc(black) mfc(none) mlw(thin) jitter(1)) ///
  , yscale(log) xscale(log) title("Working Days in Rural India") xoverhang ///
    ylab(2.5 "2.5 Minutes" 5 "5 Minutes" 10 "10 Minutes" 20 `""20 Minutes" "Per Patient""') ///
    xlab(1 "One Patient Per Day" 5 "Five Patients" 25 "25 Patients") ///
    legend(on order(6 "MP" 7 "Birbhum" 0 0 0 0 1 "15 Minutes" 2 "30 Minutes" 3 "One Hour" 4 "Two Hours" 5 "Four Hours") ///
          symxsize(small) size(small) r(2) ring(1) pos(11) region(lc(none)))

    graph export "${git}/outputs/fig2-capacity.png" , replace

// Figure 3-4-5: Checklist-time-correct

  use "${git}/constructed/sp_checklist.dta" , clear

  // Figure 3
  binsreg check_std time_std , by(study_code) ///
    polyreg(3) legend(on c(2) pos(5) ring(0)) ///
    legend(size(small) order(2 "Birbhum"  4 "China"  6 "Delhi" ///
        8 "Kenya"  10 "Madhya Pradesh"  12 "Mumbai"  14 "Patna" )) ///
    xtit("Standardized Time with SP") ytit("Standardized Checklist Completion")

    graph export "${git}/outputs/fig3-time-checklist.png" , replace


  // Figure 4
    levelsof study_code, local(levels)
    local graphs ""
    local legend ""
    local x = 1
    foreach study in `levels' {
      local ++x
      local graphs "`graphs' (lpoly correct check_std if study_code == `study' , deg(1))"
      local legend `"`legend' `x' "`:label study_code `study' '" "'
    }

    tw (histogram check_std , frac s(-2) w(0.5) yaxis(2) barwidth(0.4) fc(gs14) lc(none)) ///
      `graphs' ///
      , yscale(alt) yscale(alt axis(2)) ///
        legend(on span region(lc(none)) order(`legend') r(1) pos(11) ring(1) size(small) symxsize(small)) ///
        ylab(${pct}) ytit("Correct Treatment Frequency") ///
        ylab(0 "0%" .1 "10%" .2 "20%" , axis(2)) ///
        ytit("Distribution (Histogram)" , axis(2)) ///
        xtit("Standardized Checklist Completion")

    graph export "${git}/outputs/fig4-correct-checklist.png" , replace

  // Figure 3
  binsreg cost_std time_std , by(study_code) ///
    polyreg(3) legend(on c(2) pos(5) ring(0)) ///
    legend(size(small) order(2 "Birbhum"  4 "China"  6 "Delhi" ///
        8 "Kenya"  10 "Madhya Pradesh"  12 "Mumbai"  14 "Patna" )) ///
    xtit("Standardized Time with SP") ytit("Standardized Cost to SP")

    graph export "${git}/outputs/fig5-price-checklist.png" , replace

// Figure 6-7

  use "${git}/constructed/knowdo.dta" if strata < 4 & strata != 1 & vignette == 1, clear

  tw ///
  (histogram checklist if strata == 2, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(gs14) lc(none)) ///
  (histogram checklist if strata == 3, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(none) lc(black) lp(dash)) ///
  (lpoly correct checklist if strata == 2, lc(black) deg(1)) ///
  (lpoly correct checklist if strata == 3, lc(black) lp(dash)  deg(1)) ///
  , yscale(alt) yscale(alt axis(2)) ylab(${pct}) ytit("Correct Treatment Frequency") ///
    ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%", axis(2)) ///
    ytit("Distribution (Histogram)" , axis(2)) ///
    xlab(${pct}) xtit("SP Checklist Completion") ///
    legend(on order(3 "Birbhum Control" 4 "Birbhum Treatment") r(1) pos(12) region(lc(none)))

    graph export "${git}/outputs/fig6-birbhum-correct.png" , replace

  tw ///
  (histogram checklist if strata == 2, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(gs14) lc(none)) ///
  (histogram checklist if strata == 3, frac s(0) w(0.125) yaxis(2) barwidth(0.09) fc(none) lc(black) lp(dash)) ///
  (lpoly fee_total_usd checklist if strata == 2, lc(black) deg(1)) ///
  (lpoly fee_total_usd checklist if strata == 3, lc(black) lp(dash)  deg(1)) ///
  , yscale(alt) yscale(alt axis(2)) ytit("Total Cost to SP (USD)") ///
    ylab(0.5 "$0.50" 1 "$1.00" 1.5 "$1.50") ///
    ylab(0 "0%" .1 "10%" .2 "20%" .3 "30%", axis(2)) ///
    ytit("Distribution (Histogram)" , axis(2)) ///
    xlab(${pct}) xtit("SP Checklist Completion") ///
    legend(on order(3 "Birbhum Control" 4 "Birbhum Treatment") r(1) pos(12) region(lc(none)))

    graph export "${git}/outputs/fig7-birbhum-fees.png" , replace

// End
