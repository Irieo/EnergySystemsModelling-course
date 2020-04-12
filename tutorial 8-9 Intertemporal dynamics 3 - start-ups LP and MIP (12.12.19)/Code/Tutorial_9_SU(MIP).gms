$ontext

ESM18
Tutorial 9
Input file: Input_I.xlsx

$offtext
$eolcom //

*########################### Data ########################

SETS
        p        power plants           /                   //10
P1_NUC
P2_NUC
P3_OCGT
P4_OCGT
P5_LIG
P6_LIG
P7_CCGT
P8_CCGT
P9_Wind
P10_CCGT
P11_CCGT
P12_OCGT
P13_OCGT
P14_Wind
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

        cap(p)           capacities of PPs                      // 9
*        vc(p)            variable production costs of PPs      // 9
        ic(p)            investment costs

        demand(n,t)      demand in node N
        ntc(n,nn)        NTC value from node n to node nn [MW]
        af_wind(n,t)     availability factor for wind feed-in

*Tutorial 9
        fc(p)           fuel costs € per MWh thermal
        eta_full(p)     efficiency at full load
        sc(p)           start-up costs
        vc_full(p)      variable costs at full load
        vc_min(p)       variable costs at min load
        eta_min(p)      efficiency at min load
        g_min(p)        minimum generation
        af(p)           availability factor
;

                                                                    //10
$onecho > these_is_my_data.tmp
        set=map_pn           rng=genup!A2:A15              cdim=0 rdim=2
        par=genup            rng=genup!A1                  cdim=1 rdim=1
        par=timeup           rng=timeup!A1                 cdim=2 rdim=1
        par=ntc              rng=NTC!A1                    cdim=1 rdim=1
$offecho

$onUNDF
$call   gdxxrw I=Input_I.xlsx O=Input_I.gdx  cmerge=1 @these_is_my_data.tmp
$gdxin  Input_I.gdx
$load   map_pn, genup, timeup, ntc
$offUNDF

*Tutorials 3-8
        c(p)   = genup(p,'type')= 1 ;
        r(p)   = genup(p,'type')= 2 ;

        cap(p) =genup(p,'capacity');                            // 9
        //vc(p)=genup(p,'vc');                                  // 9

        ic(p)       = genup(p,'ic');
        demand(n,t) = timeup(t,'Demand',n);
        af_wind(n,t)= timeup(t,'Wind availability',n) ;

*Tutorial 9                                                     // 9
        fc(p)       = genup(p,'fuel costs')     ;
        eta_full(p) = genup(p,'eff')            ;
        eta_min(p)  = genup(p,'eff_min')        ;
        g_min(p)    = genup(p,'g_min')          ;
        sc(p)       = genup(p,'startup costs')  ;
        af(c)       = genup(c,'availability')   ;

        vc_full(p) = fc(p) / eta_full(p)        ;
        vc_min(p)  = fc(p) / eta_min(p)         ;

scalars
        voll            value of lost load      /30000/
        cpf             capacity power factor   /10/
        ;

Parameters

        cap_stor(n)     [MWh]            //storage
        power_turb(n)   [MW]             //storage
        power_pump(n)   [MW]             //storage
        loss_stor(n)    [~25%]           //storage
        scaling_factor                   //INV
        ;

        cap_stor('GER')    = 1000;      //storage
        power_turb('GER')  = 400;       //storage
        power_pump('GER')  = 100;       //storage
        loss_stor('GER')   = 0.2;       //storage
        scaling_factor     = 24/8760;   //INV

*EXECUTE_UNLOAD 'all_data.gdx';
*$stop


*########################### Model ########################

variable
        TC;


binary variables                                              //10
*        CS(p,n,t)  commitment status
        SU(p,n,t)
        DOWN(p,n,t)
;

positive variable
        G(p,n,t)
        FLOW(n,nn,t)
        SHED(n,t)

        level_stor(n,t)         //storage
        pump(n,t)               //storage
        gen(n,t)                //storage

        //cap(p)                //INV                           //9

* Tutorial 9
        P_ON(p,n,t) running capacity    [MW]
*        SU(p,n,t)   start-up activity   [MW]
        ;

