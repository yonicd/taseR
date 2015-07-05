system("phantomjs.exe get_tase.js")

z <- strptime("2010-01-15 13:55:23.975234", "%Y-%m-%d %H:%M:%OS")
op <- options(digits.secs=3)
options(op)

options(scipen=999)

strptime(date(), "%OS")

as.Date("2015-04-21")-as.Date("2015-03-16")

b=
  1000*24*60*60*as.numeric(Sys.Date()-as.Date("2015-04-21"))
a=1000*24*60*60*as.numeric(Sys.Date()-as.Date("2015-03-16"))
(a-b)
/(1000*24*60*60)

63565171200000/(1000*24*60*60)
63562060800000/(1000*24*60*60)
as.Date("2015-04-21")-735708

1e9*(24*6*6)*as.numeric((as.Date("2015-02-15")-as.Date("0001-01-01")))




