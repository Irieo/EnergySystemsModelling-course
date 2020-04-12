$ontext

ESM tutorial 7
Input file: input.xlsx

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
*        cap(p)           capacities of PPs                    // INV
        ic(p)            investment costs                      // INV

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
$call   gdxxrw I=Input.xlsx O=Input.gdx cmerge=1 @input_data.tmp
$gdxin  Input.gdx
$load   map_pn, genup, timeup, ntc
$offUNDF

c(p)  = genup(p,'type')= 1;
r(p)  = genup(p,'type')= 2 ;

*cap(p)=genup(p,'capacity');                            // INV
ic(p) = genup(p,'ic');                                  // INV

vc(p)=genup(p,'vc');
demand(n,t)= timeup(t,'Demand',n);
af_wind(n,t)=timeup(t,'Wind availability',n) ;

scalar
        voll            value of lost load      /3000/
;

Parameters

cap_stor(n)     [MWh]            //storage
power_turb(n)   [MW]             //storage
power_pump(n)   [MW]             //storage
loss_stor(n)    [~20%]           //storage
scaling_factor                   //INV
;

cap_stor('GER')    = 1000;    //storage
power_turb('GER')  = 100;     //storage
power_pump('GER')  = 400;     //storage
loss_stor('GER')   = 0.2;     //storage
scaling_factor     = 24/8760;   //INV

*EXECUTE_UNLOAD 'all_data.gdx';
**********************************************************
variable
        TC;

positive variable
        G(p,n,t)
        FLOW(n,nn,t)
       SHED(n,t)

        level_stor(n,t)         //storage
        charge_stor(n,t)        //storage
        gen_stor(n,t)           //storage

        cap(p)                  //INV
        ;

equations

OBJECTIVE
ENERGY_BALANCE
MAX_GENERATION
MAX_GENERATION_WIND
MAX_NTC

*STORAGE PROBLEM
stor_level_def          //storage
stor_level_cap          //storage
stor_gen_cap_level      //storage
stor_charge_cap         //storage
;

OBJECTIVE..        TC =e= sum((p,n,t), G(p,n,t)*vc(p))
                        + sum((t,n),SHED(n,t)*voll)
                        + sum(p, cap(p)*ic(p)*scaling_factor)          //INV
;

ENERGY_BALANCE(n,t)..   demand(n,t) =e= sum(p$map_pn(p,n), G(p,n,t))
                         - sum(nn,FLOW(n,nn,t))
                         + sum(nn,FLOW(nn,n,t))
                         + gen_stor(n,t) - charge_stor(n,t)
                         + shed(n,t)
;

MAX_GENERATION(c,n,t)..         G(c,n,t)        =l= cap(c);
MAX_GENERATION_WIND(r,n,t)..    G(r,n,t)        =l= cap(r)*af_wind(n,t);
MAX_NTC(n,nn,t)..               FLOW(n,nn,t)    =l= ntc(n,nn);

*STORAGE PROBLEM
stor_level_def(n,t)..       level_stor(n,t)  =e= level_stor(n,t-1) + charge_stor(n,t)*(1-loss_stor(n)) - gen_stor(n,t);
stor_level_cap(n,t)..       level_stor(n,t)  =l= cap_stor(n);
stor_gen_cap_level(n,t)..   gen_stor(n,t)    =l= power_turb(n);
stor_charge_cap(n,t)..      charge_stor(n,t) =l= power_pump(n);

model ESM_7 /all/;

demand("Ger","20") = 1000;
FLOW.fx(n,nn,t)    = 0;
level_stor.fx(n,t) = 0;
SHED.fx(n,t)       = 0;

*cap.fx('P5_Wind')  = 300;
*cap.fx('P8_Wind')  = 200;

solve ESM_7 using LP minimizing TC;

PARAMETERS

         price(*,t,n)
         generation(*,t,n,p)
         trade(*,t,n,nn)
         report_storage(t,*)

         invest(*,p)             display level of investments                    //INV
         ;



        price('ref',t,n)           = - ENERGY_BALANCE.m(n,t);
        generation('ref',t,n,p)    = (G.l(p,n,t) + eps)$map_pn(p,n);
        trade('REF',t,n,nn)        = FLOW.l(n,nn,t) + eps;

        report_storage(t,'level [MWh]') = level_stor.l("Ger",t)  + eps;          //storage
        report_storage(t,'charge [MW]') = charge_stor.l("Ger",t) + eps;          //storage
        report_storage(t,'gen [MW]')    = -gen_stor.l("Ger",t)   + eps;          //storage

        invest('REF',p)   = cap.l(p);                                            //INV

$onecho > output.tmp
        par=price               rng=price!a1        rdim=2 cdim=1
        par=generation          rng=G!a1            rdim=2 cdim=2
        par=trade               rng=Trade!A1        rdim=2 cdim=2
        par=report_storage      rng=Storage!A1      rdim=1 cdim=1
        par=invest              rng=investments!A1  rdim=1 cdim=1
$offecho

EXECUTE         'XLSTALK -c results_invest.xlsx';
EXECUTE_UNLOAD  'results_invest.gdx';
EXECUTE         'GDXXRW results_invest.GDX O=results_invest.xlsx epsout=0 @output.tmp';
