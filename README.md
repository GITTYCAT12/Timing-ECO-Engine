# Timing-ECO-Engine

An explainable post-route timing ECO workflow built around OpenSTA/OpenROAD. The engine turns timing evidence into ranked ECO candidates, generates implementation actions, and validates the result with post-ECO timing checks.

## Development evidence

This repository intentionally keeps a small set of terminal/report screenshots as **engineering evidence**. They show the workflow from candidate generation to validation instead of presenting only a polished final number.

> **Important:** The screenshots are historical evidence from the development run. The repository distinguishes measured results from estimates, and asynchronous recovery/removal checks from normal data-path hold checks.

### 1. ECO candidate generation

![ECO candidate ranking](docs/evidence/01-eco-candidate-ranking.jpg)

The tool identifies concrete cells/nets for possible ECO action. In this run, `_6529_` and `_3280_` were identified as high-impact fanout-related targets, while `_5084_`, `_5317_`, and `_5323_` were proposed for cell upsizing. The `Est. Saving` column is a **prediction/estimate**, not a measured post-ECO result.

### 2. Baseline timing evidence

![Baseline timing](docs/evidence/02-baseline-timing.jpg)

This terminal output records the starting point: **WNS = -1.66 ns** and **TNS = -33.81 ns**. In simple terms, the design has setup-timing problems before the ECO; WNS is the worst individual timing margin and TNS represents the accumulated negative setup slack.

### 3. Closed-loop validation

![Closed-loop validation](docs/evidence/03-closed-loop-validation.jpg)

This is the key screenshot for demonstrating cut-to-cut implementation. It compares the design before and after the ECO: WNS improves from **-1.660 ns to -1.200 ns**, TNS improves from **-33.810 ns to -21.290 ns**, and the reported setup-violating paths go from **50 to 0**. The reported worst data-hold slack remains **+0.040 ns**, so the normal data-path hold check is not negative in this report.

The screenshot also shows a negative recovery/removal number. That is an **asynchronous timing check**, not the same thing as a data-path hold violation; the project therefore treats it separately in validation.

### 4. Strategy comparison

![Strategy comparison](docs/evidence/04-strategy-comparison.jpg)

The experiment table compares four ECO-selection strategies across four trials each. It reports the best observed WNS/TNS improvement, post-ECO hold value, and accepted trials. The equal values across strategies are retained as evidence rather than hidden; they should be interpreted as the outcome of this particular benchmark set, not as proof that all strategies are universally equivalent.

### 5. Automated regression tests

![Regression tests](docs/evidence/05-regression-tests.jpg)

The test run shows **4/4 integrity tests passing**. These checks protect important implementation contracts, including preserving the high-fanout driver information, keeping buffer insertion distinct from cell replacement, and not confusing asynchronous removal checks with data hold.

### 6. ML scoring evidence

![ML scoring](docs/evidence/06-ml-scoring.jpg)

This screenshot shows the ML scorer being trained on **16 independent closed-loop trials**, with a **12/4 train/test split** and a held-out timing error report. The test prediction shown below is an example of the model's output for a candidate with fanout 75 and 159.54 pF load capacitance.

**Reproducibility note:** the displayed metric text contains an apparent unit/format inconsistency (`6.0033 ns` alongside `3.3 ps`). It is kept visible because the goal of this evidence section is transparency. The implementation should not claim the smaller unit until the underlying metric calculation/reporting is rechecked.

## End-to-end idea

```text
Post-route STA
     |
     v
Parse timing paths + electrical characteristics
     |
     v
Violation fingerprint / root-cause classification
     |
     v
Generate ECO candidates
     |
     v
Rank by expected timing benefit + physical risk
     |
     v
Apply targeted ECO
     |
     v
Re-place / re-route / re-estimate parasitics
     |
     v
Run post-ECO STA + hold/DRC checks
     |
     v
Accept / reject + record the experiment
```

The goal is not to replace the physical-design tool. The goal is to make the engineer's ECO decision process explicit, inspectable, and repeatable.

## Scope

Current focus: setup-timing ECO analysis, targeted buffer/rebuffer concepts, cell upsizing, closed-loop validation, experiment comparison, and optional ML-assisted scoring.

## Tooling

- OpenROAD / OpenSTA
- Python
- Tcl
- Verilog
- Docker
- Linux

## Evidence policy

Numbers shown in screenshots are not automatically treated as final benchmark claims. A result is considered final only after the exact ECO is reproduced from a clean baseline and checked for setup, data hold, asynchronous recovery/removal, routing, and design-rule side effects.
