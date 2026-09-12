import subprocess
import os

tcl_script = """
puts "=================== OPENROAD COMMAND QUERY ==================="
puts "REPLACE:  [info commands *replace*]"
puts "SIZE:     [info commands *size*]"
puts "SWAP:     [info commands *swap*]"
puts "ECO:      [info commands *eco*]"
puts "CELL:     [info commands *cell*]"
puts "BUFFER:   [info commands *buf*]"
puts "REPAIR:   [info commands *repair*]"
puts "OPT:      [info commands *opt*]"
puts "INSERT:   [info commands *insert*]"
puts "=============================================================="
exit
"""

with open("scripts/query_cmd.tcl", "w") as f:
    f.write(tcl_script)

workspace_path = os.path.abspath(".")
cmd = [
    "docker", "run", "--rm",
    "-v", f"{workspace_path}:/workspace",
    "-w", "/workspace",
    "--entrypoint", "bash",
    "openroad/orfs:latest",
    "-c",
    "export PATH=/OpenROAD-flow-scripts/tools/install/OpenROAD/bin:/OpenROAD-flow-scripts/tools/install/yosys/bin:/usr/local/bin:/usr/bin:$PATH && openroad scripts/query_cmd.tcl"
]

res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
print(res.stdout)
