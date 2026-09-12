import os
import subprocess

# 1. Create a Linux bash script that will run inside the container
bash_script = """#!/bin/bash
set -e

export PATH=/OpenROAD-flow-scripts/tools/install/OpenROAD/bin:/OpenROAD-flow-scripts/tools/install/yosys/bin:/usr/local/bin:/usr/bin:$PATH

echo "=== [1/3] Verifying Tools Inside Container ==="
which yosys
which openroad
which sta

echo "=== [2/3] Checking Nangate45 Platform Files ==="
PLATFORM_DIR="/OpenROAD-flow-scripts/flow/platforms/nangate45"
ls -la $PLATFORM_DIR/lib/
ls -la $PLATFORM_DIR/lef/

echo "=== [3/3] Running OpenROAD Flow Script ==="
openroad scripts/run_sta_baseline.tcl
"""

with open("scripts/run.sh", "w", newline="\n") as f:
    f.write(bash_script)

print("[ECO-COPILOT] scripts/run.sh written with Unix line endings.")

# 2. Execute Docker cleanly via Python subprocess
workspace_path = os.path.abspath(".")
cmd = [
    "docker", "run", "--rm",
    "-v", f"{workspace_path}:/workspace",
    "-w", "/workspace",
    "--entrypoint", "bash",
    "openroad/orfs:latest",
    "/workspace/scripts/run.sh"
]

print(f"[ECO-COPILOT] Launching Docker container...")
res = subprocess.run(cmd)
if res.returncode == 0:
    print("\n[ECO-COPILOT] Flow completed successfully!")
else:
    print(f"\n[ECO-COPILOT] Process exited with code {res.returncode}")
