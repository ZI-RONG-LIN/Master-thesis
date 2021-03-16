/*挑選對照日，並根據日期、居住地merge空氣污染物濃度*/
data a1;set a;
 format FUNC_DATE YYMMDD10.;
 run;

 data a2;set a1;
 date=MDY(month(FUNC_DATE),day(FUNC_DATE),2010);
 format date YYMMDD10.;
  key=ID||date;
 run;

 data a3;set a2;
 keep ID date ;
 run;

 data a4;set a3;
 key=ID||date;
 event=1;
 run;

 data a5;set a4;
 c1=intnx('day',date,-14);
 c2=intnx('day',date,-7);
 c3=intnx('day',date,+7);
 c4=intnx('day',date,+14);
 format c1 YYMMDD10.;
 format c2 YYMMDD10.;
 format c3 YYMMDD10.;
 format c4 YYMMDD10.;
 run;

 proc sort data=a5;by key;run;
 proc transpose data= a5 out = a6;
 var c1 c2 date c3 c4 ;
 by key;
 run;

 data a7;set a6;
 drop COL2-COL14;
 if _NAME_="date" then event=1;else event=0;
 run;

 data c;set a2;
 keep ID_S city key;
 run;
 proc sort data=c;by key;run;
 proc sort data=a7;by key;run;
data c1;
merge a7(in=k) c;
by key;if k=1;run;

data air1;set air;
by day;
if first.day;
rename day=col1;run;
proc sort data=c1;by col1;run;
proc sort data= air1;by col1;run;
data g;
merge c1(in=k) air1;
by col1;if k=1;time=2-event;run;
