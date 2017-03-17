#!/usr/bin/tclsh
#
# Non-interactive (full cached) publisher for level 2 data
#     market by order - order book using order ID as key
#     market by price - market depth using price (without decimal point) as key
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

########################################
# order book publisher
########################################
if {1} {
    # add orders
    set ORDER1 {RIC {ANZ.AX} KEY {538993C200035057B} ACTION {ADD} ORDER_PRC {20.260} ORDER_SIZE {50} ORDER_SIDE {BID} SEQNUM_QT {2744} EX_ORD_TYP {0} CHG_REAS {6} ORDER_TONE {}}
    set ORDER2 {RIC {ANZ.AX} KEY {538993C200083483B} ACTION {ADD} ORDER_PRC {20.280} ORDER_SIZE {100} ORDER_SIDE {BID} SEQNUM_QT {2744} EX_ORD_TYP {0} CHG_REAS {6} ORDER_TONE {}}
    $t marketByOrderSubmit $ORDER1 $ORDER2

    # Update order book
    every 1000 {
        dict set ORDER_UPDATE RIC "ANZ.AX"
        dict set ORDER_UPDATE ACTION "UPDATE"
        dict set ORDER_UPDATE KEY "538993C200035057B"
        dict set ORDER_UPDATE ORDER_PRC 20.[expr {round(rand()*1000)}]
        dict set ORDER_UPDATE ORDER_SIZE [expr {round(rand()*1000)}]
        dict set ORDER_UPDATE ORDER_SIDE {BID}
        dict set ORDER_UPDATE SEQNUM_QT [expr {round(rand()*1000)}]
        dict set ORDER_UPDATE EX_ORD_TYP {0}
        dict set ORDER_UPDATE CHG_REAS {10}
        $t marketByOrderSubmit $ORDER_UPDATE
    }

    # delete an order
    after 20000 {
        dict set ORDER_DEL RIC "ANZ.AX"
        dict set ORDER_DEL ACTION "DELETE"
        dict set ORDER_DEL KEY "538993C200083483B"
        $t marketByOrderSubmit $ORDER_DEL
    }
}

########################################
# market depth publisher
########################################
if {0} {
    # add market depths
    set DEPTH1 { RIC {ANZ.CHA} KEY {201000B} ACTION {ADD} ORDER_PRC {20.1000} ORDER_SIDE {BID} ORDER_SIZE {1300} NO_ORD {13} QUOTIM_MS {16987567} ORDER_TONE {}}
    set DEPTH2 { RIC {ANZ.CHA} KEY {202000B} ACTION {ADD} ORDER_PRC {20.2000} ORDER_SIDE {BID} ORDER_SIZE {100} NO_ORD {13} QUOTIM_MS {16987567} ORDER_TONE {}}
    set DEPTH3 { RIC {ANZ.CHA} KEY {210000B} ACTION {ADD} ORDER_PRC {21.0000} ORDER_SIDE {ASK} ORDER_SIZE {500} NO_ORD {13} QUOTIM_MS {16987567} ORDER_TONE {}}
    $t marketByPriceSubmit $DEPTH1 $DEPTH2 $DEPTH3

    # update depth
    every 1000 {
        dict set DEPTH_UPDATE RIC "ANZ.CHA"
        dict set DEPTH_UPDATE ACTION "UPDATE"
        dict set DEPTH_UPDATE KEY "201000B"
        dict set DEPTH_UPDATE NO_ORD [expr {round(rand()*10)}]
        dict set DEPTH_UPDATE ORDER_SIDE {BID}
        dict set DEPTH_UPDATE ORDER_SIZE [expr {round(rand()*100)}]
        $t marketByPriceSubmit $DEPTH_UPDATE
    }

    # delete a depth
    after 20000 {
        dict set DEPTH_DEL RIC "ANZ.CHA"
        dict set DEPTH_DEL ACTION "DELETE"
        dict set DEPTH_DEL KEY "202000B"
        $t marketByPriceSubmit $DEPTH_DEL
    }
}

#after 25000 {
#    $t closeAllSubmit
#}

vwait end
$t -delete

