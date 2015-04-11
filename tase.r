setwd("C:\\Users\\yoni\\Documents\\GitHub\\tase")

library(XML)
library(dplyr)


system("phantomjs.exe get_tase.js")

url="tase_out.html"
dataNode =getNodeSet(htmlParse(url),("//table[contains(@id,'gridHistoryData_DataGrid1')]"))
metaNode =getNodeSet(htmlParse(url),("//table[contains(@id,'securityGrid_DataGrid1')]"))

if(length(metaNode)==0){
tase=readHTMLTable(dataNode[[1]],header = T)%>%
                 mutate_each(funs(as.Date(.,"%d/%m/%Y")),contains("date"))%>%
                 mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("date"))
}else{
tase=left_join(readHTMLTable(metaNode[[1]],header = T)[1,c(1:4)]%>%mutate(x=1),
               readHTMLTable(dataNode[[1]],header = T)%>%
  mutate_each(funs(as.Date(.,"%d/%m/%Y")),contains("date"))%>%
  mutate_each(funs(as.numeric(gsub("[,|%]","",.))),-contains("date"))%>%mutate(x=1),
  by="x")%>%select(-x)
}

