ptm <-proc.time()
setwd("C:/Users/USER/Google 雲端硬碟/airbox/程式")
#引用package
library(tidyverse)
library(lubridate)
library(readxl)
#raw data
daily_data <<- read_xlsx("全部(清完+合縣市+校正手自動測站).xlsx")
daily_data$日期 <-  as.Date(daily_data$日期)
daily_data$PM2.5 <- as.numeric(daily_data$PM2.5)
daily_data$PM10 <- as.numeric(daily_data$PM10)
month_data <<- read.csv("monthly.csv", header=TRUE, sep=",")
month_data$日期 <- as.Date(month_data$日期)
month_data$PM2.5 <- as.numeric(month_data$PM2.5)
month_data$PM10 <- as.numeric(month_data$PM10)

#airbox1~4 4季空氣盒子資料
#smart_search1~4 4季EPA
airbox1 <<- read.csv("201902c7.csv", header=TRUE, sep=",")
smart_search1 <<- read.csv("201902s7.csv", header=TRUE, sep=",")

#code 內
CIDW <- function(Time,LN,LT,lagtime,PMX,mode){
  #日平均或月平均#mode 1 日平均/mode 2 月平均
  #時間格式例子:2019/6/4
  if (mode == 1) {
    data <- daily_data
  }else if (mode == 2) {
    data <- month_data
  }
  #PMX PM2.5或PM10 # 1是PM2.5/2是PM10
  if (PMX == 1) {
    data <- data %>%
      select(測站,LON,LAT,日期,PM2.5) %>%
      rename(PM = PM2.5) %>%
      filter(日期 == Time - lagtime , PM >= 0)
    
  }else if (PMX == 2) {
    data <- data %>%
      select(測站,LON,LAT,日期,PM10) %>%
      rename(PM = PM10) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 3){
    data <- data %>%
      select(測站,LON,LAT,日期,AMB_TEMP) %>%
      rename(PM = AMB_TEMP) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 4){
    data <- data %>%
      select(測站,LON,LAT,日期,CO) %>%
      rename(PM = CO) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 5){
    data <- data %>%
      select(測站,LON,LAT,日期,NO) %>%
      rename(PM = NO) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 6){
    data <- data %>%
      select(測站,LON,LAT,日期,NO2) %>%
      rename(PM = NO2) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 7){
    data <- data %>%
      select(測站,LON,LAT,日期,NOx) %>%
      rename(PM = NOx) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 8){
    data <- data %>%
      select(測站,LON,LAT,日期,O3) %>%
      rename(PM = O3) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 9){
    data <- data %>%
      select(測站,LON,LAT,日期,RAINFALL) %>%
      rename(PM = RAINFALL) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 10){
    data <- data %>%
      select(測站,LON,LAT,日期,RH) %>%
      rename(PM = RH) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 11){
    data <- data %>%
      select(測站,LON,LAT,日期,SO2) %>%
      rename(PM = SO2) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 12){
    data <- data %>%
      select(測站,LON,LAT,日期,CH4) %>%
      rename(PM = CH4) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 13){
    data <- data %>%
      select(測站,LON,LAT,日期,NMHC) %>%
      rename(PM = NMHC) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }else if (PMX == 14){
    data <- data %>%
      select(測站,LON,LAT,日期,THC) %>%
      rename(PM = THC) %>%
      filter(日期 == Time - lagtime , PM >= 0)
  }
  #分季節 season1~4
  season1 <- data %>%
    filter(month(日期)>=1 & month(日期)<=12)
  #季節日數//預設為0
  nums1 <- 0
  
  #每一季推估濃度//預設為0
  ss1 <- 0
  
  #if有該季節
  if (nrow(season1) > 0) {
    #找出集群內監測站
    c1 <- airbox1 %>%     
      mutate(r = 2 * 6378.137 * asin(sqrt(sin(((LN*pi/180-lon*pi/180)/2))^2 + cos(lon*pi/180) * cos(LN*pi/180) * sin(((LT*pi/180-lat*pi/180)/2))^2))) %>%     
      arrange(r)   
    cc1 <- c1$Cluster[1]
    site1 <- smart_search1 %>%     
      filter(clu == cc1)
    season1 <- season1 %>%
      filter(測站 %in% site1$測站)
    #距離排序
    site_distance1 <- site1 %>%
      filter(測站 %in% season1$測站) %>%
      mutate(r = 2 * 6378.137 * asin(sqrt(sin(((LN*pi/180-LON*pi/180)/2))^2 + cos(LON*pi/180) * cos(LN*pi/180) * sin(((LT*pi/180-LAT*pi/180)/2))^2))) %>%     
      arrange(測站)
    nums1 <- season1 %>%
      select(日期) %>%
      unique() %>%
      nrow()
    #計算
    season1 <- season1 %>%
      group_by(測站) %>%
      summarise(mean_PM = mean(PM , na.rm = TRUE)) %>%
      arrange(測站) %>%
      mutate(r = site_distance1$r) %>%
      mutate(up = mean_PM/ r ^ 2) %>%
      mutate(down = 1 / r ^ 2) %>%
      select(up,down) %>%
      colSums()
    season1 <- season1[1]/season1[2]
    ss1 <- as.vector(season1)
  } 
  nums <- nums1
  ec <- ss1
  return(ec)
}

ptm <-proc.time()
i2007 <- c2007
i2007$day <- as.Date(i2007$day)

rr = vector()
for (i in c(1:nrow(i2007))){
  p <- CIDW(i2007$day[i],i2007$lon[i],i2007$lat[i],i2007$lagtime[i],1,1)
  rr = c(rr,p)
}
i2007$r <- rr
proc.time()-ptm

ptm <-proc.time()
i2008 <- c2008
i2008$day <- as.Date(i2008$day)

