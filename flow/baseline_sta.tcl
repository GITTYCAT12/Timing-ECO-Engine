# Baseline post-route timing analysis.
# This script intentionally uses OpenROAD/OpenSTA Tcl commands as the primary
# implementation layer rather than hiding the PD flow behind Python.

source [file join [file dirname [info script]] config.tcl]

proc run_baseline_sta {} {
    puts "\n[INFO] Loading routed baseline database..."

    read_liberty $::LIBERTY
    read_lef -tech $::TECH_LEF
    read_lef $::CELL_LEF
    read_def $::ROUTE_DEF
    read_sdc $::SDC

    # The DEF contains the routed topology. Use global-routing parasitics for
    # timing instead of placement-only estimation.
    estimate_parasitics -global_routing

    report_checks -path_delay min_max -fields {slew cap input_pin} \
        -path_group clk -endpoint_path_count 50 \
        -format full_clock_expanded \
        -file "$::BASELINE_DIR/timing.rpt"

    report_worst_slack -max -file "$::BASELINE_DIR/wns.rpt"
    report_tns -max -file "$::BASELINE_DIR/tns.rpt"
    report_checks -path_delay min -fields {slew cap input_pin} \
        -path_group clk -endpoint_path_count 50 \
        -format full_clock_expanded \
        -file "$::BASELINE_DIR/hold.rpt"

    puts "[INFO] Baseline reports written to $::BASELINE_DIR"
}
