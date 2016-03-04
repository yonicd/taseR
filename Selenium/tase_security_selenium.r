library(lubridate)
library(rvest)
library(XML)
library(plyr)
library(dplyr)
library(RSelenium)
library(stringr)

stockID=read.csv("~/RawFiles/stockID.csv")

stockID=stockID%>%mutate(companyID=str_pad(companyID,width = 6,side="left",pad = "0"),
                         shareID=str_pad(shareID,width = 8,side="left",pad = "0"))


df.in=stockID%>%filter(Name%in%c("TEVA","LEUMI"))
df.in$from.date=rep(format(Sys.Date()-months(2),"%d/%m/%Y"),2)
df.in$to.date=rep(format(Sys.Date(),"%d/%m/%Y"),2)

RSelenium::startServer()
remDr <- remoteDriver()
remDr$open(silent = F)

tase.security.daily=ddply(df.in,.(Name),.fun = function(df){
    #set url
      url=paste0("http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?companyID=",
             df$companyID,
             "&subDataType=",0,
             "&shareID=",df$shareID)
    #navigate to webpage
      remDr$navigate(url)
    #enter ui variables
      webElem <- remDr$findElement(using = 'xpath', value = '//*[@id="ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_rbFrequency1"]')
      webElem$setElementAttribute(attributeName = 'checked',value = 'true')
      webElem <- remDr$findElement(using = 'xpath', value = '//*[@id="ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_rbPeriod8"]')
      webElem$setElementAttribute(attributeName = 'checked',value = 'true')
      remDr$executeScript(paste0("$('#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_dailyFromCalendar_TaseCalendar_dateInput_TextBox').val('",df$from.date,"');"), args = list())
      remDr$executeScript(paste0("$('#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_dailyToCalendar_TaseCalendar_dateInput_TextBox').val('",df$to.date,"');"), args = list())
    #click button
      remDr$executeScript("$('#trhistory0').find(':button').click();", args = list())
    #wait for data to load
      Sys.sleep(5)
    #import html table to parse
      webElem <- remDr$findElement(using='xpath',value = '//*[@id="ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_gridHistoryData_DataGrid1"]')
      out=htmlParse(remDr$getPageSource(),asText = T)
      dataNode=getNodeSet(out,"//table[contains(@id,'gridHistoryData_DataGrid1')]")
      metaNode =getNodeSet(out,("//table[contains(@id,'securityGrid_DataGrid1')]"))
    #parse table into data.frame
      tase.out=left_join(
                  readHTMLTable(metaNode[[1]],header = T)[1,c(1:4)]%>%mutate(x=1),
                  readHTMLTable(dataNode[[1]],header = T)%>%
                      mutate_each(funs(as.Date(.,"%d/%m/%Y")),contains("date"))%>%
                      mutate_each(funs(as.numeric(gsub("[,|%]","",.))),
                                  -contains("date"),-ends_with("type"))%>%mutate(x=1),
                  by="x")%>%
                select(-x)
    return(tase.out)},
  .progress = "text")

tase.security.intraday=ddply(df.in,.(Name),.fun = function(df){
    #set url
        url=paste0("http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?companyID=",
                    df$companyID,
                    "&subDataType=0",
                    "&shareID=",df$shareID)
    #navigate to webpage
      remDr$navigate(url)
    #click button
    remDr$executeScript("$('#trhistory1').find(':button').click();", args = list())
    #wait for page to load
    Sys.sleep(5)
    #capture table
    out=htmlParse(remDr$getPageSource(),asText = T)
    dataNode =getNodeSet(out,("//table[contains(@id,'gridHistoryData_DataGrid1')]"))
    metaNode =getNodeSet(out,("//parent::td[@class='tabTitleGridText']"))
    
    #organise into data.frame
    tase.out=left_join(
      data.frame(x=1,date=str_replace_all(
        (metaNode%>%html_text)[3],
        "[aA-zZ \n-]","")),
      readHTMLTable(dataNode[[1]],header = T)%>%
        mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("Time"))%>%mutate(x=1),
      by="x")%>%mutate(datetime=as.POSIXct(strptime(paste(date,Time),"%d/%m/%Y%H:%M")))%>%
      select(-c(x,date))%>%arrange(datetime)
    tase.out$datetime=tase.out$datetime+unlist(sapply((tase.out%>%count(Time))$n,seq,from=1))
  return(tase.out)},
  .progress = "text")

tase.security.otc=ddply(df.in,.(Name),.fun = function(df){
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
