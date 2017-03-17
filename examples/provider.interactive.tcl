#!/usr/bin/tclsh
#
# Interactive (server) publisher for market price domain
#
package require tclrfa
package require Tclx
source ./utils/every.tcl

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t acquireSession "Session5"
$t createOMMProvider
$t dictionaryRequest

proc interrupt {} {
    uplevel {$t logoutAllSubmit}
    uplevel {$t -delete}
    exit 1
}
signal trap SIGINT interrupt

every 5000 {
    set price "4.[expr {round(rand()*1000)}]"
    set unifiedWatchList {}
    set sessions [$t getClientSessions]
    foreach session $sessions {
        set clientWatchList [$t getClientWatchList $session]
        set unifiedWatchList [union $unifiedWatchList $clientWatchList]
        puts "\[sessions] $session : $clientWatchList"
    }
    puts "\[unifiedWatchList] $unifiedWatchList"
    foreach ric $unifiedWatchList {
        $t marketPriceSubmit "RIC $ric TIMACT now TRDPRC_1 $price"
    }
}

while {1} {
    foreach u [$t dispatchEventQueue 100] {
        puts "\[data] $u"
        set mtype [dict get $u "MTYPE"]
        set sessionID [dict get $u "SESSIONID"]
        if {$mtype == "LOGIN"} {
            # simple auth
            if {!([dict get $u "USERNAME"] == "tclrfa")} {
                $t logoutSubmit $sessionID
            }
        }
    }
    update
}
