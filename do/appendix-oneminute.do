// PO BI Revenue calculations
use "${git}/constructed/pope-summary.dta" , clear

  reg fee_total_usd  po_time  po_adl po_assets if study == "Birbhum"
    local r_b = _b[po_time]
  reg fee_total_usd  po_time  po_adl po_assets if study == "MP"
    local r_mp = _b[po_time]

  collapse (mean) po_time  fee_total_usd ///
    (sum) tottime = po_time totfee = fee_total_usd ///
    (count) n = po_time ///
    , by(facilitycode study)

  su n if study == "Birbhum"
    local b = `r(mean)'
  su n if study == "MP"
    local mp = `r(mean)'

    mat results = [ `mp' , `b' ]

  su po_time if study == "Birbhum"
    local b = `r(mean)'
  su po_time if study == "MP"
    local mp = `r(mean)'

    mat results = results \ [ `mp' , `b' ]

  su fee_total_usd if study == "Birbhum"
    local b = `r(mean)'
  su fee_total_usd if study == "MP"
    local mp = `r(mean)'

    mat results = results \ [ `mp' , `b' ]

  su totfee if study == "Birbhum"
    local b = `r(mean)'
  su totfee if study == "MP"
    local mp = `r(mean)'

    mat results = results \ [ `mp' , `b' ]

  su tottime if study == "Birbhum"
    local b = `r(mean)'
  su tottime if study == "MP"
    local mp = `r(mean)'

    mat results = results \ [ `mp' , `b' ]
    mat old = results

    outwrite results using "${git}/outputs/a-oneminute-1.tex" ///
    , replace format(%9.2f) ///
    colnames("MP" "Birbhum" ) ///
    rownames("Patients per Day" "Time per Patient" "Fees per Patient" "Revenue per Day" "Minutes Worked per Day")

  // Add one minute

  use "${git}/constructed/pope-summary.dta" , clear

    reg fee_total_usd  po_time if study == "Birbhum"
      local r_b = _b[po_time]
      replace fee_total_usd = fee_total_usd + `r_b' if study == "Birbhum"
    reg fee_total_usd  po_time  if study == "MP"
      local r_mp = _b[po_time]
      replace fee_total_usd = fee_total_usd + `r_mp' if study == "MP"

      replace po_time = po_time + 1
      mat results = [ `r_b'*60 , `r_mp'*60 ]

    collapse (mean) po_time  fee_total_usd ///
      (sum) tottime = po_time totfee = fee_total_usd ///
      (count) n = po_time ///
      , by(facilitycode study)


    su po_time if study == "Birbhum"
      local b = `r(mean)'
    su po_time if study == "MP"
      local mp = `r(mean)'

      mat results = results \ [ `mp' , `b' ]

    su fee_total_usd if study == "Birbhum"
      local b = `r(mean)'
    su fee_total_usd if study == "MP"
      local mp = `r(mean)'

      mat results = results \ [ `mp' , `b' ]

    su totfee if study == "Birbhum"
      local b = `r(mean)'
    su totfee if study == "MP"
      local mp = `r(mean)'

      mat results = results \ [ `mp' , `b' ]

    su tottime if study == "Birbhum"
      local b = `r(mean)'
    su tottime if study == "MP"
      local mp = `r(mean)'

      mat results = results \ [ `mp' , `b' ]

  // Increases

    local mp = 100*(results[4,1]-old[4,1])/old[4,1]
    local b = 100*(results[4,2]-old[4,2])/old[4,2]
    mat results = results \ [ `mp' , `b' ]

    local mp = 100*(results[5,1]-old[5,1])/old[5,1]
    local b = 100*(results[5,2]-old[5,2])/old[5,2]
    mat results = results \ [ `mp' , `b' ]

    mat results_STARS = J(rowsof(results),colsof(results),0)

matlist results

outwrite results using "${git}/outputs/a-oneminute.xlsx" ///
, replace format(%9.2f) ///
  colnames("MP" "Birbhum" ) ///
  rownames("Panel A: Current" "Patients per Day" "Time per Patient" "Fees per Patient" "Revenue per Day" "Minutes Worked per Day" ///
           "Panel B: Add One Minute per Patient" "Patients per Day" "Time per Patient" "Fees per Patient" "Revenue per Day" "Total Time per Day" ///
           "Revenue Percentage Increase" "Workday Percentage Increase")

outwrite results using "${git}/outputs/a-oneminute-2.tex" ///
, replace format(%9.2f) ///
colnames("MP" "Birbhum" ) ///
rownames("USD per Hour" "Time per Patient" "Fees per Patient" "Revenue per Day" "Minutes Worked per Day" ///
         "Revenue \% Increase" "Workday \% Increase")
// End
