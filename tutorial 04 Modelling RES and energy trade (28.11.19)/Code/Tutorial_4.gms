$Title ESM Tutorial 4

$ontext

ESM course, Tutorial 4
Modelling RES and energy trade (NTC-constrained flows)
Feedback, bug reportings and suggestions are highly welcome: 
iegor.riepin@b-tu.de

28.11.2019

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

display vc, cap, demand, af_wind, c, r;

*########################### Model ########################

variable
        COSTS;

positive variables

        G(p,n,t)
        FLOW(n,nn,t);

equations
objective
energy_balance
max_generation
max_generation_wind
Res_lineflow_imp
*Res_lineflow_exp
;

objective..                     COSTS =E= sum((p,n,t),G(p,n,t)*vc(p))
                                         + sum((t,n), sum(nn,FLOW(n,nn,t)*0.000001))
                                          ;

energy_balance(n,t)..           demand(n,t) =E= sum(p$map_pn(p,n),G(p,n,t))
                                        + sum(nn,FLOW(n,nn,t))
                                        - sum(nn,FLOW(nn,n,t));

max_generation(c,n,t)..           G(c,n,t) =L= cap(c);

max_generation_wind(r,n,t)$map_pn(r,n)..    G(r,n,t) =L= cap(r)*af_wind(n,t);

Res_lineflow_imp(n,nn,t)..      FLOW(n,nn,t) =L= ntc(n,nn);
*Res_lineflow_exp(nn,n,t)..      FLOW(nn,n,t) =L= ntc(nn,n);

model ESM_4 /all/;

*########################### Model setup and solution ########################
*FLOW.FX(n,nn,t)$(not ntc(n,nn))   = 0;
*FLOW.FX(nn,n,t)$(not ntc(nn,n))   = 0;
*FLOW.FX(n,nn,t)   = 0;
*FLOW.FX(nn,n,t)   = 0;

demand('GER','20')= 1000;

solve ESM_4 using lp minimizing COSTS;

*execute_unload "trade.gdx"
*$stop

*########################### Output ########################

Parameters

         TotalCost(*)            total system costs
         price(*,t,n)            market price at time t
         generation(*,t,n,p)     production of conventional pp
         imports (*,t,n,nn)      import quantities

;

G.l(p,n,t)$(not G.l(p,n,t) and map_pn(p,n)) = EPS;

         TotalCost('REF')         = COSTS.l                    ;
         price('REF',t,n)         = abs(energy_balance.M(n,t)) ;
         generation('REF',t,n,p)  = G.l(p,n,t)                 ;
         imports('REF',t,n,nn)    = FLOW.l(n,nn,t)             ;


$onecho >this_should_be_in_output.tmp
                 par=TotalCost            rng=TotalCost!A1        rdim=1 cdim=0
                 par=price                rng=price!A1            rdim=2 cdim=1
                 par=Generation           rng=G!A1                rdim=2 cdim=2
                 par=imports              rng=Trade!A1            rdim=2 cdim=2
$offecho

execute        "XLSTALK -c    results_trade.xlsx";
EXECUTE_UNLOAD 'results_trade.gdx';
EXECUTE        'gdxxrw results_trade.gdx o=results_trade.xlsx EpsOut=0 @this_should_be_in_output.tmp';
