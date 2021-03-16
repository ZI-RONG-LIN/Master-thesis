##最後推估程序大概一年跑一個小時(50分鐘)
library(tidyverse)
library(lubridate)
setwd("I:/2 USER/SAS匯出資料/HEALTH01/門診歸人檔")
h104 <- read.csv("h104歸人檔.csv", header=TRUE, sep=",")
setwd("I:/2 USER/SAS匯出資料/推估居住地")
OP104 <- read.csv("104.csv", header=TRUE, sep=",")

h17<- left_join(h104,OP104,by="ID")
h17 <- OP104
#求上呼吸道感染就醫地(TOWN_COUGH)
h17$ICD9CM_1 <- as.numeric(h17$ICD9CM_1)
h17$ICD9CM_2 <- as.numeric(h17$ICD9CM_2)
h17$ICD9CM_3 <- as.numeric(h17$ICD9CM_3)
#篩上呼吸道疾病碼
h18 <- h17[(substr(h17$ICD9CM_1,1,3) %in% c(460:466) | substr(h17$ICD9CM_1,1,3) == 487 | substr(h17$ICD9CM_2,1,3) %in% c(460:466) | substr(h17$ICD9CM_2,1,3) == 487 | substr(h17$ICD9CM_3,1,3) %in% c(460:466) |substr(h17$ICD9CM_3,1,3) == 487 ),]
#排序
h18 <- arrange(h18,ID,CITY,FUNC_DATE)
#計算每個患者在不同鄉鎮市區就醫的次數
hc1 <- group_by(h18,ID,CITY)%>%
  summarise(n_city=n())
#建立合併KEY
hc1$keycou <- paste0(hc1$ID,hc1$CITY)
#找出不同患者在不同鄉鎮市區最近的就醫日期
hc2<- group_by(h18,ID,CITY)%>%
  filter(FUNC_DATE == max(FUNC_DATE))%>%
  select(ID,CITY,FUNC_DATE)
#建立合併KEY
hc2$keycou <- paste0(hc2$ID,hc2$CITY)
#合併
h <- merge(x = hc1, y = hc2, by = "keycou")
#篩欄位
h <- subset(h,select = c("keycou","ID.x","CITY.x","n_city","FUNC_DATE"))
#依照KEY、就醫次數(從大到小)、就醫日期(從大到小)排序
h <- arrange(h,ID.x,desc(n_city),desc(FUNC_DATE))
#把每個人的第一筆留下(就醫次數最多的地方 OR 最近就醫日的地方)
hh <- group_by(h,ID.x)%>%
  mutate(TOWN_COUGH = CITY.x[[1]])%>%
  filter(row_number() == 1)%>%
  select(ID.x,TOWN_COUGH)

#求基層醫療就醫地(TOWN_BASIC)
h17$HOS <- as.numeric(h17$HOS)
hba <- h17[(h17$HOS %in% c(21:41)),]
hba <- arrange(hba,ID,CITY.y)
#計算每個患者在不同鄉鎮市區就醫的次數
hba1 <- group_by(hba,ID,CITY)%>%
  summarise(n_city=n())
#建立合併KEY
hba1$keybas <- paste0(hba1$ID,hba1$CITY)
#找出不同患者在不同鄉鎮市區最近的就醫日期
hba2<- group_by(hba,ID,CITY)%>%
  filter(FUNC_DATE == max(FUNC_DATE))%>%
  select(ID,CITY,FUNC_DATE)
#建立合併KEY
hba2$keybas <- paste0(hba2$ID,hba2$CITY)
#合併
hba3 <- merge(x = hba1, y = hba2, by = "keybas")
#篩欄位
hba3 <- subset(hba3,select = c("keybas","ID.x","CITY.x","n_city","FUNC_DATE"))
#依照KEY、就醫次數(從大到小)、就醫日期(從大到小)排序
hba3 <- arrange(hba3,ID.x,desc(n_city),desc(FUNC_DATE))
#把每個人的第一筆留下(就醫次數最多的地方 OR 最近就醫日的地方)
hba3 <- group_by(hba3,ID.x)%>%
  mutate(TOWN_BASIC = CITY.x[[1]])%>%
  filter(row_number() == 1)%>%
  select(ID.x,TOWN_BASIC)

##求門診就醫地(TOWN_OPD)
op <- arrange(h17,ID,CITY)
#計算每個患者在不同鄉鎮市區就醫的次數
op1 <- group_by(op,ID,CITY)%>%
  summarise(n_city=n())
#建立合併KEY
op1$keyopd <- paste0(op1$ID,op1$CITY)
#找出不同患者在不同鄉鎮市區最近的就醫日期
op2<- group_by(op,ID,CITY)%>%
  filter(FUNC_DATE == max(FUNC_DATE))%>%
  select(ID,CITY,FUNC_DATE)
