#!/usr/bin/tclsh
#
# - get timeseries from TS1 service over IDN using RFA TS1 decoder
# - timeseries period options litterally are: daily, weekly or monthly
# - number of fileds are varied by different markets
# - setTimeSeriesPeriod is optional (daily)
# - setTimeSeriesMaxRecords is optional (10)
#
# series format:
#     {yyyy/mm/dd,close,open,high,low,volume,vwap,pe,...} {...} {...}
# or
#     {yyyy/mm/dd,Market holiday}
#
package require tclrfa

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t setDebugMode "false"
$t acquireSession "Session1"
$t createOMMConsumer
$t login
$t directoryRequest
$t dictionaryRequest

set ric "CHK.N"
set period "daily"
set maxrecords "20"

$t setTimeSeriesPeriod $period
$t setTimeSeriesMaxRecords $maxrecords

set timeseries [$t getTimeSeries $ric]
puts "\n\n############## $ric $period ([llength $timeseries] records) ##############"
puts [join $timeseries "\n"]\n\n

$t -delete