#!/usr/bin/tclsh
#
# subscribe to MarketByOrder and orderbook cache
# run this script with -n to not display orderbook
#
# REFRESH/IMAGE:
#    {SERVICE {NIP} RIC {ANZ.AX} MTYPE {REFRESH}}
#    {SERVICE {NIP} RIC {ANZ.AX} MTYPE {IMAGE} ACTION {ADD} KEY {538993C200035057B} ORDER_PRC {20.835}}
#
# UPDATE:
#    {SERVICE {NIP} RIC {ANZ.AX} MTYPE {UPDATE} ACTION {UPDATE} KEY {538993C200035057B} ORDER_PRC {20.214} ORDER_SIZE {41} ORDER_SIDE {BID} SEQNUM_QT {511} EX_ORD_TYP {0} CHG_REAS {10}}
#
# DELETE:
#    {SERVICE {NIP} RIC {ANZ.AX} MTYPE {UPDATE} ACTION {DELETE} KEY {538993C200083483B}}
#
# STATUS:
#    {SERVICE {NIP} RIC {ANZ.AX} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Open} TEXT {<NIP> Source cannot provide the requested capability of MMT_MARKET_BY_ORDER [7].}}

package require tclrfa
source ./utils/trap.tcl

# run with -n to disble orderbook displayed
if {[lindex $argv 0] == "-n"} {
    set displaybook "false"
} else {
    set displaybook "true"
    source ./utils/orderbook.tcl
}

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t setDebugMode "false"
$t acquireSession "Session3"
$t createOMMConsumer

$t login
$t directoryRequest
$t dictionaryRequest

set rics "ANZ.AX"
$t marketByOrderRequest "$rics"

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

        # display orderbook
        if {$displaybook} {
            updateorderbook $updates
            foreach ric $rics {
                displayorderbook "$ric" 25
            }
        }
    }
}

$t marketByOrderCloseAllRequest
$t -delete
