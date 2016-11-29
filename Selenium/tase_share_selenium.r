require(stringr);require(rvest);require(plyr);require(dplyr)
options(scipen=999)

tase.share.daily=ddply(df.in,.(Name),.fun = function(df){
    #set url
      url=paste0("http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?companyID=",
             df$companyID,
             "&subDataType=",0,
             "&shareID=",df$secID)
    #navigate to webpage
      con$navigate(url)
    #enter ui variables
      prefix="ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_"
      Freq.path=paste0(prefix,"rbFrequency",which(c("daily","weekly","monthly","annual")%in%df$Freq))
      webElem <- con$findElement(using = 'xpath', value = paste0('//*[@id="',Freq.path,'"]'))
      webElem$setElementAttribute(attributeName = 'checked',value = 'true')
      webElem <- con$findElement(using = 'xpath', value = paste0('//*[@id="',prefix,'rbPeriod8"]'))
      webElem$setElementAttribute(attributeName = 'checked',value = 'true')
      con$executeScript(paste0("$('#",prefix,"dailyFromCalendar_TaseCalendar_dateInput_TextBox').val('",df$from.date,"');"), args = list())
      con$executeScript(paste0("$('#",prefix,"dailyToCalendar_TaseCalendar_dateInput_TextBox').val('",df$to.date,"');"), args = list())
    #click button
      con$executeScript("$('#trhistory0').find(':button').click();", args = list())
    #wait for data to load
      Sys.sleep(5)
    #import html table to parse
      webElem <- con$findElement(using='xpath',value = '//*[@id="ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_gridHistoryData_DataGrid1"]')
      out=htmlParse(con$getPageSource(),asText = T)
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

tase.share.intraday=ddply(df.in,.(Name),.fun = function(df){
    #set url
        url=paste0("http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?companyID=",
                    df$companyID,
                    "&subDataType=0",
                    "&shareID=",df$secID)
    #navigate to webpage
      con$navigate(url)
    #click button
    con$executeScript("$('#trhistory1').find(':button').click();", args = list())
    #wait for page to load
    Sys.sleep(5)
    #capture table
    out=htmlParse(con$getPageSource(),asText = T)
    dataNode =getNodeSet(out,("//table[contains(@id,'gridHistoryData_DataGrid1')]"))
    metaNode =xpathSApply(out,('//*[(@id = "trResult")]//*[contains(concat( " ", @class, " " ), concat( " ", "tabTitleGridText", " " ))]'),xmlValue)
    #organise into data.frame
    tase.out=
      readHTMLTable(dataNode[[1]],header = T)%>%
      mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("Time"))%>%
      mutate(date=gsub('[^0-9]','',metaNode),
             DateTime=as.POSIXct(strptime(paste(date,Time),"%d%m%Y%H:%M")))%>%
      select(-c(date))%>%arrange(DateTime)
  return(tase.out)},
  .progress = "text")

tase.share.otc=ddply(df.in,.(Name),.fun = function(df){
url=paste0("http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?companyID=",
           df$companyID,
           "&subDataType=0",
           "&shareID=",df$secID)
#navigate to webpage
con$navigate(url)
#set ui
prefix="ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_"
webElem <- con$findElement(using = 'xpath', value = paste0('//*[@id="',prefix,'rbPeriodOTC8"]'))
webElem$setElementAttribute(attributeName = 'checked',value = 'true')
con$executeScript(paste0("$('#",prefix,"calendarOTCFrom_TaseCalendar_dateInput_TextBox').val('",df$from.date,"');"), args = list())
con$executeScript(paste0("$('#",prefix,"calendarOTCTo_TaseCalendar_dateInput_TextBox').val('",df$to.date,"');"), args = list())
#click button
con$executeScript("$('#trhistory3').find(':button').click();", args = list())
#wait for page to load
Sys.sleep(5)
#capture table
out=htmlParse(con$getPageSource(),asText = T)
#organise into data.frame
dataNode =getNodeSet(out,("//table[contains(@id,'gridHistoryData_DataGrid1')]"))
tase.out=readHTMLTable(dataNode[[1]],header = T)%>%mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("Date"))
return(tase.out)},
  .progress = "text")