#!/usr/bin/env bash
set -euo pipefail

IMAGE="${OPENROAD_IMAGE:-openroad/orfs:latest}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The ORFS image places the OpenROAD executable under this installation path.
OPENROAD_PATH="/OpenROAD-flow-scripts/tools/install/OpenROAD/bin:/OpenROAD-flow-scripts/tools/install/yosys/bin:/usr/local/bin:/usr/bin"

exec docker run --rm \
  -v "${ROOT}:/workspace" \
  -w /workspace \
  --entrypoint bash \
  "${IMAGE}" \
  -c "export PATH=${OPENROAD_PATH}:\$PATH && openroad -exit /workspace/flow/run_flow.tcl"
