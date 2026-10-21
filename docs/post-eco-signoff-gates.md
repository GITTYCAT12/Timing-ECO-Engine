# Post-ECO Signoff Acceptance Gates

A timing ECO is a candidate until the updated design has been checked. Use this checklist when comparing a baseline run with an ECO run.

## Required comparisons

| Gate | Evidence to capture | Acceptance question |
|---|---|---|
| Setup timing | WNS, TNS and worst violating paths | Did setup improve, and are remaining violations within the project's target? |
| Hold timing | WHS/THS or the flow's equivalent hold metrics | Did the change create or worsen hold violations? |
| Electrical limits | Slew/transition, capacitance and fanout reports | Are required limits satisfied? |
| Physical legality | Placement legality and routing completion | Did the ECO leave cells legal and routing complete? |
| Design-rule checks | DRC report and violation count | Did the candidate introduce new violations? |
| Area | Cell area or utilization summary | Is the physical cost acceptable? |
| Reproducibility | Config, tool version, constraints and run logs | Can the result be traced to the exact run inputs? |

Use the metric names emitted by the active flow. Do not silently treat a missing report or an unavailable metric as a passing check.

## Suggested decision logic

1. Confirm that baseline and candidate use the same RTL/netlist starting point, timing constraints, libraries and analysis settings.
2. Verify that each required stage completed successfully.
3. Compare setup and hold metrics together; never approve a setup-only improvement.
4. Check electrical and physical violations, including new violations introduced by the candidate.
5. Review the changed cells/nets and retain the reports that explain the result.
6. Mark the candidate **accepted**, **rejected** or **inconclusive**. Use *inconclusive* when required evidence is missing.

## Important distinctions

- **Improvement** means a metric moved in the desired direction; it does not automatically mean the design passes.
- **Pass** means every required gate has evidence and satisfies the configured criteria.
- **Inconclusive** means the run or report set is incomplete, ambiguous or not comparable.

Thresholds must come from the design's constraints and project configuration. This document intentionally does not hard-code universal WNS, hold, area or DRC limits.
