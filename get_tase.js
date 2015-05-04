var page = require('webpage').create();
                     var fs = require('fs');
                     var path = 'tase_out.html';
                     var webPAgeAddress  = 'http://www.tase.co.il/Eng/Management/GeneralPages/Pages/GridOnSeparatePage.aspx?Action=1&subDataType=2&IndexId=143&day=3&date=635595552000000000&GridId=143&CurGuid={F9AF0818-85CC-43D3-AE34-76D89C0EB977}';
                     page.open(webPAgeAddress , function (status) {
                     var content = page.content;
                     fs.write(path,content,'w') ;
                     phantom.exit();  
                     });
