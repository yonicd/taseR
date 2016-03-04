setwd("C:\\Users\\yoni\\Documents\\GitHub\\tase")

stockIDs=read.csv("stockIDs.csv")
tickers=read.csv("tickers.csv")

stockID=left_join(tickers,stockIDs,by="shareID")%>%rename(Name.Full=name)

stockID=read.csv("stockID.csv")

library(lubridate)
library(XML)
library(plyr)
library(dplyr)
library(RSelenium)

sapply(list.files(pattern = "call"),source,echo=F)

url='http://www.tase.co.il/Eng/Management/GeneralPages/Pages/GridOnSeparatePage.aspx?Action=2&subDataType=2&IndexId=137&day=3&date=634138848000000000&GridId=143&CurGuid={F9AF0818-85CC-43D3-AE34-76D89C0EB977}'

hist.node=getNodeSet(htmlParse(url),("//table[contains(@id,
                                     'ctl00_SPWebPartManager1_g_fb4ab7c6_284a_4f5c_9cc2_0ebb4a9012a3_ctl00_NiaROGrid1_DataGrid1')]"))

tase=tase.fetch(cID='000281',
                sID='00281014',
                From.Date = format(Sys.Date()-months(3),"%d/%m/%Y"))

tase.index=tase.fetch(indexID='142',
                From.Date = format(Sys.Date()-months(3),"%d/%m/%Y"))

tase.index.intraday=tase.fetch(indexID='137',
                      From.Date = format(Sys.Date()-months(3),"%d/%m/%Y"),intraday=T)

tase.index.component=tase.fetch(indexID='142',
                               From.Date = format(Sys.Date()-months(3),"%d/%m/%Y"))

tase.fetch=function(cID='',sID='',indexID='',From.Date=format(Sys.Date()-months(1),"%d/%m/%Y"),To.Date=format(Sys.Date(),"%d/%m/%Y"),Dtype='0',Freq="daily",intraday=F){
  
#Security  
  if(cID!=''&sID!='')  tase.security(companyID=cID,shareID=sID,From.Date,To.Date,subDataType=Dtype,Freq)
  if(cID!=''&sID!='')  tase.security.otc(companyID=cID,shareID=sID,From.Date,To.Date)
  if(cID!=''&sID!='')  tase.security.intraday(companyID=cID,shareID=sID)
  
#Treasure Bills  
  if(cID!=''&sID!='')  tase.tbill(companyID=cID,shareID=sID,From.Date,To.Date,subDataType=Dtype,Freq)
  if(cID!=''&sID!='')  tase.tbill.otc(companyID=cID,shareID=sID,From.Date,To.Date)
  if(cID!=''&sID!='')  tase.tbill.intraday(companyID=cID,shareID=sID)

#Index  
  if(indexID!=''&intraday==F)  tase.index(indexID,From.Date,To.Date,Freq)
  if(indexID!=''&intraday==T)  tase.index.intraday(indexID,From.Date,To.Date)
  if(indexID!=''&intraday==T)  tase.index.component(indexID,From.Date)
  
  #system("phantomjs.exe get_tase.js")
  
  pJS <- phantom()
  remDr <- remoteDriver(browserName = "phantom")
  remDr$open()
  Jin=paste0(readLines("get_tase.js"),collapse = "\n")
  result <- remDr$phantomExecute(Jin)
  Sys.sleep(8)
  pJS$stop()
  
  url="tase_out.html"
  dataNode =getNodeSet(htmlParse(url),("//table[contains(@id,'gridHistoryData_DataGrid1')]"))
  dataNode =getNodeSet(htmlParse(url),("//table[contains(@id,'DataGrid1')]"))
  dataNode =getNodeSet(htmlParse(url),("//table[contains(@id,'tabAllShares')]
                                        //td//a//@onclick"))
  metaNode =getNodeSet(htmlParse(url),("//table[contains(@id,'securityGrid_DataGrid1')]"))
  
  
  y=getNodeSet(htmlParse(paste0("www.tase.co.il",str_split(dataNode[[4]][1],"'",n=3)[[1]][2]),isURL = T),"//table")
  
  x=unlist(sapply(xpathSApply(dataNode[[1]],"//td[@onclick]",xmlAttrs),'[[',1))
  x=x[grepl("csv",x)]
  
  tase=mdply(x,.fun = function(xin){
    suppressWarnings(
             read.csv(xin,
             header = T,
             skip = 1,
             col.names = c("Time","LastIndex","IndexType","Change"),
             stringsAsFactors = F))})
  
  if(length(metaNode)==0){
    tase=readHTMLTable(dataNode[[1]],header = T)%>%
          mutate_each(funs(as.Date(.,"%d/%m/%Y")),contains("date"))%>%
          mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("date"))
    
    tase=readHTMLTable(dataNode[[1]],header = T)
    tase=tase[,-c(9,10)]%>%filter(!is.na(ISIN))

    
    
  }else{
    tase=left_join(
                  readHTMLTable(metaNode[[1]],header = T)[1,c(1:4)]%>%mutate(x=1),
                  readHTMLTable(dataNode[[1]],header = T)%>%
                    mutate_each(funs(as.Date(.,"%d/%m/%Y")),contains("date"))%>%
                    mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("date"),-ends_with("type"))%>%mutate(x=1),
                  by="x")%>%
      select(-x)
}
return(tase)
}