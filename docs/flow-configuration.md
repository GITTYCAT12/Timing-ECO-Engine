# Flow Configuration

The flow defaults to the repository's Nangate45 `alu32` development setup. You can point its input paths and fixed ECO actions at another mounted design and technology by setting environment variables before launching it. The recipe still performs two buffer insertions and one cell resize; it does not discover or rank candidates automatically.

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
| `ECO_BUFFER_1_PIN` | Driver output pin for the first inserted buffer | `_6529_/Q` |
| `ECO_BUFFER_1_CELL` | Library cell used for the first buffer | `BUF_X4` |
| `ECO_BUFFER_1_NAME` | Unique instance name assigned to the first buffer | `ECO_BUF_6529` |
| `ECO_BUFFER_2_PIN` | Driver output pin for the second inserted buffer | `_3280_/ZN` |
| `ECO_BUFFER_2_CELL` | Library cell used for the second buffer | `BUF_X4` |
| `ECO_BUFFER_2_NAME` | Unique instance name assigned to the second buffer | `ECO_BUF_3280` |
| `ECO_RESIZE_INSTANCE` | Existing instance to resize | `_5084_` |
| `ECO_RESIZE_CELL` | Target library cell for the resize | `NOR2_X2` |

The three explicit technology-file variables are useful when a platform uses a different directory layout or file naming convention. If they are not set, the flow retains the existing Nangate45 defaults.

The eight `ECO_BUFFER_*` and `ECO_RESIZE_*` variables map the fixed recipe to matching pins, instances and library cells in another netlist. Choose buffer and resize cells that are available in the selected Liberty/LEF set, keep inserted instance names unique, and confirm the selected targets against baseline timing reports. These overrides do not prove logical equivalence or timing improvement; run the complete post-ECO setup, hold, recovery/removal and physical checks.

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
