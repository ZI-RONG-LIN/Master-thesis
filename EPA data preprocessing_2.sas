/*計算誤差*/
data b;set a;
n=(NOx-NO-NO2)/NOx;
t=(THC-CH4-NMHC)/THC;
run;

/*設定可接受的誤差範圍*/
data c;set b;
if ABS(n)<0.05 then error_n=0;
else error_n=1;
if ABS(t)<0.05 then error_t=0;
else error_t=1;
run;

/*輸出頻率報表*/
proc freq data=c;
table error_n error_t;
run;

/*處理不合理數據*/
data d;set c;
if error_n=1 then do;
NO=.;NO2=.;NOx=.;
end;
run;

data e;set d;
if error_t then do;
THC=.;CH4=.;NMHC=.;
end;
run;

data f;set e;
p=(PM2_5-PM10)/PM10;
if p>0.05 then error_p=1;
else error_p=0;
run;

data g;set f;
if RH>100 then error_r=1;
else error_r=0;
run;
/*輸出不合理數據的頻率報表*/
proc freq data=g;
table error_n error_t error_p error_r;
run;

data h;set g;
if error_p=1 then do;
PM2_5=.;PM10=.;
end;
run;

data i;set h;
if error_r=1 then do ;
RH=.;
end;
run;