rr = vector()
for (i in c(1:nrow(i2008))){
  p <- CIDW(i2008$day[i],i2008$lon[i],i2008$lat[i],i2008$lagtime[i],i2008$PMX[i],i2008$mode[i])
  rr = c(rr,p)
}
i2008$r <- rr
proc.time()-ptm

ptm <-proc.time()
i2009 <- c2009
i2009$day <- as.Date(i2009$day)

rr = vector()
for (i in c(1:nrow(i2009))){
  p <- CIDW(i2009$day[i],i2009$lon[i],i2009$lat[i],i2009$lagtime[i],i2009$PMX[i],i2009$mode[i])
  rr = c(rr,p)
}
i2009$r <- rr
proc.time()-ptm

ptm <-proc.time()
i2010 <- c2010
i2010$day <- as.Date(i2010$day)

rr = vector()
for (i in c(1:nrow(i2010))){
  p <- CIDW(i2010$day[i],i2010$lon[i],i2010$lat[i],i2010$lagtime[i],i2010$PMX[i],i2010$mode[i])
  rr = c(rr,p)
}
i2010$r <- rr
proc.time()-ptm
export(i2010,"i2010.csv")

ptm <-proc.time()
i2011 <- c2011
i2011$day <- as.Date(i2011$day)

rr = vector()
for (i in c(1:nrow(i2011))){
  p <- CIDW(i2011$day[i],i2011$lon[i],i2011$lat[i],i2011$lagtime[i],i2011$PMX[i],i2011$mode[i])
  rr = c(rr,p)
}
i2011$r <- rr
proc.time()-ptm
export(i2011,"i2011.csv")

ptm <-proc.time()
i2012 <- c2012
i2012$day <- as.Date(i2012$day)

rr = vector()
for (i in c(1:nrow(i2012))){
  p <- CIDW(i2012$day[i],i2012$lon[i],i2012$lat[i],i2012$lagtime[i],i2012$PMX[i],i2012$mode[i])
  rr = c(rr,p)
}
i2012$r <- rr
proc.time()-ptm
export(i2012,"i2012.csv")

ptm <-proc.time()
i2013 <- c2013
i2013$day <- as.Date(i2013$day)

rr = vector()
for (i in c(1:nrow(i2013))){
  p <- CIDW(i2013$day[i],i2013$lon[i],i2013$lat[i],i2013$lagtime[i],i2013$PMX[i],i2013$mode[i])
  rr = c(rr,p)
}
i2013$r <- rr
proc.time()-ptm
export(i2013,"i2013.csv")

ptm <-proc.time()
i2014 <- c2014
i2014$day <- as.Date(i2014$day)

rr = vector()
for (i in c(1:nrow(i2014))){
  p <- CIDW(i2014$day[i],i2014$lon[i],i2014$lat[i],i2014$lagtime[i],i2014$PMX[i],i2014$mode[i])
  rr = c(rr,p)
}
i2014$r <- rr
proc.time()-ptm
export(i2014,"i2014.csv")

ptm <-proc.time()
i2015 <- gg
i2015$day <- as.Date(i2015$day)

rr = vector()
for (i in c(1:nrow(i2015))){
  p <- CIDW(i2015$day[i],i2015$lon[i],i2015$lat[i],i2015$lagtime[i],i2015$PMX[i],i2015$mode[i])
  rr = c(rr,p)
}
i2015$r <- rr
proc.time()-ptm
export(i2015,"i2015.csv")

ptm <-proc.time()
i2016 <- c2016
i2016$day <- as.Date(i2016$day)

rr = vector()
for (i in c(1:nrow(i2016))){
  p <- CIDW(i2016$day[i],i2016$lon[i],i2016$lat[i],i2016$lagtime[i],1,1)
  rr = c(rr,p)
}
i2016$r <- rr
proc.time()-ptm
export(i2016,"i2016.csv")

ptm <-proc.time()
i2017 <- c2017
i2017$day <- as.Date(i2017$day)

rr = vector()
for (i in c(1:nrow(i2017))){
  p <- CIDW(i2017$day[i],i2017$lon[i],i2017$lat[i],i2017$lagtime[i],1,1)
  rr = c(rr,p)
}
i2017$r <- rr
proc.time()-ptm
export(i2017,"i2017.csv")


ptm <-proc.time()
i2018 <- c2018
i2018$day <- as.Date(i2018$day)

rr = vector()
for (i in c(1:nrow(i2018))){
  p <- CIDW(i2018$day[i],i2018$lon[i],i2018$lat[i],i2018$lagtime[i],1,1)
  rr = c(rr,p)
}
i2018$r <- rr
proc.time()-ptm
export(i2018,"i2018.csv")

ptm <-proc.time()
i2019 <- add
i2019$day <- as.Date(i2019$day)

rr = vector()
for (i in c(1:nrow(i2019))){
  p <- CIDW(i2019$day[i],i2019$lon[i],i2019$lat[i],i2019$lagtime[i],1,1)
  rr = c(rr,p)
}
i2019$r <- rr
proc.time()-ptm
export(i2019,"i2019.csv")



install.packages("rio")
library("rio")
export(i1,"i1.csv")
export(i2007,"i2007.csv")
export(i2008,"i2008.csv")
export(i2009,"i2009.csv")


ptm <-proc.time()
i5 <- c2005
i5$day <- as.Date(i5$day)

rr = vector()
for (i in c(1:nrow(i5))){
  p <- CIDW(i5$day[i],i5$lon[i],i5$lat[i],i5$lagtime[i],i5$PMX[i],i5$mode[i])
  rr = c(rr,p)
}
i5$r <- rr
proc.time()-ptm
export(i5,"i2005.csv")