#建立合併KEY
op2$keyopd <- paste0(op2$ID,op2$CITY)
op3 <- merge(x = op1, y = op2, by = "keyopd")
op3 <- subset(op3,select = c("keyopd","ID.x","CITY.x","n_city","FUNC_DATE"))
op3 <- arrange(op3,ID.x,desc(n_city),desc(FUNC_DATE))
op3 <- group_by(op3,ID.x)%>%
  mutate(TOWN_OPD = CITY.x[[1]])%>%
  filter(row_number() == 1)%>%
  select(ID.x,TOWN_OPD)

#求綜合就醫地(TOWN_MIX)
#op3是門診就醫地檔案
#hba是基層就醫地檔案
#h 是上呼吸道就醫地檔案
mi <- full_join(op3,hba3,by="ID.x")
mi <- full_join(mi,hh,by="ID.x")
mi <- subset(mi,select = c("ID.x","TOWN_OPD","TOWN_BASIC","TOWN_COUGH"))
mi$TOWN_COUGH <- as.numeric(mi$TOWN_COUGH)
mi$TOWN_MIX <- ifelse(!is.na(mi$TOWN_COUGH),mi$TOWN_COUGH,ifelse(!is.na(mi$TOWN_BASIC),mi$TOWN_BASIC,mi$TOWN_OPD))

setwd("I:/2 USER/SAS匯出資料/HEALTH01/門診歸人檔")
h16 <- read.csv("h104歸人檔.csv", header=TRUE, sep=",")

###mi是氣喘患者且有上呼吸道就診等資料的人
###h16是全部氣喘患者
CITY <- merge(x=h16 , y=mi, by ="ID.x")
CIty <- subset(CITY,select = c("ID.x","TOWN_MIX","HOME_CITY"))

library(readxl)
install.packages("taRifx")
library(taRifx)
cb <-read_xlsx("I:/2 USER/縣市.xlsx")
cb$key <- cb$代碼
CIty$key <- CIty$HOME_CITY
cb1 <- left_join( CIty , cb, by = "key")



cb1$TOWN_MIX <- as.character(cb1$TOWN_MIX)
cb1$HOME_CITY <- as.character(cb1$HOME_CITY)
cb1$CBCODE1 <- as.character(cb1$CBCODE1)
cb1$CBCODE2 <- as.character(cb1$CBCODE2)
cb1$CBCODE3 <- as.character(cb1$CBCODE3)
cb1$CBCODE4 <- as.character(cb1$CBCODE4)
cb1$CBCODE5 <- as.character(cb1$CBCODE5)
cb1$CBCODE6 <- as.character(cb1$CBCODE6)
cb1$CBCODE7 <- as.character(cb1$CBCODE7)
cb1$CBCODE8 <- as.character(cb1$CBCODE8)
cb1$CBCODE9 <- as.character(cb1$CBCODE9)
cb1$CBCODE10 <- as.character(cb1$CBCODE10)
cb1$CBCODE11 <- as.character(cb1$CBCODE11)
cb1 <- cb1[complete.cases(cb1$CBCODE1),]

#求得推估居住地
LOCA <- function(TOWN_MIX,HOME_CITY,CBCODE1,CBCODE2,CBCODE3,CBCODE4,CBCODE5,CBCODE6,CBCODE7,CBCODE8,CBCODE9,CBCODE10,CBCODE11){
  if (TOWN_MIX == HOME_CITY){
    loca <- HOME_CITY
  }else if (TOWN_MIX == CBCODE1){
    loca <- HOME_CITY
  }else if (TOWN_MIX == CBCODE2){
    loca <- HOME_CITY
  }else if (TOWN_MIX == CBCODE3){
    loca <- HOME_CITY
  }else if (TOWN_MIX == CBCODE4){
    loca <- HOME_CITY
  }else if (TOWN_MIX == CBCODE5){
    loca <- HOME_CITY
  }else if (TOWN_MIX == CBCODE6){
    loca <- HOME_CITY
  }else if (TOWN_MIX == CBCODE7){
    loca <- HOME_CITY
  }else if (TOWN_MIX == CBCODE8){
    loca <- HOME_CITY
  }else if (TOWN_MIX == CBCODE9){
    loca <- HOME_CITY
  }else if (TOWN_MIX == CBCODE10){
    loca <- HOME_CITY
  }else if (TOWN_MIX == CBCODE11){
    loca <- HOME_CITY
  }else{
    loca <- TOWN_MIX
  }
  return(loca)
}

ptm <- proc.time()
rr = vector()
for (i in c(1:nrow(cb1))){
  p <- LOCA(cb1$TOWN_MIX[i],cb1$HOME_CITY[i],cb1$CBCODE1[i],cb1$CBCODE2[i],cb1$CBCODE3[i],cb1$CBCODE4[i],cb1$CBCODE5[i],cb1$CBCODE6[i],cb1$CBCODE7[i],cb1$CBCODE8[i],cb1$CBCODE9[i],cb1$CBCODE10[i],cb1$CBCODE11[i])
  rr = c(rr,p)
}
cb1$locate <- rr
proc.time() - ptm
