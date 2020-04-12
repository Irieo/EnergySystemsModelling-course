$ontext

ESM course gams tutorial
Tutorial 1
True Story

$offtext

set i power plants /x1, x2/;

parameters cap(i), c(i), d;

        c('x1') = 40;
        c('x2') = 70;
        d = 1000;
        cap('x1') = 800;
        cap('x2') = 500;

positive variables x(i);
variable totcost;

*x.up('x1') = 500;

equations
        obj     objective function
        dem     demand constraint
        cons(i) capacity constraint;

obj..     totcost =e= sum(i, x(i)*c(i));
dem..     d =e= sum(i, x(i));
cons(i).. cap(i) =g= x(i);

model ESM_is_a_simple_course /all/;

solve ESM_is_a_simple_course using LP minimizing totcost;

display x.l;
display dem.m, cons.m;
* =e= equality equation
* =g= higher or equal
* =l= lower or equal
