
***************************************
*Conditionally execute an assignment
A $ (b gt 0) = 20;

*Conditionally add a term in sum or other set operation
z = sum(i$(y(i) gt 0),x(i));

* Conditionally define an equation
Eq1(i)$(subset) .. sum(i,a(i)*x(i)) =e= 1;

* Conditionally include a term in an equation.
Eqc .. xvar + yvar $(aa gt 0) =e= 1;
