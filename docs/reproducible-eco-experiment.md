# Reproducible ECO Experiment Checklist

Use this record for every baseline-to-candidate timing ECO comparison. Keeping the inputs and run conditions together makes the result reviewable and helps isolate regressions.

## Before the run

- [ ] Record the repository commit and working-tree state.
- [ ] Record the design/netlist snapshot used as the starting point.
- [ ] Record OpenROAD/OpenSTA versions or the container image tag/digest.
- [ ] Preserve the timing constraints, Liberty files and RC/parasitic assumptions.
- [ ] Save the baseline reports before applying any ECO.
- [ ] State the hypothesis: which path or electrical issue should improve, and why?

## During the run

- [ ] Record the exact command or Tcl entry point.
- [ ] Keep stdout, stderr and stage-specific logs.
- [ ] Record each ECO operation, including target instance/net and replacement cell or buffer.
- [ ] Confirm placement legalization and routing stages completed.
- [ ] Do not overwrite the baseline artifacts with candidate outputs.

## After the run

- [ ] Compare setup and hold metrics.
- [ ] Compare slew, capacitance, fanout and physical-rule evidence.
- [ ] Record area and any available congestion/routing metrics.
- [ ] Inspect the critical paths, not only aggregate numbers.
- [ ] Mark missing or failed stages as inconclusive rather than passing.
- [ ] Save a short conclusion with the accepted trade-off or reason for rejection.

## Experiment record template

Copy this block into the experiment notes for a run:

```text
Experiment ID:
Date:
Repository commit:
Tool/container version:
Design and constraints:
Baseline artifact directory:
Candidate artifact directory:

Hypothesis:
ECO operation:
Setup baseline -> candidate:
Hold baseline -> candidate:
Area baseline -> candidate:
Electrical/DRC result:
Run completeness:
Decision: ACCEPTED / REJECTED / INCONCLUSIVE
Reason:
```

## Comparing runs fairly

Change one variable at a time where practical. If several related edits are applied together, list them as one candidate set and avoid attributing the full result to a single edit. Compare only runs with equivalent constraints, libraries and analysis methodology.
