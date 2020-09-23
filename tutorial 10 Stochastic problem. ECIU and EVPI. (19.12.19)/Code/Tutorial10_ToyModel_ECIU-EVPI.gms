$Title ESM Tutorial 10

$ontext

ESM course, Tutorial 10
Simple stochastic problem. ECIU and EVPI.
Feedback, bug reportings and suggestions are highly welcome: 
iegor.riepin@b-tu.de

19.12.2019

$offtext

set s scenarios /s1,s2/;

parameters
vc_new, ic_new, vc, d_fx, d(s);

vc_new = 2;
ic_new = 4;
vc     = 20;
d('s1') = 4;
d('s2') = 6;
d_fx = 5

*******EVP

positive variables
x,y,u;

variables
TC;

equations
eq1, eq2, eq3;

eq1.. TC =e= ic_new*x + vc_new*y + vc*u;
eq2.. d_fx  =e= y+u ;
eq3.. y  =l= x;

model EVP /eq1,eq2,eq3/;
solve EVP  using LP minimizing TC;

parameter
report (*,*);
report ( "TC", "EVP")             = TC.l;
report ( "INV", "EVP")            = x.l;
report ( "y d=5(EVP)", "EVP")     = y.l+eps;
report ( "u d=5(EVP)", "EVP")     = u.l+eps;

*******SP

positive variables
xx,yy(s),uu(s);

equations
*stoch problem
eq4, eq5, eq6;

eq4..    TC  =e= ic_new*xx + sum(s, 0.5*(vc_new*yy(s) + vc*uu(s)));
eq5(s).. d(s)=e= yy(s)+uu(s);
eq6(s).. yy(s)=l= xx;

model stoch /eq4,eq5,eq6/;
solve stoch using LP minimizing TC;

report ("TC", "SP") = TC.l;
report ("INV", "SP")= xx.l;
report ("y d=4", "SP")= yy.l('s1')+eps;
report ("u d=4", "SP")= uu.l('s1')+eps;
report ("y d=6", "SP")= yy.l('s2')+eps;
report ("u d=6", "SP")= uu.l('s2')+eps;

*******SP(fixed 1st stage to EVP)

option clear = xx;
option clear = yy;
option clear = uu;

xx.fx = report ( "INV", "EVP");
solve stoch using LP minimizing TC;

report ("TC", "SPfx") = TC.l;
report ("INV", "SPfx")= xx.l;
report ("y d=4", "SPfx")= yy.l('s1')+eps;
report ("u d=4", "SPfx")= uu.l('s1')+eps;
report ("y d=6", "SPfx")= yy.l('s2')+eps;
report ("u d=6", "SPfx")= uu.l('s2')+eps;

*******WS1 problem

option clear = x;
option clear = y;
option clear = u;

d_fx = d('s1');
model WS1 /eq1,eq2,eq3/;
solve WS1 using LP minimizing TC;

report ( "TC", "WS1")             = TC.l;
report ( "INV", "WS1")            = x.l;
report ( "y d=4(WS1)", "WS1")     = y.l+eps;
report ( "u d=4(WS1)", "WS1")     = u.l+eps;

*******WS2 problem

option clear = x;
option clear = y;
option clear = u;

d_fx = d('s2');
model WS2 /eq1,eq2,eq3/;
solve WS2 using LP minimizing TC;

report ( "TC", "WS2")             = TC.l;
report ( "INV", "WS2")            = x.l;
report ( "y d=6(WS2)", "WS2")     = y.l+eps;
report ( "u d=6(WS2)", "WS2")     = u.l+eps;

*******ECIU & EVPI

report ( "ECIU", "") = report("TC","SPfx") - report("TC","SP");
report ( "EVPI", "") = report("TC","SP") - 0.5*(report("TC","WS1") + report("TC","WS2")) ;

option report:0;
display report;

*EXECUTE_UNLOAD 'stoch.gdx';