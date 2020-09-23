$Title ESM Tutorial 2

$ontext

ESM course, Tutorial 2
GAMS features - report example
Feedback, bug reportings and suggestions are highly welcome: 
iegor.riepin@b-tu.de

14.11.2019

$offtext


positive variables x1,x2;
variable           Z;

equations
                   obj, con1, con2;

scalar a /1/;


obj..   z =e= a*x1 + 5*x2;

con1..  x1 =l= 4;
con2..  9*power(x1,2) + 5*power(x2,2) =l= 216;

model Mod3 /all/;

set t /1*10/;
parameter report(t,*) convenient report parameter;

loop(t,
        a = a*1.5;
        solve Mod3 using nlp maximizing z;
*        display z.l, x1.l, x2.l;
        report(t,'my objective') = z.l;
        report(t,'value x1') = x1.l;
        report(t,'value x2') = x2.l;
        );

display report

