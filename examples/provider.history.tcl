#!/usr/bin/tclsh
#
# Non-interactive (full cached) publisher for history domain
# HISTORY provides full indexed time series
#
package require tclrfa
source ./utils/trap.tcl
source ./utils/every.tcl

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t setDebugMode "true"
$t acquireSession "Session4"
$t createOMMProvider
$t login
$t dictionaryRequest

set UPDATE1 { RIC {tANZ.AX} TRDPRC_1 {40.124} SALTIM {now} TRADE_ID {123456789} BID_ORD_ID {5307FBL20AL7B} ASK_ORD_ID {5307FBL20BN8A}}
set UPDATE2 { RIC {tBHP.AX} TRDPRC_1 {25.234} SALTIM {now} TRADE_ID {987654321} BID_ORD_ID {5307FBL2XXXXB} ASK_ORD_ID {5307FBL2YYYYA}}
$t historySubmit $UPDATE1 $UPDATE2

set count 0
every 1000 {
    if {$count < 100} {
        $t historySubmit $UPDATE1 $UPDATE2
    }
    incr count
}

vwait end
$t -delete
