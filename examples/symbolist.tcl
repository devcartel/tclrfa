#!/usr/bin/tclsh
#
# Request for symbolList. Currently RFA only support refresh messages
# for symbolList. Hence, polling is required and symbolListRequest is called
# internally by getSymbolList.
#
# Sample:
#   {SERVICE {NIP} RIC {0#BMD} MTYPE {REFRESH}} 
#   {SERVICE {NIP} RIC {0#BMD} MTYPE {IMAGE} ACTION {ADD} KEY {FKLI} PROD_PERM {12} PROV_SYMB {MY527690}} {SERVICE {NIP} RIC {0#BMD} MTYPE {IMAGE} ACTION {ADD} KEY {FCPO} PROD_PERM {10} PROV_SYMB {MY439483}}
#
# STATUS:
#    {SERVICE {NIP} RIC {0#BM} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Closed} TEXT {F10: Not In Cache}}
package require tclrfa

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t acquireSession "Session3"
$t createOMMConsumer

$t login

# Must call directory/dictinary request first
$t directoryRequest
$t dictionaryRequest

set RIC "0#BMD"
set symbolList "[$t getSymbolList $RIC]"
puts "\n=======\n$RIC\n======="
puts [join $symbolList "\n"]\n

$t -delete
