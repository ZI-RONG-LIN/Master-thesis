/*匯入*/
%macro in(first,last);
%do i=&first %to &last;
PROC IMPORT OUT= WORK.date&i. 
            DATAFILE= "C:\Users\USER\Google 雲端硬碟\airbox\環保署\新增資料夾\total\統一格式\date&i..xls" 
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
%in(95,107);

/*統一日期格式*/
%macro d(first,last);
%do i=&first %to &last;
data d&i.;set date&i.;
format var1 YYMMDD10.;
run;
%end;
%mend;
%d(95,107);

/*統一欄位長度*/
%macro len(first,last);
%do i=&first %to &last;
data len&i.;
length var2 $6.;
length var3 $15.;
set d&i.;
run;
%end;
%mend;
%len(95,107);

/*照日期、測站、測項排序*/
%macro proc(first,last);
%do i=&first %to &last;
proc sort data=len&i.;
by var1 var2 var3;
run;
%end;
%mend;
%proc(95,107);
/*合併*/
data try;
set len107 len106 len105 len104 len103 len102 len101 len100 len99 len98 len97 len96 len95;
run;

/*排序變項*/
data try1;
retain var1 var2 var3 OVER_HOUR LOSS_HOUR TOTAL_CON total_hour valid_hour ave_con;
set try;
run;

proc sort data=try1;
by var1;
run;
