#!/usr/bin/tclsh
#
# Subscribe to market price and and pause the streaming. Once paused,
# updates are conflated at ADS. To get 10-second conflated update, just
# resume and pause again every 10 seconds.
#
package require tclrfa
source ./utils/trap.tcl
source ./utils/every.tcl

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t acquireSession "Session1"
$t createOMMConsumer
$t login
$t directoryRequest
$t dictionaryRequest
$t marketPriceRequest "JPY="
$t dispatchEventQueue 1000
$t pauseAll

set ms 10000
every $ms {
    $t resumeAll
    foreach u [$t dispatchEventQueue 100] {
        puts "\n[dict get $u SERVICE] - [dict get $u RIC]"
        foreach {k v} $u {
            puts "[format "%15s    %-10s" $k $v]"
        }
    }
    $t pauseAll
}

vwait forever
$t -delete
