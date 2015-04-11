# get_tase.js
# Gil Dafnai and Jonathan Sidi
tase.security=function(companyID,shareID,From.Date,To.Date,subDataType=0,Freq){
url=paste0("http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?companyID=",
           companyID,
           "&subDataType=",subDataType,
           "&shareID=",shareID)

Freq.Btn=paste0("#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_rbFrequency",which(c("daily","weekly","monthly","annual")%in%Freq))

writeLines(sprintf("var page = require('webpage').create();
                    var fs = require('fs');
                    var path = 'tase_out.html';
                    var webPAgeAddress  = '%s';
                   page.open(webPAgeAddress , function (status) {
  	
  	page.includeJs('http://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js', function() {
    	
    	console.log('clicking') ;

    	var myBtnValue = page.evaluate(function() {
    		
    		var myBtn = $('#trhistory0').find(':button') ;
        $('#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_rbPeriod8').prop('checked', true);
        $('#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_dailyFromCalendar_TaseCalendar_dateInput_TextBox').val('%s');
        $('#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_dailyToCalendar_TaseCalendar_dateInput_TextBox').val('%s');
        $('%s').prop('checked', true);
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
});",url,From.Date,To.Date,Freq.Btn),con="get_tase.js")}