import subprocess
import os

tcl_script = """
read_liberty /OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib
read_lef /OpenROAD-flow-scripts/flow/platforms/nangate45/lef/NangateOpenCellLibrary.tech.lef
read_lef /OpenROAD-flow-scripts/flow/platforms/nangate45/lef/NangateOpenCellLibrary.macro.lef
read_def data/processed/alu32_post_route.def
read_sdc benchmarks/alu32.sdc

puts "--- TESTING GLOBAL ROUTE ---"
catch {global_route -help} msg; puts $msg
global_route
puts "--- TESTING ESTIMATE PARASITICS ---"
set_wire_rc -layer metal3
estimate_parasitics -placement
report_wns
report_tns
exit
"""

with open("scripts/test_route.tcl", "w") as f:
    f.write(tcl_script)

workspace_path = os.path.abspath(".")
cmd = [
    "docker", "run", "--rm",
    "-v", f"{workspace_path}:/workspace",
    "-w", "/workspace",
    "--entrypoint", "bash",
    "openroad/orfs:latest",
    "-c",
    "export PATH=/OpenROAD-flow-scripts/tools/install/OpenROAD/bin:/OpenROAD-flow-scripts/tools/install/yosys/bin:/usr/local/bin:/usr/bin:$PATH && openroad scripts/test_route.tcl"
]

res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
print(res.stdout)
