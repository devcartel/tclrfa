# TCLRFA
TclRFA provides Tcl extension for accessing Thomson Reuters market data feeds such as Elektron,
RMDS,Thomson Reuter Enterprise Platform for Real-time (TREP-RT) or RDF-D. It supports subscription
and publication of level 1 and 2 market data using OMM data message model.

Features:

* Subscription for Market Price (level 1)
* Subscription for Market by Order (order book)
* Subscription for Market by Price (market depth)
* Snapshot request
* Multiple service subscription
* Pause and resume subscription
* OMM Posting
* View
* Dictionary download or using local files
* Directory request
* Symbol list request
* Timeseries request and decoder for IDN TS1
* Custom domain MMT_HISTORY which can be used for intraday publishing
* Non-interactive provider for `MARKET_PRICE`, `MARKET_BY_ORDER`, `MARKET_BY_PRICE`, `SYMBOLLIST`, `HISTORY` domain
* Interactive provider for `MARKET_PRICE` domain
* Debug mode
* Logging
* Low-latency mode
* Subscription outbound NIC binding

Tclrfa is written with C++ and ported as a stub extension for Tcl 8.5+

# INSTALLATION
Download a package from:

Version | Release Date | Windows (64-bit) | Linux (64-bit) | Windows (x86)
:-:|:-:|:-:|:-:|:-:| 
8.1.0 | 17 Mar 17 | [download](https://github.com/devcartel/tclrfa/releases/download/8.1.0/tclrfa8.1.0-win32-ix86_64.zip)  | [download](https://github.com/devcartel/tclrfa/releases/download/8.1.0/tclrfa8.1.0-linux-x86_64.zip) | -
7.7.0 | 17 Mar 17 | - | - |[download](https://github.com/devcartel/tclrfa/releases/download/7.7.0/tclrfa7.7.0-win32-ix86.zip)

Then run:

```
> unzip tclrfa<version>-<platform>.zip
> cd tclrfa<version>-<platform>/
> tclsh setup.tcl install
```

See [changelog](CHANGELOG8.md).

# SUPPORTED SYSTEMS
* Linux x86 64bit
* Windows x86 32 and 64bit

With Tcl8.5+. We recommend [ActiveTcl 8.5](http://www.activestate.com/activetcl/downloads) from ActiveState.

# EXAMPLE
```tcl
package require tclrfa
set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t acquireSession "Session1"
$t createOMMConsumer
$t login
$t directoryRequest
$t dictionaryRequest
$t marketPriceRequest "EUR= JPY="

while {1} {
    foreach u [$t dispatchEventQueue] {
        puts "\n[dict get $u SERVICE] - [dict get $u RIC]"
        foreach {k v} $u {
            puts "[format "%15s    %-10s" $k $v]"
        }
    }
}

```

# SUPPORT
* See [API documentation](API.md)
* Report an issue on our [GitHub](https://github.com/devcartel/tclrfa/issues)
* Enterprise support is [available](http://devcartel.com/enterprise)
