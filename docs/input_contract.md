# Flow input contract

The public repository does not bundle the Nangate45 PDK or generated implementation databases.

Before running the flow, provide the benchmark files expected by `flow/config.tcl`:

```text
data/processed/alu32_post_route.def
benchmarks/alu32.sdc
```

The Docker image is expected to provide the Nangate45 technology files at:

```text
/OpenROAD-flow-scripts/flow/platforms/nangate45/
```

The flow then creates generated signoff artifacts under:

```text
reports/baseline/
reports/post_eco/
```

These generated reports/databases are intentionally ignored by Git.

This keeps the repository focused on the **flow logic, ECO methodology and reproducible scripts**, rather than redistributing a PDK or large generated EDA databases.
