#!/usr/bin/tclsh
#
# Like a consumer but no updates after refresh messages
#
# IMAGE/REFRESH:
#    {SERVICE {NIP} RIC {EUR=} MTYPE {REFRESH}} 
#    {SERVICE {NIP} RIC {EUR=} MTYPE {IMAGE} RDNDISPLAY {100} RDN_EXCHID {SES} BID {0.988} ASK {0.999} DIVPAYDATE {23 JUN 2011}}
#
# STATUS:
#    {SERVICE {NIP} RIC {EUR=} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Open} TEXT {Source unavailable... will recover when source is up}}
package require tclrfa
source ./utils/trap.tcl

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t setDebugMode "false"
$t acquireSession "Session1"
$t createOMMConsumer

$t login

$t directoryRequest
$t dictionaryRequest

set rics "JPY= EUR="
$t setInteractionType "snapshot"
$t marketPriceRequest "$rics"

# run until all images received or timeout
set timeout "false"
set refresh_received 0
after 10000 {set timeout "true"}
while {!$timeout && ($refresh_received < [llength $rics])} {
    foreach u [$t dispatchEventQueue] {
        puts "\n[dict get $u SERVICE] - [dict get $u RIC]"
        foreach {k v} $u {
            puts "[format "%15s    %-10s" $k $v]"
            if {$k == "MTYPE" && $v == "REFRESH"} {
                incr refresh_received
            }
        }
    }
}

$t -delete
