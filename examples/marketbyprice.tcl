#!/usr/bin/tclsh
#
# subscribe to MarketByPrice and depth cache
# run this script with -n to not display market depth
#
# REFRESH/IMAGE:
#    {SERVICE {NIP} RIC {ANZ.CHA} MTYPE {REFRESH}}
#    {SERVICE {NIP} RIC {ANZ.CHA} MTYPE {IMAGE} ACTION {ADD} KEY {201000B} ORDER_PRC {20.1000} ORDER_SIDE {BID} ORDER_SIZE {17} NO_ORD {6} QUOTIM_MS {16987567} ORDER_TONE {}}
#
# UPDATE:
#    {SERVICE {NIP} RIC {ANZ.CHA} MTYPE {UPDATE} ACTION {UPDATE} KEY {201000B} NO_ORD {7} ORDER_SIDE {BID} ORDER_SIZE {5}}
#
# DELETE:
#   {SERVICE {NIP} RIC {ANZ.CHA} MTYPE {UPDATE} ACTION {DELETE} KEY {202000B}}
#
# STATUS:
#    {SERVICE {NIP} RIC {ANZ.CHA} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Open} TEXT {<NIP> Source cannot provide the requested capability of MMT_MARKET_BY_PRICE [8].}}

package require tclrfa
source ./utils/trap.tcl

# run with -n to disable market depth displayed
if {[lindex $argv 0] == "-o"} {
    set displaymarketdepth "false"
} else {
    set displaymarketdepth "true"
    source ./utils/marketdepth.tcl
}

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t acquireSession "Session3"
$t createOMMConsumer

$t login
$t directoryRequest
$t dictionaryRequest

set rics "ANZ.CHA"
$t marketByPriceRequest "$rics"

# run for N millisecs, parse updates and display on stdout
set end 0
after 1000000 {set end 1}
while {!$end} {
    set updates [$t dispatchEventQueue 1000]
    if {$updates != ""} {
        puts "\n$updates"
        foreach u $updates {
            puts "\n[dict get $u SERVICE] - [dict get $u RIC]"
            foreach {k v} $u {
                puts "[format "%15s    %-10s" $k $v]"
            }
        }

        # display depth
        if {$displaymarketdepth} {
            updatedepth $updates
            foreach ric $rics {
                displaydepth "$ric" 25
            }
        }
    }
}

$t marketByPriceCloseAllRequest
$t -delete
