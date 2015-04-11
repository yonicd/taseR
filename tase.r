setwd("C:\\Users\\yoni\\Documents\\GitHub\\tase")

library(lubridate)
library(XML)
library(dplyr)
source("call_tase.r")


tase=tase.fetch(cID='000281',
                sID='00281014',
                From.Date = format(Sys.Date()-months(3),"%d/%m/%Y"))

tase.fetch=function(cID,sID,From.Date=format(Sys.Date()-months(1),"%d/%m/%Y"),To.Date=format(Sys.Date(),"%d/%m/%Y"),Dtype='0',Freq="daily"){
  tase.security(companyID=cID,shareID=sID,From.Date,To.Date,subDataType=Dtype,Freq)
  system("phantomjs.exe get_tase.js")
  url="tase_out.html"
  dataNode =getNodeSet(htmlParse(url),("//table[contains(@id,'gridHistoryData_DataGrid1')]"))
  metaNode =getNodeSet(htmlParse(url),("//table[contains(@id,'securityGrid_DataGrid1')]"))
  
  if(length(metaNode)==0){
    tase=readHTMLTable(dataNode[[1]],header = T)%>%
          mutate_each(funs(as.Date(.,"%d/%m/%Y")),contains("date"))%>%
          mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("date"))
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