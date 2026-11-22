#!/usr/bin/env tclsh
# Run from any directory with: tclsh tests/test_flow_config.tcl
# This checks config defaults/overrides without requiring OpenROAD.

set test_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $test_dir ..]]
set config_path [file join $repo_root flow config.tcl]

foreach name {
    ECO_LIB_ROOT ECO_DESIGN_NAME ECO_ROUTE_DEF ECO_SDC
    ECO_LIBERTY ECO_TECH_LEF ECO_CELL_LEF
    ECO_BUFFER_1_PIN ECO_BUFFER_1_CELL ECO_BUFFER_1_NAME
    ECO_BUFFER_2_PIN ECO_BUFFER_2_CELL ECO_BUFFER_2_NAME
    ECO_RESIZE_INSTANCE ECO_RESIZE_CELL
} {
    catch {unset ::env($name)}
}

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

source $config_path

set default_lib_root "/OpenROAD-flow-scripts/flow/platforms/nangate45"
set default_route_def [file join $repo_root data processed alu32_post_route.def]
set default_sdc [file join $repo_root benchmarks alu32.sdc]

check_equal "default library root" $::LIB_ROOT $default_lib_root
check_equal "default design name" $::DESIGN_NAME "alu32"
check_equal "default routed DEF" $::ROUTE_DEF $default_route_def
check_equal "default SDC" $::SDC $default_sdc
check_equal "default Liberty under library root" $::LIBERTY [file join $default_lib_root lib NangateOpenCellLibrary_typical.lib]
check_equal "default technology LEF under library root" $::TECH_LEF [file join $default_lib_root lef NangateOpenCellLibrary.tech.lef]
check_equal "default cell LEF under library root" $::CELL_LEF [file join $default_lib_root lef NangateOpenCellLibrary.macro.lef]

check_equal "default first buffer pin" $::ECO_BUFFER_1_PIN "_6529_/Q"
check_equal "default first buffer cell" $::ECO_BUFFER_1_CELL "BUF_X4"
check_equal "default first buffer name" $::ECO_BUFFER_1_NAME "ECO_BUF_6529"
check_equal "default second buffer pin" $::ECO_BUFFER_2_PIN "_3280_/ZN"
check_equal "default second buffer cell" $::ECO_BUFFER_2_CELL "BUF_X4"
check_equal "default second buffer name" $::ECO_BUFFER_2_NAME "ECO_BUF_3280"
check_equal "default resize instance" $::ECO_RESIZE_INSTANCE "_5084_"
check_equal "default resize cell" $::ECO_RESIZE_CELL "NOR2_X2"

# Empty exported values should behave exactly like unset values.
foreach name {
    ECO_LIB_ROOT ECO_DESIGN_NAME ECO_ROUTE_DEF ECO_SDC
    ECO_LIBERTY ECO_TECH_LEF ECO_CELL_LEF
    ECO_BUFFER_1_PIN ECO_BUFFER_1_CELL ECO_BUFFER_1_NAME
    ECO_BUFFER_2_PIN ECO_BUFFER_2_CELL ECO_BUFFER_2_NAME
    ECO_RESIZE_INSTANCE ECO_RESIZE_CELL
} {
    set ::env($name) ""
}
source $config_path

