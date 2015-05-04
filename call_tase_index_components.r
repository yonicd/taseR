# get_tase.js
# Gil Dafnai and Jonathan Sidi
tase.index.component=function(indexID,From.Date){

  date.url=1e9*(24*6*6)*as.numeric((as.Date(From.Date)-as.Date("0001-01-01")))
  
  url=paste0("http://www.tase.co.il/Eng/Management/GeneralPages/Pages/GridOnSeparatePage.aspx?Action=1&subDataType=2&IndexId=",indexID,
             "&day=3&date=",date.url,
             "&GridId=143&CurGuid={F9AF0818-85CC-43D3-AE34-76D89C0EB977}")
  
  writeLines(sprintf("var page = require('webpage').create();
                     var fs = require('fs');
                     var path = 'tase_out.html';
                     var webPAgeAddress  = '%s';
                     page.open(webPAgeAddress , function (status) {
                     var content = page.content;
                     fs.write(path,content,'w') ;
                     phantom.exit();  
                     });",url),con="get_tase.js")}