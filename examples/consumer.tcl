#!/usr/bin/tclsh
#
# - Subscribe to multiple RICs, using local dictionary, debug mode is manually off.
# - Using Tcl to format and print out market data updates.
# - trap.tcl requires TclX lib to trap control-c and exit gracefully.
#
# REFRESH/IMAGE:
#    {SERVICE {NIP} RIC {EUR=} MTYPE {REFRESH}}
#    {SERVICE {NIP} RIC {EUR=} MTYPE {IMAGE} RDNDISPLAY {100} RDN_EXCHID {SES} BID {0.988} ASK {0.999} DIVPAYDATE {23 JUN 2011}}
#
# UPDATE:
#    {SERVICE {NIP} RIC {EUR=} MTYPE {UPDATE} BID_NET_CH {0.0041} BID {0.988} ASK {0.999} ASK_TIME {15:14:24:180:000:000}}
#
# STATUS:
#    {SERVICE {NIP} RIC {EUR=} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Open} TEXT {Source unavailable... will recover when source is up}}

package require tclrfa
source ./utils/trap.tcl

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t acquireSession "Session1"
$t createOMMConsumer
$t login
$t directoryRequest
$t dictionaryRequest
$t marketPriceRequest "EUR= JPY="

while {1} {
    foreach u [$t dispatchEventQueue] {
        puts "\n[dict get $u SERVICE] - [dict get $u RIC]"
        foreach {k v} $u {
            puts "[format "%15s    %-10s" $k $v]"
        }
    }
}

$t -delete
