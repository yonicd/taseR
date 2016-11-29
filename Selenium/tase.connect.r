tase.connect=function(browserName="firefox",silent=F,...){
  require(RSelenium)
  
  RSelenium::startServer(dir = file.path(getwd(),'Selenium'))
  remDr <- remoteDriver(browserName = browserName)
  remDr$open(silent = silent)
  
  return(remDr)
}