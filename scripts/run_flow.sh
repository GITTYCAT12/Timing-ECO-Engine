#!/usr/bin/env bash
set -euo pipefail

IMAGE="${OPENROAD_IMAGE:-openroad/orfs:latest}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker was not found in PATH. Start Docker Desktop or install Docker Engine." >&2
  exit 127
fi

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker is installed but the daemon is not reachable. Start Docker and retry." >&2
  exit 1
fi

OPENROAD_PATH="/OpenROAD-flow-scripts/tools/install/OpenROAD/bin:/OpenROAD-flow-scripts/tools/install/yosys/bin:/usr/local/bin:/usr/bin"

exec docker run --rm \
  -v "${ROOT}:/workspace" \
  -w /workspace \
  --entrypoint bash \
  "${IMAGE}" \
  -c "export PATH=${OPENROAD_PATH}:\$PATH && openroad -exit /workspace/flow/run_flow.tcl"
