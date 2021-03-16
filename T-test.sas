Proc ttest data=m1;
Class event; /*分組變項*/
Var O3;/*預檢定變項*/
Run;
Proc ttest data=m1;
Class event; /*分組變項*/
Var NOx;/*預檢定變項*/
Run;
Proc ttest data=m1;
Class event; /*分組變項*/
Var SOx;/*預檢定變項*/
Run;
Proc ttest data=m1;
Class event; /*分組變項*/
Var NMHC;/*預檢定變項*/
Run;

Proc ttest data=n1;
Class event; /*分組變項*/
Var r;/*預檢定變項*/
Run;
Proc ttest data=n1;
Class event; /*分組變項*/
Var O3;/*預檢定變項*/
Run;
Proc ttest data=n1;
Class event; /*分組變項*/
Var NOx;/*預檢定變項*/
Run;
Proc ttest data=n1;
Class event; /*分組變項*/
Var SOx;/*預檢定變項*/
Run;
Proc ttest data=n1;
Class event; /*分組變項*/
Var NMHC;/*預檢定變項*/
Run;
