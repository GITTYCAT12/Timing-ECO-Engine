import os
import subprocess
import sys

print("=================================================================================")
print("            ECO COPILOT -- UNIFIED END-TO-END DOCKER ORCHESTRATOR                 ")
print("=================================================================================")

os.makedirs("scripts", exist_ok=True)
os.makedirs("data/raw", exist_ok=True)
os.makedirs("data/processed", exist_ok=True)
os.makedirs("data/experiments", exist_ok=True)

# Write unified runner script with Unix line endings (\n)
bash_content = """#!/bin/bash
set -e

export PATH=/OpenROAD-flow-scripts/tools/install/OpenROAD/bin:/OpenROAD-flow-scripts/tools/install/yosys/bin:/usr/local/bin:/usr/bin:$PATH

echo "=== [1/4] Installing Required Packages (Fast Apt-Get) ==="
apt-get update -qq && apt-get install -y -qq python3-pandas python3-numpy python3-sklearn python3-tabulate >/dev/null 2>&1 || pip install pandas numpy scikit-learn tabulate

echo "=== [2/4] Running Full ECO Copilot Pipeline (Triage + ECO + Post-STA) ==="
python3 eco_copilot.py --all

echo "=== [3/4] Running Multi-Strategy Closed-Loop Experiments ==="
python3 experiments/run_experiments.py

echo "=== [4/4] Evaluating Machine Learning vs Rule-Based Scoring ==="
python3 tests/test_ml_benchmarking.py

echo "================================================================================="
echo "  [+] DOCKER ECOSYSTEM COMPLETE! ALL TIMING REPORTS & DATASETS GENERATED."
echo "================================================================================="
"""

with open("scripts/docker_run_all.sh", "w", newline="\n") as f:
    f.write(bash_content)

print("[+] scripts/docker_run_all.sh generated cleanly.")

workspace_path = os.path.abspath(".")
cmd = [
    "docker", "run", "--rm",
    "-v", f"{workspace_path}:/workspace",
    "-w", "/workspace",
    "--entrypoint", "bash",
    "openroad/orfs:latest",
    "/workspace/scripts/docker_run_all.sh"
]

print("[+] Launching unified pipeline inside Docker container...")
proc = subprocess.Popen(
    cmd,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    text=True,
    encoding="utf-8",
    errors="replace",
    bufsize=1
)

for line in proc.stdout:
    print(line, end="")
proc.wait()

if proc.returncode != 0:
    print(f"\n[-] Docker Pipeline failed with exit code {proc.returncode}")
    sys.exit(1)

print("\n[+] Success! Full closed-loop execution completed inside Docker.")
