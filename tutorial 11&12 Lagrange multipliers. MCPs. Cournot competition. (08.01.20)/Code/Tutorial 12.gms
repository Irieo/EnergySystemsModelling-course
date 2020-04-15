$Title ESM Tutorial 12

$ontext

ESM course, Tutorial 12
tutorial 11-12 Lagrange multipliers. MCPs. Cournot competition.
Iegor Riepin, LSEW BTU CS

Feedback, bug reportings and suggestions are highly welcome: 
iegor.riepin@b-tu.de

08.01.2020

$offtext


$ONTEXT


        - two players
        - Costs=q(p)+0,5*q(p)^2
        - price=30-4*(q1+q2)

a) both players play perfect competition
b) both players play Nash-Cournot
c1) one player exerts market power the other one plays perfect competition - myopic
c2) one player exerts market power the other one plays perfect competition - maximization
c3) one player exerts market power the other one plays perfect competition - conjectured variations
d1) iterate the cv parameter for player 1 from zero to one
d1) iterate the cv1 and cv2 parameters from zero to one

$OFFTEXT
$eolcom #

*------------------------------------------------------------------------------*
*                               Set definitions
*------------------------------------------------------------------------------*
set i iterations  /1*21/;
set p producers   /p1, p2/;

*------------------------------------------------------------------------------*
*                        Model Parameters and Variables
*------------------------------------------------------------------------------*

Parameters
    report(*,*)     report parameter for the  for tasks a, b, and c
    reportI(i,*)    report for the iteration of the cv1 parameter
    reportII(i,*)   report for the iteration of both the cv parameters
    ;

parameter
    cv(p) cournot switcher
    ;

positive variables
    q(p) quantity supplied
    q1   quantity 1st optimization
    ;

variables
    prof_max        for c2 scenario
    price           price in the market
    ;

*===============================================================================
*                              Model A, B, C1, C3, D formulation
*===============================================================================
equations

         foc(p)     producers objective function kkt
         demand_f   demand function
 ;

         foc(p)..   - price
                    + 4*q(p)*cv(p)  # derivative of demand_function with respect to q(p)
                    + (1 + q(p))    # derivative of cost_function with respect to q(p)
                    =g= 0;

         demand_f..  price - (30-4*sum(p, q(p))) =e= 0;

model Model_MCP  /foc.q,
                  demand_f/;

*===============================================================================
*                              Model C2 formulation
*===============================================================================

*linear formulation: objective function of 1st player
equations
         obj         Maximization of profits of 1st "smart" player;
         obj..       prof_max =e= (30-4*(q1+29/5-4/5*q1))*q1-q1-0.5*q1**2;

model Model_NLP  /obj/;

*------------------------------------------------------------------------------*
* a)                       Solve Perfect Competition
*------------------------------------------------------------------------------*
cv('p1') = 0;
cv('p2') = 0;

solve Model_MCP using mcp;

parameter
      profit(p) producers profit
      costs(p)  costs for prod;
      costs(p)  = q.l(p) + 0.5*(q.l(p)*q.l(p));
      profit(p) = price.l*q.l(p) - costs(p);

      report('Perfect competition','q1')      =q.l('p1');
      report('Perfect competition','q2')      =q.l('p2');
      report('Perfect competition','price')   =price.l;
      report('Perfect competition','profit1') =profit('p1');
      report('Perfect competition','profit2') =profit('p2');




*------------------------------------------------------------------------------*
* b)                          Cournot-Game
*------------------------------------------------------------------------------*
cv('p1') = 1;
cv('p2') = 1;

solve Model_MCP using mcp;

parameter
      profit(p) producers profit
      costs(p)  costs for prod;
      costs(p)  = q.l(p) + 0.5*(q.l(p)*q.l(p));
      profit(p) = price.l*q.l(p) - costs(p);

      report('Cournot competition','q1')      =q.l('p1');
      report('Cournot competition','q2')      =q.l('p2');
      report('Cournot competition','price')   =price.l;
      report('Cournot competition','profit1') =profit('p1');
      report('Cournot competition','profit2') =profit('p2');


