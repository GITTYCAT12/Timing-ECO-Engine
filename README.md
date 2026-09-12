# ECO Copilot

**Explainable Fix Recommendation & Closed-Loop Validation for Physical-Design Timing ECOs**

ECO Copilot is a Python/OpenROAD/OpenSTA decision-support layer for post-route setup-timing analysis. It parses STA paths, extracts path/stage features, fingerprints timing bottlenecks, ranks candidate ECOs, generates OpenROAD Tcl, executes the ECO in an isolated run, and validates timing and safety metrics before accepting a result.

## Current ECO scope

- Cell upsizing using `replace_cell`.
- Targeted net rebuffering using OpenROAD Resizer `rebuffer_net`.
- Independent before/after experiment directories for strategy benchmarking.
- Data-hold and asynchronous recovery/removal checks are reported separately.
- ML scoring is optional and requires a real closed-loop experiment dataset with held-out evaluation.

## Important implementation contract

A `BUFFER_INSERTION` recommendation must never be implemented by replacing a logic/sequential cell with a `BUF_*` master. Buffer recommendations carry a driver pin and execute through Resizer rebuffering.

Each ML training row corresponds to one actual ECO trial. Batch-level timing deltas must not be copied onto every candidate in the batch.

## Main flow

```text
RTL -> OpenROAD P&R -> OpenSTA timing
                     |
                     v
              ECO Copilot
     parse -> features -> fingerprint
       -> root cause -> rank ECOs
       -> generate Tcl -> execute
       -> re-route -> validate
```

## Files

- `eco_copilot.py` — main analysis/recommendation CLI
- `experiments/run_experiments.py` — isolated ECO benchmark/dataset generation
- `src/parser/sta_parser.py` — OpenSTA report parser
- `src/recommendation/eco_candidates.py` — ECO candidate generation
- `src/tcl/tcl_generator.py` — executable OpenROAD Tcl generation
- `src/validation/eco_executor.py` — Docker/OpenROAD execution
- `src/validation/validator.py` — before/after timing and safety validation
- `src/scoring/ml_scorer.py` — optional ML scorer

## Verification

Run the project-integrity tests with:

```bash
python -m unittest tests/test_project_integrity.py -v
```

The repository's generated baseline/post-ECO reports are experimental artifacts and should be treated as measured evidence from the included flow, not as universal performance claims.
