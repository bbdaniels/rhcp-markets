*! ranktest 1.1.02  15oct2007
*! author mes, based on code by fk

program define ranktest, rclass
	version 9.2
	local lversion 01.1.00
	
	if substr("`1'",1,1)== "," {
		if "`2'"=="version" {
			di in ye "`lversion'"
			return local version `lversion'
			exit
		}
		else {
di as err "invalid syntax"
			exit 198
		}
	}

* If varlist 1 or varlist 2 have a single element, parentheses optional

	if substr("`1'",1,1)=="(" {
		GetVarlist `0'
		local y `s(varlist)'
		local K : word count `y'
		local 0 `"`s(rest)'"'
		sret clear
	}
	else {
		local y `1'
		local K 1
		mac shift 1
		local 0 `"`*'"'
	}

	if substr("`1'",1,1)=="(" {
		GetVarlist `0'
		local z `s(varlist)'
		local L : word count `z'
		local 0 `"`s(rest)'"'
		sret clear
	}
	else {
		local z `1'
		local K 1
		mac shift 1
* Need to reinsert comma before options (if any) for -syntax- command to work
		local 0 `", `*'"'
	}

* Option version ignored here if varlists were provided
	syntax [if] [in] [aw fw pw iw/] [, partial(varlist ts) fwl(varlist ts) /*
		*/ NOConstant wald ALLrank NULLrank FULLrank ROBust cluster(varname) /*
		*/ BW(string) kernel(string) Tvar(varname) Ivar(varname) version]

	local partial "`partial' `fwl'"
		
	marksample touse

	if "`noconstant'"=="" {
		tempvar one
		gen byte `one' = 1
		local partial "`partial' `one'"
	}

	if "`wald'"~="" {
		local LMWald "Wald"
	}
	else {
		local LMWald "LM"
	}
	
	local optct : word count `allrank' `nullrank' `fullrank'
	if `optct' > 1 {
di as err "Incompatible options: `allrank' `nullrank' `fullrank'"
		error 198
	}
	else if `optct' == 0 {
* Default
		local allrank "allrank"
	}

	tsrevar `y'
	local vl1 `r(varlist)'
	tsrevar `z'
	local vl2 `r(varlist)'
	tsrevar `partial'
	local partial `r(varlist)'

	foreach vn of varlist `vl1' {
		tempvar tv
		qui gen double `tv' = .
		local tempvl1 "`tempvl1' `tv'"
	}
	foreach vn of varlist `vl2' {
		tempvar tv
		qui gen double `tv' = .
		local tempvl2 "`tempvl2' `tv'"
	}

	tempvar wvar
	if "`weight'" == "fweight" | "`weight'"=="aweight" {
		local wtexp `"[`weight'=`exp']"'
		gen double `wvar'=`exp'
	}
	if "`weight'" == "fweight" & "`kernel'" !="" {
		di in red "fweights not allowed (data are -tsset-)"
		exit 101
	}
	if "`weight'" == "iweight" {
		if "`robust'`cluster'`bw'" !="" {
			di in red "iweights not allowed with robust, cluster, AC or HAC"
			exit 101
		}
		else {
			local wtexp `"[`weight'=`exp']"'
			gen double `wvar'=`exp'
		}
	}
	if "`weight'" == "pweight" {
		local wtexp `"[aweight=`exp']"'
		gen double `wvar'=`exp'
		local robust "robust"
	}
	if "`weight'" == "" {
* If no weights, define neutral weight variable
		qui gen byte `wvar'=1
	}
	else if "`weight'"=="aweight" | "`weight'" == "pweight" {
		sum `wvar' if `touse', meanonly
		qui replace `wvar'=`wvar'*r(N)/r(sum)
	}

	markout `touse' `vl1' `vl2' `partial'
			
* HAC estimation.
* If bw is omitted, default `bw' is empty string.
* If bw or kernel supplied, check/set `kernel'.
* Macro `kernel' is also used for indicating HAC in use.
	if "`bw'" != "" | "`kernel'" != "" {
* Need tvar only for markout with time-series stuff
* but data must be tsset for time-series operators in code to work
		if "`tvar'" == "" {
			local tvar "`_dta[_TStvar]'"
		}
		else if "`tvar'"!="`_dta[_TStvar]'" {
di as err "invalid tvar() option - data already tsset"
			exit 5
		}
		if "`ivar'" == "" {
			local ivar "`_dta[_TSpanel]'"
		}
		else if "`ivar'"!="`_dta[_TSpanel]'" {
di as err "invalid ivar() option - data already tsset"
			exit 5
		}
		if "`tvar'" == "" & "`ivar'" != "" {
di as err "missing tvar() option with ivar() option"
			exit 5
		}
		if "`ivar'`tvar'"=="" {
			capture tsset
		}
		else {
			capture tsset `ivar' `tvar'
		}
		capture local tvar "`r(timevar)'"
		capture local ivar "`r(panelvar)'"
	
		if "`tvar'" == "" {
di as err "must tsset data and specify timevar"
			exit 5
		}
		tsreport if `tvar' != .
		if `r(N_gaps)' != 0 & "`ivar'"=="" {
di in gr "Warning: time variable " in ye "`tvar'" in gr " has " /*
	*/ in ye "`r(N_gaps)'" in gr " gap(s) in relevant range"
		}

		if "`bw'" == "" {
di as err "bandwidth option bw() required for HAC-robust estimation"
			exit 102
		}
		local bw real("`bw'")
