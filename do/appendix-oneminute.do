// PO BI Revenue calculations
use "${git}/constructed/pope-summary.dta" , clear

  mat results = [. , 0]

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

    mat results = results \ [ `mp' , `b' ]

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

  // Add one minute

  use "${git}/constructed/pope-summary.dta" , clear

    reg fee_total_usd  po_time po_checklist treat_correct po_meds po_refer po_adl po_assets if study == "Birbhum"
      local r_b = _b[po_time]
      replace fee_total_usd = fee_total_usd + `r_b' if study == "Birbhum"
    reg fee_total_usd  po_time po_checklist treat_correct po_meds po_refer po_adl po_assets if study == "MP"
      local r_mp = _b[po_time]
      replace fee_total_usd = fee_total_usd + `r_mp' if study == "MP"

      replace po_time = po_time + 1
      mat results = results \ [.,0] \ [ `r_b' , `r_mp' ]

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

    local mp = 100*(results[11,1]-results[5,1])/results[5,1]
    local b = 100*(results[11,2]-results[5,2])/results[5,2]
    mat results = results \ [ `mp' , `b' ]

    local mp = 100*(results[12,1]-results[6,1])/results[6,1]
    local b = 100*(results[12,2]-results[6,2])/results[6,2]
    mat results = results \ [ `mp' , `b' ]

    mat results_STARS = J(rowsof(results),colsof(results),0)

matlist results

outwrite results using "${git}/outputs/a-oneminute.xlsx" ///
, replace format(%9.2f) ///
  colnames("MP" "Birbhum" ) ///
  rownames("Panel A: Current" "Patients per Day" "Time per Patient" "Fees per Patient" "Revenue per Day" "Total Time per Day" ///
           "Panel B: Add One Minute per Patient" "Patients per Day" "Time per Patient" "Fees per Patient" "Revenue per Day" "Total Time per Day" ///
           "Revenue Percentage Increase" "Workday Percentage Increase")

outwrite results using "${git}/outputs/a-oneminute.tex" ///
, replace format(%9.2f) ///
colnames("MP" "Birbhum" ) ///
rownames("Panel A: Current" "Patients per Day" "Time per Patient" "Fees per Patient" "Revenue per Day" "Total Time per Day" ///
         "Panel B: Add One Minute per Patient" "Patients per Day" "Time per Patient" "Fees per Patient" "Revenue per Day" "Total Time per Day" ///
         "Revenue Percentage Increase" "Workday Percentage Increase")
// End
