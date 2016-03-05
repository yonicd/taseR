tase.connect=function(browserName="firefox",silent=F,...){
  require(RSelenium)
  
  RSelenium::startServer()
  remDr <- remoteDriver(browserName = browserName)
  remDr$open(silent = silent)
  
  return(remDr)
}