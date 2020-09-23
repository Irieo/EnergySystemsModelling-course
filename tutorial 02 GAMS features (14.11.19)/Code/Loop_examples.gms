$Title ESM Tutorial 2

$ontext

ESM course, Tutorial 2
GAMS features - loop examples
Feedback, bug reportings and suggestions are highly welcome: 
iegor.riepin@b-tu.de
14.11.2019

$offtext


positive variables x1,x2;
variable           Z;
scalar a /4/;

equations
                   obj, con1, con2, con3;

obj..   z =e= a*x1 + 5*x2;
con1..  x1 =l= 80;
con2..  x2 =l= 50;
con3..  x1 + x2 =e= 100;

model lp_loops /all/;
solve lp_loops using LP minimizing z;


**************** While ****************
model lp_loops1 /all/;

while( (a le 6),
         solve lp_loops1 using LP minimizing z;
         display z.l;
         display "---------------------------"
                    "Loop completed for lp_loops1"
                  "---------------------------";
         a = a + 1;
         );

$stop

**************** For ****************
model lp_loops2 /all/;

for( a = 4 to 6,
        solve lp_loops2 using LP minimizing z;
        display z.l;
        display "---------------------------"
                    "Loop completed for lp_loops2"
                  "---------------------------";
        );

**************** loop ****************
model lp_loops3 /all/;
set t /1*3/;

loop(t,
        a = ord(t)*2;
        solve lp_loops3 using LP minimizing z;
        display z.l;
        display "---------------------------"
                    "Loop completed for lp_loops3"
                    "/ESM is a simple class... so far./"
                  "---------------------------";
        );



