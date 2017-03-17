#!/usr/bin/tclsh
package require tclrfa

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t setDebugMode "true"
$t acquireSession "Session1"
$t createOMMConsumer

$t login

# Download dictionary from server
# Must call directory request first
$t directoryRequest
$t dictionaryRequest

$t -delete