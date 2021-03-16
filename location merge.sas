/*保留欄位
data h961;set h96;
keep ID_X ;
run;
data lo961;set lo96;
keep ID_x lo;
run;

/*資料排序*/
proc sort data= h961;by ID_X;run;
proc sort data= lo961;by ID_X;run;
data c96;
merge h961(IN=K) lo961;
by ID_x;
if k=1;
run;
*/

/*macro匯入門診資料*/
%macro in(f,l);
%do i=&f %to &l;
PROC IMPORT OUT= WORK.H&i. 
            DATAFILE= "I:\2 USER\SAS匯出資料\HEALTH01\門診歸人檔\h&i.歸人
檔.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
%end;
%mend;
%in(98,104);

/*macro匯入居住地資料*/
%macro lo(f,l);
%do i=&f %to &l;
PROC IMPORT OUT= WORK.LO&i.
            DATAFILE= "I:\2 USER\SAS匯出資料\推估居住地\完成\居住地推估O
K\fin&i..csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
%end;
%mend;
%lo(98,104);

/*macro 保留指定欄位、依據ID合併居住地*/
%macro t(f,l);
%do i=&f %to &l;
data t&i.;set h&i.;
keep ID_X ;
run;
%end;%mend;run;
%t(97,104);
%macro l(f,l);
%do i=&f %to &l;
data l&i.;set lo&i.;
keep ID_x lo;
run;
%end;%mend;run;
%l(97,104);
%macro proc(f,l);
%do i= &f %to &l;
proc sort data= t&i.;by ID_X;run;
proc sort data= l&i.;by ID_X;run;
%end;
%mend;
run;
%proc(97,104);
%macro c(f,l);
%do i= &f %to &l;
data c&i.;
merge t&i.(IN=K) l&i.;
by ID_x;
if k=1;
run;
%end;%mend;run;
%c(97,104);

/*macro 匯出*/
%macro ex(f,l);
%do i=&f %to &l;
PROC EXPORT DATA= WORK.C&i.
            OUTFILE= "I:\2 USER\SAS匯出資料\HEALTH01\門診歸人檔\歸人檔+居住地\c&i..csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
%end;%mend;run;
%ex(98,104);
