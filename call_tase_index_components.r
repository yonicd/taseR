# get_tase.js
# Gil Dafnai and Jonathan Sidi
tase.index.component=function(indexID,From.Date){
  url=paste0("http://www.tase.co.il/Eng/MarketData/Indices/MarketCap/Pages/IndexComponents.aspx?Action=1&addTab=&IndexId=",indexID)
  
  writeLines(sprintf("var page = require('webpage').create();
                     var fs = require('fs');
                     var path = 'tase_out.html';
                     var webPAgeAddress  = '%s';
                     page.open(webPAgeAddress , function (status) {
                     
                     page.includeJs('http://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js', function() {
                     
                     console.log('clicking') ;
                     
                     var myBtnValue = page.evaluate(function() {
                     
                     var myBtn = $('#trotherDate').find(':button') ;
                     $('#ctl00_SPWebPartManager1_g_586d3b01_0278_44c2_a993_5a672c228633_ctl00_otherDate_TaseCalendar_dateInput_TextBox').val('%s');
                     myBtn.click();
                     return myBtn.attr('value') ;
                     });
                     console.log('clicked') ;			
                     //console.log(myBtnValue) ;
                     

                    page.onPageCreated = function(newPage) {
                      console.log('A new child page was created! Its requested URL is not yet available, though.');
                      // Decorate
                      newPage.onClosing = function(closingPage) {
                        console.log('A child page is closing: ' + closingPage.url);
                      };
                    };

                     window.setTimeout(function () {
                     console.log('time out') ;
                     var content = page.content;
                     fs.write(path,content,'w') ;
                     phantom.exit();
                     } , 8000);	
                     });
                     });",url,From.Date),con="get_tase.js")}