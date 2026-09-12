# Central flow configuration for the OpenROAD Tcl implementation.

set ::ECO_ROOT [file normalize [file join [pwd] ..]]

set ::LIB_ROOT "/OpenROAD-flow-scripts/flow/platforms/nangate45"
set ::LIBERTY  "$::LIB_ROOT/lib/NangateOpenCellLibrary_typical.lib"
set ::TECH_LEF "$::LIB_ROOT/lef/NangateOpenCellLibrary.tech.lef"
set ::CELL_LEF "$::LIB_ROOT/lef/NangateOpenCellLibrary.macro.lef"

set ::DESIGN_NAME "alu32"
set ::ROUTE_DEF  "$::ECO_ROOT/data/processed/alu32_post_route.def"
set ::SDC        "$::ECO_ROOT/benchmarks/alu32.sdc"

set ::REPORT_DIR "$::ECO_ROOT/reports"
set ::BASELINE_DIR "$::REPORT_DIR/baseline"
set ::POST_ECO_DIR "$::REPORT_DIR/post_eco"

file mkdir $::REPORT_DIR
file mkdir $::BASELINE_DIR
file mkdir $::POST_ECO_DIR
