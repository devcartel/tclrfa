#!/usr/bin/tclsh
package require Tclx
proc interrupt {} {
    uplevel {$t log "\n\n\t!!!!!!!!!! Ctrl-C signal received !!!!!!!!!!!!"}
    uplevel {$t marketPriceCloseAllRequest}
    uplevel {$t -delete}
    exit 1
}
signal trap SIGINT interrupt