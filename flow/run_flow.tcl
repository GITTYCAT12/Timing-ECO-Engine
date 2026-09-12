# Timing-ECO-Engine
# Physical-design-first entry point.
# Runs the ECO analysis/implementation loop inside OpenROAD.

set ::FLOW_DIR [file dirname [file normalize [info script]]]
set ::ECO_ROOT [file normalize [file join $::FLOW_DIR ..]]

source [file join $::FLOW_DIR baseline_sta.tcl]
source [file join $::ECO_ROOT eco apply_eco.tcl]
source [file join $::ECO_ROOT sta signoff.tcl]

puts ""
puts "=============================================================="
puts " Timing-ECO-Engine: OpenROAD/OpenSTA ECO Flow"
puts "=============================================================="
puts " Baseline -> STA -> targeted ECO -> placement -> route -> STA"
puts "=============================================================="

run_baseline_sta
run_targeted_eco
run_signoff

puts ""
puts "\[INFO\] Timing-ECO-Engine flow completed."
