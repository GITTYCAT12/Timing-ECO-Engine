# Central flow configuration for the OpenROAD Tcl implementation.

set ::FLOW_DIR [file dirname [file normalize [info script]]]
set ::ECO_ROOT [file normalize [file join $::FLOW_DIR ..]]

# Allow the same Tcl flow to run against another mounted technology/design
# without editing the implementation scripts. Defaults preserve the current
# Nangate45 alu32 development setup.
if {[info exists ::env(ECO_LIB_ROOT)]} {
    set ::LIB_ROOT $::env(ECO_LIB_ROOT)
} else {
    set ::LIB_ROOT "/OpenROAD-flow-scripts/flow/platforms/nangate45"
}

if {[info exists ::env(ECO_DESIGN_NAME)]} {
    set ::DESIGN_NAME $::env(ECO_DESIGN_NAME)
} else {
    set ::DESIGN_NAME "alu32"
}

if {[info exists ::env(ECO_ROUTE_DEF)]} {
    set ::ROUTE_DEF $::env(ECO_ROUTE_DEF)
} else {
    set ::ROUTE_DEF "$::ECO_ROOT/data/processed/alu32_post_route.def"
}

if {[info exists ::env(ECO_SDC)]} {
    set ::SDC $::env(ECO_SDC)
} else {
    set ::SDC "$::ECO_ROOT/benchmarks/alu32.sdc"
}

set ::LIBERTY  "$::LIB_ROOT/lib/NangateOpenCellLibrary_typical.lib"
set ::TECH_LEF "$::LIB_ROOT/lef/NangateOpenCellLibrary.tech.lef"
set ::CELL_LEF "$::LIB_ROOT/lef/NangateOpenCellLibrary.macro.lef"

set ::REPORT_DIR "$::ECO_ROOT/reports"
set ::BASELINE_DIR "$::REPORT_DIR/baseline"
set ::POST_ECO_DIR "$::REPORT_DIR/post_eco"

file mkdir $::REPORT_DIR
file mkdir $::BASELINE_DIR
file mkdir $::POST_ECO_DIR
