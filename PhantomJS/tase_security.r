setwd("C:\\Users\\yoni\\Documents\\GitHub\\tase")
pkgs=c("lubridate","XML","RSelenium","plyr","dplyr","stringr","rvest")
out=sapply(pkgs,require,character.only = T,quietly =T)
f=list.files()
out=sapply(f[str_detect(f,glob2rx("call*.r"))],source,echo=F);rm(pkgs,out,f);cat("\014")

stockIDs=read.csv("stockID.csv")%>%
  mutate(companyID=str_pad(companyID,6,side = "left","0"),
         shareID=str_pad(shareID,8,side = "left","0"))


call.phantom=function(){
pJS <- phantom()
remDr <- remoteDriver(browserName = "phantom")
remDr$open()
Jin=paste0(readLines("get_tase.js"),collapse = "\n")
result <- remDr$phantomExecute(Jin)
pJS$stop()
}

url="tase_out.html"

stock=stockIDs%>%filter(Symbol=="TEVA")

if(type=="daily"){
  
  From.Date=format(Sys.Date()-months(3),"%d/%m/%Y")
  To.Date=format(Sys.Date(),"%d/%m/%Y")
  Freq="daily"
  
  tase.security(companyID=stock$companyID,
                shareID=stock$shareID,
                From.Date=From.Date,
                To.Date=To.Date,
                subDataType="0",Freq=Freq)
  
  call.phantom()
  
  dataNode =getNodeSet(htmlParse(url),("//table[contains(@id,'gridHistoryData_DataGrid1')]"))
  metaNode =getNodeSet(htmlParse(url),("//table[contains(@id,'securityGrid_DataGrid1')]"))
  
  tase.out=left_join(
  readHTMLTable(metaNode[[1]],header = T)[1,c(1:4)]%>%mutate(x=1),
  readHTMLTable(dataNode[[1]],header = T)%>%
  mutate_each(funs(as.Date(.,"%d/%m/%Y")),contains("date"))%>%
  mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("date"),-ends_with("type"))%>%mutate(x=1),
  by="x")%>%
  select(-x)
}

if(type=="intraday"){
  
  tase.security.intraday(companyID=stock$companyID,shareID=stock$shareID)
  
  call.phantom()
  
  str_replace_all(xpathSApply(htmlParse(url),path = '//*[@id="trResult"]/td/table/tbody/tr[1]/td/table/tbody/tr/td[2]'),
                  "[aA-zZ]","")

  
  dataNode =getNodeSet(htmlParse(url),("//table[contains(@id,'gridHistoryData_DataGrid1')]"))
  metaNode =getNodeSet(htmlParse(url),("//parent::td[@class='tabTitleGridText']"))
  
  tase.out=left_join(
    data.frame(x=1,date=str_replace_all(
      (html(url)%>%html_nodes(xpath="//parent::td[@class='tabTitleGridText']")%>%html_text)[3],
      "[aA-zZ \n-]","")),
    readHTMLTable(dataNode[[1]],header = T)%>%
      mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("Time"))%>%mutate(x=1),
    by="x")%>%mutate(datetime=as.POSIXct(strptime(paste(date,Time),"%d/%m/%Y%H:%M")))%>%
    select(-c(x,date))%>%arrange(datetime)
  
  tase.out$datetime=tase.out$datetime+unlist(sapply((tase.out%>%count(Time))$n,seq,from=1))
}

if(type=="otc"){
  
  From.Date=format(Sys.Date()-months(2),"%d/%m/%Y")
  To.Date=format(Sys.Date(),"%d/%m/%Y")


  tase.security.otc(companyID=stock$companyID,
                    shareID=stock$shareID,
                    From.Date=From.Date,
                    To.Date=To.Date)
  
  call.phantom()
  

  dataNode =getNodeSet(htmlParse(url),("//table[contains(@id,'gridHistoryData_DataGrid1')]"))

  
  tase.out=readHTMLTable(dataNode[[1]],header = T)%>%
      mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("Date"))
}




ggplot(tase.out%>%filter(!is.na(Volume))%>%head(-1)%>%select(-Time)%>%melt(.,id=c("datetime")),
       aes(x=datetime,y=value))+
  geom_point(size=.1)+facet_wrap(~variable,scales="free_y",ncol=1)

ggplot(tase.out%>%melt(.,id=c("Date")),
       aes(x=Date,y=value))+
  geom_point(size=.1)+facet_wrap(~variable,scales="free_y",ncol=1)