* Check it's a valid bandwidth; allow non-integer bandwidth
//		if   `bw' != int(`bw') | /*
		if   `bw' == .  | /*
			*/   `bw' <= 0 {
di as err "invalid bandwidth in option bw() - must be integer > 0"
			exit 198
		}
* Convert bw macro to simple integer
		local bw=`bw'

* Check it's a valid kernel
		local validkernel 0
		if lower(substr("`kernel'", 1, 3)) == "bar" | "`kernel'" == "" {
* Default kernel
			local kernel "Bartlett"
			local window "lag"
			local validkernel 1
			if `bw'==1 {
di in ye "Note: kernel=Bartlett and bw=1 implies zero lags used."
di in ye "      Test statistics are not autocorrelation-consistent."
			}
		}
		if lower(substr("`kernel'", 1, 3)) == "par" {
			local kernel "Parzen"
			local window "lag"
			local validkernel 1
			if `bw'==1 {
di in ye "Note: kernel=Parzen and bw=1 implies zero lags used."
di in ye "      Test statistics are not autocorrelation-consistent."
			}
		}
		if lower(substr("`kernel'", 1, 3)) == "tru" {
			local kernel "Truncated"
			local window "lag"
			local validkernel 1
		}
		if lower(substr("`kernel'", 1, 9)) == "tukey-han" | lower("`kernel'") == "thann" {
			local kernel "Tukey-Hanning"
			local window "lag"
			local validkernel 1
			if `bw'==1 {
di in ye "Note: kernel=Tukey-Hanning and bw=1 implies zero lags."
di in ye "      Test statistics are not autocorrelation-consistent."
			}
		}
		if lower(substr("`kernel'", 1, 9)) == "tukey-ham" | lower("`kernel'") == "thamm" {
			local kernel "Tukey-Hamming"
			local window "lag"
			local validkernel 1
			if `bw'==1 {
di in ye "Note: kernel=Tukey-Hamming and bw=1 implies zero lags."
di in ye "      Test statistics are not autocorrelation-consistent."
			}
		}
		if lower(substr("`kernel'", 1, 3)) == "qua" | lower("`kernel'") == "qs" {
			local kernel "Quadratic spectral"
			local window "spectral"
			local validkernel 1
		}
		if lower(substr("`kernel'", 1, 3)) == "dan" {
			local kernel "Daniell"
			local window "spectral"
			local validkernel 1
		}
		if lower(substr("`kernel'", 1, 3)) == "ten" {
			local kernel "Tent"
			local window "spectral"
			local validkernel 1
		}
		if ~`validkernel' {
			di in red "invalid kernel"
			exit 198
		}
	}
	else {
		local bw 1
	}

* Note that bw is passed as a value, not as a string
	mata: rkstat("`vl1'", "`vl2'", "`partial'", "`wvar'", "`weight'", "`touse'", /*
		*/ "`LMWald'", "`allrank'", "`nullrank'", "`fullrank'", "`robust'", "`cluster'", /*
		*/ `bw', "`kernel'", "`window'", "`tempvl1'", "`tempvl2'")

	tempname rkmatrix chi2 df df_r p rank ccorr eval
	mat `rkmatrix'=r(rkmatrix)
	mat `ccorr'=r(ccorr)
	mat `eval'=r(eval)
	mat colnames `rkmatrix' = "rk" "df" "p" "rank" "eval" "ccorr"
	
