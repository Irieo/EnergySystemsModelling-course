$Title ESM Tutorial 3

$ontext

ESM course, Tutorial 3
Setting up a three-node toy electricity dispatch model
Iegor Riepin, LSEW BTU CS

Feedback, bug reportings and suggestions are highly welcome: 
iegor.riepin@b-tu.de

21.11.2019

$offtext

*########################### Data ########################

SETS
        p        power plants           /
P1_NUC
P2_OCGT
P3_LIG
P4_CCGT
P5_Wind
P6_CCGT
P7_OCGT
P8_Wind
/
        t        time periods           /1*24/
        n        countries (nodes)      /GER, FR, NL/
;

SETS
        c(p)            conventional plants
        r(p)            RES plants
        map_pn(p,n)     mapping of plant and country
;

alias (n,nn);

PARAMETERS
        genup            all information about generation
        timeup           all information about time-series

        cap(p)           capacities of PPs
        vc(p)            variable production costs of PPs

        demand(n,t)      demand in node N
        ntc(n,nn)        NTC value from node n to node nn [MW]
        af_wind(n,t)     availability factor for wind feed-in
;


$onecho > these_is_my_data.tmp
        set=map_pn           rng=genup!A2:A9               cdim=0 rdim=2
        par=genup            rng=genup!A1                  cdim=1 rdim=1
        par=timeup           rng=timeup!A1                 cdim=2 rdim=1
        par=ntc              rng=NTC!A1                    cdim=1 rdim=1
$offecho


$onUNDF
$call   gdxxrw I=Input.xlsx O=Input.gdx  cmerge=1 @these_is_my_data.tmp
$gdxin  Input.gdx
$load   map_pn, genup, timeup, ntc
$offUNDF

c(p)  = genup(p,'type')= 1;
r(p)  = genup(p,'type')= 2 ;

cap(p)=genup(p,'capacity');
vc(p)=genup(p,'vc');

demand(n,t)= timeup(t,'Demand',n);
af_wind(n,t)=timeup(t,'Wind availability',n) ;

*display vc, cap, demand, af_wind, c, r;

*EXECUTE_UNLOAD 'all_data.gdx';
*$stop


**********************************************************

variable
        TC;

positive variable
        G(p,n,t);

equations

OBJECTIVE
ENERGY_BALANCE
MAX_GENERATION
MAX_GENERATION_WIND
;

OBJECTIVE..        TC =e= sum((p,n,t), G(p,n,t)*vc(p));

ENERGY_BALANCE(n,t)..   demand(n,t) =e= sum(p$map_pn(p,n), G(p,n,t));

MAX_GENERATION(c,n,t)..   G(c,n,t) =l= cap(c);

MAX_GENERATION_WIND(r,n,t).. G(r,n,t) =e= cap(r)*af_wind(n,t);

model ESM_3 /all/;

demand("Ger","20") = 1000;

solve ESM_3 using LP minimizing TC;
$stop

PARAMETERS

         price(*,t,n)            this is our prices
         generation(*,t,n,p) this is the generation ;

        price('ref',t,n) = -ENERGY_BALANCE.m(n,t);
        generation('ref',t,n,p) = G.l(p,n,t)$map_pn(p,n);


$onecho > these_is_my_output.tmp
        par=price       rng=price!a1   rdim=2 cdim=1
        par=generation  rng=G!a1       rdim=2 cdim=2
$offecho

EXECUTE "XLSTALK -c RESULTS.xlsx";
EXECUTE_UNLOAD 'data_results.gdx';
EXECUTE 'GDXXRW data_results.GDX O=RESULTS.xlsx epsout=0 @these_is_my_output.tmp';
