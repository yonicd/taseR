// get_tase.js
// Gil Dafnai and Jonathan Sidi


var page = require('webpage').create();
var fs = require('fs');
var path = 'tase_out.html' ;


var webPAgeAddress  = 'http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?companyID=001612&subDataType=0&shareID=01130699';

//var webPAgeAddress  = 'http://www.tase.co.il/Eng/marketdata/indices/marketcap/Pages/IndexHistoryData.aspx?Action=1&subDataType=0&IndexId=142';

//var myTableID = 'ctl00_SPWebPartManager1_g_54223d45_af2f_49cf_88ed_9e3db1499c51_ctl00_HistoryData1_gridHistoryData_DataGrid1' ;


page.open(webPAgeAddress , function (status) {
  	
  	page.includeJs("http://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js", function() {
    	
    	console.log("clicking") ;

    	var myBtnValue = page.evaluate(function() {
    		
    		var myBtn = $("#trhistory0").find(":button") ;
    		myBtn.click();
    		return myBtn.attr("value") ;
    		
    	});
    	console.log("clicked") ;			
    	//console.log(myBtnValue) ;

    	window.setTimeout(function () {
			console.log("time out") ;
			var content = page.content;
			fs.write(path,content,'w') ;
			phantom.exit();
		} , 8000);	
	});

	
	
	
	// var content = page.content;
	// fs.write(path,content,'w') ;

	  		
});

// phantom.exit();