di
di "Kleibergen-Paap rk `LMWald' test of rank of matrix"
	if "`robust'"~="" & "`kernel'"~= "" {
di "  Test statistic robust to heteroskedasticity and autocorrelation"
di "  Kernel: `kernel'   Bandwidth: `bw'"
	}
	else if "`kernel'"~="" {
di "  Test statistic robust to autocorrelation"
di "  Kernel: `kernel'   Bandwidth: `bw'"
	}
	else if "`cluster'"~="" {
di "  Test statistic robust to heteroskedasticity and clustering on `cluster'"
	}
	else if "`robust'"~="" {
di "  Test statistic robust to heteroskedasticity"
	}
	else if "`LMWald'"=="LM" {
di "  Test assumes homoskedasticity (Anderson canonical correlations test)"
	}
	else {
di "  Test assumes homoskedasticity (Cragg-Donald test)"
	}
		
	local numtests = rowsof(`rkmatrix')
	forvalues i=1(1)`numtests' {
di "Test of rank=" %3.0f `rkmatrix'[`i',4] "  rk=" %8.2f `rkmatrix'[`i',1] /*
	*/	"  Chi-sq(" %3.0f `rkmatrix'[`i',2] ") pvalue=" %8.6f `rkmatrix'[`i',3]
	}
	scalar `chi2' = `rkmatrix'[`numtests',1]
	scalar `p' = `rkmatrix'[`numtests',3]
	scalar `df' = `rkmatrix'[`numtests',2]
	scalar `rank' = `rkmatrix'[`numtests',4]
	local N `r(N)'
	if "`cluster'"~="" {
		local N_clust `r(N_clust)'
	}
	return scalar df = `df'
	return scalar chi2 = `chi2'
	return scalar p = `p'
	return scalar rank = `rank'
	if "`cluster'"~="" {
		return scalar N_clust = `N_clust'
	}
	return scalar N = `N'
	return matrix rkmatrix `rkmatrix'
	return matrix ccorr `ccorr'
	return matrix eval `eval'
	
	tempname S V Omega
	if `K' > 1 {
		foreach en of local y {
* Remove "." from equation name
			local en1 : subinstr local en "." "_", all
			foreach vn of local z {
				local cn "`cn' `en1':`vn'"
			}
		}
	}
	else {
		foreach vn of local z {
		local cn "`cn' `vn'"
		}
	}
	mat `V'=r(V)
	matrix colnames `V' = `cn'
	matrix rownames `V' = `cn'
	return matrix V `V'
end

* Adopted from -canon-
program define GetVarlist, sclass 
	sret clear
	gettoken open 0 : 0, parse("(") 
	if `"`open'"' != "(" {
		error 198
	}
	gettoken next 0 : 0, parse(")")
	while `"`next'"' != ")" {
		if `"`next'"'=="" { 
			error 198
		}
		local list `list'`next'
		gettoken next 0 : 0, parse(")")
	}
	sret local rest `"`0'"'
	tokenize `list'
	local 0 `*'
	sret local varlist "`0'"
