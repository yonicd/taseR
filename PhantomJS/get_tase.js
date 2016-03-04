var page = require('webpage').create();
                    var fs = require('fs');
                    var path = 'tase_out.html';
                    var webPAgeAddress  = 'http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?companyID=000629&subDataType=0&shareID=00629014';
                   page.open(webPAgeAddress , function (status) {
  	
  	page.includeJs('http://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js', function() {
    	
    	console.log('clicking') ;

    	var myBtnValue = page.evaluate(function() {
    		
    		var myBtn = $('#trhistory0').find(':button') ;
        $('#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_rbPeriod8').prop('checked', true);
        $('#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_dailyFromCalendar_TaseCalendar_dateInput_TextBox').val('15/03/2015');
        $('#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_dailyToCalendar_TaseCalendar_dateInput_TextBox').val('15/06/2015');
        $('#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_rbFrequency1').prop('checked', true);
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
});
