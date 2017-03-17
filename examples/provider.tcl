#!/usr/bin/tclsh
#
# Non-interactive (full cached) publisher for market price domain
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

set IMAGE1 {RIC {EUR=} RDNDISPLAY {100} RDN_EXCHID {155} BID {0.988} ASK {0.999} DIVPAYDATE {20110623}}
set IMAGE2 {RIC {C.N} RDNDISPLAY {100} RDN_EXCHID {NAS} OFFCL_CODE {isin1234XYZ} BID {4.23} DIVPAYDATE {20110623} OPEN_TIME {09:00:01.000}}
$t marketPriceSubmit $IMAGE1 $IMAGE2

# updates every x ms.
# after 500000 {every cancel {$t marketPriceSubmit $update1 $update2};set end 1}
set UPDATE1 {RIC {EUR=} BID_NET_CH {0.0041} BID {0.988} ASK {0.999} ASK_TIME {now}}

set vol 1000
set price 4.800
set ms 5000
dict set UPDATE2 RIC "C.N"
dict set UPDATE2 TIMACT {now}
every $ms {
    dict set UPDATE2 ACVOL_1 "[incr vol]"
    dict set UPDATE2 TRDPRC_1 "4.[expr {round(rand()*1000)}]"
    $t marketPriceSubmit $UPDATE2
}

# send item close status
#after 10000 {
#    $t closeAllSubmit
#}

vwait end
$t -delete
