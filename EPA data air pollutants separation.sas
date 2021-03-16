/*macro 匯入*/
%macro in(first,last);
%do i=&first %to &last;
PROC IMPORT OUT= WORK.A&i. 
            DATAFILE= "C:\Users\USER\Google 雲端硬碟\airbox\環保署\帶進去的檔\A&i..xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
%end;
%mend;
%in(95,104);
%in(105,107);

/*處理日期格式*/
/*日期分割*/
%macro date(f,l);
%do i=&f %to &l;
data b&i.;set a&i.;
year=substr(_col0,1,4);
month=substr(_col0,6,2);
day=substr(_col0,9,2);
date=MDY(month,day,year);
format date YYMMDD10.;
drop year month day;
run;
%end;
%mend;
%date(99,107);
/*日期合併格式*/
%macro da(f,l);
%do i=&f %to &l;
data b&i.;set a&i.;
format _col0 YYMMDD10.;
rename _col0=date;
run;
%end;
%mend;
%da(95,98);

/*排序資料*/
%macro proc(f,l);
%do i=&f %to &l;
proc sort data=b&i.;by date _COL1 _COL2;
run;
%end;
%mend;
%proc(95,107);

/*有效小時數未滿18小時則篩去*/
%macro av(f,l);
%do i=&f %to &l;
data c&i.;set b&i.;
if valid_hour<18 then delete;
run;
%end;
%mend;
%av(95,107);

/*將各測項獨立*/
%macro out(f,l);
%do i=&f %to &l;
data t1&i. t2&i. t3&i. t4&i. t5&i. t6&i. t7&i. t8&i. t9&i. t10&i. t11&i. t12&i. t13&i. t14&i.;
set c&i.;
if  _COL2= 'AMB_TEMP' or _COL2='AMB' or _COL2= 'AMB_T' then output t1&i.;
if _COL2='CO' then output t2&i.;
if _COL2='NO' then output t3&i.;
if _COL2='NO2' then output t4&i.;
if _COL2='NOx' then output t5&i.;
if _COL2='O3' then output t6&i.;
if _COL2='PM10' or _COL2='PM1' then output t7&i.;
if _COL2='PM2.5' or _COL2='PM2' then output t8&i.;
if _COL2='RAINFALL' or _COL2='RAINF' or _COL2='RAI' then output t9&i.;
if _COL2='RH' then output t10&i.;
if _COL2='SO2' then output t11&i.;
if _COL2='CH4' then output t12&i.;
if _COL2='NMHC' or _COL2='NMH' then output t13&i.;
if _COL2='THC' then output t14&i.;
run;
%end;
%mend;
%out(95,107);

/*資料轉置後合併*/
%MACRO COMBINE(F,L);
%DO i=&F %to &L;
%macro year(a,b);
%do u=&a %to &b;
proc transpose data=T&i.&u. out=Z&i.&u.;
by  date  _COL1 ;
var ave_con ;
run;
%end;
%mend year;
%year(95,107);
%end;
%mend combine;
%combine(1,14);

/*更改欄位名稱*/
%macro r1(f,l);
%do i=&f %to &l;
data r1&i.;set z1&i.;
rename col1=AMB_TEMP;
run;
%end;
%mend ;
%r1(95,107);

%macro r2(f,l);
%do i=&f %to &l;
data r2&i.;set z2&i.;
rename col1=CO;
run;
%end;
%mend ;
%r2(95,107);

%macro r3(f,l);
%do i=&f %to &l;
data r3&i.;set z3&i.;
rename col1=NO;
run;
%end;
%mend ;
%r3(95,107);

%macro r4(f,l);
%do i=&f %to &l;
data r4&i.;set z4&i.;
rename col1=NO2;
run;
%end;
%mend ;
%r4(95,107);

%macro r5(f,l);
%do i=&f %to &l;
data r5&i.;set z5&i.;
rename col1=NOx;
run;
%end;
%mend ;
%r5(95,107);

%macro r6(f,l);
%do i=&f %to &l;
data r6&i.;set z6&i.;
rename col1=O3;
run;
%end;
%mend ;
%r6(95,107);

%macro r7(f,l);
%do i=&f %to &l;
data r7&i.;set z7&i.;
rename col1=PM10;
run;
%end;
%mend ;
%r7(95,107);

%macro r8(f,l);
%do i=&f %to &l;
data r8&i.;set z8&i.;
rename col1=PM2_5;
run;
%end;
%mend ;
%r8(95,107);

%macro r9(f,l);
%do i=&f %to &l;
data r9&i.;set z9&i.;
rename col1=RAINFALL;
run;
%end;
%mend ;
%r9(95,107);

%macro r10(f,l);
%do i=&f %to &l;
data r10&i.;set z10&i.;
rename col1=RH;
run;
%end;
%mend ;
%r10(95,107);

%macro r11(f,l);
%do i=&f %to &l;
data r11&i.;set z11&i.;
rename col1=SO2;
run;
%end;
%mend ;
%r11(95,107);

%macro r12(f,l);
%do i=&f %to &l;
data r12&i.;set z12&i.;
rename col1=CH4;
run;
%end;
%mend ;
%r12(95,107);

%macro r13(f,l);
%do i=&f %to &l;
data r13&i.;set z13&i.;
rename col1=NMHC;
run;
%end;
%mend ;
%r13(95,107);

%macro r14(f,l);
%do i=&f %to &l;
data r14&i.;set z14&i.;
rename col1=THC;
run;
%end;
%mend ;
%r14(95,107);

/*資料排序*/
%MACRO PS(F,L);
%DO i=&f %to &l;
%macro year(a,b);
%do u=&a %to &b;
PROC SORT DATA=R&i.&u.;BY date _COL1;RUN;
%end;
%mend year;
%year(95,107);
%end;
%mend ps;
%PS(1,14);

/*資料合併*/
%macro mer(f,l);
%do i=&f %to &l;
data fin&i.;
merge r1&i. r2&i. r3&i. r4&i. r5&i. r6&i. r7&i. r8&i. r9&i. r10&i. r11&i. r12&i. r13&i. r14&i.;
by date _col1;
run;
%end;
%mend;
%mer(95,107);

/*去除不必要的欄位*/
%macro drop(f,l);
%do i=&f %to &l;
data f&i.; set fin&i.;
drop _NAME_ _LABEL_;
run;
%end;
%mend;
%drop(95,107);

/*更改欄位長度*/
%macro len(f,l);
%do i=&f %to &l;
data len&i.;
length _col1 $6.;
set fin&i.;
run;
%end;%mend;
%len(95,107);

/*垂直合併*/
%macro m1;
data total;
set _null_;
run;
%do i=95 %to 107;
data total;
set total len&i.;
run;
%end;
%mend m1;
%m1;

/*多檔輸出*/
%macro exp(f,l);
%do i=&f %to &l;
PROC EXPORT DATA= WORK.Fin&i. 
            OUTFILE= "C:\Users\USER\Google 雲端硬碟\airbox\環保署\帶進去的檔\橫向資料\fin&i..xlsx" 
            DBMS=EXCEL LABEL REPLACE;
     SHEET="sheet"; 
RUN;
%end;
%mend;
%exp(95,107);

