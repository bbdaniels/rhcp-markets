/* Estimation program for Frazis and Loewenstein, "Estimating Linear Regressions...", Journal of Econometrics 2003 151-178, called by binaryshell.do */

#d;
version 8;
preserve;
count;
di c(current_time);

logit $t $x $z;
predict pt;
local omq=100-$q;
centile pt,centile($q `omq');
gen lopt=pt<=r(c_1);
gen hipt=pt>=r(c_2);

/*gen v=(1-lopt-hipt)/(1-2*.01*$q);
replace lopt=lopt-.01*$q*v;
replace hipt=hipt-.01*$q*v;
*/
tabstat $x [aw=$wt],save;
matrix xmean=r(StatTot);
matrix xmean=xmean,1;
regress $y $t $x [pw=$wt];
predict ey,resid;
matrix b1=get(_b);
matrix colnames b1 = $y: ;
regress $t $x [pw=$wt];
predict et,resid;
matrix b4=get(_b);
matrix colnames b4 = aux: ;
gen etsq=et^2;
regress $t lopt hipt ,nocons;
predict etv,resid;
matrix b2=get(_b);
matrix colnames b2= tonv: ;
regress etsq [pw=$wt];
predict eetsq,resid;
matrix b3=get(_b);
matrix colnames b3= etsq: ;
/* duplicate Xs for auxiliary regression calc */
foreach var of varlist $x {;
  gen I`var'=`var';
};
/* constants for various regressions */
gen byte c=1;
gen byte cetsq=1;
gen byte caux=1;
save temp,replace;


gen e=ey*$wt;
foreach var of varlist $x {;
  replace I`var'=0;
};
replace lopt=0;
replace hipt=0;
replace cetsq=0;
replace caux=0;
save stack,replace;
u temp;
replace $y=$t;
gen e=etv;
/* correct for pt regression unweighted */
replace $wt=1;
foreach var of varlist $x {;
  replace `var'=0;
};
foreach var of varlist $x {;
  replace I`var'=0;
};
replace $t=0;
replace c=0;
replace cetsq=0;
replace caux=0;
append using stack;
save stack,replace;
u temp;
replace $y=etsq;
gen e=eetsq*$wt;
foreach var of varlist $x {;
  replace `var'=0;
};
foreach var of varlist $x {;
  replace I`var'=0;
};
replace lopt=0;
replace hipt=0;
replace c=0;
replace caux=0;
replace $t=0;
append using stack;
save stack,replace;
u temp;
replace $y=$t;
gen e=et*$wt;
foreach var of varlist $x {;
  replace `var'=0;
};
replace lopt=0;
replace hipt=0;
replace c=0;
replace cetsq=0;
replace $t=0;
append using stack;
regress $y $t $x c lopt hipt cetsq I* caux [pw=$wt],robust cluster($clust) noconst;

sort $clust;
di c(current_time);
compress;
matrix accum outer=$t $x c lopt hipt cetsq I* caux [pw=$wt], noconst;
matrix iouter=syminv(outer);
egen tag=tag($clust);
foreach var of varlist $t $x c  lopt hipt  cetsq I* caux {;
  egen S`var'=sum(e*`var'),by($clust);
  drop `var';
  rename S`var' `var';
  };
matrix accum inner= $t $x c  lopt hipt  cetsq I* caux  if tag,noconst;
egen m0=group($clust);
sum m0;
scalar M=r(max);
drop m0;


/*di c(current_time);
matrix opaccum inner= /*$x */c  lopt hipt  cetsq /* I* caux*/,group($clust) opvar(e) noconst;
di c(current_time);*/
matrix b=b1,b2,b3,b4;
scalar k=colsof(b);
matrix inner=inner*((_N-1)/(_N-k))*(M/(M-1));
matrix V=iouter*inner*iouter;
matrix b=b1,b2,b3,b4;
local names: colfullnames(b);
matrix rownames V=`names';
matrix colnames V=`names';
ereturn post b V;
ereturn display;

matrix b=get(_b);
matrix V=get(VCE);
matrix P=xmean*b4';
scalar pp=trace(P);
matrix A0=b2[1,"tonv:lopt"];
matrix omA1=b2[1,"tonv:hipt"];
scalar a0=trace(A0);
scalar a1=1-trace(omA1);
scalar ssqt=trace(b3);
scalar r2=1-ssqt/(pp*(1-pp));
scalar ff=((pp-a0)*(1-pp-a1)-r2*pp*(1-pp))/(pp*(1-pp)*(1-a0-a1)*(1-r2));
matrix beta=b1[1,"$y:anycov"];
scalar bound=trace(beta)/ff;
scalar dfda0=-r2/((1-a0-a1)^2*(1-r2))-(1-pp-a1)^2/(pp*(1-pp)*(1-r2)*(1-a0-a1)^2);
scalar dfda1=-r2/((1-a0-a1)^2*(1-r2))-(pp-a0)^2/(pp*(1-pp)*(1-r2)*(1-a0-a1)^2);
scalar dfdp=(a0*(1-pp)*(1-a1-pp)+pp*a1*(a0-pp))/((1-r2)*(1-a0-a1)*(pp*(1-pp))^2);
scalar dfdr=-(a0+a1)/((1-a0-a1)*(1-r2)^2)-
            ((1-pp)*(1-pp-a1)*a0+pp*(pp-a0)*a1)/(pp*(1-pp)*(1-a0-a1)*(1-r2)^2);
