# Flow Configuration

The flow defaults to the repository's Nangate45 `alu32` development setup. You can point it at another mounted design and technology without editing the Tcl implementation files by setting environment variables before launching the flow.

## Supported variables

| Variable | Purpose | Default |
|---|---|---|
| `OPENROAD_IMAGE` | OpenROAD/ORFS Docker image used by the launcher | `openroad/orfs:latest` |
| `ECO_LIB_ROOT` | Root directory of the platform library | `/OpenROAD-flow-scripts/flow/platforms/nangate45` |
| `ECO_DESIGN_NAME` | Design name used in output artifact names | `alu32` |
| `ECO_ROUTE_DEF` | Input routed DEF | `data/processed/alu32_post_route.def` in the repository |
| `ECO_SDC` | Timing constraints file | `benchmarks/alu32.sdc` in the repository |
| `ECO_LIBERTY` | Explicit Liberty file path | Nangate45 typical Liberty under `ECO_LIB_ROOT` |
| `ECO_TECH_LEF` | Explicit technology LEF path | Nangate45 technology LEF under `ECO_LIB_ROOT` |
| `ECO_CELL_LEF` | Explicit cell/macro LEF path | Nangate45 cell LEF under `ECO_LIB_ROOT` |

The three explicit technology-file variables are useful when a platform uses a different directory layout or file naming convention. If they are not set, the flow retains the existing Nangate45 defaults.

## Windows PowerShell example

Set paths visible **inside the Docker container**, not host-only paths. Mount the relevant platform and design data into the container before running the launcher.

```powershell
$env:ECO_DESIGN_NAME = "alu32"
$env:ECO_ROUTE_DEF = "/workspace/data/processed/alu32_post_route.def"
$env:ECO_SDC = "/workspace/benchmarks/alu32.sdc"
$env:ECO_LIBERTY = "/OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib"
$env:ECO_TECH_LEF = "/OpenROAD-flow-scripts/flow/platforms/nangate45/lef/NangateOpenCellLibrary.tech.lef"
$env:ECO_CELL_LEF = "/OpenROAD-flow-scripts/flow/platforms/nangate45/lef/NangateOpenCellLibrary.macro.lef"

.\scripts\run_windows.ps1
```

## Linux example

```bash
export ECO_DESIGN_NAME=alu32
export ECO_ROUTE_DEF=/workspace/data/processed/alu32_post_route.def
export ECO_SDC=/workspace/benchmarks/alu32.sdc
export ECO_LIBERTY=/OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib
export ECO_TECH_LEF=/OpenROAD-flow-scripts/flow/platforms/nangate45/lef/NangateOpenCellLibrary.tech.lef
export ECO_CELL_LEF=/OpenROAD-flow-scripts/flow/platforms/nangate45/lef/NangateOpenCellLibrary.macro.lef

./scripts/run_flow.sh
```

## Validation behavior

Before baseline STA starts, `flow/run_flow.tcl` checks that the selected Liberty, technology LEF, cell LEF, routed DEF and SDC paths exist, are regular readable files and are non-empty. A missing or empty input stops the run with a specific error instead of allowing a long flow to fail later.

## Reproducibility note

Record the values of all `ECO_*` variables and `OPENROAD_IMAGE` alongside each experiment. Two timing reports should only be compared when their design snapshot, constraints, libraries and analysis assumptions are equivalent.
