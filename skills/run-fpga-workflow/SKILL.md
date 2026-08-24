---
name: run-fpga-workflow
description: Evidence-driven FPGA/SoC FPGA workflow for architecture, RTL, registers, CDC/RDC, timing, vendor platforms, verification, board evidence, single-writer implementation, and independent sign-off. Use only for FPGA and directly related hardware/firmware/verification tasks.
---

# FPGA multi-role engineering workflow

Use the main conversation as coordinator. Invoke only roles relevant to the task. The goal is a traceable engineering result, not maximum agent count.

## 1. Authorization and mode

Writing requires an explicit request to implement, change, fix, or build. Risk never expands authorization.

- `ANALYZE`: read-only analysis, diagnosis, design, or review.
- `QUICK`: authorized, small, interface-preserving, single-clock, low-risk change.
- `FULL`: authorized new RTL, CDC/RDC, regmap/IRQ/DMA, constraints, vendor IP, external timing, high-energy control, or significant refactor.

Do not use QUICK for clock/reset crossings, published interfaces, external timing, vendor IP/constraints, safety/energy outputs, possible data loss, or critical ambiguity. Read [task profiles](references/task-profiles.md) for detailed routing.

## 2. Establish the evidence baseline

Read all applicable `AGENTS.md` files, requirements, project SSOT, interface and register sources, relevant RTL/constraints/tests/scripts, installed tool versions, existing reports, and current diff. Protect user work. Label facts `CONFIRMED`, `INFERRED`, or `UNKNOWN`. Never invent device/package, pin, voltage, clock/reset, polarity, address, protocol, IP configuration, command, or result.

## 3. Lead and parallel read-only pre-review

The `fpga_architect` defines scope/non-goals, microarchitecture, data flow, throughput/latency/resource budgets, clock/reset impact, interfaces, Requirement -> Design -> Test traceability, ownership, and acceptance. Then run only relevant read-only specialists in parallel:

- verification risk: `verification_engineer` in read-only planning mode;
- CDC/RDC, clocks, constraints, STA: `fpga_cdc_timing_reviewer`;
- CSR/commands/IRQ/DMA/firmware contract: `fpga_interface_architect`;
- primitives/IP/wrappers/targets: `fpga_vendor_platform_reviewer`;
- electrical evidence and bring-up: `fpga_board_validation_engineer`;
- cross-domain architecture: `system_architect` and `hardware_datasheet` when needed.

Wait for relevant reviews, expose conflicting evidence, and create one approved implementation contract. Do not resolve conflicts by vote.

## 4. Single-writer implementation

Skip in ANALYZE. In one checkout, only `fpga_engineer` writes product RTL, constraints, platform wrappers, regmap implementation, or FPGA build scripts. Freeze and summarize its diff when done. If required, run `embedded_engineer` later as a separate firmware-only batch, then `verification_engineer` as a separate test-asset-only batch. No overlapping writers in the same checkout. Parallel writers require explicit user approval, disjoint files, separate worktrees/branches, and integration into one reviewable diff.

### Stable-diff checkpoint supervision

For long or high-risk implementations, supervise near-real-time through stable checkpoints, not character-by-character monitoring:

1. writer completes a coherent slice and stops;
2. coordinator freezes a diff/hash snapshot;
3. relevant read-only specialists review that exact snapshot in parallel;
4. coordinator consolidates evidence and conflicts into one repair list;
5. the same writer repairs; affected reviewers re-check.

Recommended checkpoints are interface skeleton, FSM/error recovery, datapath/FIFO/RAM/DSP, CDC/reset, regmap/IRQ/DMA, vendor wrapper/constraints, and integrated diff. BLOCKER/HIGH findings stop the next slice. The final reviewer remains independent and does not coach implementation.

## 5. Isolated validation

Run only confirmed project commands. Each parallel EDA job gets a unique output directory, simulation library, project database, IP/cache, seed, and report path, for example `out/codex/<run-id>/<target>/<job-id>/`. Never share Vivado runs, Quartus databases, ModelSim/Questa work libraries, IP generation directories, or report files. If a tool writes in-place and cannot be isolated, run serially.

Capture exact command, tool/version, exit status, seed, significant warnings, and report path. Unexecuted or unread checks are `NOT RUN`/`UNVERIFIED`. Simulation cannot replace structural CDC/RDC or implementation STA evidence.

## 6. Re-review and sign-off

After all write batches, re-run affected specialists read-only against the integrated diff and new evidence; always include verification review. Then invoke a separate `fpga_reviewer`. Use `independent_reviewer` for cross-domain or safety-critical releases. Reviewers return `PASS`, `PASS WITH CONDITIONS`, or `FAIL` with BLOCKER/HIGH/MEDIUM/LOW findings. Missing critical requirements/evidence, failed regressions, or BLOCKER/HIGH findings prevent completion. Reviewers never fix code; repairs return to the appropriate sequential writer and require re-review.

## 7. Safety and evidence boundaries

Physical wiring, power-up, download, motion, heat, laser, relay, high voltage, and other high-energy operations are user actions with prerequisites and stop conditions. Reset, unconfigured, clock-loss, communication-loss, watchdog, and fault states must be safe. Keep simulation, static reports, instrument measurements, and actual board results distinct.

## 8. Improvement audit

After core validation and sign-off, do a small improvement audit without expanding scope. Follow [improvement policy](references/improvement-policy.md) and use the blank [evidence ledger](references/improvement-evidence.md). Do not promote guesses, one-off workarounds, secrets, private paths, project-specific electrical/register facts, or stale pass claims.

## Minimum orchestration

- ANALYZE: architect -> relevant specialists -> independent reviewer only when a sign-off verdict is requested.
- QUICK: architect -> FPGA writer -> verification review -> final reviewer.
- FULL: architect -> relevant parallel pre-review -> sequential writers -> isolated validation -> parallel re-review -> final reviewer -> cross-domain reviewer when required.

Final output must state mode/scope, assumptions/unknowns, roles and conclusions, changed files by write batch, behavior/latency/throughput, clock/reset/CDC/RDC, registers/IRQ/DMA/firmware, vendor/board impact, commands and actual evidence, sign-off verdict, remaining risks, and user board actions.