equations

OBJECTIVE
ENERGY_BALANCE
MAX_GENERATION
MAX_GENERATION_WIND
MAX_NTC

*STORAGE PROBLEM
*stor_level_cap
*stor_level_def
*stor_activity_cap1
*stor_activity_cap2
*stor_gen_cap

*Tutorial 9
max_generation
min_generation
max_online
startup
;

OBJECTIVE..        TC =e= sum((p,n,t), G(p,n,t)*vc_full(p))
*                        + sum((t,n),SHED(n,t)*voll)
*                        + sum(p, cap(p)*ic(p)*scaling_factor)          //INV
                        + sum((p,n,t), SU(p,n,t)*sc(p)*cap(c))                                                         // 9
                        + sum((p,n,t), (P_ON(p,n,t)-G(p,n,t)) * (vc_min(p)-vc_full(p)) * g_min(p)/(1-g_min(p))) // 9
                        ;

ENERGY_BALANCE(n,t)..   demand(n,t) =e= sum(p$map_pn(p,n), G(p,n,t))
*                                      - sum(nn,FLOW(n,nn,t))
*                                      + sum(nn,FLOW(nn,n,t))
*                                     + gen(n,t)*(1-loss_stor(n)) - pump(n,t)
*                                     + shed(n,t)
                         ;

*MAX_GENERATION(c,n,t)..        G(c,n,t)     =l= cap(c);                      // 9
MAX_GENERATION_WIND(r,n,t)..    G(r,n,t)     =L= cap(r)*af_wind(n,t);         // L
MAX_NTC(n,nn,t)..               FLOW(n,nn,t) =L= ntc(n,nn);

*STORAGE PROBLEM
*stor_level_cap(n,t)..       level_stor(n,t)  =L= cap_stor(n);
*stor_level_def(n,t)..       level_stor(n,t)  =L= level_stor(n,t-1) + pump(n,t) - gen(n,t)*(1-loss_stor(n));
*stor_activity_cap1(n,t)..   gen(n,t)         =L= power_turb(n);
*stor_activity_cap2(n,t)..   pump(n,t)        =L= power_pump(n);
*stor_gen_cap(n,t)..         gen(n,t)         =L= level_stor(n,t);

*Tutorial 9
max_generation(c,n,t)$map_pn(c,n)..     G(c,n,t)                    =L= P_ON(c,n,t)                         ;
min_generation(c,n,t)$map_pn(c,n)..     P_ON(c,n,t)*g_min(c)        =L= G(c,n,t)                            ;
max_online(c,n,t)$map_pn(c,n)..         P_ON(c,n,t)                 =L= cap(c) * af(c)                      ;
startup(c,n,t)$map_pn(c,n)..            P_ON(c,n,t)-P_ON(c,n,t-1)   =e= SU(c,n,t)*cap(c) - DOWN(c,n,t)*cap(c);

model ESM_9 /all/;


demand("Ger","20") = 1000;

FLOW.fx(n,nn,t)    = 0;
level_stor.fx(n,t) = 0;
SHED.fx(n,t)       = 0;
*ntc(n,nn)         = ntc(n,nn)*0.1;

*g_min(c)           =  1;

*sc('P3_LIG')    = sc('P3_LIG') / 3;
*sc('P4_CCGT')   = sc('P4_CCGT') / 3;


solve ESM_9 using MIP minimizing TC;

PARAMETERS

         price(*,t,n)            this is our prices
         generation(*,t,n,p)     this is the generation
         ;

        price('ref',t,n)                    = - ENERGY_BALANCE.m(n,t);
        generation('ref',t,n,p)             = G.l(p,n,t)$map_pn(p,n);


$onecho > these_is_my_output.tmp
        par=price               rng=price!a1        rdim=2 cdim=1
        par=generation          rng=G!a1            rdim=2 cdim=2
$offecho

EXECUTE         'XLSTALK -c results_10_SU_MIP.xlsx';
EXECUTE_UNLOAD  'results_10_SU_MIP.gdx';
EXECUTE         'GDXXRW results_10_SU_MIP.GDX O=results_10_SU_MIP.xlsx epsout=0 @these_is_my_output.tmp';
