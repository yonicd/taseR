# taseR
read data from tel aviv stock exchange (tase) website to r using a backend phantomjs and jquery script

tase.r is the wrapper function that calls low level functions

low levels functions that construct js file to pull securities data from tase website

  - call_tase: stock daily history with dates as varin
  - call_tase_index: index daily history with dates as varin
  - call_tase_index_intraday: index intra-day history with dates as varin
  - call_tase_index_components: index components daily history
  
stockID.csv: dictionary of all stocks traded on tase with ticker symbols

todo: 
  - corporate bonds
  - otc trading
  - t-bills
  - batch downloading
  - combining to PerformanceAnalystics library for further analysis capabilities