// Set global path locations

  ssc install repkit, replace

  global box "/Users/bbdaniels/Library/CloudStorage/Box-Box/_Papers/RHCP Markets"
  global git "/Users/bbdaniels/GitHub/rhcp-markets"
    repado using "${git}/ado/"
    cd "${git}/ado/"

    ssc install iefieldkit
    ssc install winsor
    net install binsreg , from("https://raw.githubusercontent.com/nppackages/binsreg/master/stata")

  net from "https://github.com/bbdaniels/stata/raw/main/"
    net install betterbar

  copy "https://github.com/graykimbrough/uncluttered-stata-graphs/raw/master/schemes/scheme-uncluttered.scheme" ///
    "${git}/ado/scheme-uncluttered.scheme" , replace

  set scheme uncluttered , perm
  graph set eps fontface "Helvetica"

// Globals

  // Options for -twoway- graphs
  global tw_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) ///
  	yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))

  // Options for -graph- graphs
  global graph_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left))  ///
  	yscale(noline) legend(region(lc(none) fc(none)))

  // Options for histograms
  global hist_opts ///
  	ylab(, angle(0) axis(2)) yscale(off alt axis(2)) ///
  	ytit(, axis(2)) ytit(, axis(1))  yscale(alt)

  // Useful stuff
  global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'
  global numbering `""(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)""'
  global bar lc(white) lw(thin) la(center) fi(100)

// Run code past here

  foreach file in "knowdo_data" "MP_DataSet_EconPaper" {

    iecodebook export "${box}/constructed/`file'.dta" ///
      using "${git}/data/`file'.xlsx" ///
    , save replace sign reset
  }

  iecodebook export "${box}/data/public/maqari_pope.dta" ///
    using "${git}/data/maqari_pope.xlsx" ///
  , save replace sign reset

  iecodebook export "${box}/data/raw/birbhum_pope.dta" ///
    using "${git}/data/birbhum_pope.xlsx" ///
  , save replace sign reset


// End of runfile
