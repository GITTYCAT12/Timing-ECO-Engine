# Timing-ECO-Engine
# Physical-design-first entry point.
# Runs the ECO analysis/implementation loop inside OpenROAD.

set ::FLOW_DIR [file dirname [file normalize [info script]]]
set ::ECO_ROOT [file normalize [file join $::FLOW_DIR ..]]

proc require_file {label path} {
    if {![file exists $path]} {
        error "Missing $label: $path"
    }
    puts "[INFO] Found $label: $path"
}

source [file join $::FLOW_DIR baseline_sta.tcl]
source [file join $::ECO_ROOT eco apply_eco.tcl]
source [file join $::ECO_ROOT sta signoff.tcl]

puts ""
puts "=============================================================="
puts " Timing-ECO-Engine: OpenROAD/OpenSTA ECO Flow"
puts "=============================================================="
puts " Baseline -> STA -> targeted ECO -> placement -> route -> STA"
puts "=============================================================="

# Fail early before OpenSTA/OpenROAD starts consuming a long flow runtime.
require_file "Liberty" $::LIBERTY
require_file "technology LEF" $::TECH_LEF
require_file "cell LEF" $::CELL_LEF
require_file "routed DEF" $::ROUTE_DEF
require_file "SDC constraints" $::SDC

puts "[INFO] Input preflight passed for design '$::DESIGN_NAME'."

run_baseline_sta
run_targeted_eco
run_signoff

puts ""
puts "\[INFO\] Timing-ECO-Engine flow completed."
