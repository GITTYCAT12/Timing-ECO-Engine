import os
import subprocess
import sys

print("==================================================================")
print("     ECO COPILOT — END-TO-END BASELINE & PARSER EXECUTION         ")
print("==================================================================")

tcl_content = """
set DESIGN_NAME "alu32"
set PLATFORM_DIR "/OpenROAD-flow-scripts/flow/platforms/nangate45"
set LIB_FILE "$PLATFORM_DIR/lib/NangateOpenCellLibrary_typical.lib"
set TECH_LEF "$PLATFORM_DIR/lef/NangateOpenCellLibrary.tech.lef"
set CELL_LEF "$PLATFORM_DIR/lef/NangateOpenCellLibrary.macro.lef"
set MAKE_TRACKS "$PLATFORM_DIR/make_tracks.tcl"
set SET_RC "$PLATFORM_DIR/setRC.tcl"

file mkdir "data/raw"
file mkdir "data/processed"

puts "ECO-COPILOT INFO: Step 1/7 - Reading Liberty and LEF..."
read_liberty $LIB_FILE
read_lef $TECH_LEF
read_lef $CELL_LEF

puts "ECO-COPILOT INFO: Step 2/7 - Loading Netlist and SDC..."
read_verilog data/processed/alu32_synth.v
link_design $DESIGN_NAME
read_sdc benchmarks/alu32.sdc

puts "ECO-COPILOT INFO: Step 3/7 - Floorplanning & Track Generation..."
initialize_floorplan -site FreePDK45_38x28_10R_NP_162NW_34O \
    -utilization 60 \
    -aspect_ratio 1.0 \
    -core_space 5.0

# Generate PDK track grids
source $MAKE_TRACKS

# Place I/O pins
place_pins -hor_layer metal3 -ver_layer metal2

puts "ECO-COPILOT INFO: Step 4/7 - Initial Placement..."
global_placement -density 0.65
detailed_placement

puts "ECO-COPILOT INFO: Step 5/7 - Clock Tree Synthesis & Legalization..."
clock_tree_synthesis -root_buf CLKBUF_X2 -buf_list "CLKBUF_X1 CLKBUF_X2 CLKBUF_X3" -sink_clustering_enable
# Legalize newly inserted CTS clock buffers
detailed_placement

puts "ECO-COPILOT INFO: Step 6/7 - Routing..."
# Source accurate PDK RC models
if {[file exists $SET_RC]} {
    source $SET_RC
} else {
    set_wire_rc -layer metal3
}

global_route
detailed_route

# Export post-route design databases
write_def data/processed/alu32_post_route.def
write_verilog data/processed/alu32_post_route.v

puts "ECO-COPILOT INFO: Step 7/7 - Signoff OpenSTA Timing Analysis..."
estimate_parasitics -global_routing

report_wns > data/raw/baseline_wns.rpt
report_tns > data/raw/baseline_tns.rpt

report_checks -path_delay max \
              -fields {input_pin slew cap net fanout} \
              -format full_clock_expanded \
              -endpoint_path_count 50 \
              -unique_paths_to_endpoint \
              > data/raw/baseline_sta.rpt

report_checks -path_delay min \
              -fields {input_pin slew cap net fanout} \
              -format full_clock_expanded \
              -endpoint_path_count 50 \
              -unique_paths_to_endpoint \
              > data/raw/baseline_hold.rpt

puts "ECO-COPILOT INFO: Flow Completed Successfully! Baseline Signoff Reports Written."
exit
"""

with open("scripts/run_sta_baseline.tcl", "w") as f:
    f.write(tcl_content)

print("[+] scripts/run_sta_baseline.tcl updated cleanly.")

# Launch OpenROAD inside Docker with real-time log streaming
print("[+] Launching OpenROAD inside Docker...")
workspace_path = os.path.abspath(".")
cmd = [
    "docker", "run", "--rm",
    "-v", f"{workspace_path}:/workspace",
    "-w", "/workspace",
    "--entrypoint", "bash",
    "openroad/orfs:latest",
    "-c",
    "export PATH=/OpenROAD-flow-scripts/tools/install/OpenROAD/bin:/OpenROAD-flow-scripts/tools/install/yosys/bin:/usr/local/bin:/usr/bin:$PATH; openroad scripts/run_sta_baseline.tcl"
]

proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
for line in proc.stdout:
    print(line, end="")
proc.wait()

if proc.returncode != 0:
    print(f"\n[-] OpenROAD failed with exit code {proc.returncode}")
    sys.exit(1)

print("\n[+] OpenROAD execution completed successfully!")

# Trigger Day 2 Parser Verification
if os.path.exists("data/raw/baseline_sta.rpt"):
    print("\n[+] Triggering Day 2 Parser Verification...\n")
    subprocess.run([sys.executable, "tests/test_parser.py"])
else:
    print("\n[-] Error: baseline_sta.rpt was not created.")
