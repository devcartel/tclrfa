# TCLRFA - API

## TABLE OF CONTENTS
1. [Configuration File](#configuration-file)
2. [API](#api)
   1. [Initialization](#initialization)
   2. [Configuration](#configuration)
   3. [Session](#session)
   4. [Client](#client)
   5. [Directory](#directory)
   6. [Dictionary](#dictionary)
   7. [Logging](#logging)
   8. [Symbol List](#symbol-list)
   9. [Market Price](#market-price)
   10. [Market by Order](#market-by-order)
   11. [Market by Price](#market-by-price)
   12. [OMM Posting](#omm-posting)
   13. [Pause and Resume](#pause-and-resume)
   14. [Timeseries](#timeseries)
   15. [History](#history)
   16. [Getting Data](#getting-data)
   17. [Publication](#publication)
   18. [Interactive Provider](#interactive-provider)

## CONFIGURATION FILE
### Example of tclrfa.cfg

    \tclrfa\debug = false

    \Logger\AppLogger\useInternalLogStrings  = true
    \Logger\AppLogger\windowsLoggerEnabled   = false
    \Logger\AppLogger\fileLoggerEnabled      = true
    \Logger\AppLogger\fileLoggerFilename     = "./tclrfa.log"

    \Connections\Connection_RSSL1\rsslPort = "14002"
    \Connections\Connection_RSSL1\ServerList = "127.0.0.1"
    \Connections\Connection_RSSL1\connectionType = "RSSL"
    \Connections\Connection_RSSL1\logEnabled = true
    \Connections\Connection_RSSL1\UserName = "USERNAME"
    \Connections\Connection_RSSL1\InstanceId = "1"
    \Connections\Connection_RSSL1\ApplicationId = "180"
    \Connections\Connection_RSSL1\Position = "127.0.0.1"
    \Connections\Connection_RSSL1\ServiceName = "SERVICE"
    \Connections\Connection_RSSL1\fieldDictionaryFilename = "../etc/RDM/RDMFieldDictionary"
    \Connections\Connection_RSSL1\enumTypeFilename  = "../etc/RDM/enumtype.def"
    \Connections\Connection_RSSL1\downloadDataDict = false

    \Sessions\Session1\connectionList = "Connection_RSSL1"

    \ServiceGroups\SG1\serviceList = "SERVICE1, SERVICE2"
    \Sessions\Session1\serviceGroupList = "SG1"

---

### Parameter
#### Debug Configuration
Namespace: `\#tclrfa\`

| Parameter        | Example value    | Description                                            |
|------------------|------------------|--------------------------------------------------------|
| `debug`          | `true`/`false`   | Enable/Disable debug mode                              |

#### Logger
Namespace: `\Logger\AppLogger\`
   
| Parameter            | Example value    | Description                                        |
|----------------------|------------------|----------------------------------------------------|
| `fileLoggerEnabled`  | `true`/`false`   | Enable/Disable logging capability                  |
| `fileLoggerFilename` | `"./tclrfa.log"` | Log file name                                      |

---

#### Connection
Namespace: `\Connections\<connection_name>\`

| Parameter        | Example value    | Description                                            |
|------------------|------------------|--------------------------------------------------------|
| `rsslPort`       | `"14002"`        | P2PS/ADS RSSL port number                              |
| `ServerList`     | `"127.0.0.1"`    | P2PS/ADS IP address or hostnam                         |
| `connectionType` | `"RSSL"`         | The specific type of the connection. Must be `RSSL`    |
| `logEnabled`     | `true`/`false`   | Enable/Disable logging capability                      |
| `UserName`       | `"tclrfa"`       | DACS username                                          |
| `InstanceId`     | `"123"`          | Application instance ID                                |
| `ApplicationId`  | `"180"`          | Application ID                                         |
| `Position`       | `"127.0.0.1/net"`| DACS position                                          |
| `ServiceName`    | `"NIP"`          | Service name to be subscribe                           |
| `VendorName`     | `"OMMCProv_DevCartel"` | Name of the vendor that provides the data for this service |
| `symbolList`     | `"0#BMD"`        | Symbollist name to be subscribe(d)                     |
| `maxSymbols`     | `30`             | Configure maximum number of symbol inside symbollist   |
| `fieldDictionaryFilename` | `"../etc/RDM/RDMFieldDictionary"`| Dictionary file path          |
| `enumTypeFilename` | `"../etc/RDM/enumtype.def"` | enumtype file path                        |
| `downloadDataDict` | `true`/`false` | Enable/Disable data dictionary download from P2PS/ADS  |
| `dumpDataDict`   | `true`/`false`   | Enable/Disable to dump data dictionary from P2PS/ADS   |

#### Session
Namespace: `\Sessions\<session_name>\`

| Parameter          | Example value         | Description                                            |
|--------------------|-----------------------|--------------------------------------------------------|
| `connectionList`   | `"Connection_RSSL1"`  | Match `connection_name`                                |
| `serviceGroupList` | `"SG1"`               | Service group name                                     |

`session_name` must be passed to `acquireSession()` function.

#### Service Group
Namespace: `\ServiceGroups\<service_group_name>\`

| Parameter          | Example value         | Description                                            |
|--------------------|-----------------------|--------------------------------------------------------|
| `serviceList`      | `"SERVICE1, SERVICE2"`| Available service names for the group                  |

## API
### Initialization
__[tclrfa]__  
_➥return: object_  
Instantiate a TclRFA object

```tcl
set t [tclrfa]
```

__setDebugMode__ _True|False_  
Enable or disable debug messages. If argument is empty, it will read a value from `\pyrfa\debug` in the configuration file. This function can only be called after `createConfigDb`.  

Example:

```tcl
$t setDebugMode True
```

---

### Configuration
__createConfigDb__ _filename_  
_filename = configuration file location, full or relative path_  
Read the configuration file. Initialize RFA context.  

Example:

```tcl
$t createConfigDb "./tclrfa.cfg"
```

__printConfigDb__ _config_node_  
_config_node = part of the configuration node to be printed out_  
Print current configuration values. If the arg is omitted, this function returns all of the configuration values under the ‘Default’ namespace.  

Example:

```tcl
$t printConfigDb "\\Default\\Sessions"
```
Output:
```
\Default\Sessions\Session1\connectionList = Connection_RSSL1
\Default\Sessions\Session2\connectionList = Connection_RSSL2
\Default\Sessions\Session3\connectionList = Connection_RSSL3
\Default\Sessions\Session4\connectionList = Connection_RSSL4
```

---

### Session
__acquireSession__ _session_  
_session = session name_  
Acquire a session as defined in the configuration file and look up for an appropriate connection type then establish a client/server network session.  

Example:

```
$t acquireSession "Session1"
```

---

### Client
__createOMMConsumer__  
Create an OMM data consumer client. 

__createOMMProvider__  
Create an OMM data provider client. Type of provider is defined by `connectionType`. Use `RSSL_PROV` for interactive provider and `RSSL_NIPROV` for non-interactive, full-cached provider.

```tcl
$t createOMMProvider
```

__login__ _?username instanceid appid position?_  
_username = DACS user ID_  
_instanceid = unique application instance ID_  
_appid = application ID (1-256)_  
_position = application position e.g. IP address_  
Send an authentication message with user information. This step is mandatory in order to consume the market data from P2PS/ADS. If arguments are omitted, TclRFA will read values from configuration file.

__isLoggedIn__  
_➥return: boolean_  
Check whether the client successfully receives a login status from the P2PS/ADS.

__setInteractionType__ _type_  
_type = “snapshot” or “streaming”_  
Set subscription type `snapshot` or `streaming`. If `snapshot` is specified, the client will receive only the full image of an instrument then the subscribed stream will be closed.  

Example:

```tcl
$t setInteractionType “snapshot”
```

__setServiceName__ _service_  
Programmatically set service name for subcription. Call this before making any request. This allows subcription to multiple services.  

Example:

```tcl
$t setServiceName "IDN"
$t marketPriceRequest "EUR="
```

---

### Directory
__directoryRequest__  
Send a directory request through the acquired session. This step is the mandatory in order to consume the market data from P2PS/ADS.

---

### Dictionary
__dictionaryRequest__  
If `downloadDataDict` configuration is set to True then TclRFA will send a request for data dictionaries to P2PS/ADS. Otherwise, it uses local data dictionaries specified by `fieldDictionaryFilename` and `enumTypeFilename` from configuration file.

__isNetworkDictionaryAvailable__  
_➥return: boolean_  
Check whether the data dictionary is successfully downloaded from the server.  

Example:

```tcl
$t isNetworkDictionaryAvailable
```
Output:
```
1
```

__getFieldID__ _field_name_  
_field_name = a valid field name_  
_➥return: int_  
To translate field name to field ID.  

Example:

```tcl
$t getFieldID BID
```
Output:
```tcl
22
```

---

### Logging
__logInfo__ _message_  
Write an informational message to a log file.

__logWarning__ _message_  
Write a warning message to a log file.

__logError__ _message_  
Write an error message to a log file.

---

### Symbol List
__symbolListRequest__ _RIC ?RIC RIC ...?_  
_RIC = Reuters Instrument Code_  
For consumer application to subscribe symbol lists. User can define multiple symbol list names. Data dispatched using `dispatchEventQueue` function.

__symbolListCloseRequest__ _RIC ?RIC RIC ...?_   
_RIC = Reuters Instrument Code_  
Unsubscribe the specified symbol lists. User can define multiple symbol list names

__symbolListCloseAllRequest__  
Unsubscribe all symbol lists in the watch list.

__isSymbolListRefreshComplete__  
_➥return: boolean_  
Check whether the client receives a complete list of the symbol list.

__getSymbolListWatchList__  
_➥return: str_  
Return names of the subscribed symbol lists.

__getSymbolList__ _RIC_  
_RIC = Reuters Instrument Code_  
_➥return: str_  
Return item names available under a symbol list in string format.  

Example:

```tcl
$t getSymbolList “0#BMD”
```
Output:
```
FPCO FPKC FPRD FPGO
```

---

### Market Price
__marketPriceRequest__ _RIC ?RIC RIC ...?_   
_RIC = Reuters Instrument Code_  
For consumer client to subscribe market data from P2PS/ADS, user can define multiple item names. The data dispatched through `dispatchEventQueue`.  

Example:

```tcl
while {1} {
    foreach u [$t dispatchEventQueue] {
        puts "\n[dict get $u]
        }
    }
}
```

Image
```tcl
{SERVICE {NIP} RIC {EUR=} MTYPE {REFRESH}}
{SERVICE {NIP} RIC {EUR=} MTYPE {IMAGE} RDNDISPLAY {100} RDN_EXCHID {SES} BID {0.988} ASK {0.999} DIVPAYDATE {23 JUN 2011}}
```

Update
```tcl
{SERVICE {NIP} RIC {EUR=} MTYPE {UPDATE} BID_NET_CH {0.0041} BID {0.988} ASK {0.999} ASK_TIME {15:14:24:180:000:000}}
```
Status
```tcl
{SERVICE {NIP} RIC {EUR=} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Open} TEXT {Source unavailable... will recover when source is up}}
    
{SERVICE {NIP} RIC {JPY=} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Close} TEXT {F10: Not In Cache}}
```

__setView__ _FID ?FID FID ...?_  
_FID = a valid field name or number (Optional)_  
To specify a view (a subset of fields to be filtered) for the next subscribed items. User can define multitple fields.  

Example:

```tcl
% $t setView "RDNDISPLAY TRDPRC_1 22 25"
% $t marketPriceRequest "EUR= JPY="
```

Or define as multiple arguments:

```tcl
% $t setView RDNDISPLAY TRDPRC_1 22 25
% $t marketPriceRequest EUR= JPY=
```

And reset view to subscribe all fields with:

```tcl
$t setView
```

__marketPriceCloseRequest__ _RIC ?RIC RIC ...?_  
_RIC = Reuters Instrument Code_  
Unsubscribe items from streaming service. User can define multiple item names.

__marketPriceCloseAllRequest__  
Unsubscribe all items from streaming service.

__getMarketPriceWatchList__  
Returns names of the subscribed items with service names.  

Example:

```tcl
$t getMarketPriceWatchList
```
Output:
```
C.N.IDN_SELECTFEED JPY=.IDN_SELECTFEED
```

---

### Market by Order
__marketByOrderRequest__ _RIC ?RIC RIC ...?_   
_RIC = Reuters Instrument Code_  
For a consumer application to subscribe order book data, user can define multiple item names. The data dispatched through `dispatchEventQueue`.  

Example:

```tcl
$t marketByOrderRequest "ANZ.AX"
while {1} {
    set updates [$t dispatchEventQueue 1000]
    if {$updates != ""} {
        foreach u [$t dispatchEventQueue] {
        puts "\n[dict get $u]
        }
    }
}
```

IMAGE:
```tcl
{SERVICE {NIP} RIC {ANZ.AX} MTYPE {REFRESH}}
{SERVICE {NIP} RIC {ANZ.AX} MTYPE {IMAGE} ACTION {ADD} KEY {538993C200035057B} ORDER_PRC {20.835}}
```

UPDATE:
```tcl
{SERVICE {NIP} RIC {ANZ.AX} MTYPE {UPDATE} ACTION {UPDATE} KEY {538993C200035057B} ORDER_PRC {20.214} ORDER_SIZE {41} ORDER_SIDE {BID} SEQNUM_QT {511} EX_ORD_TYP {0} CHG_REAS {10}}
```

DELETE:
```tcl
{SERVICE {NIP} RIC {ANZ.AX} MTYPE {UPDATE} ACTION {DELETE} KEY {538993C200083483B}}
```

STATUS:
```tcl
{SERVICE {NIP} RIC {ANZ.AX} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Open} TEXT {<NIP> Source cannot provide the requested capability of MMT_MARKET_BY_ORDER [7].}}
    
{SERVICE {NIP} RIC {ANZ.AX} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Close} TEXT {F10: Not In Cache}}
```

__marketByOrderCloseRequest__ _RIC ?RIC RIC ...?_  
_RIC = Reuters Instrument Code_  
Unsubscribe items from order book streaming service. User can define multiple item names.

__marketByOrderCloseAllRequest__  
Unsubscribe all items from order book data streaming service.

__getMarketByOrderWatchList__  
_➥return: str_
Return all subscribed item names on order book streaming service with service names.

---

###  Market by Price
__marketByPriceRequest__ _RIC ?RIC RIC ...?_  
_RIC = Reuters Instrument Code_  
For consumer application to subscribe market depth data, user can define multiple item names. Data dispatched through `dispatchEventQueue`.  

Example:

```tcl
$t marketByOrderRequest "ANZ.CHA"
while {1} {
    set updates [$t dispatchEventQueue 1000]
    if {$updates != ""} {
        foreach u [$t dispatchEventQueue] {
        puts "\n[dict get $u]
        }
    }
}
```

IMAGE:
```tcl
{SERVICE {NIP} RIC {ANZ.CHA} MTYPE {REFRESH}}
{SERVICE {NIP} RIC {ANZ.CHA} MTYPE {IMAGE} ACTION {ADD} KEY {201000B} ORDER_PRC {20.1000} ORDER_SIDE {BID} ORDER_SIZE {17} NO_ORD {6} QUOTIM_MS {16987567} ORDER_TONE {}}
```

UPDATE:
```tcl
{SERVICE {NIP} RIC {ANZ.CHA} MTYPE {UPDATE} ACTION {UPDATE} KEY {201000B} NO_ORD {7} ORDER_SIDE {BID} ORDER_SIZE {5}}
```

DELETE:
```tcl
{SERVICE {NIP} RIC {ANZ.CHA} MTYPE {UPDATE} ACTION {DELETE} KEY {202000B}}
```

STATUS:
```tcl
{SERVICE {NIP} RIC {ANZ.CHA} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Open} TEXT {<NIP> Source cannot provide the requested capability of MMT_MARKET_BY_PRICE [8].}}
    
{SERVICE {NIP} RIC {ANZ.CHA} MTYPE {STATUS} DATA_STATE {Suspect} STREAM_STATE {Close} TEXT {F10: Not In Cache}}
```

__marketByPriceCloseRequest__ _RIC ?RIC RIC ...?_  
_RIC = Reuters Instrument Code_  
Unsubscribe items from market depth data stream. User can define multiple item names.

__marketByPriceCloseAllRequest__  
Unsubscribe all items from market depth stream.

__getMarketByPriceWatchList__  
_➥return: str_  
Return all subscribed item names on market depth streaming service with service names.

---

### OMM Posting  
OMM Posting (off-stream) leverages on consumer login channel to contribute aka. "post" data up to ADH/ADS cache or provider application. The posted service must be up before receiving any post message. For posting to an Interactive Provider, the posted RIC must already be made available by the provider.

__marketPricePost__ _data ?data data ...?_  
_data = a Tcl dict_  
Post market price data. _data_ can be populated as below.`MTYPE IMAGE` can be added to `data` in order to post item as an IMAGE (default `MTYPE` is `UPDATE`).  

Example:

```tcl
$t marketPricePost "RIC TRI.N TIMACT now TRDPRC_1 123.45"
```

---

### Pause and Resume  
__pauseAll__  
Pause all subscription on all domains. Updates are conflated during the pause.

__resumeAll__  
Resume all subscription.

__marketPricePause__ _RIC ?RIC RIC ...?_  
_RIC = Reuters Instrument Code_  
Pause subscription to the items.

__marketPriceResume__ _RIC ?RIC RIC ...?_  
_RIC = Reuters Instrument Code_  
Resume subscription to the item.

---

### Timeseries
Time Series One (TS1) provides access to historical data distributed via the Reuter Integrated Data Network (IDN). It provides a range of facts (such as Open, High, Low, Close) for the equity, money, fixed income, commodities and energy markets. TS1 data is available in three frequencies; _daily_, _weekly_, and _monthly_. For daily data there is up to two years worth of history, for weekly data there is _five years_, and for monthly data up to _ten years_.

__setTimeSeriesPeriod__ _daily|weekly|monthly_  
Define a time period for a time series subscription. Default is daily.

__setTimeSeriesMaxRecords__ _max_records_  
_max_records = number of maximum time series output records_  
Define the maximum record before calling `getTimeSeries.` Default is 10.

__getTimeSeries__ _RIC_  
_RIC = Reuters Instrument Code_  
_➥return: str_  
A helper function that subscribes, wait for data dissemination to be complete, unsubscribe from the service and return series as a list of records. `getTimeSeries` supports one time series retrieval at a time.  

Example:

```tcl
set ric "CHK.N"
set period "daily"
set maxrecords "15"
$t setTimeSeriesPeriod $period
$t setTimeSeriesMaxRecords $maxrecords
set timeseries [$t getTimeSeries "CHK.N"]
puts "\n\n############## $ric $period ([llength $timeseries] records)##############"
puts [join $timeseries "\n"]\n\n
```
Output:
```
############## CHK.N daily (21 records) ##############
DATE,CLOSE,OPEN,HIGH,LOW,VOLUME,VWAP
2012/02/26,25.110,25.360,25.440,25.010,2457997.000,25.218
2012/02/23,25.450,24.830,25.830,24.820,3420367.000,25.451
2012/02/22,24.980,24.130,24.990,23.960,3786628.000,24.582
2012/02/21,24.030,24.220,24.340,23.640,4144242.000,23.998
2012/02/20,24.620,25.000,25.060,24.540,3713133.000,24.767
2012/02/19,Market holiday
2012/02/16,24.710,24.220,24.980,24.130,5116842.000,24.508
2012/02/15,23.770,23.070,23.790,22.730,3540557.000,23.489
2012/02/14,23.020,22.740,23.270,22.520,3885523.000,22.923
2012/02/13,22.710,22.800,22.950,22.450,3114849.000,22.684
2012/02/12,22.660,22.750,23.320,22.260,5041853.000,22.746
2012/02/09,22.130,21.900,22.190,21.560,3179328.000,21.970
2012/02/08,22.340,22.320,22.640,22.030,3298569.000,22.355
2012/02/07,22.110,22.310,22.510,22.030,2662700.000,22.187
2012/02/06,22.180,22.680,22.680,22.020,2829459.000,22.175
```

---

### History
__historyRequest__ _RIC ?RIC RIC ...?_  
_RIC = Reuters Instrument Code_  
Request for historical data (data domain 12), this domain is not officially supported by Thomson Reuters. User can define multiple items. The data dispatched through `dispatchEventQueue`.  

Example:

```tcl
$t historyRequest "tANZ.AX"
while {1} {
    set updates [$t dispatchEventQueue 1000]
    if {$updates != ""} {
        foreach u [$t dispatchEventQueue] {
        puts "\n[dict get $u]
        }
    }
}
```

IMAGE:
```tcl
{SERVICE {NIP} RIC {tANZ.AX} MTYPE {REFRESH}} 
{SERVICE {NIP} RIC {tANZ.AX} MTYPE {IMAGE} TRPRC_1 {40.124} SALTIM {14:31:34:335:000:000} TRADE_ID {123456789} BID_ORD_ID {5307FBL20AL7B}ASK_ORD_ID {5307FBL20BN8A}}
```

__historyCloseRequest__ _RIC ?RIC RIC ...?_  
_RIC = Reuters Instrument Code_  
Unsubscribe items from historical data stream. The user can define multiple item names.

__historyCloseAllRequest__  
Unsubscribe all items from historical data stream.

---

### Getting Data
__dispatchEventQueue__ _?timeout?_  
_timeout = time in milliseconds to wait for data (Optional)_  
_➥return: str_  
Dispatch the events (data) from EventQueue within a period of time (If timeout is omitted, it will return immediately). If there are many events in the queue at any given time, a single call gets all the data until the queue is empty. Data is in a list of Tcl dicts.

---

### Non-Interactive Provider  
__directorySubmit__ _?domain?_ _?service?_  
_domain = data domain number (Optional)_  
_service = target service (Optional)_  
Submit directory with domain type (capability) in a provider application, it currently supports:

* 6 - market price
* 7 - market by order
* 8 - market by price
* 10 - symbol list
* 12 - history

This function is normally called automatically upon data submission. If _service_ is omitted, it will use the value from configuration file.  

Example:

```tcl
$t directorySubmit "6 8 10" IDN
```

__serviceDownSubmit__ _?service?_  
_service = target service (Optional)_  
Submit service down status to ADH. If _service_ is omitted, it uses _service_ from configuration file. For Interactive Provider, _service_ will be ignored and use the default value from configuration file instead. This function must be called after `directorySubmit`.

__serviceUpSubmit__ _?service?_  
_service = target service (Optional)_  
Submit service up status to ADH. If _service_ is omitted, it uses _service_ from configuration file. For Interactive Provider, _service_ will be ignored and use the default value from configuration file instead.

__symbolListSubmit__ _data ?data data ...?_   
_data = a Tcl dict_   
For a provider client to publish a list of symbols to MDH/ADH under data domain 10, The Tcl dict must be specify in the below format. `MTYPE IMAGE` can be added to `data` in order to publish the IMAGE of the item (default `MTYPE` is `UPDATE`).  `ACTION` can be `ADD`, `UPDATE` and `DELETE`.  

Example:

```tcl
$t symbolListSubmit {RIC {0#BMD} KEY {FCPO} ACTION {ADD} PROD_PERM {10} PROV_SYMB {MY439483}}
```

_RIC_ contains the name of an instrument list. _KEY_ contains an instrument name and _ACTION_ is one of the following:
* ADD - add a new instrument name to the list
* UPDATE - update an instrument name's attributes
* DELETE - remove an instrument from the list

__marketPriceSubmit__ _data ?data data...?_   
_data = a Tcl dict_  
For provider clients to publish market data to MDH/ADH, the market data image/update must be in the below Tcl dict format. `MTYPE IMAGE` can be added to `data` in order to publish the IMAGE of the item (default `MTYPE` is `UPDATE`).  

Example:

```tcl
$t marketPriceSubmit {RIC {EUR=} RDNDISPLAY {100} RDN_EXCHID {155} BID {0.988} ASK {0.999} DIVPAYDATE {20110623}}
```

__marketByOrderSubmit__ _data ?data data...?_  
_data = a Tcl dict_   
For a provider client to publish specified order book data to MDH/ADH, `marketByOrderSubmit` requires two parameters, The Tcl dict must be specify in the below format. `MTYPE IMAGE` can be added to `data` in order to publish the IMAGE of the item (default `MTYPE` is `UPDATE`).  

Example:

```tcl
set ORDER {RIC {ANZ.AX} KEY {538993C200035057B} ACTION {ADD} ORDER_PRC {20.260} ORDER_SIZE {50} ORDER_SIDE {BID} SEQNUM_QT {2744} EX_ORD_TYP {0} CHG_REAS {6} ORDER_TONE {}}
$t marketByOrderSubmit $ORDER
```
_RIC_ contains the name of an instrument. _KEY_ contains an order ID name and _ACTION_ is one of the following:
* ADD - add a new order to the book
* UPDATE - update an order's attributes
* DELETE - remove an order from the book

__marketByPriceSubmit__ _data ?data data ...?_  
_data = a Tcl dict_    
For a provider client to publish the specified market depth data to MDH/ADH, `marketByPriceSubmit` requires two parameters, The Tcl dict must be specify in the below format. `MTYPE IMAGE` can be added to `data` in order to publish the IMAGE of the item (default `MTYPE` is `UPDATE`).  

Example:  

```tcl
set DEPTH { RIC {ANZ.CHA} KEY {201000B} ACTION {ADD} ORDER_PRC {20.1000} ORDER_SIDE {BID} ORDER_SIZE {1300} NO_ORD {13} QUOTIM_MS {16987567} ORDER_TONE {}}
$t marketByPriceSubmit $DEPTH
```

_RIC_ contains the name of an instrument. _KEY_ contains a price and _ACTION_ is one of the following:
* ADD - add a new price to the depth
* UPDATE - update a price's attributes
* DELETE - remove a price from the depth

__historySubmit__ _data ?data data ...?_  
_data = a Tcl dict_  
For a provider client to publish the specified history data to MDH/ADH, each history data image/update must be in the following format and `MTYPE IMAGE` can be added to `data` in order to publish the IMAGE of the item(default `MTYPE = UPDATE`).  

Example:

```tcl
set UPDATE {RIC {tANZ.AX} TRDPRC_1 {40.124} SALTIM {now} TRADE_ID {123456789} BID_ORD_ID {5307FBL20AL7B} ASK_ORD_ID {5307FBL20BN8A}}
$t historySubmit $UPDATE
```

__closeSubmit__ _RIC.service ?RIC.service RIC.service ...?_  
_RIC = Reuters Instrument Code_  
_service = target service_  
For a provider to close the published item with specific service. User can define multiple item names.  

Example:

```tcl
$t closeSubmit EUR=.DEV
```

__closeAllSubmit__  
For a provider to close all published items.  

---

### Interactive Provider
A publisher server for market price domain. Interactive provider's `dispatchEventQueue()` output yields `MTYPE` of `LOGIN`, `REQUEST`, `CLOSE` and `LOGOUT`.  

Example:
```
...
$t createOMMProvider
$t dictionaryRequest
while {1} {
    foreach u [$t dispatchEventQueue] {
        puts $u
    }
}
```
Output:
```tcl
{MTYPE {LOGIN} USERNAME {tclrfa} SERVICE {DIRECT_FEED} SESSIONID {140672527137824}}
{MTYPE {REQUEST} RIC {EUR=} USERNAME {tclrfa} SERVICE {DIRECT_FEED} SESSIONID {140672527137824}}
{MTYPE {CLOSE} RIC {EUR=} USERNAME {EUR=} SERVICE {DIRECT_FEED} SESSIONID {140672527137824}}
{MTYPE {LOGOUT} USERNAME {tclrfa} SERVICE {DIRECT_FEED} SESSIONID {140672527137824}}
```

__getClientSessions__  
_➥return: str_  
For interactive provider to obtain the connected client session IDs.  

Example:

```tcl
$t getClientSessions
```
Output:  
```tcl
140566629350432 140566632265280
```

__getClientWatchList__ _sessionID_  
_sessionID = Client session ID_  
_➥return: str_  
For interactive provider to obtains the watch list of a specific client referenced by sessionID.  

Example:  

```tcl
$t getClientWatchList 140566629350432
```
Output:  
```tcl
JPY= EUR=
```

__marketPriceSubmit__ _data? data data ...?_  
_data = a Tcl dict_  
For a provider to submit items to a specific client instead of all clients. _data_ dict can be populated as below and can referrence to the client by _sessionID_.  

Example:

```tcl
$t marketPriceSubmit "RIC JPY= TRDPRC_1 115.2 TIMACT now SESSIONID 140339066107568" 
```

__closeSubmit__ _RICS_ _?sessionID?_   
_RICS = Reuters Instrument Code_  
_sessionID = Client session ID (Optional)_  
For a provider to close published items for all subscribed clients. Or close published items for a spicific client referenced by _sessionID_. User can define multiple item names.  

Example:

```tcl
$t closeSubmit "EUR= JPY="
$t closeSubmit "EUR= JPY=" 140339066107568
```

__logoutSubmit__ _?sessionID?_  
_sessionID = Client session ID (Optional)_  
For a provider to logout subscription from specific client by sessionID.  

Example:  

```tcl
$t logoutSubmit 140566632265280
```

__logoutAllSubmit__  
For a provider to logout subscription from all clients.  
