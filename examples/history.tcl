#!/usr/bin/tclsh
#
# Request for historical data (RDM type 12) published by provider.history.tcl
# This domain is not officially supported by Thomson Reuters
#
# REFRESH/IMAGE:
#   {SERVICE {NIP} RIC {tANZ.AX} MTYPE {REFRESH}} {SERVICE {NIP} RIC {tANZ.AX} MTYPE {IMAGE} TRPRC_1 {40.124} SALTIM {14:31:34:335:000:000} TRADE_ID {123456789} BID_ORD_ID {5307FBL20AL7B}ASK_ORD_ID {5307FBL20BN8A}}
#
# STATUS: 
#   {SERVICE {NIP} RIC {tANZ.AX} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Open} TEXT {<NIP> Source cannot provide the requested capability of MMT_HISTORY [12].}}

package require tclrfa
source ./utils/trap.tcl
source ./utils/every.tcl

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t setDebugMode "true"
$t acquireSession "Session3"
$t createOMMConsumer
$t login
$t directoryRequest
$t dictionaryRequest

set RIC "tANZ.AX"
$t historyRequest $RIC

set count 0
while {![$t isHistoryRefreshComplete]} {
    foreach u [$t dispatchEventQueue]  {
        if {$count == 1} {
            puts "\n[dict get $u SERVICE] - [dict get $u RIC]"
            puts "-----------------------"
            foreach {k v} $u {
                puts -nonewline "$k,"
            }
            puts ""
            foreach {k v} $u {
                puts -nonewline "$v,"
            }
        } elseif {$count > 1} {
            foreach {k v} $u {
                puts -nonewline "$v,"
            }
        }
        puts ""
        incr count
    }
    update
}
puts "\n\n########## total history records: [expr $count - 1] ###################\n\n"
$t -delete
