/*年齡分層*/
%macro a(f,l);
%do i=&f %to &l;
data a&i.;
set m&i. ; 
if aage<=10 then age_group=1;
if aage >10 and aage<=20 then age_group=2;
if aage >20 and aage <=30 then age_group=3;
if aage >30 and aage <=40 then age_group=4;
if aage >40 and aage <=50 then age_group=5;
if aage >50 and aage <= 60 then age_group=6;
if aage>60 and aage <=70 then age_group=7;
if aage >70 and aage<=80 then age_group =8;
if aage>80 then age_group=9;
run;
%end;
%mend;
%a(97,104);

%macro b(f,l);
%do i=&f %to &l;
data B&i.;set a&i.;
CITY=lo;
run;
%end;
%mend;
%b(97,104);

data j4;set j3;
CITY=code;
run;

data j2;set j9799;
drop f3-f7;
city=code;
run;


proc sort data= j4;by CITY;run;
%macro bb(f,l);
%do i=&f %to &l;
proc sort data=b&i.;by CITY;run;
%end;
%mend;
%bb(97,104);

data s100;
merge b100(IN=K) j4;
by CITY;
if K=1;
run;

data d100;set s100;
if lo="" then delete;
run;
proc sort data=j1;by country;run;

/*縣市分組*/
data e100;set d100;
if  0101 <= CITY <= 0102 | 0109<= CITY <= 0112 | 0115 <= CITY <=0120 
then CT="臺北市"; 
if  1701 <= CITY <= 1708 | 3601 <= CITY <=3621 then CT="臺中市";
if  2101 <= CITY <=2107 | 4101 <= CITY <= 4131 then CT ="臺南市";
if  0201 <= CITY <= 0211| 4201 <=CITY <= 4227 then CT ="高雄市";
if  1101 <= CITY <= 1107 then CT = "基隆市";
if   CITY =1201|  CITY = 1204 |  CITY =1205 then CT="新竹市";
if  CITY =2201|  CITY = 2202 then CT="嘉義市";
if 3101 <= CITY <= 3129 then CT = "新北市";
if 3201 <= CITY <= 3213 then CT = "桃園市";
if 3301 <= CITY <= 3314 then CT ="新竹縣" ;
if 3401 <=CITY <= 3412 then CT ="宜蘭縣";
if 3501 <=CITY<= 3518 then CT ="苗栗縣";
if 3701 <=CITY <= 3726 then CT = "彰化縣";
if 3801 <=CITY <= 3813 then CT="南投縣";
if 3901 <= CITY <= 3920 then CT = "雲林縣";
if 4001 <=CITY <=4018 then CT ="嘉義縣";
if 4301 <=CITY <= 4333 then CT ="屏東縣";
if 4501 <=CITY <= 4513 then CT = "花蓮縣";
if 4601 <= CITY <= 4616 then CT ="臺東縣";
run;

data b2; set b1;
if CT=" " then delete;
run;
/*就診季節*/
data f97;set e97;
month=substr(FUNC_DATE,5,6);
if 2<= substr(month,5,6)<=4 then season="春季";
if 5<=  substr(month,5,6)<=7 then season="夏季";
if 8<=  substr(month,5,6)<=10 then season="秋季";
if  substr(month,5,6)=1|  substr(month,5,6)=12 | substr(month,5,6)=11 then season="冬季";
run;

data g97;set f97;
drop CITY CODE month;
run;
/*描述性統計*/
proc freq data =b3;
table ID_S CT age_group season;
run;
