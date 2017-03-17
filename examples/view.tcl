#!/usr/bin/tclsh
#
# Specify a set of fields in a request to subscribe only defined field.
#
package require tclrfa
source ./utils/trap.tcl

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t acquireSession "Session1"
$t createOMMConsumer
$t login
$t directoryRequest
$t dictionaryRequest
$t setView "RDNDISPLAY TRDPRC_1 22 25"
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
