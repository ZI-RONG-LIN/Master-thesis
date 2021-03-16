AQI

if PM2_5<=35 then APM2_5="優";
else if 35<PM2_5<=75 then APM2_5="良";
else if 75<PM2_5<=115 then APM2_5="輕度污染";
else if 115<PM2_5<=150 then APM2_5="中度污染";
else if 150<PM2_5<=250 then APM2_5="重度污染";
else APM2_5="嚴重污染";

if O3<=160 then AO3="優";
else if 160<O3<=200 then AO3="良";
else if 200<O3<=300 then AO3="輕度污染";
else if 300<O3<=400 then AO3="中度污染";
else if 400<O3<=800 then AO3="重度污染";
else AO3="嚴重污染";

if NOx<=40 then ANOx="優";
else if 40<NOx<=80 then ANOx="良";
else if 80<NOx<=180 then ANOx="輕度污染";
else if 180<NOx<=280 then ANOx="中度污染";
else if 280<NOx<=565 then ANOx="重度污染";
else ANOx="嚴重污染";

if SO2<=50 then ASO2="優";
else if 50<SO2<=150 then ASO2="良";
else if 150<SO2<=475 then ASO2="輕度污染";
else if 475<SO2<=800 then ASO2="中度污染";
else if 800<SO2<=1600 then ASO2="重度污染";
else ASO2="嚴重污染";


Q
if PM2_5<=16.41 then QPM2_5="Q1";
else if 16.41<PM2_5<=25.17 then QPM2_5="Q2";
else if 25.17<PM2_5<=37.91 then QPM2_5="Q3";
else QPM2_5="Q4";

if O3<=21.38 then QO3="Q1";
else if 21.38<O3<=27.97 then QO3="Q2";
else if 27.97<O3<=35.60 then QO3="Q3";
else QO3="Q4";

if NOx<=11.32 then QNOx="Q1";
else if 11.32<NOx<=15.92 then QNOx="Q2";
else if 15.92<NOx<=22.15 then QNOx="Q3";
else QNOx="Q4";

if SO2<=2.20 then QSO2="Q1";
else if 2.20<SO2<=2.91 then QSO2="Q2";
else if 2.91<SO2<=3.82 then QSO2="Q3";
else QSO2="Q4";



data a3;
time=2-event;
run;
proc phreg data=a4;
class sex(param=ref ref='Q1');
model time*event(0)=sex PM2.5 age_group/ties=discrete;
selection=stepwise risklimits;
strata ID;
ods output parameterestimates=pp;
proc print data=pp;
run;
