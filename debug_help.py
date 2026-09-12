import subprocess
import os

tcl_script = """
puts "--- HELP: replace_cell ---"
catch {replace_cell -help} msg; puts $msg
puts "--- HELP: insert_buffer ---"
catch {insert_buffer -help} msg; puts $msg
exit
"""

with open("scripts/query_help.tcl", "w") as f:
    f.write(tcl_script)

workspace_path = os.path.abspath(".")
cmd = [
    "docker", "run", "--rm",
    "-v", f"{workspace_path}:/workspace",
    "-w", "/workspace",
    "--entrypoint", "bash",
    "openroad/orfs:latest",
    "-c",
    "export PATH=/OpenROAD-flow-scripts/tools/install/OpenROAD/bin:/OpenROAD-flow-scripts/tools/install/yosys/bin:/usr/local/bin:/usr/bin:$PATH && openroad scripts/query_help.tcl"
]

res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
print(res.stdout)