end

version 9.2
mata:
void rkstat(string scalar vl1, string scalar vl2, string scalar partial, /*
	*/ string scalar wvar, string scalar weight, string scalar touse, string scalar LMWald, /*
	*/ string scalar allrank, string scalar nullrank, string scalar fullrank, /*
	*/ string scalar robust, string scalar cluster, bw, string scalar kernel, string scalar window, /*
	*/ string scalar tempvl1, string scalar tempvl2)
{

// tempx, tempy and tempz are the Stata names of temporary variables that will be changed by rkstat
	if (partial~="") {
		tempx=tokens(partial)
	}
	tempy=tokens(tempvl1)
	tempz=tokens(tempvl2)

	st_view(y=.,.,tokens(vl1),touse)
	st_view(z=.,.,tokens(vl2),touse)
	st_view(yhat=.,.,tempy,touse)
	st_view(zhat=.,.,tempz,touse)
	st_view(mtouse=.,.,tokens(touse),touse)
	st_view(mwvar=.,.,tokens(wvar),touse)
	noweight=(st_vartype(wvar)=="byte")

// Effective number of observations is sum of weight variable.
// If no weights, then wvar is ones.
	N=colsum(mwvar)
// Stata convention is to truncate sum of iweights so it's an integer
	if (weight=="iweight") {
		N=trunc(N)
	}
	if (cluster~="") {
		st_view(clustvar,.,cluster,touse)
		info = panelsetup(clustvar, 1)
		N_clust=rows(info)
	}

// Partial out the X variables
	if (partial~="") {
		st_view(x=.,.,tempx,touse)
		xx = quadcross(x, mwvar, x)
		xy = quadcross(x, mwvar, y)
		xz = quadcross(x, mwvar, z)
// y=XB => X'y=X'XB
		by = qrsolve(xx,xy)
		bz = qrsolve(xx,xz)
		yhat[.,.] = y-x*by
		zhat[.,.] = z-x*bz
	}
	else {
		yhat[.,.] = y
		zhat[.,.] = z
	}

	K=cols(y)
	L=cols(z)

	zhzh = quadcross(zhat, mwvar, zhat)
	zhyh = quadcross(zhat, mwvar, yhat)
	yhyh = quadcross(yhat, mwvar, yhat)

	pihat = qrsolve(zhzh,zhyh)
// rzhat is F in paper (p. 103)
// iryhat is G in paper (p. 103)
	ryhat=cholesky(yhyh)
	rzhat=cholesky(zhzh)
	iryhat=luinv(ryhat')
	irzhat=luinv(rzhat')
	that=rzhat'*pihat*iryhat

// cc is canonical correlations.  Squared cc is eigenvalues.
	fullsvd(that, ut, cc, vt)
	vt=vt'
	vecth=vec(that)
	ev = cc:^2
// S matrix in paper (p. 100).  Not used in code below.
//	smat=fullsdiag(cc, rows(that)-cols(that))

	if (abs(1-cc[1,1])<1e-10) {
printf("\n{text:Warning: collinearities detected between (varlist1) and (varlist2)}\n")
	}
	if ((missing(ryhat)>0) | (missing(iryhat)>0) | (missing(rzhat)>0) | (missing(irzhat)>0)) {
printf("\n{error:Error: non-positive-definite matrix. May be caused by collinearities.}\n")
		exit(error(3351))
	}

// If Wald, yhat is residuals
	if (LMWald=="Wald") {
		yhat[.,.]=yhat-zhat*pihat
		yhyh = quadcross(yhat, mwvar, yhat)
	}

// Covariance matrices
// vhat is W in paper (eqn below equation 17, p. 103)
// shat is V in paper (eqn below eqn 15, p. 103)
// shat * 1/N is same as estimated S matrix of orthog conditions as e.g. saved by ivreg2
//    (including cluster case)

	if ((LMWald=="LM") & (kernel=="") & (robust=="") & (cluster=="")) {
// Homoskedastic, iid LM case means vcv is identity matrix
// Generates canonical correlation stats.  Default.
		vhat=I(L*K,L*K)/N
	}
	else if ((robust=="") & (cluster=="")) {
// Block for homoskedastic and AC.
		sigma2=yhyh/N
		shat=sigma2#zhzh

		if (kernel~="") {
			if (window=="spectral") {
				TAU=st_nobs()-1
			}
			else {
				TAU=bw
			}
			for (tau=1; tau<=TAU; tau++) {
				sigmahat=J(K,K,0)
				zzhat=J(L,L,0)
				for (i=tau+1; i<=st_nobs(); i++) {
					mtousei=st_data(i,touse)
					mtousei1=st_data(i,"L"+strofreal(tau)+"."+touse)
					if ((mtousei==1) & (mtousei1==1)) {
						mwvari=st_data(i,wvar)
						mwvari1=st_data(i,"L"+strofreal(tau)+"."+wvar)
						yi=st_data(i,tempy)
						yi1names = J(1,0,"")
						for (r=1; r<=cols(y); r++) {
							yi1names = yi1names, "L"+strofreal(tau)+"."+tempy[r]
						}
						yi1=st_data(i,yi1names)
// Should never happen that fweights or iweights make it here, but if they did they would be sqrts
						sigmahat=sigmahat+quadcross(yi,yi1)*mwvari*mwvari1/N
						zi=st_data(i,tempz)
						zi1names = J(1,0,"")
						for (r=1; r<=cols(z); r++) {
							zi1names = zi1names, "L"+strofreal(tau)+"."+tempz[r]
						}
						zi1=st_data(i,zi1names)
// Should never happen that fweights or iweights make it here, but if they did they would be sqrts
						zzhat=zzhat+quadcross(zi,zi1)*mwvari*mwvari1
					}
				}

				ghat = sigmahat#zzhat
				karg = tau/bw

				if (kernel=="Truncated") {
					kw=1
				}
				if (kernel=="Bartlett") {
					kw=(1-karg)
				}
				if (kernel=="Parzen") {
					if (karg <= 0.5) {
						kw = 1-6*karg^2+6*karg^3
					}
					else {
						kw = 2*(1-karg)^3
					}
				}
				if (kernel=="Tukey-Hanning") {
					kw=0.5+0.5*cos(pi()*karg)
				}
				if (kernel=="Tukey-Hamming") {
					kw=0.54+0.46*cos(pi()*karg)
				}
				if (kernel=="Tent") {
					kw=2*(1-cos(tau*karg)) / (karg^2)
				}
				if (kernel=="Daniell") {
					kw=sin(pi()*karg) / (pi()*karg)
				}
				if (kernel=="Quadratic spectral") {
					kw=25/(12*pi()^2*karg^2) /*
						*/ * ( sin(6*pi()*karg/5)/(6*pi()*karg/5) /*
						*/     - cos(6*pi()*karg/5) )
				}

				shat=shat+kw*(ghat+ghat')
			}
		}
		vhat=(iryhat'#irzhat')*shat*(iryhat'#irzhat')'
		vhat=(vhat+vhat')/2
	}
	else if (cluster=="") {
// Block for HC and HAC
		shat=J(L*K,L*K,0)
		for (i=1; i<=rows(yhat); i++) {
			yzi=yhat[i,.]#zhat[i,.]
			if ((weight=="fweight") | (weight=="iweight")) {
// mwvar is a column vector
				shat=shat+quadcross(yzi,yzi)*mwvar[i]
			}
			else {
				shat=shat+quadcross(yzi,yzi)*(mwvar[i])^2
			}
		}

		if (kernel~="") {

// Spectral windows require looping through all T-1 autocovariances
			if (window=="spectral") {
				TAU=st_nobs()-1
			}
			else {
				TAU=bw
			}

			for (tau=1; tau<=TAU; tau++) {
				ghat=J(L*K,L*K,0)

				for (i=tau+1; i<=st_nobs(); i++) {
					mtousei=st_data(i,touse)
					mtousei1=st_data(i,"L"+strofreal(tau)+"."+touse)
					if ((mtousei==1) & (mtousei1==1)) {
						yi=st_data(i,tempy)
						yi1names = J(1,0,"")
						for (r=1; r<=cols(y); r++) {
							yi1names = yi1names, "L"+strofreal(tau)+"."+tempy[r]
						}
						yi1=st_data(i,yi1names)
						zi=st_data(i,tempz)
						zi1names = J(1,0,"")
						for (r=1; r<=cols(z); r++) {
							zi1names = zi1names, "L"+strofreal(tau)+"."+tempz[r]
						}
						zi1=st_data(i,zi1names)
						mwvari=st_data(i,wvar)
						mwvari1=st_data(i,"L"+strofreal(tau)+"."+wvar)
						yzi =yi#zi
						yzi1=yi1#zi1
// Should never happen that fweights or iweights make it here, but if they did
// the next line would be ghat=ghat+yzi'*yzi1*sqrt(mwvari)*sqrt(mwvari1)
						ghat=ghat+quadcross(yzi,yzi1)*mwvari*mwvari1
					}
				}
				
				karg = tau/bw

				if (kernel=="Truncated") {
					kw=1
				}
				if (kernel=="Bartlett") {
					kw=(1-karg)
				}

				if (kernel=="Parzen") {
					if (karg <= 0.5) {
						kw = 1-6*karg^2+6*karg^3
					}
					else {
						kw = 2*(1-karg)^3
					}
				}

				if (kernel=="Tukey-Hanning") {
					kw=0.5+0.5*cos(pi()*karg)
				}

				if (kernel=="Tukey-Hamming") {
					kw=0.54+0.46*cos(pi()*karg)
				}
				if (kernel=="Tent") {
					kw=2*(1-cos(tau*karg)) / (karg^2)
				}
				if (kernel=="Daniell") {
					kw=sin(pi()*karg) / (pi()*karg)
				}
				if (kernel=="Quadratic spectral") {
					kw=25/(12*pi()^2*karg^2) /*
						*/ * ( sin(6*pi()*karg/5)/(6*pi()*karg/5) /*
						*/     - cos(6*pi()*karg/5) )
				}
// Saves a matrix multiplication of w=1 (e.g., last loop of Bartlett-NW)
				if (kw > 0) {
					shat=shat+kw*(ghat+ghat')
				}
			}
		}

		vhat=(iryhat'#irzhat')*shat*(iryhat'#irzhat')'
		vhat=(vhat+vhat')/2
	}
	else {
// Block for cluster-robust
		shat=J(L*K,L*K,0)

		for (i=1; i<=N_clust; i++) {
			yz=J(1,L*K,0)
			ysub=panelsubmatrix(yhat,i,info)
			zsub=panelsubmatrix(zhat,i,info)
			mwsub=panelsubmatrix(mwvar,i,info)
			for (j=1; j<=rows(ysub); j++) {
				yz=yz+(ysub[j,.]#zsub[j,.])*mwsub[j,.]
			}
			shat=shat+quadcross(yz,yz)
		}

		vhat=(iryhat'#irzhat')*shat*(iryhat'#irzhat')'
		vhat=(vhat+vhat')/2
	}

// ready to start collecting test stats
	if (allrank~="") {
		firstrank=1
		lastrank=min((K,L))
	}
	else if (nullrank~="") {
		firstrank=1
		lastrank=1
	}
	else if (fullrank~="") {
		firstrank=min((K,L))
		lastrank=min((K,L))
	}
	else {
// should never reach this point
printf("ranktest error\n")
		exit
	}

	rkmatrix=J(lastrank-firstrank+1,6,.)
	for (i=firstrank; i<=lastrank; i++) {

		if (i>1) {
			u12=ut[(1::i-1),(i..L)]
			v12=vt[(1::i-1),(i..K)]
		}
		u22=ut[(i::L),(i..L)]
		v22=vt[(i::K),(i..K)]
		
		symeigensystem(u22*u22', evec, eval)
		u22v=evec
		u22d=diag(eval)
		u22h=u22v*(u22d:^0.5)*u22v'

		symeigensystem(v22*v22', evec, eval)
		v22v=evec
		v22d=diag(eval)
		v22h=v22v*(v22d:^0.5)*v22v'

		if (i>1) {
			aq=(u12 \ u22)*luinv(u22)*u22h
			bq=v22h*luinv(v22')*(v12 \ v22)'
		}
		else {
			aq=u22*luinv(u22)*u22h
			bq=v22h*luinv(v22')*v22'
		}

// lab is lambda_q in paper (eqn below equation 21, p. 104)
// vlab is omega_q in paper (eqn 19 in paper, p. 104)
		lab=(bq#aq')*vecth
		vlab=(bq#aq')*vhat*(bq#aq')'

// Symmetrize if numerical inaccuracy means it isn't
		vlab=(vlab+vlab')/2
		vlabinv=invsym(vlab)
// rk stat Assumption 2: vlab (omega_q in paper) is nonsingular.  Detected by a zero on the diagonal,
// since when returning a generalized inverse, Stata/Mata choose the generalized inverse that
// sets entire column(s)/row(s) to zeros.
// Save df and rank even if test stat not available.
		df=(L-i+1)*(K-i+1)
		rkmatrix[i-firstrank+1,2]=df
		rkmatrix[i-firstrank+1,4]=i-1
		if (diag0cnt(vlabinv)>0) {
printf("\n{text:Warning: covariance matrix omega_%f}", i-1)
printf("{text: not full rank; test of rank %f}", i-1)
printf("{text: unavailable}\n")
		}
// Note not multiplying by N - already incorporated in vhat.
		else {
			rk=lab'*vlabinv*lab
			pvalue=chi2tail(df, rk)
			rkmatrix[i-firstrank+1,1]=rk
			rkmatrix[i-firstrank+1,3]=pvalue
		}
// end of test loop
	}

// insert squared (=eigenvalues if canon corr) and unsquared canon correlations
	for (i=firstrank; i<=lastrank; i++) {
		rkmatrix[i-firstrank+1,6]=cc[i-firstrank+1,1]
		rkmatrix[i-firstrank+1,5]=ev[i-firstrank+1,1]
	}
	st_matrix("r(rkmatrix)", rkmatrix)
	st_matrix("r(ccorr)", cc')
	st_matrix("r(eval)",ev')
// Save V matrix as in paper, without factor of 1/N
	vhat=N*vhat
	st_matrix("r(V)", vhat)
	st_numscalar("r(N)", N)
	if (cluster~="") {
		st_numscalar("r(N_clust)", N_clust)
	}

// end of program
}
end

* Version notes
* 1.0.00  First distributed version
* 1.0.01  With iweights, rkstat truncates N to mimic official Stata treatment of noninteger iweights
*         Added warning if shat/vhat/vlab not of full rank.
* 1.0.02  Added NULLrank option
*         Added eq names to saved V and S matrices
* 1.0.03  Added error catching for collinearities between varlists
*         Not saving S matrix; V matrix now as in paper (without 1/N factor)
*         Statistic, p-value etc set to missing if vcv not of full rank (Assumpt 2 in paper fails)
* 1.0.04  Fixed touse bug - was treating missings as touse-able
*         Change some cross-products in robust loops to quadcross
* 1.0.05  Fixed bug with col/row names and ts operators.  Added eval to saved matrices.
* 1.1.00  First ssc-ideas version.  Added version 9.2 prior to Mata compiled section.
* 1.1.01  Allow non-integer bandwidth
* 1.1.02  Changed calc of yhat, zhat and pihat to avoid needlessly large intermediate matrices
*         and to use more accurate qrsolve instead of inverted X'X.