scalar dbdbols=1/ff;
scalar dbdf=-trace(beta)/ff^2;
scalar dbda0=dfda0*dbdf;
scalar dbda1=dfda1*dbdf;

scalar drdp=ssqt*(1-2*pp)/(pp*(1-pp))^2;
scalar drdssq=-1/(pp*(1-pp));
scalar dbdp=(dfdp+dfdr*drdp)*dbdf;
scalar dbdssq=dfdr*drdssq*dbdf;

matrix infac=J(5,colsof(V),0);
matrix infac[1,colnumb(V,"$y:$t")]=1;
matrix infac[2,colnumb(V,"tonv:lopt")]=1;
matrix infac[3,colnumb(V,"tonv:hipt")]=1;
matrix infac[4,colnumb(V,"aux:")]=xmean;
matrix infac[5,colnumb(V,"etsq:")]=1;

matrix g=(1\0\0\0\0),(dbdbols\dbda0\dbda1\dbdp\dbdssq);
/* reversal of sign for a1 */
matrix V[rownumb(V,"tonv:hipt"),1]=-V["tonv:hipt",.];
matrix V[1,colnumb(V,"tonv:hipt")]=-V[.,"tonv:hipt"];
matrix varbound=g'*infac*V*infac'*g;
matrix b=b[1,"$y:$t"],bound;
matrix V=varbound;
matrix colnames b = $t:ols $t:upper;
matrix rownames V = $t:ols $t:upper;
matrix colnames V = $t:ols $t:upper;

ereturn post b V;
ereturn display;

mat ols = r(table);

u temp, replace;
ivregress 2sls  $y ($t=$z) $x [pw=$wt],robust cluster($clust) first;

predict eiv,resid;
sum $t [aw=$wt],meanonly;
matrix b3=r(mean);
gen td=$t-r(mean);
capture drop e;
save temp,replace;

replace lopt=0;
replace hipt=0;
replace caux=0;
gen e=eiv*$wt;
matrix b1=get(_b);
matrix colnames b1 = $y: ;


save stack,replace;

u temp;
replace $y=$t;
replace $t=0;
foreach var of varlist $x $z {;
  replace `var'=0;
};
replace c=0;
replace caux=0;
gen e=etv;
replace $wt=1;
append using stack;
save stack,replace;

u temp;
replace $y=$t;
replace $t=0;
gen e=td*$wt;
replace td=0;
foreach var of varlist $x $z {;
  replace `var'=0;
};
replace c=0;
replace lopt=0;
replace hipt=0;

append using stack;

matrix accum qq=$z $t $x c lopt hipt caux [pw=$wt], noconst;
/* correct for pt regression not being weighted */
/*matrix accum nowt=lopt hipt ,noconst;*/
matrix hpr=qq[1..rownumb(qq,"$t")-1,"$t"...]\qq[rownumb(qq,"$t")+1...,"$t"...];
matrix vecaccum hy=$y $z $x c lopt hipt caux [pw=$wt],noconst;

egen tag=tag($clust);
foreach var of varlist $z $x c lopt hipt caux {;
  egen S`var'=sum(e*`var'),by($clust);
  drop `var';
  rename S`var' `var';
  };
matrix accum homh= $z $x c lopt hipt caux if tag,noconst;

