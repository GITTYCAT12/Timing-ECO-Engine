#!/usr/bin/env tclsh
# Run from any directory with: tclsh tests/test_eco_execution.tcl
# OpenROAD database and mutation commands are stubbed. The production ECO Tcl
# is sourced unchanged so this checks the configured execution sequence.

set test_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $test_dir ..]]

foreach name {
    ECO_BUFFER_1_PIN ECO_BUFFER_1_CELL ECO_BUFFER_1_NAME
    ECO_BUFFER_2_PIN ECO_BUFFER_2_CELL ECO_BUFFER_2_NAME
    ECO_RESIZE_INSTANCE ECO_RESIZE_CELL
} {
    catch {unset ::env($name)}
}

set ::mock_pins [dict create "_6529_/Q" 1 "_3280_/ZN" 1]
set ::mock_nets [dict create "_6529_/Q" "net_6529" "_3280_/ZN" "net_3280"]
set ::mock_cells [dict create "_5084_" 1]
set ::mutation_log {}
set ::flow_log {}

proc get_pins {pin_name} {
    if {[dict exists $::mock_pins $pin_name]} {
        return [list $pin_name]
    }
    return {}
}

proc get_nets {args} {
    if {[llength $args] != 2 || [lindex $args 0] ne "-of_objects"} {
        error "unexpected get_nets arguments: $args"
    }
    set pins [lindex $args 1]
    if {[llength $pins] == 0} {
        return {}
    }
    set pin_name [lindex $pins 0]
    if {[dict exists $::mock_nets $pin_name]} {
        return [list [dict get $::mock_nets $pin_name]]
    }
    return {}
}

proc get_cells {cell_name} {
    if {[dict exists $::mock_cells $cell_name]} {
        return [list $cell_name]
    }
    return {}
}

proc insert_buffer {args} {
    lappend ::mutation_log [linsert $args 0 insert_buffer]
}

proc replace_cell {args} {
    lappend ::mutation_log [linsert $args 0 replace_cell]
}

proc detailed_placement {} {
    lappend ::flow_log [list detailed_placement]
}

proc global_route {args} {
    lappend ::flow_log [linsert $args 0 global_route]
}

proc detailed_route {} {
    lappend ::flow_log [list detailed_route]
}

proc estimate_parasitics {args} {
    lappend ::flow_log [linsert $args 0 estimate_parasitics]
}

proc write_def {path} {
    lappend ::flow_log [list write_def $path]
}

proc write_verilog {path} {
    lappend ::flow_log [list write_verilog $path]
}

proc write_db {path} {
    lappend ::flow_log [list write_db $path]
}

source [file join $repo_root eco apply_eco.tcl]

set ::POST_ECO_DIR [file normalize [file join $test_dir ".eco-execution-test-output"]]
set ::DESIGN_NAME "alu32"

set ::passed 0
set ::failed 0

proc check_equal {name actual expected} {
    if {$actual eq $expected} {
        incr ::passed
        puts "PASS: $name"
    } else {
        incr ::failed
        puts "FAIL: $name"
        puts "  expected: $expected"
        puts "  actual:   $actual"
    }
}

if {[catch {run_targeted_eco} error_message]} {
    incr ::failed
    puts "FAIL: targeted ECO execution raised an error: $error_message"
} else {
    incr ::passed
    puts "PASS: targeted ECO execution completed"
}

set expected_mutations [list \
    [list insert_buffer -buffer_cell BUF_X4 -net net_6529 -buffer_name ECO_BUF_6529] \
    [list insert_buffer -buffer_cell BUF_X4 -net net_3280 -buffer_name ECO_BUF_3280] \
    [list replace_cell _5084_ NOR2_X2]]
check_equal "two configured buffers and one configured resize are applied" \
    $::mutation_log $expected_mutations

set expected_flow [list \
    [list detailed_placement] \
    [list global_route -start_incremental] \
    [list global_route -end_incremental] \
    [list detailed_route] \
    [list estimate_parasitics -global_routing] \
    [list write_def [file join $::POST_ECO_DIR alu32_post_eco.def]] \
    [list write_verilog [file join $::POST_ECO_DIR alu32_post_eco.v]] \
    [list write_db [file join $::POST_ECO_DIR alu32_post_eco.odb]]]
check_equal "legalization, incremental routing, parasitics and outputs run in order" \
    $::flow_log $expected_flow

puts "\\nTcl ECO execution regression: $::passed passed, $::failed failed"
if {$::failed != 0} {
    exit 1
}
