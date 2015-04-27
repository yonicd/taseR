var page = require('webpage').create();
var fs = require('fs');
var path = 'tase_out_popup.html';
var webPAgeAddress  = 'http://www.tase.co.il/Eng/Management/GeneralPages/Pages/GridOnSeparatePage.aspx?Action=1&subDataType=2&IndexId=142&day=1&GridId=98&CurGuid={F9AF0818-85CC-43D3-AE34-76D89C0EB977}';
page.open(webPAgeAddress , function (status) {
  var content = page.content;
  fs.write(path,content,'w') ;
  phantom.exit();  
});