matrix b=b1,b2,b3;
scalar k=colsof(b);
matrix homh=homh*((_N-1)/(_N-k))*(M/(M-1));
matrix ihomh=syminv(homh);
matrix V=syminv(hpr'*ihomh*hpr);
matrix b=/* V*hpr'*ihomh*hy' */ hy*ihomh*hpr*V;
local names: colfullnames(b);
matrix rownames V=`names';
matrix colnames V=`names';
/*mat b=b';*/
ereturn post b V;
ereturn display;
matrix bound=_b[$t]*(_b[hipt]-_b[lopt]);
matrix g=(1\0\0),((_b[hipt]-_b[lopt])\-_b[$t]\_b[$t]);
matrix V=get(VCE);
matrix infac=J(3,colsof(V),0);
matrix infac[1,colnumb(V,"$t")]=1;
matrix infac[2,colnumb(V,"lopt")]=1;
matrix infac[3,colnumb(V,"hipt")]=1;

matrix b=_b[$t],bound;
matrix V=g'*infac*V*infac'*g;
matrix colnames b = $t:iv $t:lower;
matrix rownames V = $t:iv $t:lower;
matrix colnames V = $t:iv $t:lower;

ereturn post b V;
ereturn display;

mat iv = r(table);

u temp, replace;
foreach var of varlist $x $z $y {;
  sum `var' [aw=$wt],meanonly;
  replace `var'=`var'-r(mean);
};
capture drop e;
gen t1=0;
gen t2=0;
gen t3=0;
foreach var of varlist  $z {;
  gen  W`var'=0;
};
foreach var of varlist  $x {;
  replace I`var'=0;
};

save temp,replace;

replace lopt=0;
replace hipt=0;
replace caux=0;
replace t1=td;

foreach var of varlist  $x {;
  replace I`var'=`var';
};
save stack,replace;

u temp;
foreach var of varlist $z {;
  replace `var'=0;
};
foreach var of varlist $x {;
  replace I`var'=0;
};
replace t2=td;
replace lopt=0;
replace hipt=0;
replace caux=0;

append using stack;
save stack,replace;

u temp;
foreach var of varlist $z {;
  replace W`var'=`var'*$t;
  sum W`var',meanonly;
  replace W`var'=W`var'-r(mean);
  replace `var'=0;
};
foreach var of varlist $x {;
  replace I`var'=0;
};
replace t3=td;
replace lopt=0;
replace hipt=0;
replace caux=0;
append using stack;
save stack,replace;

u temp;
foreach var of varlist  $z {;
  replace `var'=0;
};
foreach var of varlist $x {;
  replace `var'=0;
  replace I`var'=0;
};
replace caux=0;
replace $y=$t;
/* replace weight before weighted IV regression */
replace $wt=1;
append using stack;
save stack,replace;

u temp;
foreach var of varlist  $z {;
  replace `var'=0;
};
foreach var of varlist $x {;
  replace `var'=0;
  replace I`var'=0;
};
replace lopt=0;
replace hipt=0;
replace $y=$t;

append using stack;
ivregress 2sls $y (t1 t3 $x = $z I* W*) t2 lopt hipt caux [pw=$wt],noconst robust cluster($clust);
predict e,resid;
replace e=e*$wt;
matrix b=get(_b);

matrix accum qq=$z I* W* t1 t3 $x t2 lopt hipt caux [pw=$wt], noconst;
matrix hpr=qq[1..rownumb(qq,"t1")-1,"t1"...]\qq[rownumb(qq,"t2")...,"t1"...];
matrix vecaccum hy=$y $z  I* W* t2 lopt hipt caux [pw=$wt],noconst;
/* e already weighted */
matrix vecaccum he=e $z  I* W* t2 lopt hipt caux ,noconst;

egen tag=tag($clust);
foreach var of varlist $z I* W* t2 lopt hipt caux {;
  egen S`var'=sum(e*`var'),by($clust);
  drop `var';
  rename S`var' `var';
  };
matrix accum homh= $z I* W* t2 lopt hipt caux  if tag,noconst;
egen m0=group($clust);
sum m0;
scalar M=r(max);
drop m0;
scalar k=colsof(b);
matrix homh=homh*((_N-1)/(_N-k))*(M/(M-1));
matrix ihomh=syminv(homh);
matrix V=syminv(hpr'*ihomh*hpr);
matrix  b=V*hpr'*ihomh*hy';

matrix qover=he*ihomh*he';
scalar q=trace(qover);
di "overidentification q " q " p value " chi2tail(colsof(he)-rowsof(b),q);


matrix b=b';

local names: colfullnames(b);
matrix rownames V=`names';
matrix colnames V=`names';

ereturn post b V;
ereturn display;



scalar b1g=_b[t1];
scalar b2g=_b[t2];
scalar b3g=_b[t3];
scalar pg=_b[caux];
scalar beta=sign(b1g)*sqrt(4*pg*(1-pg)*b1g*b2g+((1-pg)*b3g-pg*b1g)^2);

matrix Vfull=get(VCE);
matrix infac=J(6,colsof(Vfull),0);
matrix infac[1,colnumb(Vfull,"t1")]=1;
matrix infac[2,colnumb(Vfull,"t2")]=1;
matrix infac[3,colnumb(Vfull,"t3")]=1;
matrix infac[4,colnumb(Vfull,"caux")]=1;
matrix infac[5,colnumb(Vfull,"lopt")]=1;
matrix infac[6,colnumb(Vfull,"hipt")]=-1;


scalar dbdb1=(2*pg*(1-pg)*b2g-pg*((1-pg)*b3g-pg*b1g))/beta;
scalar dbdb2=2*pg*(1-pg)*b1g/beta;
scalar dbdb3=((1-pg)*b3g-pg*b1g)*(1-pg)/beta;
scalar dbdp=(2*b1g*b2g*(1-2*pg)-(b1g+b3g)*((1-pg)*b3g-pg*b1g))/beta;
matrix fb=dbdb1\dbdb2\dbdb3\dbdp\0\0;

scalar da1db1=((1-pg)*b3g+beta)/(2*b1g^2)-dbdb1/(2*b1g);
scalar da1db2=-dbdb2/(2*b1g);
scalar da1db3=-((1-pg)+dbdb3)/(2*b1g);
scalar da1dp=(b3g-b1g-dbdp)/(2*b1g);

scalar da0db1=(beta/b1g^2)-dbdb1/b1g-da1db1;
scalar da0db2=-dbdb2/b1g-da1db2;
scalar da0db3=-dbdb3/b1g-da1db3;
scalar da0dp =-dbdp/b1g -da1dp;

matrix f2=da0db1\da0db2\da0db3\da0dp\0\0;
matrix f3=da1db1\da1db2\da1db3\da1dp\0\0;
matrix a0f=0\0\0\0\1\0;
matrix a1f=0\0\0\0\0\1;
matrix g=fb,f2,f3,a0f,a1f;
scalar a1=((1-pg)*(b1g-b3g)+b1g-beta)/(2*b1g);
scalar a0=-beta/b1g+1-a1;
scalar a0b=_b[lopt];
scalar a1b=1-_b[hipt];

matrix vrel=infac*Vfull*infac';
matrix V=g'*vrel*g;
matrix b=beta,a0,a1,a0b,a1b;
matrix colnames b= beta a0 a1 a0b a1b;

local names: colfullnames(b);
matrix rownames V=`names';
matrix colnames V=`names';

matrix Vtau=V[2..5,2..5];
matrix fac2=I(4);
matrix fac2[3,1]=-1;
matrix fac2[4,2]=-1;
matrix Vtau=fac2*Vtau*fac2';
scalar tau=0;
if a0<0 & a1>=0 & a1<=a1b scalar tau=(a0^2/Vtau[1,1]);
if a0>=0 & a1<0 & a0<=a0b scalar tau=(a1^2/Vtau[2,2]);
if a0>=a0b & a1>=0 & a1<=a1b scalar tau=((a0-a0b)^2/Vtau[3,3]);
if a0>=0 & a0<=a0b & a1>a1b scalar tau=((a1-a1b)^2/Vtau[4,4]);
if tau==0 & ~(a0>=0 & a0<=a0b & a1>=0 & a1<=a1b) {;
   di "tau to be computed later";
   };
else {;
   di "tau " scalar(tau) "p value " chi2tail(2,tau);
};

ereturn post b V;
ereturn display;

matrix brel=b1g,b2g,b3g,pg,a0b,a1b;


drop _all;
quietly {;
set obs 10000;
  drawnorm b1new b2new b3new pnew a0bnew a1bnew,means(brel) cov(vrel);
  gen betanew=sqrt(4*pnew*(1-pnew)*b1new*b2new+((1-pnew)*b3new-pnew*b1new)^2);
  gen a1new=((1-pnew)*(b1new-b3new)+b1new-betanew)/(2*b1new);
  gen a0new=-betanew/b1new+1-a1new;
  keep if a1new>=0 & a0new>=0 & a1new<=a1bnew & a0new<=a0bnew;
  count;
  scalar valcount=r(N);
  scalar iter=0;
  save btemp,replace;
while valcount<10000 & iter<5000 {;
  drop _all;
  set obs 10000;
  drawnorm b1new b2new b3new pnew a0bnew a1bnew,means(brel) cov(vrel);
  gen betanew=sign(b1new)*sqrt(4*pnew*(1-pnew)*b1new*b2new+((1-pnew)*b3new-pnew*b1new)^2);
  gen a1new=((1-pnew)*(b1new-b3new)+b1new-betanew)/(2*b1new);
  gen a0new=-betanew/b1new+1-a1new;
  keep if a1new>=0 & a0new>=0 & a1new<=a1bnew & a0new<=a0bnew;
  count;
  scalar valcount=r(N)+valcount;
  scalar iter=iter+1;
  append using btemp;
  save btemp,replace;
  };
};
if iter<5000 {;
  sum;
  tabstat betanew a0new a1new a0bnew a1bnew,save;
  matrix b=r(StatTot);
  matrix accum V = betanew a0new a1new a0bnew a1bnew,nocons dev;
  matrix V=V/(_N-1);
  ereturn post b V;
  ereturn display;
  };
else {;
  di "iteration limit exceeded ";
};
di c(current_time);
