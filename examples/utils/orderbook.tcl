#!/usr/bin/tclsh
#
# Create orderbook from update tuples
#
namespace eval ::orderbook:: {}

proc updateorderbook {updates} {

    foreach u $updates {
        set service [dict get $u SERVICE]
        set ric [dict get $u RIC]
        set mtype [dict get $u MTYPE]
        if {$mtype == "STATUS"} {
            continue
        } elseif {$mtype == "REFRESH"} {
            array set ::orderbook::$ric {
                BID {}
                BIDSIZ {}
                BIDORDERID {}
                ASK {}
                ASKSIZ {}
                ASKORDERID {}
            }
            continue
        }
        set action [dict get $u ACTION]
        set key [dict get $u KEY]
        #puts "\n$service - $ric ($action $key)"

        set order_prc "0"
        foreach {k v} $u {
            #puts "[format "%15s    %-10s" $k $v]"
            switch -exact $k {
                ORDER_SIDE {
                    set order_side $v
                } ORDER_SIZE {
                    set order_size $v
                } ORDER_PRC {
                    set order_prc $v
                }
            }
        }

        # determine ORDER_SIDE in the update
        if ([regexp {B$} $key]) {
            set order_side "BID"
        } else {
            set order_side "ASK"
        }

        if {![array exists ::orderbook::$ric]} {
            array set ::orderbook::$ric {
                BID {}
                BIDSIZ {}
                BIDORDERID {}
                ASK {}
                ASKSIZ {}
                ASKORDERID {}
            }
        }

        # update orderbook for N levels for a ric
        switch -exact $action {
            ADD {
                # prevent duplicate key (e.g. looping canned data)
                if {[eval lsearch \${::orderbook::${ric}(${order_side}ORDERID)} $key] < 0} {
                    lappend ::orderbook::${ric}($order_side) $order_prc
                    if {$order_side == "BID"} {
                        set ::orderbook::${ric}(BID) [eval lsort -real -decreasing \${::orderbook::${ric}(BID)}]
                        set pos [lindex [eval lsearch -all -exact \${::orderbook::${ric}(BID)} $order_prc] end]
                        set ::orderbook::${ric}(BIDSIZ) [eval linsert \${::orderbook::${ric}(BIDSIZ)} $pos $order_size]
                        set ::orderbook::${ric}(BIDORDERID) [eval linsert \${::orderbook::${ric}(BIDORDERID)} $pos $key]
                    } else {
                        set ::orderbook::${ric}(ASK) [eval lsort -real -increasing \${::orderbook::${ric}(ASK)}]
                        set pos [lindex [eval lsearch -all -exact \${::orderbook::${ric}(ASK)} $order_prc] end]
                        set ::orderbook::${ric}(ASKSIZ) [eval linsert \${::orderbook::${ric}(ASKSIZ)} $pos $order_size]
                        set ::orderbook::${ric}(ASKORDERID) [eval linsert \${::orderbook::${ric}(ASKORDERID)} $pos $key]
                    }
                }
            } UPDATE {
                # if the updated item not in order book cache, then ADD it.(e.g. looping canned data)
                if {([eval lsearch \${::orderbook::${ric}(${order_side}ORDERID)} $key] < 0) && ($order_size > 0)} {
                    lappend ::orderbook::${ric}($order_side) $order_prc
                    if {$order_side == "BID"} {
                        set ::orderbook::${ric}(BID) [eval lsort -real -decreasing \${::orderbook::${ric}(BID)}]
                        set pos [lindex [eval lsearch -all -exact \${::orderbook::${ric}(BID)} $order_prc] end]
                        set ::orderbook::${ric}(BIDSIZ) [eval linsert \${::orderbook::${ric}(BIDSIZ)} $pos $order_size]
                        set ::orderbook::${ric}(BIDORDERID) [eval linsert \${::orderbook::${ric}(BIDORDERID)} $pos $key]
                    } else {
                        set ::orderbook::${ric}(ASK) [eval lsort -real -increasing \${::orderbook::${ric}(ASK)}]
                        set pos [lindex [eval lsearch -all -exact \${::orderbook::${ric}(ASK)} $order_prc] end]
                        set ::orderbook::${ric}(ASKSIZ) [eval linsert \${::orderbook::${ric}(ASKSIZ)} $pos $order_size]
                        set ::orderbook::${ric}(ASKORDERID) [eval linsert \${::orderbook::${ric}(ASKORDERID)} $pos $key]
                    }
                } else {
                    # if order_size is 0, remove it from order book
                    if {$order_size > 0} {
                        if {$order_side == "BID"} {
                            set pos [eval lsearch -exact \${::orderbook::${ric}(BIDORDERID)} $key]
                            if {$pos >= 0} {set ::orderbook::${ric}(BIDSIZ) [eval lreplace \${::orderbook::${ric}(BIDSIZ)} $pos $pos $order_size]}
                        } else {
                            set pos [eval lsearch -exact \${::orderbook::${ric}(ASKORDERID)} $key]
                            if {$pos >= 0} {set ::orderbook::${ric}(ASKSIZ) [eval lreplace \${::orderbook::${ric}(ASKSIZ)} $pos $pos $order_size]}
                        }
                    } else {
                        if {$order_side == "BID"} {
                            set pos [eval lsearch -exact \${::orderbook::${ric}(BIDORDERID)} $key]
                            set ::orderbook::${ric}(BID) [eval lreplace \${::orderbook::${ric}(BID)} $pos $pos]
                            set ::orderbook::${ric}(BIDSIZ) [eval lreplace \${::orderbook::${ric}(BIDSIZ)} $pos $pos]
                            set ::orderbook::${ric}(BIDORDERID) [eval lreplace \${::orderbook::${ric}(BIDORDERID)} $pos $pos]
                        } else {
                            set pos [eval lsearch -exact \${::orderbook::${ric}(ASKORDERID)} $key]
                            set ::orderbook::${ric}(ASK) [eval lreplace \${::orderbook::${ric}(ASK)} $pos $pos]
                            set ::orderbook::${ric}(ASKSIZ) [eval lreplace \${::orderbook::${ric}(ASKSIZ)} $pos $pos]
                            set ::orderbook::${ric}(ASKORDERID) [eval lreplace \${::orderbook::${ric}(ASKORDERID)} $pos $pos]
                        }
                    }
                }
            } DELETE {
                if {$order_side == "BID"} {
                    set pos [eval lsearch -exact \${::orderbook::${ric}(BIDORDERID)} $key]
                    set ::orderbook::${ric}(BID) [eval lreplace \${::orderbook::${ric}(BID)} $pos $pos]
                    set ::orderbook::${ric}(BIDSIZ) [eval lreplace \${::orderbook::${ric}(BIDSIZ)} $pos $pos]
                    set ::orderbook::${ric}(BIDORDERID) [eval lreplace \${::orderbook::${ric}(BIDORDERID)} $pos $pos]
                } else {
                    set pos [eval lsearch -exact \${::orderbook::${ric}(ASKORDERID)} $key]
                    set ::orderbook::${ric}(ASK) [eval lreplace \${::orderbook::${ric}(ASK)} $pos $pos]
                    set ::orderbook::${ric}(ASKSIZ) [eval lreplace \${::orderbook::${ric}(ASKSIZ)} $pos $pos]
                    set ::orderbook::${ric}(ASKORDERID) [eval lreplace \${::orderbook::${ric}(ASKORDERID)} $pos $pos]
                }
            }
        }
        #parray ::orderbook::$ric
    }
}

