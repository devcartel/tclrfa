#!/usr/bin/tclsh
proc every {ms script} {
    global ids
    if {$ms eq "cancel"} {
        catch {after cancel $ids($script)}
        return
    }
    set ids($script) [after $ms [info level 0]]
    uplevel #0 $script
}