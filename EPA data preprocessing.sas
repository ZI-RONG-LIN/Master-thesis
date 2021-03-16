/*macro 匯入*/
%macro in(first,last);
%do i=&first %to &last;
PROC IMPORT OUT= WORK.A107&i. 
            DATAFILE= "C:\Users\user\Desktop\107 all\A107&i..xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
%end;
%mend;
%in(1,77);

/*照日期先排序，再照測站、測項排序*/
%macro ps(f,l);
%do i=&f %to &l;
proc sort data=a107&i.;
by _col0 _COL1 _col2;
run;
%end;
%mend;
%ps(1,77);
/*把行列轉置
101年(_1 _2 _3 _4 _5 _6 _7 _8 _9 _0 _10 _20 _30 _40 _50 _60 _70  _80 _90  _00  _11 _21 _31 _41)*/
%macro pt(f,l);
%do i=&f %to &l;
proc transpose data = a107&i. out=b107&i.;
by _col0 _COL1 _col2;
var _0 _1 _2 _3 _4 _5 _6 _7 _8 _9 _00 _10 _20 _30 _40 _50 _60 _70  _80 _90 _01 _11 _21 _31;
run;
%end;
%mend;
%pt(1,77);

/*篩出測項是pm2.5的資料*/
%macro pm(f,l);
%do i=&f %to &l;
DATA pm107&i.;SET b107&i.;
IF _COL2='PM2.5';
RUN;
%end;
%mend;
%pm(1,77);

/*把無效值判定成.*/
%macro test(f,l);
%do i=&f %to &l;
data te107&i.;set pm107&i.;
i2=left(COL1);
if substr(i2,1,2)="#" or  substr(i2,1,3)="#" or  substr(i2,1,4)="#"  or  substr(i2,1,5)="#" or
substr(i2,1,2)="*" or  substr(i2,1,3)="*" or  substr(i2,1,4)="*"  or  substr(i2,1,5)="*" or
substr(i2,1,2)="x" or  substr(i2,1,3)="x" or  substr(i2,1,4)="x"  or  substr(i2,1,5)="x" then col2=.;
else col2=col1;
run;
%end;
%mend;
%test(1,77);

/*把篩過的COL1跟i2兩欄刪掉，剩下COL2作為PM2.5的值*/
%macro col2(f,l);
%do i=&f %to &l;
data new107&i. ; set te107&i.;
drop col1 i2;
run;
%end;
%mend;
%col2(1,77);

/*垂直合併*/
%macro m1;
data a107;
set _null_;
run;
%do i=1 %to 77;
data a107;
set a107 new107&i.;
run;
%end;
%mend m1;
%m1;

/*再照日期、測站、測項排序*/
proc sort data=a106;
by _col0 _COL1 _col2;
run;

/*測值超過15.4的，over=1*/
data PM1; set a107;
IF  COL2 >15.4 THEN OVER=1;
ELSE OVER=0;
RUN;

/*計算超標小時數*/
DATA PM2;SET PM1;
BY _COL0 _COL1;
IF FIRST._COL1 THEN OVER_HOUR =0;
OVER_HOUR+OVER;
RUN;

/*沒有測值的，LOSS=1*/
DATA PM3;SET PM2;
IF  COL2=. THEN LOSS=1;
ELSE LOSS=0;
RUN;


/*計算缺值小時數*/
DATA PM4;SET PM3;
BY _COL0 _COL1;
IF FIRST._COL1 THEN LOSS_HOUR =0;
LOSS_HOUR+LOSS;
RUN;

/*計算日累積濃度*/
DATA PM5;SET PM4;
BY  _COL0 _COL1;
IF FIRST._COL1 THEN TOTAL_CON=0;
TOTAL_CON+COL2;
RUN;

/*計算總小時數，看有沒有都是24小時*/
data pm6; set pm5;
by _COL0 _COL1;
if first._col1 then total_hour=0;
total_hour+1;
run;

/*留下最後一筆資料*/
data pm7;set pm6;
by _COL0 _COL1;
if last._col1;
run;

/*計算日平均濃度*/
data pm8;set pm7;
valid_hour=total_hour-loss_hour;
a_con=total_con/valid_hour;
ave_con=round(a_con,0.01);
run;

/*留下日期、測站、測項、超標小時值、缺值小時值、日累積濃度、總小時數、有效小時數、日平均濃度，其他變項篩掉*/
data pm9; set pm8;
keep _COL0 _COL1 _col2   OVER_HOUR LOSS_HOUR TOTAL_CON total_hour valid_hour  ave_con;
run;
