# Temporal and simulation evidence

## Impact-cone boundary

Default review scope is one primary clock domain and one transaction/dataflow cone. Start at the last unchanged, contract-defined input boundary or register and stop at the first unchanged, contract-defined output boundary or register. Include reverse `ready`/backpressure and every aligned payload/control signal.

Return `NEEDS_PARTITION` for multiple domains, shared FIFO/RAM/arbiter/global reset, common package/function/macro fanout, unknown black-box timing, missing stable boundaries, or context truncation. Partition first; never infer the unseen remainder.

## Clock-edge reasoning

For each relevant edge, document:

1. pre-edge registers and stable inputs;
2. condition priority and RHS values, using old register state;
3. nonblocking-assignment commit;
4. post-edge register state;
5. combinational settling;
6. the next edge that can sample the result.

Use this table:

| Domain | Edge | Reset | Pre-edge state | Inputs | Event | RHS/priority | NBA next | Post-edge state | Stable output | Token/stage |
|---|---|---|---|---|---|---|---|---|---|---|

Track pipeline fill, steady state, bubbles, stall, resume, flush, drain, first/last transaction, FIFO simultaneous push/pop, RAM read latency/read-during-write, reset release, timeout, abort, and recovery.

## Simulation acceptance

A simulation pass requires the exact snapshot, compile/elaboration/run exits, test discovery and execution, enabled assertions, a drained scoreboard, cycle-indexed expected/actual comparisons, reviewed model provenance, and a negative canary for every critical checker. A clean console, `$stop`, or visual waveform alone is `INCONCLUSIVE`.

Validate the machine-readable record with `scripts/validate-simulation-evidence.ps1`; `SIMULATION_PASS` is rejected for zero tests, stale snapshots, non-zero phase exits, an undrained scoreboard, empty comparisons, missing or undetected canaries, or an empty proof packet.

If manual waveform inspection contradicts automation, revoke the pass, preserve the proof window, classify the verification-asset defect, repair the checker/model in its own write batch, and rerun independent evidence review.
