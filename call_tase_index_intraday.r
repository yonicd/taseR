# get_tase.js
# Gil Dafnai and Jonathan Sidi
tase.index.intraday=function(indexID,From.Date,To.Date){
  url=paste0("http://www.tase.co.il/Eng/MarketData/Indices/MarketCap/Pages/IndexHistoryData.aspx?Action=1&addTab=&IndexId=",indexID)

  
    
  writeLines(sprintf("var page = require('webpage').create();
                     var fs = require('fs');
                     var path = 'tase_out.html';
                     var webPAgeAddress  = '%s';
                     page.open(webPAgeAddress , function (status) {
                     
                     page.includeJs('http://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js', function() {
                     
                     console.log('clicking') ;
                     
                     var myBtnValue = page.evaluate(function() {


                     var myBtn = $('#trhistory1').find(':button') ;
                     $('#ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_rbIndPeriod4').prop('checked', true);
                     $('#ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_InDayFromCalendar_TaseCalendar_dateInput_TextBox').val('%s');
                     $('#ctl00_SPWebPartManager1_g_b2f63986_2b4a_438d_b1b1_fb08c9e1c862_ctl00_HistoryData1_InDayToCalendar_TaseCalendar_dateInput_TextBox').val('%s');
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
                     });",url,From.Date,To.Date),con="get_tase.js")}