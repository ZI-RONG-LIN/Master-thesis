#資料匯入
setwd("C:/Users/USER/Google 雲端硬碟/模擬數據檔/併成一檔")
health01 <- read.csv("health01.csv", header=TRUE, sep=",")
health07 <- read.csv("health07.csv", header=TRUE, sep=",")
health10 <- read.csv("health10.csv", header=TRUE, sep=",")

#門診明細檔 
h1 <- health01
#篩ICD氣喘患者
h1 <- subset(h1, substr(ICD9CM_1,1,3) == "493" | substr(ICD9CM_2,1,3) == "493" | substr(ICD9CM_3,1,3) == "493")
#需要用解密的就醫日期和就醫年齡得到患者的出生年，因為患者ID會重複使用，ID一樣但出生年不同
h1$func_year <- as.numeric(substr(h1$FUNC_DATE,1,4))
h1$AAge <- ifelse(grepl("天",h1$AGE),"0",sub("歲","",h1$AGE))
h1$AAge <- as.numeric(sub("以上","",h1$AAge))
h1$birth <- h1$func_year-h1$AAge
h1$key <- paste0(h1$ID,h1$birth)

#承保檔歸人前處理
#照ID排序
h7 <- arrange(health07,ID)
#建立與health01合併的KEY，以ID+出生年作為KEY
h7$key <- paste0(h7$ID,h7$ID_BIRTH_Y)
#ID_ROC等於0的留下
h7 <- h7[(h7$ID_ROC == 0),]
#依據KEY進行分組，取每組最新一次的投保紀錄做為該人的承保資料，必須是加保狀態
h71 <- subset(h7,h7$ID_STATUS == "1")
h71 <-  group_by(h71,key) %>%
  filter(PREM_YM == max(PREM_YM))
#留下戶籍地HOME_CITY和key
h71 <- select(h71,HOME_CITY,key)
#照KEY排序
h1 <- arrange(h1,key)
h71 <- arrange(h71,key)
h12 <- left_join( h1 , h71, by = "key")

#死因統計檔歸人處理
h10 <- health10
h10$birth_year <- substr(h10$BIRTH_YM,1,4)
h10$key <- paste0(h10$ID,h10$birth_year)
#留下出生年月、死亡日期、ICD10、key
h10 <- select(h10,BIRTH_YM,D_DATE,ICD10,key)
#以health01&health07併好的檔為底，和死因統計檔合併
h13 <- left_join(h12,h10,by="key")

library(lubridate)
#篩選條件
#出生日<就醫日<死亡日
h13$BIRTH <- paste(substr(h13$ID_BIRTH_Y,1,4),substr(h13$BIRTH_YM,5,6),15,sep = "/")
h13$func <- paste(substr(h13$FUNC_DATE,1,4),substr(h13$FUNC_DATE,5,6),substr(h13$FUNC_DATE,7,8),sep = "/")
h13$D <- paste(substr(h13$D_DATE,1,4),substr(h13$D_DATE,5,6),substr(h13$D_DATE,7,8),sep = "/")
#把承保檔有NA值的資料刪掉
h14 <- h13[complete.cases(h13$ID1_CITY),]
#改成日期格式
h14$BIRTH <- as.Date(h14$BIRTH)
#測試h14$func <- ymd('2000/1/1')
h14$func <- as.Date(h14$func)
h14$D <- as.Date(h14$D)
h15 <- h14
#就醫日介在出生日與死亡日間
h15 <- h15[(h14$func > h14$BIRTH & h14$func < h14$D),]
#出生日<死亡日
h15 <- h15[(h15$BIRTH < h15$D),]
#性別必為男或女
h15 <- h15[(h15$SEX == 1 | h15$SEX == 2),]
#戶籍地點沒有對應城市的資料刪掉
h15 <- h15[complete.cases(h15$HOME_CITY),]
