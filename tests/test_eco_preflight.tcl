#!/usr/bin/env tclsh
# Run from any directory with: tclsh tests/test_eco_preflight.tcl
# OpenROAD commands are stubbed; the production ECO Tcl is sourced unchanged.

set test_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $test_dir ..]]

# Keep tests deterministic even when the caller exports ECO overrides.
foreach name {
    ECO_BUFFER_1_PIN ECO_BUFFER_1_CELL ECO_BUFFER_1_NAME
    ECO_BUFFER_2_PIN ECO_BUFFER_2_CELL ECO_BUFFER_2_NAME
    ECO_RESIZE_INSTANCE ECO_RESIZE_CELL
} {
    catch {unset ::env($name)}
}

# Minimal OpenROAD collection stubs for the preflight commands.
set ::mock_pins {}
set ::mock_nets {}
set ::mock_cells {}
set ::mutation_count 0

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

# Mutation stubs prove that invalid input is rejected before any design edit.
proc insert_buffer {args} { incr ::mutation_count }
proc replace_cell {args} { incr ::mutation_count }

source [file join $repo_root eco apply_eco.tcl]

set ::passed 0
set ::failed 0

proc reset_state {} {
    set ::ECO_BUFFER_1_PIN "_6529_/Q"
    set ::ECO_BUFFER_1_CELL "BUF_X4"
    set ::ECO_BUFFER_1_NAME "ECO_BUF_6529"
    set ::ECO_BUFFER_2_PIN "_3280_/ZN"
    set ::ECO_BUFFER_2_CELL "BUF_X4"
    set ::ECO_BUFFER_2_NAME "ECO_BUF_3280"
    set ::ECO_RESIZE_INSTANCE "_5084_"
    set ::ECO_RESIZE_CELL "NOR2_X2"
    set ::mock_pins [dict create "_6529_/Q" 1 "_3280_/ZN" 1]
    set ::mock_nets [dict create "_6529_/Q" net_6529 "_3280_/ZN" net_3280]
    set ::mock_cells [dict create "_5084_" 1]
    set ::mutation_count 0
}

proc expect_success {name script} {
    if {[catch {uplevel 1 $script} message]} {
        incr ::failed
        puts "FAIL: $name -- unexpected error: $message"
    } else {
        incr ::passed
        puts "PASS: $name"
    }
}

proc expect_error {name expected_fragment script} {
    if {![catch {uplevel 1 $script} message]} {
        incr ::failed
        puts "FAIL: $name -- expected error containing '$expected_fragment'"
    } elseif {[string first $expected_fragment $message] < 0} {
        incr ::failed
        puts "FAIL: $name -- got '$message', expected '$expected_fragment'"
    } else {
        incr ::passed
        puts "PASS: $name"
    }
}

reset_state
expect_success "valid default targets" {eco_validate_targets}

reset_state
dict unset ::mock_pins "_3280_/ZN"
expect_error "missing second driver pin" "ECO target pin not found" {eco_validate_targets}

reset_state
dict unset ::mock_nets "_3280_/ZN"
expect_error "driver pin without a net" "No net found" {eco_validate_targets}

reset_state
set ::ECO_BUFFER_2_PIN $::ECO_BUFFER_1_PIN
expect_error "duplicate driver pins" "distinct driver pins" {eco_validate_targets}

reset_state
set ::ECO_BUFFER_2_NAME $::ECO_BUFFER_1_NAME
expect_error "duplicate buffer instance names" "must be unique" {eco_validate_targets}

reset_state
dict set ::mock_cells "ECO_BUF_6529" 1
expect_error "buffer instance name collision" "already exists" {eco_validate_targets}

reset_state
dict unset ::mock_cells "_5084_"
expect_error "missing resize instance" "resize target instance not found" {eco_validate_targets}

reset_state
set ::ECO_BUFFER_1_PIN ""
expect_error "empty buffer target pin" "must not be empty" {eco_validate_targets}

reset_state
set ::ECO_BUFFER_2_NAME ""
expect_error "empty buffer instance name" "must not be empty" {eco_validate_targets}

reset_state
dict unset ::mock_pins "_3280_/ZN"
expect_error "run rejects invalid targets" "ECO target pin not found" {run_targeted_eco}
if {$::mutation_count == 0} {
    incr ::passed
    puts "PASS: no ECO mutation occurs before preflight succeeds"
} else {
    incr ::failed
    puts "FAIL: preflight failure reached $::mutation_count mutation command(s)"
}

puts "\nTcl ECO preflight regression: $::passed passed, $::failed failed"
if {$::failed != 0} {
    exit 1
}
