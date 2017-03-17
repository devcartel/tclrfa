#!/usr/bin/tclsh
#
# Create market depth from update tuples
#
namespace eval ::depth:: {}

proc updatedepth {updates} {
    foreach u $updates {
        set service [dict get $u SERVICE]
        set ric [dict get $u RIC]
        set mtype [dict get $u MTYPE]
        if {$mtype == "STATUS"} {
            continue
        } elseif {$mtype == "REFRESH"} {
            array set ::depth::$ric {
                BID {}
                BIDSIZ {}
                ASK {}
                ASKSIZ {}
            }
            continue
        }
        set action [dict get $u ACTION]
        set key [dict get $u KEY]
        #puts "\n$service - $ric ($action $key)"

        foreach {k v} $u {
            #puts "[format "%15s    %-10s" $k $v]"
            switch -exact $k {
                ORDER_SIDE {
                    set order_side $v
                } ORDER_SIZE {
                    set order_size $v
                } ORDER_PRC {
                    set order_prc $v
                    if {![info exists ::depth::decimal_point]} {
                        set ::depth::decimal_point [ expr [llength [split $v ""]] -  [lsearch [split $v ""] "."] - 1 ]
                    }
                }
            }
        }

        # determine ORDER_SIDE in the update
        if ([regexp {B} $key]) {
            set order_side "BID"
        } else {
            set order_side "ASK"
        }

        if {![array exists ::depth::$ric]} {
            array set ::depth::$ric {
                BID {}
                BIDSIZ {}
                ASK {}
                ASKSIZ {}
            }
        }

        # update depth for N levels for a ric
        switch -exact $action {
            ADD {
                # prevent duplicate key (e.g. looping canned data)
                if {[eval lsearch \${::depth::${ric}($order_side)} [regsub {B|S|A} $key ""]] < 0} {
                    lappend ::depth::${ric}($order_side) [regsub {B|S|A} $key ""]
                    if {$order_side == "BID"} {
                        set ::depth::${ric}(BID) [eval lsort -real -decreasing \${::depth::${ric}(BID)}]
                        set pos [eval lsearch -exact \${::depth::${ric}(BID)} [regsub {B|S|A} $key ""]]
                        set ::depth::${ric}(BIDSIZ) [eval linsert \${::depth::${ric}(BIDSIZ)} $pos $order_size]
                    } else {
                        set ::depth::${ric}(ASK) [eval lsort -real -increasing \${::depth::${ric}(ASK)}]
                        set pos [eval lsearch -exact \${::depth::${ric}(ASK)} [regsub {B|S|A} $key ""]]
                        set ::depth::${ric}(ASKSIZ) [eval linsert \${::depth::${ric}(ASKSIZ)} $pos $order_size]
                    }
                }
            } UPDATE {
                # if the updated item not in depth cache, then ADD it.(e.g. looping canned data)
                if {[eval lsearch \${::depth::${ric}($order_side)} [regsub {B|S|A} $key ""]] < 0} {
                    lappend ::depth::${ric}($order_side) [regsub {B|S|A} $key ""]
                    if {$order_side == "BID"} {
                        set ::depth::${ric}(BID) [eval lsort -real -decreasing \${::depth::${ric}(BID)}]
                        set pos [eval lsearch -exact \${::depth::${ric}(BID)} [regsub {B|S|A} $key ""]]
                        set ::depth::${ric}(BIDSIZ) [eval linsert \${::depth::${ric}(BIDSIZ)} $pos $order_size]
                    } else {
                        set ::depth::${ric}(ASK) [eval lsort -real -increasing \${::depth::${ric}(ASK)}]
                        set pos [eval lsearch -exact \${::depth::${ric}(ASK)} [regsub {B|S|A} $key ""]]
                        set ::depth::${ric}(ASKSIZ) [eval linsert \${::depth::${ric}(ASKSIZ)} $pos $order_size]
                    }
                } else {
                    if {$order_side == "BID"} {
                        set pos [eval lsearch -exact \${::depth::${ric}(BID)} [regsub {B|S|A} $key ""]]
                        if {$pos >= 0} {set ::depth::${ric}(BIDSIZ) [eval lreplace \${::depth::${ric}(BIDSIZ)} $pos $pos $order_size]}
                    } else {
                        set pos [eval lsearch -exact \${::depth::${ric}(ASK)} [regsub {B|S|A} $key ""]]
                        if {$pos >= 0} {set ::depth::${ric}(ASKSIZ) [eval lreplace \${::depth::${ric}(ASKSIZ)} $pos $pos $order_size]}
                    }
                }
            } DELETE {
                if {$order_side == "BID"} {
                    set pos [eval lsearch -exact \${::depth::${ric}(BID)} [regsub {B|S|A} $key ""]]
                    set ::depth::${ric}(BID) [eval lreplace \${::depth::${ric}(BID)} $pos $pos]
                    set ::depth::${ric}(BIDSIZ) [eval lreplace \${::depth::${ric}(BIDSIZ)} $pos $pos]
                } else {
                    set pos [eval lsearch -exact \${::depth::${ric}(ASK)} [regsub {B|S|A} $key ""]]
                    set ::depth::${ric}(ASK) [eval lreplace \${::depth::${ric}(ASK)} $pos $pos]
                    set ::depth::${ric}(ASKSIZ) [eval lreplace \${::depth::${ric}(ASKSIZ)} $pos $pos]
                }
            }
        }
        #parray ::depth::$ric
    }
}

#
# print out depth for N levels
#
proc displaydepth {ric {levels 0}} {
    if {![info exists ::depth::${ric}(BIDSIZ)]} {
        return
    }
    # dynamic level display
    if {$levels == 0} {
        if {[eval llength \${::depth::${ric}(BID)}] > [eval llength \${::depth::${ric}(ASK)}]} {
            set levels [eval llength \${::depth::${ric}(BID)}]
        } else {
            set levels [eval llength \${::depth::${ric}(ASK)}]
        }
    }
    puts "\n--------------- depth $ric ---------------"
    puts [format "%5s%10s%10s%1s%-10s%7s" Level #Size "BID " / " ASK" #Size]
    if {[info exists ::depth::decimal_point]} {
        set dp "$::depth::decimal_point"
    } else {
        set dp 0
    }
    for {set i 0} {$i < $levels} {incr i} {
        set level [expr $i + 1]
        set bid_size [eval lindex \${::depth::${ric}(BIDSIZ)} $i]
        set bid [eval lindex \${::depth::${ric}(BID)} $i]
        if {$bid != ""} {
            set bid [format "%.${dp}f" ${bid}e-$dp]
        }
        set ask [eval lindex \${::depth::${ric}(ASK)} $i]
        if {$ask != ""} {
            set ask [format "%.${dp}f" ${ask}e-$dp]
        }
        set ask_size [eval lindex \${::depth::${ric}(ASKSIZ)} $i]
        puts [format "%5s%10s%10s%1s%-10s%7s" $level $bid_size "$bid " / " $ask" $ask_size]
    }
    puts "--------------------------------------------\n\n"
}
