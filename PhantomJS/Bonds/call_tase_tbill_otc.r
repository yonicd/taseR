# get_tase.js
# Gil Dafnai and Jonathan Sidi
tase.tbill.otc=function(companyID,shareID,From.Date,To.Date){
  url=paste0("http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?",
             "&subDataType=5",
             "&shareID=",shareID,
             "&bondType=")

  writeLines(sprintf("var page = require('webpage').create();
                     var fs = require('fs');
                     var path = 'tase_out.html';
                     var webPAgeAddress  = '%s';
                     page.open(webPAgeAddress , function (status) {
                     
                     page.includeJs('http://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js', function() {
                     
                     console.log('clicking') ;
                     
                     var myBtnValue = page.evaluate(function() {

                     var myBtn = $('#trhistory3').find(':button') ;
                     $('#ctl00_SPWebPartManager1_g_ed8af170_7f0e_440a_85fe_19d9352a2a86_ctl00_HistoryData1_rbPeriodOTC8').prop('checked', true);
                     $('#ctl00_SPWebPartManager1_g_ed8af170_7f0e_440a_85fe_19d9352a2a86_ctl00_HistoryData1_calendarOTCFrom_TaseCalendar_dateInput_TextBox').val('%s');
                     $('#ctl00_SPWebPartManager1_g_ed8af170_7f0e_440a_85fe_19d9352a2a86_ctl00_HistoryData1_calendarOTCTo_TaseCalendar_dateInput_TextBox').val('%s');
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