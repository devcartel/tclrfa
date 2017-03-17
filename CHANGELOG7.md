# CHANGELOG
## TclRFA 7
7.7.0
* 17 March 2017
* Adds getClientSessions() for Interactive Provider
* Adds getClientWactchList() for Interactive Provider
* Automatically loads dictionaries from the installed package folder
* Able to privately submitData to a specific session ID
* Able to closeSubmit items for a specific session ID

7.6.4
* 13 December 2016
* Interactive provider is able to logout clients with logoutSubmit
* Fixed a bug where NIP not closeAllSubmit when call serviceDownSubmit

7.6.3
* 5 October 2016
* Adds data output for interactive provider
* Makes TclRFA totally silent
* Fixed a Timeseries bug
* New versioning number
* Other bugs fixed
* Compiled with RFA C++ 7.6.2.E2

7.6.2.2
* 23 June 2016
* Supports RMTES strings to UTF-8
* New getFieldID function

7.6.2.1
* 18 May 2016
* Supports Interactive Provider
* Supports FID filtering subscription with View
* Updates RDMDictionary and enumtype.def

7.6.2.0
* 17 December 2015
* Compiled with RFA 7.6.2.L1

7.6.1.4
* 24 November 2015
* Compiled with RFA 7.6.1.E5
* Added serviceUpSubmit()
* Fixed serviceDownSubmit() that caused session disconnection
* Fixed a bug where it fails to close a complete published item list

7.6.1.3
* 24 August 2015
* New output message in pure dictionary format
* Supports STATUS output message type
* New message types include REFRESH, IMAGE, UPDATE, STATUS
* RIC and SERVICE now treated as part of data output
* Translate Reuters tick symbol to unicode
* Minimum requirement is now Tcl 8.5
* Supports Pause and Resume
* Supports OMM Posting for market price
* Provider can submit data as unsolicited REFRESH using MTYPE = IMAGE
* Provider can submit data to different service using SERVICE key in dict 
* Supports sending service up/down status
* Fixed timeseries floating point data limitation
* Fixed memory leak in data dictionary handler
* Fixed memory leak in data dictionary handler
* Prevent memory leak caused by login handler
* Fixed another potential memory leak

7.6.1.2
* 28 May 2015
* Support sending service down status programmatically

7.6.1.1
* 19 December 2014
* Fixed OMM provider not submit directory data after reconnecting to ADH/MDH

7.6.0.3
* 2 Sep 2014
* Added logger eventqueue to process log events
* Fixed log() functions purge data in buffer resulted missing updates
* Will be free software under MIT license

7.6.0.2
* 1 Aug 2014
* Added setup.tcl: TclRFA package installer
* setServiceName() to select a service programmatically
* Fixed core dump upon exit if call getWatchList in script

7.6.0.1
* 18 July 2014
* Minor bug fixes
* Updates common files

7.6.0.0
* 9 July 2014
* RFA 7.6.0.L1
* Less log output to stdout
* Remove using `update` in Tcl example scripts

7.5.1.2
* 11 February 2014
* Fixed provider can convert string into ASCII_STRING field
* Support Position parameter in the config file

7.5.1.1
* 5 November 2013
* isLoggedIn returning P2PS/ADS login status
* Fixed bug#35 TclRFA handles login status incorrectly when ServerList is unreachable

7.5.1.0
* 15 October 2013
* RFA 7.5.1.L1
* ApplicationId from config file submitted for login
* New config `responseQueueBatchInterval` for low latency inbound message setup
* New config `flushTimerInterval` for low latency outbound message setup

7.4.1.0
* 28 April 2013
* RFA 7.4.1.L1 for Linux and Windows
* Ability to bind OMM Consumer to a NIC in config file

7.2.1.0
* 2 Feb 2013
* Source repo relocated to GitHub
* Using "tag" as part of the release number
* RFA 7.2.1.L1 for Linux
* RFA 7.2.1.E3 for Windows