# Post-ECO signoff and before/after timing report generation.

source [file join [file dirname [info script]] .. flow config.tcl]

proc run_signoff {} {
    puts "\n\[INFO\] Running post-ECO OpenSTA signoff..."

    report_checks -path_delay max -fields {slew cap input_pin} \
        -path_group clk -endpoint_path_count 50 \
        -format full_clock_expanded \
        -file "$::POST_ECO_DIR/timing.rpt"

    report_worst_slack -max -file "$::POST_ECO_DIR/wns.rpt"
    report_tns -max -file "$::POST_ECO_DIR/tns.rpt"

    # Keep normal data-path hold checks separate from asynchronous timing
    # checks so an async recovery/removal failure is not mistaken for hold.
    report_checks -path_delay min -fields {slew cap input_pin} \
        -path_group clk -endpoint_path_count 50 \
        -format full_clock_expanded \
        -file "$::POST_ECO_DIR/hold.rpt"

    report_checks -check_type recovery -path_delay max \
        -fields {slew cap input_pin} \
        -endpoint_path_count 50 \
        -format full_clock_expanded \
        -file "$::POST_ECO_DIR/recovery.rpt"

    report_checks -check_type removal -path_delay min \
        -fields {slew cap input_pin} \
        -endpoint_path_count 50 \
        -format full_clock_expanded \
        -file "$::POST_ECO_DIR/removal.rpt"

    # Physical checks remain part of the signoff evidence. A DRC-clean route
    # is required before treating a timing improvement as an accepted ECO.
    check_drc -report_file "$::POST_ECO_DIR/drc.rpt"

    puts "\[INFO\] Post-ECO reports written to $::POST_ECO_DIR"
    puts "\[INFO\] Compare baseline/ and post_eco/ WNS, TNS, data hold, recovery/removal and DRC."
}