*------------------------------------------------------------------------------*
* c1) One player exerts market power the other one plays perfect competition - myopic
*------------------------------------------------------------------------------*
cv('p1') = 1;
cv('p2') = 0;

solve Model_MCP using mcp;
parameter
      profit(p) producers profit
      costs(p)  costs for prod;
      costs(p)  = q.l(p) + 0.5*(q.l(p)*q.l(p));
      profit(p) = price.l*q.l(p) - costs(p);

      report('Cournot 1st (myopic)','q1')      =q.l('p1');
      report('Cournot 1st (myopic)','q2')      =q.l('p2');
      report('Cournot 1st (myopic)','price')   =price.l;
      report('Cournot 1st (myopic)','profit1') =profit('p1');
      report('Cournot 1st (myopic)','profit2') =profit('p2');


*------------------------------------------------------------------------------*
* c2)                   Maximization of 1st player profits
*------------------------------------------------------------------------------*

solve Model_NLP maximizing prof_max using nlp;

parameter price_NLP as a parameter for optimization problem;
          price_NLP = 30 - 4*(q1.l+29/5-4/5*q1.l);

        report('profit_max 1st','q1')      = q1.l;
        report('profit_max 1st','q2')      = 29/5-4/5*q1.l;
        report('profit_max 1st','price')   = price_NLP;
        report('profit_max 1st','profit1') = price_NLP*q1.l - (q1.l + 0.5*q1.l**2);
        report('profit_max 1st','profit2') = price_NLP*(29/5-4/5*q1.l) - ((29/5-4/5*q1.l) + 0.5*(29/5-4/5*q1.l)**2);



*---------------------------------------------------------------------------*
* c3) Solving c1) with computed conjecture (cv = 0.2 = 1-0.8) for player 1.
*------------------------------------------------------------------------------*
cv('p1') = 0.2;
cv('p2') = 0;

solve Model_MCP using mcp;

parameter
           profit(p) producers profit
           costs(p)  costs for prod;
           costs(p) = q.l(p) + 0.5*(q.l(p)*q.l(p));
           profit(p) = price.l*q.l(p) - costs(p);

        report('Conjecture 1st','q1')      =q.l('p1');
        report('Conjecture 1st','q2')      =q.l('p2');
        report('Conjecture 1st','price')   =price.l;
        report('Conjecture 1st','profit1') =profit('p1');
        report('Conjecture 1st','profit2') =profit('p2');



*------------------------------------------------------------------------------*
* d1) Iterating cv1 from 0 to 1
*------------------------------------------------------------------------------*
cv('p1') = 0;
cv('p2') = 0;

Loop (i,
      solve Model_MCP using mcp;

        costs(p) = q.l(p) + 0.5*(q.l(p)*q.l(p));
        profit(p) = price.l*q.l(p) - costs(p);

        reportI(i,'cv1')          =cv('p1');
        reportI(i,'q1')           =q.l('p1');
        reportI(i,'q2')           =q.l('p2');
        reportI(i,'price')        =price.l;
        reportI(i,'profit1')      =profit('p1');
        reportI(i,'profit2')      =profit('p2');
        reportI(i,'total profit') =profit('p1')+profit('p2');

        cv('p1')=cv('p1')+0.05;
);


*------------------------------------------------------------------------------*
* d2)  Iterating cv1 and cv2 from 0 to 1
*------------------------------------------------------------------------------*
cv('p1') = 0;
cv('p2') = 0;

Loop (i,
      solve Model_MCP using mcp;

      costs(p) = q.l(p)+0.5*(q.l(p)*q.l(p));
      profit(p) = price.l*q.l(p)- costs(p);

      reportII(i,'cv1/cv2')=cv('p1');
      reportII(i,'q1')=q.l('p1');
      reportII(i,'q2')=q.l('p2');
      reportII(i,'price')=price.l;
      reportII(i,'profit1')=profit('p1');
      reportII(i,'profit2')=profit('p2');
      reportII(i,'total profit')=profit('p1')+profit('p2');

      cv(p)=cv(p)+0.05;
);

$ontext
$offtext

option limcol=10;

display report   ;
display reportI  ;
display reportII ;
