$eolcom #

set   i  technologies /x1, x2/;

parameters  c(i), d, cap(i);

            c('x1') = 40;
            c('x2') = 70;
            d = 1000;
            cap('x1')=800;
            cap('x2')=500;

positive variables
            x(i) 'production quantity';

variable    z;

equations
            obj     objective function
            dem     demand constraint
            cons(i) capacity constraint
            ;

obj..       z =e= sum(i, x(i)*c(i));
dem..       d =e= sum(i, x(i));
cons(i)..   cap(i) =g= x(i);


model ESM_is_a_simple_course /all/;
solve ESM_is_a_simple_course using lp minimizing z;


$ontext
Conditionally execute an assignment
        A$(b gt 0) = 20;

parameter
        TOBY ;
        TOBY = 1;

cap('x1')$(TOBY = 1) = 1e6;

solve ESM_is_a_simple_course using lp minimizing z;
      display x.l, z.l;

*$offtext

*$ontext
*Conditionally add a term in sum or other set operation
*        z = sum(i$(y(i) gt 0), x(i));

SET
        i_conv(i) /x2/;

Parameter
        cap_conv capacity of conventional techs;

cap_conv = sum(i$i_conv(i), cap(i))

display cap_conv
*$offtext

*$ontext
*Conditionally define an equation
*        Equation1(i)$(ii).. sum(i, a(i)*x(i)) =e= 1;

SET
        i_emergency(i) /x1/;

equation
        cons_conv(i) new constraint;

cons_conv(i)$i_emergency(i)..   x(i) =l= cap(i)*0.75  ;

model ESM2 /all/;
solve ESM2 using lp minimizing z;
      display x.l, z.l;
      display dem.m;
      display cons.m;

$offtext

*$ontext
*Conditionally include a term in an equation
*        Equation1 .. x + y $(a gt 0) =e= 1;

parameters
        cost_co2
        flag    do we include co2?;

        cost_co2 = 30;
        flag = 1;

        c('x2') = 70 + cost_co2$(flag = 1);

solve ESM_is_a_simple_course using lp minimizing z;
      display x.l, z.l;
*$offtext










