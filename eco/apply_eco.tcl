# Targeted timing ECO implementation.
#
# Important: this project uses the Tcl commands actually exposed by the
# OpenROAD image used during development. In particular, buffer insertion is
# performed with insert_buffer; the unavailable rebuffer_net wrapper is not
# assumed.

source [file join [file dirname [info script]] .. flow config.tcl]

proc eco_insert_buffer {driver_pin buffer_cell buffer_name} {
    set driver [get_pins $driver_pin]
    if {[llength $driver] == 0} {
        error "ECO target pin not found: $driver_pin"
    }

    set net [get_nets -of_objects $driver]
    if {[llength $net] == 0} {
        error "No net found for ECO target pin: $driver_pin"
    }

    puts "\[ECO\] Buffer insertion: $driver_pin -> $buffer_cell"
    puts "      Net: $net"

    # OpenROAD's insert_buffer command can operate on the complete target net.
    insert_buffer -buffer_cell $buffer_cell \
        -net $net \
        -buffer_name $buffer_name
}

proc eco_resize_cell {instance target_cell} {
    set cell [get_cells $instance]
    if {[llength $cell] == 0} {
        error "ECO target instance not found: $instance"
    }

    puts "\[ECO\] Cell resize: $instance -> $target_cell"
    replace_cell $instance $target_cell
}

proc run_targeted_eco {} {
    puts "\n\[INFO\] Applying targeted timing ECO actions..."

    # Candidate 1: buffer insertion on a configured driver output pin.
    # The default alu32 target is a high-fanout sequential driver; for another
    # design, select a target using baseline fanout/capacitance/slew evidence.
    eco_insert_buffer "$::ECO_BUFFER_1_PIN" "$::ECO_BUFFER_1_CELL" "$::ECO_BUFFER_1_NAME"

    # Candidate 2: buffer insertion on a second configured driver output pin.
    eco_insert_buffer "$::ECO_BUFFER_2_PIN" "$::ECO_BUFFER_2_CELL" "$::ECO_BUFFER_2_NAME"

    # Candidate 3: resize a configured instance to a compatible library cell.
    # Keep sequential and clock cells out of this transformation class.
    eco_resize_cell "$::ECO_RESIZE_INSTANCE" "$::ECO_RESIZE_CELL"

    # Re-legalize after incremental cell/buffer changes. OpenROAD documents
    # detailed placement as the legalizer for resizing and buffer insertion.
    detailed_placement

    # Re-route only after ECO placement has been legalized.
    global_route -start_incremental
    global_route -end_incremental
    detailed_route

    estimate_parasitics -global_routing

    write_def "$::POST_ECO_DIR/${::DESIGN_NAME}_post_eco.def"
    write_verilog "$::POST_ECO_DIR/${::DESIGN_NAME}_post_eco.v"
    write_db "$::POST_ECO_DIR/${::DESIGN_NAME}_post_eco.odb"

    puts "\[INFO\] ECO implementation and routing completed."
}
