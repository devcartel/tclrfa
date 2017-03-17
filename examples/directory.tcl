#!/usr/bin/tclsh
package require tclrfa

set t [tclrfa]
$t createConfigDb "./tclrfa.cfg"
$t setDebugMode "true"
$t acquireSession "Session1"
$t createOMMConsumer

$t login

$t directoryRequest

$t -delete