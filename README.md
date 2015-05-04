# taseR
read data from tel aviv stock exchange (tase) website to r using a backend phantomjs and jquery script

tase.r is the wrapper function that calls low level functions

low levels functions that construct js file to pull securities data from tase website

  - Security
    - call_tase_security: stock daily history with dates as varin
    - call_tase_security_intraday: stock intra-day last trading day
    - call_tase_security_otc: stock daily OTC history with dates as varin
  - Treasure Bills
    - call_tase_tbill: treasury bill daily history with dates as varin
    - call_tase_tbill_intraday: treasury bill intra-day last trading day
    - call_tase_tbill_otc: treasury bill daily OTC history with dates as varin
  - Index
    - call_tase_index: index daily history with dates as varin
    - call_tase_index_intraday: index intra-day history with dates as varin
    - call_tase_index_components: index component daily history with date as varin
  
stockID.csv: dictionary of all stocks traded on tase with ticker symbols

todo:

  - batch downloading
  - combining to PerformanceAnalystics library for further analysis capabilities