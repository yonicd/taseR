# get_tase.js
# Gil Dafnai and Jonathan Sidi
tase.security.intraday=function(companyID,shareID){
  url=paste0("http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?companyID=",
             companyID,
             "&subDataType=0",
             "&shareID=",shareID)
  
  writeLines(sprintf("var page = require('webpage').create();
                     var fs = require('fs');
                     var path = 'tase_out.html';
                     var webPAgeAddress  = '%s';
                     page.open(webPAgeAddress , function (status) {
                     
                     page.includeJs('http://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js', function() {
                     
                     console.log('clicking') ;
                     
                     var myBtnValue = page.evaluate(function() {
                     
                     var myBtn = $('#trhistory1').find(':button') ;
                     myBtn.click();
                     return myBtn.attr('value') ;
                     });
                     console.log('clicked') ;			
                     //console.log(myBtnValue) ;
                     
                     window.setTimeout(function () {
                     console.log('time out') ;
                     var content = page.content;
                     fs.write(path,content,'w') ;
                     phantom.exit();
                     } , 8000);	
                     });
                     });",url),con="get_tase.js")}