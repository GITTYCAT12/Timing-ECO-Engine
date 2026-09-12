$ErrorActionPreference = "Stop"

$Image = if ($env:OPENROAD_IMAGE) { $env:OPENROAD_IMAGE } else { "openroad/orfs:latest" }
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

Write-Host "==============================================================="
Write-Host " Timing-ECO-Engine | Windows -> Docker -> OpenROAD Tcl"
Write-Host "==============================================================="
Write-Host "Workspace: $Root"
Write-Host "Image:     $Image"

$cmd = 'export PATH=/OpenROAD-flow-scripts/tools/install/OpenROAD/bin:/OpenROAD-flow-scripts/tools/install/yosys/bin:/usr/local/bin:/usr/bin:$PATH && openroad -exit /workspace/flow/run_flow.tcl'

docker run --rm `
  -v "${Root}:/workspace" `
  -w /workspace `
  --entrypoint bash `
  $Image `
  -c $cmd

if ($LASTEXITCODE -ne 0) {
    throw "OpenROAD Tcl flow failed with exit code $LASTEXITCODE"
}

Write-Host "[DONE] Timing-ECO-Engine flow completed."
