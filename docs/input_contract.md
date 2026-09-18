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

## Preflight checklist

Run these checks before treating a flow failure as an ECO failure:

1. Confirm the DEF and SDC paths match the configured design inputs.
2. Confirm the referenced Nangate45 platform files are available inside the OpenROAD container.
3. Confirm the routed DEF is readable and corresponds to the constrained design.
4. Start from a clean generated-report state when reproducing a result.
5. Preserve baseline STA output before applying any ECO.
6. Validate post-ECO setup, data-path hold, recovery/removal, routing completion and physical checks separately.

This distinction is important because a missing input, stale generated database or constraint mismatch can fail before the ECO logic is exercised.

This keeps the repository focused on the **flow logic, ECO methodology and reproducible scripts**, rather than redistributing a PDK or large generated EDA databases.
