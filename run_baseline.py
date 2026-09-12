import os

print("=== [ECO COPILOT] UPDATING BASELINE FLOW SCRIPT ===")

tcl_content = """
set DESIGN_NAME "alu32"
set PLATFORM_DIR "/OpenROAD-flow-scripts/flow/platforms/nangate45"
set LIB_FILE "$PLATFORM_DIR/lib/NangateOpenCellLibrary_typical.lib"
set TECH_LEF "$PLATFORM_DIR/lef/NangateOpenCellLibrary.tech.lef"
set CELL_LEF "$PLATFORM_DIR/lef/NangateOpenCellLibrary.macro.lef"

file mkdir "data/raw"
file mkdir "data/processed"

puts "ECO-COPILOT INFO: 1. Reading Liberty and LEF..."
read_liberty $LIB_FILE
read_lef $TECH_LEF
read_lef $CELL_LEF

puts "ECO-COPILOT INFO: 2. Reading Netlist..."
read_verilog data/processed/alu32_synth.v
link_design $DESIGN_NAME
read_sdc benchmarks/alu32.sdc

puts "ECO-COPILOT INFO: 3. Floorplanning..."
initialize_floorplan -site FreePDK45_38x28_10R_NP_162NW_34O \
    -utilization 60 \
    -aspect_ratio 1.0 \
    -core_space 5.0

place_pins -hor_layers metal3 -ver_layers metal2

puts "ECO-COPILOT INFO: 4. Placement..."
global_placement -density 0.65
detailed_placement

puts "ECO-COPILOT INFO: 5. Clock Tree Synthesis..."
clock_tree_synthesis -root_buf CLKBUF_X2 -buf_list "CLKBUF_X1 CLKBUF_X2 CLKBUF_X3" -sink_clustering_enable

puts "ECO-COPILOT INFO: 6. Routing..."
global_route
detailed_route

# Save physical database
write_def data/processed/alu32_post_route.def
write_verilog data/processed/alu32_post_route.v

puts "ECO-COPILOT INFO: 7. Post-Route Signoff STA Timing Analysis..."
set_wire_rc -layer metal3
estimate_parasitics -placement

report_wns > data/raw/baseline_wns.rpt
report_tns > data/raw/baseline_tns.rpt

report_checks -path_delay max \
              -fields {input_pin slew cap net fanout} \
              -format full_clock_expanded \
              -endpoint_count 50 \
              -unique_paths_to_endpoint \
              > data/raw/baseline_sta.rpt

puts "ECO-COPILOT INFO: Flow Completed Successfully! Baseline reports generated."
exit
"""
with open('scripts/run_sta_baseline.tcl', 'w') as f:
    f.write(tcl_content)

print("[ECO-COPILOT] scripts/run_sta_baseline.tcl updated successfully.")
