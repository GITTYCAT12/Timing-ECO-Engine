# Timing ECO Candidate Selection

This guide makes candidate ranking explicit before changing a routed design. It is a decision aid, not a substitute for STA or physical signoff.

## 1. Start with the path evidence

For each violating path, record:

- Startpoint and endpoint
- Setup or hold check and slack
- Cell delay versus net delay
- High-fanout nets, transition violations and capacitance
- Whether the path is constrained by the intended clock and exceptions

Do not select an ECO from WNS alone. WNS identifies the worst endpoint but does not explain the cause or the number of affected paths.

## 2. Match the action to the cause

| Observed evidence | Candidate to evaluate | Main trade-off |
|---|---|---|
| High net delay and high fanout | Buffer insertion or fanout restructuring | Area, routing demand and added stages |
| High cell delay on a combinational cell | Upsize that combinational cell | Area, input capacitance and upstream delay |
| Long logic depth | RTL or synthesis-level restructuring | Functional risk and implementation effort |
| Setup improves but hold slack shrinks | Reject or revise the candidate; evaluate hold repair | Added delay cells, area and routing |
| Congestion or detoured nets dominate delay | Placement/routing investigation | May require broader physical changes |
| Clock skew dominates the check | Review CTS and clock constraints | Clock-tree impact and signoff complexity |

These are hypotheses to test, not automatic prescriptions. A buffer is not guaranteed to improve a path if the added stage or placement worsens delay.

## 3. Rank candidates consistently

Use a common evidence sheet for each candidate:

- Expected setup-slack improvement
- Expected impact on hold slack
- Cell area delta
- Fanout, slew and capacitance changes
- Routing/congestion risk
- Number of affected critical endpoints
- Reversibility and validation cost

Prefer a small, explainable change with measurable benefit over a broad edit whose effect cannot be isolated.

## 4. Keep experiments comparable

Capture baseline metrics before the ECO. Change one candidate or one tightly related group at a time. Run the same implementation and analysis stages for baseline and candidate, using the same constraints, libraries and parasitic methodology.

Record both improvements and regressions. A better WNS is not sufficient if hold, DRC or another required signoff check fails.

## 5. Decision

- **Accept for further evaluation:** setup improves and no required check regresses beyond its allowed limit.
- **Revise:** setup benefit is plausible, but hold, slew, capacitance, area or congestion needs another iteration.
- **Reject:** no repeatable timing benefit, a hard limit is violated, or the change is not supported by path evidence.

Final acceptance requires the repository's post-ECO signoff flow and review of its generated reports.
