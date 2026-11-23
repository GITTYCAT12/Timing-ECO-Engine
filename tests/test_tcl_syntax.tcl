#!/usr/bin/env tclsh
# Check Tcl completeness for project flow, ECO, signoff, and regression scripts.
# This is a syntax-structure check only; it does not resolve OpenROAD commands.

set test_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $test_dir ..]]
set tcl_files {}

foreach directory {eco flow sta tests} {
    set directory_path [file join $repo_root $directory]
    foreach path [glob -nocomplain -directory $directory_path *.tcl] {
        lappend tcl_files $path
    }
}
set tcl_files [lsort -dictionary $tcl_files]

if {[llength $tcl_files] == 0} {
    puts stderr "FAIL: no project Tcl files were found"
    exit 1
}

set passed 0
set failed 0
foreach path $tcl_files {
    if {[catch {
        set handle [open $path r]
        fconfigure $handle -encoding utf-8
        set contents [read $handle]
        close $handle
    } message]} {
        incr failed
        puts stderr "FAIL: could not read $path: $message"
        continue
    }

    set relative [string range $path [expr {[string length $repo_root] + 1}] end]
    if {[info complete $contents]} {
        incr passed
        puts "PASS: $relative"
    } else {
        incr failed
        puts stderr "FAIL: incomplete Tcl script: $relative"
    }
}

puts "\nTcl syntax-structure regression: $passed passed, $failed failed"
if {$failed != 0} {
    exit 1
}
