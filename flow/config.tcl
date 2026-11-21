# Central flow configuration for the OpenROAD Tcl implementation.

set ::FLOW_DIR [file dirname [file normalize [info script]]]
set ::ECO_ROOT [file normalize [file join $::FLOW_DIR ..]]

# Allow the same Tcl flow to run against another mounted technology/design
# without editing the implementation scripts. Defaults preserve the current
# Nangate45 alu32 development setup. Empty exported variables are treated as
# unset so an accidental empty shell override cannot create an empty input path.
proc eco_config_value {name default_value} {
    if {[info exists ::env($name)] && $::env($name) ne ""} {
        return $::env($name)
    }
    return $default_value
}

set ::LIB_ROOT [eco_config_value ECO_LIB_ROOT "/OpenROAD-flow-scripts/flow/platforms/nangate45"]
set ::DESIGN_NAME [eco_config_value ECO_DESIGN_NAME "alu32"]
set ::ROUTE_DEF [eco_config_value ECO_ROUTE_DEF "$::ECO_ROOT/data/processed/alu32_post_route.def"]
set ::SDC [eco_config_value ECO_SDC "$::ECO_ROOT/benchmarks/alu32.sdc"]

# Permit explicit library/LEF overrides for platforms whose files do not
# follow the Nangate45 directory and naming convention.
set ::LIBERTY [eco_config_value ECO_LIBERTY "$::LIB_ROOT/lib/NangateOpenCellLibrary_typical.lib"]
set ::TECH_LEF [eco_config_value ECO_TECH_LEF "$::LIB_ROOT/lef/NangateOpenCellLibrary.tech.lef"]
set ::CELL_LEF [eco_config_value ECO_CELL_LEF "$::LIB_ROOT/lef/NangateOpenCellLibrary.macro.lef"]


# The default ECO recipe targets the alu32 development netlist. Override these
# identifiers when mapping the same two-buffer/one-resize recipe to another
# design or library; the flow does not automatically select ECO candidates.
if {[info exists ::env(ECO_BUFFER_1_PIN)] && $::env(ECO_BUFFER_1_PIN) ne ""} {
    set ::ECO_BUFFER_1_PIN $::env(ECO_BUFFER_1_PIN)
} else {
    set ::ECO_BUFFER_1_PIN "_6529_/Q"
}

if {[info exists ::env(ECO_BUFFER_1_CELL)] && $::env(ECO_BUFFER_1_CELL) ne ""} {
    set ::ECO_BUFFER_1_CELL $::env(ECO_BUFFER_1_CELL)
} else {
    set ::ECO_BUFFER_1_CELL "BUF_X4"
}

if {[info exists ::env(ECO_BUFFER_1_NAME)] && $::env(ECO_BUFFER_1_NAME) ne ""} {
    set ::ECO_BUFFER_1_NAME $::env(ECO_BUFFER_1_NAME)
} else {
    set ::ECO_BUFFER_1_NAME "ECO_BUF_6529"
}

if {[info exists ::env(ECO_BUFFER_2_PIN)] && $::env(ECO_BUFFER_2_PIN) ne ""} {
    set ::ECO_BUFFER_2_PIN $::env(ECO_BUFFER_2_PIN)
} else {
    set ::ECO_BUFFER_2_PIN "_3280_/ZN"
}

if {[info exists ::env(ECO_BUFFER_2_CELL)] && $::env(ECO_BUFFER_2_CELL) ne ""} {
    set ::ECO_BUFFER_2_CELL $::env(ECO_BUFFER_2_CELL)
} else {
    set ::ECO_BUFFER_2_CELL "BUF_X4"
}

if {[info exists ::env(ECO_BUFFER_2_NAME)] && $::env(ECO_BUFFER_2_NAME) ne ""} {
    set ::ECO_BUFFER_2_NAME $::env(ECO_BUFFER_2_NAME)
} else {
    set ::ECO_BUFFER_2_NAME "ECO_BUF_3280"
}

if {[info exists ::env(ECO_RESIZE_INSTANCE)] && $::env(ECO_RESIZE_INSTANCE) ne ""} {
    set ::ECO_RESIZE_INSTANCE $::env(ECO_RESIZE_INSTANCE)
} else {
    set ::ECO_RESIZE_INSTANCE "_5084_"
}

if {[info exists ::env(ECO_RESIZE_CELL)] && $::env(ECO_RESIZE_CELL) ne ""} {
    set ::ECO_RESIZE_CELL $::env(ECO_RESIZE_CELL)
} else {
    set ::ECO_RESIZE_CELL "NOR2_X2"
}

set ::REPORT_DIR "$::ECO_ROOT/reports"
set ::BASELINE_DIR "$::REPORT_DIR/baseline"
set ::POST_ECO_DIR "$::REPORT_DIR/post_eco"

file mkdir $::REPORT_DIR
file mkdir $::BASELINE_DIR
file mkdir $::POST_ECO_DIR
