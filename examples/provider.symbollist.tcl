#!/usr/bin/tclsh
#
# Non-interactive (full cached) publisher for symbol list e.g 0#BMD
# submission format can include fieldList as well, for example: 
#     	dict set SYMBOLLIST 0#BMD {FKLI { PROD_PERM {10} PROV_SYMB {MY439483} } FCPO {}}
#
# NOTE: symbol list publisher does not require a valid login name at the moment (RFA bug) 
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

set SYMBOLLIST1 {RIC {0#BMD} KEY {FCPO} ACTION {ADD} PROD_PERM {10} PROV_SYMB {MY439483}}
set SYMBOLLIST2 {RIC {0#BMD} KEY {FKLI} ACTION {ADD}}
$t symbolListSubmit $SYMBOLLIST1 $SYMBOLLIST2

# update rics from symbollist
after 20000 {
set UPDATE_SYMBOLLIST {RIC {0#BMD} KEY {FKLI} ACTION {UPDATE} PROD_PERM {12} PROV_SYMB {MY527690}}
$t symbolListSubmit $UPDATE_SYMBOLLIST
}

# delete rics from symbollist
after 40000 {
    set DEL_SYMBOLLIST1 {RIC {0#BMD} KEY {FCPO} ACTION {DELETE}}
    set DEL_SYMBOLLIST2 {RIC {0#BMD} KEY {FKLI} ACTION {DELETE}}
    $t symbolListSubmit $DEL_SYMBOLLIST1 $DEL_SYMBOLLIST2
}

#after 25000 {
#    $t closeAllSubmit
#}

vwait end
$t -delete