#!/usr/bin/tclsh
#
# OMM Posting (off-stream) leverages on consumer login channel to contribute aka. "post" data
# up to ADH/ADS cache. Posted service must be up.
#
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

set ms 5000
every $ms {
    set price "4.[expr {round(rand()*1000)}]"
    $t marketPricePost "RIC TRI.N TIMACT now TRDPRC_1 $price"
}

vwait end
$t -delete