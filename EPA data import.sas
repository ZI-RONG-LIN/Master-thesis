%macro in(first,last);
%do i=&first %to &last;
PROC IMPORT OUT= WORK.A100&i.
            DATAFILE= "C:\Users\USER\Google 雲端硬碟\airbox\環保署\新增資料夾\100 all\A100&i..csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
%end;
%mend;
%in(1,78);

%macro ps(f,l);
%do i=&f %to &l;
proc sort data=a100&i.;
by VAR1 VAR2 VAR3;
run;
%end;
%mend;
%ps(1,78);

%macro pt(f,l);
%do i=&f %to &l;
proc transpose data = a100&i. out=b100&i.;
by VAR1 VAR2 VAR3;
var _1 _2 _3 _4 _5 _6 _7 _8 _9  _10 _11 _12 _13 _14 _15 _16 _17 _18 _19 _20 _21 _22 _23 _24;
run;
%end;
%mend;
%pt(1,78);

%macro pm(f,l);
%do i=&f %to &l;
DATA pm100&i.;SET b100&i.;
IF VAR3='PM2.5';
RUN;
%end;
%mend;
%pm(1,78);

%macro test(f,l);
%do i=&f %to &l;
data te100&i.;set pm100&i.;
i2=left(COL1);
if substr(i2,1,2)="#" or  substr(i2,1,3)="#" or  substr(i2,1,4)="#"  or  substr(i2,1,5)="#" or
substr(i2,1,2)="*" or  substr(i2,1,3)="*" or  substr(i2,1,4)="*"  or  substr(i2,1,5)="*" or
substr(i2,1,2)="x" or  substr(i2,1,3)="x" or  substr(i2,1,4)="x"  or  substr(i2,1,5)="x" then col2=.;
else col2=col1;
run;
%end;
%mend;
%test(1,78);

%macro col2(f,l);
%do i=&f %to &l;
data new100&i. ; set te100&i.;
drop col1 i2;
run;
%end;
%mend;
%col2(1,78);

%macro m1;
data a100;
set _null_;
run;
%do i=1 %to 78;
data a100;
set a100 new100&i.;
run;
%end;
%mend m1;
%m1;

proc sort data=a100;
by VAR1 VAR2 VAR3;
run;

data PM1; set a100;
IF  COL2 >15.4 THEN OVER=1;
ELSE OVER=0;
RUN;

DATA PM2;SET PM1;
BY VAR1 VAR2;
IF FIRST.VAR2 THEN OVER_HOUR =0;
OVER_HOUR+OVER;
RUN;

DATA PM3;SET PM2;
IF  COL2=. THEN LOSS=1;
ELSE LOSS=0;
RUN;

DATA PM4;SET PM3;
BY VAR1 VAR2;
IF FIRST.VAR2 THEN LOSS_HOUR =0;
LOSS_HOUR+LOSS;
RUN;

DATA PM5;SET PM4;
BY  VAR1 VAR2;
IF FIRST.VAR2 THEN TOTAL_CON=0;
TOTAL_CON+COL2;
RUN;

data pm6; set pm5;
by  VAR1 VAR2;
if first.VAR2 then total_hour=0;
total_hour+1;
run;

data pm7;set pm6;
by  VAR1 VAR2;
if last.VAR2;
run;

data pm8;set pm7;
valid_hour=total_hour-loss_hour;
a_con=total_con/valid_hour;
ave_con=round(a_con,0.01);
run;

data pm9; set pm8;
keep VAR1 VAR2 VAR3   OVER_HOUR LOSS_HOUR TOTAL_CON total_hour valid_hour  ave_con;
run;