#
# print out orderbook for N levels
#
proc displayorderbook {ric {levels "0"}} {
    if {![info exists ::orderbook::${ric}(BIDORDERID)]} {
        return
    }
    # dynamic level display
    if {$levels == 0} {
        if {[eval llength \${::orderbook::${ric}(BIDORDERID)}] > [eval llength \${::orderbook::${ric}(ASKORDERID)}]} {
            set levels [eval llength \${::orderbook::${ric}(BIDORDERID)}]
        } else {
            set levels [eval llength \${::orderbook::${ric}(ASKORDERID)}]
        }
    }
    puts "\n--------------------------------- order book $ric -----------------------------------"
    puts [format "%5s%20s%10s%10s%1s%-10s%-10s%20s" Level OrderID #Size "BID " / " ASK" #Size OrderID]
    for {set i 0} {$i < $levels} {incr i} {
        set level [expr $i + 1]
        set bid_order_id [eval lindex \${::orderbook::${ric}(BIDORDERID)} $i]
        set bid_size [eval lindex \${::orderbook::${ric}(BIDSIZ)} $i]
        set bid [eval lindex \${::orderbook::${ric}(BID)} $i]
        set ask [eval lindex \${::orderbook::${ric}(ASK)} $i]
        set ask_size [eval lindex \${::orderbook::${ric}(ASKSIZ)} $i]
        set ask_order_id [eval lindex \${::orderbook::${ric}(ASKORDERID)} $i]
        puts [format "%5s%20s%10s%10s%1s%-10s%-10s%20s" $level $bid_order_id $bid_size "$bid " / " $ask" $ask_size $ask_order_id]
    }
    puts "----------------------------------------------------------------------------------------\n\n"
}
