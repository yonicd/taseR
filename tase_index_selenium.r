library(lubridate)
library(rvest)
library(XML)
library(plyr)
library(dplyr)
library(RSelenium)
library(stringr)

setwd("C:\\Users\\yoni\\Documents\\GitHub\\tase")

RSelenium::startServer()
remDr <- remoteDriver()
remDr$open(silent = F)

df.in=data.frame(Name=c("TA25","TA100"),indexID=c(142,137))
df.in$from.date=rep(format(Sys.Date()-days(2),"%d/%m/%Y"),2)
df.in$to.date=rep(format(Sys.Date(),"%d/%m/%Y"),2)



tase.index.daily=ddply(df.in,.(Name),.fun = function(df){
  #set url
  url=paste0("http://www.tase.co.il/Eng/MarketData/Indices/MarketCap/Pages/IndexHistoryData.aspx?Action=1&addTab=&IndexId=",df$indexID)
  
  #navigate to webpage
  remDr$navigate(url)
  #enter ui variables
  
  webElem <- remDr$findElement(using = 'xpath', value = '//*[@id="ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_rbFrequency1"]')
  webElem$setElementAttribute(attributeName = 'checked',value = 'true')
  webElem <- remDr$findElement(using = 'xpath', value = '//*[@id="ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_rbPeriod8"]')
  webElem$setElementAttribute(attributeName = 'checked',value = 'true')
  remDr$executeScript(paste0("$('#ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_dailyFromCalendar_TaseCalendar_dateInput_TextBox').val('",df$from.date,"');"), args = list())
  remDr$executeScript(paste0("$('#ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_dailyToCalendar_TaseCalendar_dateInput_TextBox').val('",df$to.date,"');"), args = list())
  #click button
  remDr$executeScript("$('#trhistory0').find(':button').click();", args = list())
  #wait for data to load
  Sys.sleep(5)
  #import html table to parse
  webElem <- remDr$findElement(using='xpath',value = '//*[@id="ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_gridHistoryData_DataGrid1"]')
  out=htmlParse(remDr$getPageSource(),asText = T)
  dataNode=getNodeSet(out,"//table[contains(@id,'gridHistoryData_DataGrid1')]")
  #parse table into data.frame
  tase.out=readHTMLTable(dataNode[[1]],header = T)%>%
    mutate_each(funs(as.Date(.,"%d/%m/%Y")),contains("date"))%>%
    mutate_each(funs(as.numeric(gsub("[,|%]","",.))),
                -contains("date"),-ends_with("type"))
  return(tase.out)},
  .progress = "text")

tase.index.intraday=ddply(df.in,.(Name),.fun = function(df){
  #set url
  url=paste0("http://www.tase.co.il/Eng/MarketData/Indices/MarketCap/Pages/IndexHistoryData.aspx?Action=1&addTab=&IndexId=",df.in$indexID)
  
  #navigate to webpage
  remDr$navigate(url[1])
  #enter ui variables
  
  webElem <- remDr$findElement(using = 'xpath', value = '//*[@id="ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_rbIndPeriod4"]')
  webElem$setElementAttribute(attributeName = 'checked',value = 'true')
  remDr$executeScript(paste0("$('#ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_InDayFromCalendar_TaseCalendar_dateInput_TextBox').val('",df.in$from.date[1],"');"), args = list())
  remDr$executeScript(paste0("$('#ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_InDayToCalendar_TaseCalendar_dateInput_TextBox').val('",df.in$to.date[1],"');"), args = list())
  #click button
  remDr$executeScript("$('#trhistory1').find(':button').click();", args = list())
  #wait for data to load
  Sys.sleep(2)
  #import html table to parse
  webElem <- remDr$findElement(using='xpath',value = '//*[@id="ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_gridHistoryData_DataGrid1"]')
  webElems<-webElem$findChildElements("css selector","a")
  links=unlist(sapply(webElems,function(x){x$getElementAttribute('href')}))
  tase.out=mdply(links,.fun = function(x) read.csv(x,header = T,skip = 1))
  tase.out=  tase.out%>%select(-X1)%>%
    rename(datetime=Time)%>%
    mutate(date=as.POSIXct(strptime(datetime,"%d/%m/%Y")),
           datetime=as.POSIXct(strptime(datetime,"%d/%m/%Y %H:%M:%S")))
  return(tase.out)},
  .progress = "text")

tase.index.otc=ddply(df.in,.(Name),.fun = function(df){
  url=paste0("http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?companyID=",
             df$companyID,
             "&subDataType=0",
             "&shareID=",df$shareID)
  #navigate to webpage
  remDr$navigate(url)
  #set ui
  webElem <- remDr$findElement(using = 'xpath', value = '//*[@id="ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_rbPeriodOTC8"]')
  webElem$setElementAttribute(attributeName = 'checked',value = 'true')
  remDr$executeScript(paste0("$('#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_calendarOTCFrom_TaseCalendar_dateInput_TextBox').val('",df$from.date,"');"), args = list())
  remDr$executeScript(paste0("$('#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_calendarOTCTo_TaseCalendar_dateInput_TextBox').val('",df$to.date,"');"), args = list())
  #click button
  remDr$executeScript("$('#trhistory3').find(':button').click();", args = list())
  #wait for page to load
  Sys.sleep(5)
  #capture table
  out=htmlParse(remDr$getPageSource(),asText = T)
  #organise into data.frame
  dataNode =getNodeSet(out,("//table[contains(@id,'gridHistoryData_DataGrid1')]"))
  tase.out=readHTMLTable(dataNode[[1]],header = T)%>%mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("Date"))
  return(tase.out)},
  .progress = "text")

remDr$closeall()
