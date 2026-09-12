import subprocess
import os

print("=== RUNNING DETAILED OPENROAD LOG CAPTURE ===")

# Create a clean direct script
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

proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
print("\n--- OPENROAD OUTPUT ---")
print(proc.stdout)
print("-----------------------")
print(f"Exit code: {proc.returncode}")

print("\n--- FILES IN WORKSPACE ---")
for root, dirs, files in os.walk("."):
    # skip .git or venv
    if ".git" in root or "venv" in root or "__pycache__" in root:
        continue
    for f in files:
        full = os.path.join(root, f)
        size = os.path.getsize(full)
        print(f"  {full} ({size} bytes)")
