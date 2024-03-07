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

// End
