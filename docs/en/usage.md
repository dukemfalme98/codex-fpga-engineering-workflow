# Usage

ANALYZE prompt:

```text
Use $run-fpga-workflow to analyze this CDC issue read-only. Inventory clocks and crossings, inspect constraints and report evidence, and do not claim PASS without the reports.
```

QUICK prompt:

```text
Use $run-fpga-workflow in QUICK mode for this single-clock, interface-preserving RTL fix. Protect the current diff, make the minimum change, run existing tests, and obtain independent review.
```

FULL prompt:

```text
Use $run-fpga-workflow in FULL mode for this async streaming block. Freeze interface, throughput, latency, reset, and error contracts; pre-review CDC and verification; use one product writer, isolated validation, and independent sign-off.
```

For long work, request stable checkpoints at interface, FSM, datapath, crossing/constraints, and integration boundaries. Timing claims require synthesis/implementation STA evidence.
