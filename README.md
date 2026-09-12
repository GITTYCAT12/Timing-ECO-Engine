# Timing-ECO-Engine

An explainable post-route timing ECO workflow built around OpenSTA/OpenROAD. The engine turns timing evidence into ranked ECO candidates, generates implementation actions, and validates the result with post-ECO timing checks.

## Development evidence

This repository intentionally keeps a **transparent development evidence board** derived from the six terminal/report screenshots supplied during development. It makes the cut-to-cut flow understandable even to someone who is not deeply familiar with physical design.

![Timing ECO development evidence](docs/evidence/timing-eco-development-evidence.svg)

### 1. ECO candidate generation — what the first screenshot says

The engine produced a ranked list of possible ECO actions. `_6529_` and `_3280_` were identified as high-impact fanout-related targets, while `_5084_`, `_5317_`, and `_5323_` were proposed for cell upsizing. The important point is that the tool does not simply say “timing is bad”; it points to concrete implementation targets and gives an estimated timing benefit and score.

**For a non-VLSI reader:** this is the “what should I change?” stage. The savings shown here are **estimates**, not measured results.

### 2. Baseline timing — what the second screenshot says

The starting reports show **WNS = -1.66 ns** and **TNS = -33.81 ns**.

**In simple terms:** the design starts with setup-timing failures. WNS is the worst timing margin of the design; TNS is the total accumulated negative setup slack. These numbers establish the “before” state against which the ECO is judged.

### 3. Closed-loop validation — what the third screenshot says

This is the most important cut-to-cut evidence. The reported before/after comparison is:

| Metric | Baseline | Post-ECO | Change |
|---|---:|---:|---:|
| WNS | -1.660 ns | -1.200 ns | +0.460 ns |
| TNS | -33.810 ns | -21.290 ns | +12.520 ns |
| Setup-violating paths | 50 | 0 | 50 resolved |
| Worst data-hold slack | +0.040 ns | +0.040 ns | no change |

**For a non-VLSI reader:** this is the “did the physical implementation actually get better?” stage. The screenshot shows the ECO improving setup timing while the reported normal data-path hold slack stays positive.

The screenshot also contains a negative **recovery/removal** value. That is an asynchronous timing check and is **not the same as a data-path hold violation**. The project therefore reports it separately instead of incorrectly calling it a hold failure.

### 4. Strategy comparison — what the fourth screenshot says

Four ECO-selection strategies were exercised over four trials each: `Greedy_WorstSlack`, `RuleBased_Heuristic`, `ECO_Copilot_Balanced`, and `ECO_Copilot_HoldAware`. The table reports the best observed WNS/TNS improvement, post-ECO hold value, and number of accepted trials.

The values are similar across the strategies in this particular benchmark. That result is intentionally shown rather than hidden: it is evidence from this experiment, **not a claim that the strategies are universally equivalent**.

### 5. Automated regression tests — what the fifth screenshot says

The command `python -m unittest discover tests -v` reports **4 tests passed / 4 tests passed overall**.

The tests protect implementation correctness, including preservation of the high-fanout driver information, keeping buffer insertion separate from cell replacement, and preventing asynchronous recovery/removal checks from being mistaken for normal data hold.

**Why this matters:** a timing tool should not be trusted only because it produced a better number. The tests help catch mistakes in the reasoning and implementation around that number.

### 6. ML scoring — what the sixth screenshot says

The ML scorer reports a Random Forest trained from **16 independent closed-loop trials**, using a **12/4 train/test split**. The example prediction uses a candidate with **fanout 75** and **159.54 pF** load capacitance and predicts approximately **+0.4561 ns ΔWNS**, with a reported hold-safety confidence of `1.0`.

There is one issue deliberately called out in the evidence: the screenshot displays `6.0033 ns` together with `(3.3 ps)` for the held-out MAE. Those units cannot both describe the same numeric value. The screenshot is retained for transparency, but the smaller unit should **not** be claimed until the underlying metric calculation/reporting is rechecked.

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

Numbers shown in the evidence board are development evidence. A result is treated as a final benchmark claim only after the exact ECO is reproduced from a clean baseline and checked for setup, data hold, asynchronous recovery/removal, routing, and design-rule side effects.
