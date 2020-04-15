$ontext

1.1 Linear probram
1.2 MCP

$offtext

********************************************************
*       task formulation for part 1
********************************************************

positive variable
    x pos var
    y pos var;

variable
    z obj var;

equations
    obj  objective function
    st   constraint
    ;

    obj.. z =e= 4*x+5*y;
    st..  x+y =l= 24

model EX /all/
solve  EX using lp maximizing z;

x.l$(Not x.l) = eps;
y.l$(Not y.l) = eps;

    set s_LP /LPsolution/;
    parameter report_LP (*,*);
       report_LP (s_LP, "x")= x.l;
       report_LP (s_LP, "y")= y.l;
       report_LP (s_LP, "Obj(lp)")= z.l;
       report_LP (s_LP, "marginal")= st.m;

option clear=x;
option clear=y;

********************************************************
*       task formulation for part 2a
********************************************************
positive variable
    a lagr(lambda);

equations

    cons   constraint
    focx kkt x
    focy kkt y;

        focx..-4+a =g= 0;
        focy..-5+a =g= 0;
        cons.. -x-y+24 =g= 0;

model EXmcp /cons.a, focx.x, focy.y/
solve EXmcp using mcp;


*report writings for mcp
parameter ObjMcp objective function;
          ObjMcp=4*x.l+5*y.l;

x.l$(Not x.l) = eps;
y.l$(Not y.l) = eps;

set s_MCP /MCPsolution/;
parameter report_MCP (*,*);

          report_mcp (s_MCP,"x")= x.l;
          report_mcp (s_MCP,"y")= y.l;
          report_mcp (s_MCP,"labmda")= a.l;
          report_mcp (s_MCP,"Obj(mcp)")= ObjMcp;

********************************************************
*       displaying all:
********************************************************
option report_mcp:0;
option report_LP:0;

display report_LP;
display report_mcp;

