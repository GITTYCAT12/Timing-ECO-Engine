$ErrorActionPreference = "Stop"

$Image = if ($env:OPENROAD_IMAGE) { $env:OPENROAD_IMAGE } else { "openroad/orfs:latest" }
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$FlowScript = Join-Path $Root "flow/run_flow.tcl"

if (-not (Test-Path -LiteralPath $FlowScript -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: OpenROAD flow script was not found: $FlowScript")
    [Console]::Error.WriteLine("Check that the repository is complete and flow/run_flow.tcl exists.")
    exit 2
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    [Console]::Error.WriteLine("ERROR: Docker was not found in PATH. Start Docker Desktop or install Docker Engine.")
    exit 127
}

& docker info 1>$null 2>$null
if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("ERROR: Docker is installed but the daemon is not reachable. Start Docker and retry.")
    exit 1
}

Write-Host "==============================================================="
Write-Host " Timing-ECO-Engine | Windows -> Docker -> OpenROAD Tcl"
Write-Host "==============================================================="
Write-Host "Workspace: $Root"
Write-Host "Image:     $Image"

$cmd = 'export PATH=/OpenROAD-flow-scripts/tools/install/OpenROAD/bin:/OpenROAD-flow-scripts/tools/install/yosys/bin:/usr/local/bin:/usr/bin:$PATH && openroad -exit /workspace/flow/run_flow.tcl'

docker run --rm `
  -e ECO_LIB_ROOT -e ECO_DESIGN_NAME -e ECO_ROUTE_DEF -e ECO_SDC `
  -e ECO_LIBERTY -e ECO_TECH_LEF -e ECO_CELL_LEF `
  -e ECO_BUFFER_1_PIN -e ECO_BUFFER_1_CELL -e ECO_BUFFER_1_NAME `
  -e ECO_BUFFER_2_PIN -e ECO_BUFFER_2_CELL -e ECO_BUFFER_2_NAME `
  -e ECO_RESIZE_INSTANCE -e ECO_RESIZE_CELL `
  -v "${Root}:/workspace" `
  -w /workspace `
  --entrypoint bash `
  $Image `
  -c $cmd

if ($LASTEXITCODE -ne 0) {
    throw "OpenROAD Tcl flow failed with exit code $LASTEXITCODE"
}

Write-Host "[DONE] Timing-ECO-Engine flow completed."