check_equal "empty library-root override falls back" $::LIB_ROOT $default_lib_root
check_equal "empty design-name override falls back" $::DESIGN_NAME "alu32"
check_equal "empty DEF override falls back" $::ROUTE_DEF $default_route_def
check_equal "empty SDC override falls back" $::SDC $default_sdc
check_equal "empty Liberty override falls back" $::LIBERTY [file join $default_lib_root lib NangateOpenCellLibrary_typical.lib]
check_equal "empty technology-LEF override falls back" $::TECH_LEF [file join $default_lib_root lef NangateOpenCellLibrary.tech.lef]
check_equal "empty cell-LEF override falls back" $::CELL_LEF [file join $default_lib_root lef NangateOpenCellLibrary.macro.lef]
check_equal "empty first buffer pin falls back" $::ECO_BUFFER_1_PIN "_6529_/Q"
check_equal "empty first buffer cell falls back" $::ECO_BUFFER_1_CELL "BUF_X4"
check_equal "empty first buffer name falls back" $::ECO_BUFFER_1_NAME "ECO_BUF_6529"
check_equal "empty second buffer pin falls back" $::ECO_BUFFER_2_PIN "_3280_/ZN"
check_equal "empty second buffer cell falls back" $::ECO_BUFFER_2_CELL "BUF_X4"
check_equal "empty second buffer name falls back" $::ECO_BUFFER_2_NAME "ECO_BUF_3280"
check_equal "empty resize instance falls back" $::ECO_RESIZE_INSTANCE "_5084_"
check_equal "empty resize cell falls back" $::ECO_RESIZE_CELL "NOR2_X2"

# Non-empty values must still override every configurable input.
set ::env(ECO_LIB_ROOT) "/tmp/eco-custom-platform"
set ::env(ECO_DESIGN_NAME) "custom_block"
set ::env(ECO_ROUTE_DEF) "/tmp/custom.def"
set ::env(ECO_SDC) "/tmp/custom.sdc"
set ::env(ECO_LIBERTY) "/tmp/custom.lib"
set ::env(ECO_TECH_LEF) "/tmp/custom.tech.lef"
set ::env(ECO_CELL_LEF) "/tmp/custom.cell.lef"
set ::env(ECO_BUFFER_1_PIN) "custom_driver_1/Q"
set ::env(ECO_BUFFER_1_CELL) "CUSTOM_BUF_X2"
set ::env(ECO_BUFFER_1_NAME) "CUSTOM_ECO_BUF_1"
set ::env(ECO_BUFFER_2_PIN) "custom_driver_2/ZN"
set ::env(ECO_BUFFER_2_CELL) "CUSTOM_BUF_X4"
set ::env(ECO_BUFFER_2_NAME) "CUSTOM_ECO_BUF_2"
set ::env(ECO_RESIZE_INSTANCE) "custom_resize_inst"
set ::env(ECO_RESIZE_CELL) "CUSTOM_NOR2_X4"
source $config_path

check_equal "non-empty library-root override" $::LIB_ROOT "/tmp/eco-custom-platform"
check_equal "non-empty design-name override" $::DESIGN_NAME "custom_block"
check_equal "non-empty DEF override" $::ROUTE_DEF "/tmp/custom.def"
check_equal "non-empty SDC override" $::SDC "/tmp/custom.sdc"
check_equal "non-empty Liberty override" $::LIBERTY "/tmp/custom.lib"
check_equal "non-empty technology-LEF override" $::TECH_LEF "/tmp/custom.tech.lef"
check_equal "non-empty cell-LEF override" $::CELL_LEF "/tmp/custom.cell.lef"
check_equal "non-empty first buffer pin override" $::ECO_BUFFER_1_PIN "custom_driver_1/Q"
check_equal "non-empty first buffer cell override" $::ECO_BUFFER_1_CELL "CUSTOM_BUF_X2"
check_equal "non-empty first buffer name override" $::ECO_BUFFER_1_NAME "CUSTOM_ECO_BUF_1"
check_equal "non-empty second buffer pin override" $::ECO_BUFFER_2_PIN "custom_driver_2/ZN"
check_equal "non-empty second buffer cell override" $::ECO_BUFFER_2_CELL "CUSTOM_BUF_X4"
check_equal "non-empty second buffer name override" $::ECO_BUFFER_2_NAME "CUSTOM_ECO_BUF_2"
check_equal "non-empty resize instance override" $::ECO_RESIZE_INSTANCE "custom_resize_inst"
check_equal "non-empty resize cell override" $::ECO_RESIZE_CELL "CUSTOM_NOR2_X4"

puts "\nTcl flow configuration regression: $::passed passed, $::failed failed"
if {$::failed != 0} {
    exit 1
}
