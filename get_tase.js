var page = require('webpage').create();
                     var fs = require('fs');
                     var path = 'tase_out.html';
                     var webPAgeAddress  = 'http://www.tase.co.il/Eng/MarketData/Indices/MarketCap/Pages/IndexComponents.aspx?Action=1&addTab=&IndexId=137';
                     page.open(webPAgeAddress , function (status) {
                     
                     page.includeJs('http://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js', function() {
                     
                     console.log('clicking') ;
                     
                     var myBtnValue = page.evaluate(function() {
                     
                     var myBtn = $('#trotherDate').find(':button') ;
                     $('#ctl00_SPWebPartManager1_g_586d3b01_0278_44c2_a993_5a672c228633_ctl00_otherDate_TaseCalendar_dateInput_TextBox').val('20/04/2015');
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
