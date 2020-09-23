$Title ESM Tutorial 5

$ontext

ESM course, Tutorial 5
3-node toy model: more on trade / load clipping at VOLL.
Feedback, bug reportings and suggestions are highly welcome: 
iegor.riepin@b-tu.de
21.11.2019

$offtext

$eolcom //

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

$onecho > input_data.tmp
        set=map_pn           rng=genup!A2:A9               cdim=0 rdim=2
        par=genup            rng=genup!A1                  cdim=1 rdim=1
        par=timeup           rng=timeup!A1                 cdim=2 rdim=1
        par=ntc              rng=NTC!A1                    cdim=1 rdim=1
$offecho

$onUNDF
$call   gdxxrw I=Input.xlsx O=Input.gdx  cmerge=1 @input_data.tmp
$gdxin  Input.gdx
$load   map_pn, genup, timeup, ntc
$offUNDF

c(p)     = genup(p,'type')= 1;
r(p)     = genup(p,'type')= 2 ;
cap(p)   = genup(p,'capacity');
vc(p)    = genup(p,'vc');
demand(n,t)  = timeup(t,'Demand',n);
af_wind(n,t) = timeup(t,'Wind availability',n) ;

scalar
        voll            value of lost load /3000/;

**********************************************************
variable
        TC;

positive variable
        G(p,n,t)
        FLOW(n,nn,t)
        SHED(n,t)
        ;

equations

OBJECTIVE
ENERGY_BALANCE
MAX_GENERATION
MAX_GENERATION_WIND
Res_lineflow_imp        //T5
Res_lineflow_exp        //T5
;

OBJECTIVE..        TC =e= sum((p,n,t), G(p,n,t)*vc(p))
                        + sum((t,n),SHED(n,t)*voll)
                        ;

ENERGY_BALANCE(n,t)..   demand(n,t) =e= sum(p$map_pn(p,n), G(p,n,t))
                         - sum(nn,FLOW(n,nn,t))
                         + sum(nn,FLOW(nn,n,t))
                         + shed(n,t)
                         ;

MAX_GENERATION(c,n,t)..         G(c,n,t) =l= cap(c);
MAX_GENERATION_WIND(r,n,t)..    G(r,n,t) =e= cap(r)*af_wind(n,t);
Res_lineflow_imp(n,nn,t)..      FLOW(n,nn,t) =L= ntc(n,nn);
Res_lineflow_exp(nn,n,t)..      FLOW(nn,n,t) =L= ntc(nn,n);

model ESM_5 /all/;

*demand("Ger","20") = 1000;
FLOW.fx(n,nn,t) = 0;
*ntc(n,nn) = ntc(n,nn)*0.1;

solve ESM_5 using LP minimizing TC;

PARAMETERS

         price(*,t,n)            this is the prices
         generation(*,t,n,p)     this is the generation
         trade(*,t,n,nn)

         utilization(*,t,n,nn)   % NTC utilization rate
         prof_cont(*,t,p)
         profits(*,p)
         sum_profits(*)
         ;

        price('ref',t,n)                    = - ENERGY_BALANCE.m(n,t);
        generation('ref',t,n,p)             = (G.l(p,n,t)+EPS)$map_pn(p,n);
        trade('REF',t,n,nn)                 = FLOW.l(n,nn,t);
        utilization('REF',t,n,nn)$ntc(n,nn) = FLOW.l(n,nn,t)/NTC(n,nn);

        prof_cont('REF',t,p)              = sum(n, (price('REF',t,n) - vc(p))*G.l(p,n,t));
        profits('REF',p)                  = sum(t, prof_cont('REF',t,p)) + EPS;
        sum_profits('REF')                = sum(p, profits('REF',p));

$onecho > output.tmp
        par=price       rng=price!a1        rdim=2 cdim=1
        par=generation  rng=G!a1            rdim=2 cdim=2
        par=trade       rng=Trade!A1        rdim=2 cdim=2
        par=Utilization rng=Utilization!A1  rdim=2 cdim=2
        par=Profits     rng=ProfitsPP!A1    rdim=1 cdim=1
$offecho

*EXECUTE        'XLSTALK -c results_trade.xlsx';
*EXECUTE_UNLOAD 'results_trade.gdx';
*EXECUTE        'GDXXRW results_trade.GDX O=results_trade.xlsx epsout=0 @output.tmp';

*EXECUTE        'XLSTALK -c results_no_trade.xlsx';
*EXECUTE_UNLOAD 'results_no_trade.gdx';
*EXECUTE        'GDXXRW results_no_trade.GDX O=results_no_trade.xlsx epsout=0 @output.tmp';

EXECUTE        'XLSTALK -c results_LS.xlsx';
EXECUTE_UNLOAD 'results_LS.gdx';
EXECUTE        'GDXXRW results_LS.GDX O=results_LS.xlsx epsout=0 @output.tmp';