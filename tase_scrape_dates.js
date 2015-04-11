// scrape_tase.js

var page = require('webpage').create();
var fs = require('fs');
var path = 'tase_scrape_dates.html' ;


var webPAgeAddress  = 'http://www.tase.co.il/Eng/general/company/Pages/companyHistoryData.aspx?companyID=001363&subDataType=0&shareID=01100007';

//var myTableID = 'ctl00_SPWebPartManager1_g_54223d45_af2f_49cf_88ed_9e3db1499c51_ctl00_HistoryData1_gridHistoryData_DataGrid1' ;

var id_of_endDate_window    =  "ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_dailyToCalendar_TaseCalendar_dateInput_TextBox";

var id_of_startDate_window  =  "ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_dailyFromCalendar_TaseCalendar_dateInput_TextBox";

function getDate(day , month , year){
    day =  day.toString() ;
    month = month.toString() ;
    year = year.toString() ;

    return day+"/"+month+"/"+year ; 
}
var startDate = getDate(01 , 01 , 2015) ;
var endDate = getDate(11 , 04 , 2015) ;
//console.log(startDate) ;
//console.log(endDate) ;

page.open(webPAgeAddress , function (status) {
  	
  	page.includeJs("http://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js", function() {
    	
    	console.log("clicking") ;

    	var myBtnValue = page.evaluate(function() {
    		
    		var myBtn = $("#trhistory0").find(":button") ;
        $("#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_rbPeriod8").prop("checked", true)

  $("#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_dailyFromCalendar_TaseCalendar_dateInput_TextBox").val("01/01/2015");
$("#ctl00_SPWebPartManager1_g_301c6a3d_c058_41d6_8169_6d26c5d97050_ctl00_HistoryData1_dailyToCalendar_TaseCalendar_dateInput_TextBox").val("11/04/2015");
    		myBtn.click();
    		//myRadioBtn.click();
    		return myBtn.attr("value") ;
    		
    	});
    	console.log("clicked") ;			
    	console.log(myBtnValue) ;

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