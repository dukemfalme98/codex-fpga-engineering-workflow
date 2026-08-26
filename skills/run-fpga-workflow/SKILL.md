---
name: run-fpga-workflow
description: Evidence-driven FPGA/SoC FPGA workflow for architecture, cycle-accurate RTL, registers, CDC/RDC, timing, three-vendor toolflows, verification, board evidence, single-writer implementation, and independent sign-off. Use only for FPGA and directly related hardware/firmware/verification tasks.
---

# FPGA multi-role engineering workflow

Use the main conversation as coordinator. Invoke only roles relevant to the task. The goal is a traceable engineering result, not maximum agent count.

## 1. Authorization and mode

Writing requires an explicit request to implement, change, fix, or build. Risk never expands authorization.

- `ANALYZE`: read-only analysis, diagnosis, design, or review.
- `QUICK`: authorized, small, interface-preserving, single-clock, low-risk change.
- `FULL`: authorized new RTL, pipeline/FIFO/RAM behavior, CDC/RDC, regmap/IRQ/DMA, constraints, vendor IP, external timing, high-energy control, or significant refactor.

Do not use QUICK for clock/reset crossings, published interfaces, observable latency, external timing, vendor IP/constraints, safety/energy outputs, possible data loss, or critical ambiguity. Read [task profiles](references/task-profiles.md) for detailed routing.

## 2. Establish one evidence baseline

Read applicable `AGENTS.md` files, requirements, project SSOT, interface/register sources, RTL, constraints, tests, scripts, installed tool versions, current reports, and the current diff. Protect user work. Label facts `CONFIRMED`, `INFERRED`, or `UNKNOWN`. Never invent device/package, pin, voltage, clock/reset, address, protocol, IP configuration, vendor command, or result.

Create only the artifacts needed to support the requested claim under `codex_out/<run-id>/`. A small diagnostic or smoke run may need only a command/result record; a functional, timing, CDC, formal, or release acceptance claim needs the applicable stable artifacts:

- `task-contract.json`: scope, immutable behavior, authorization, and acceptance evidence;
- `snapshot-manifest.json`: revision, dirty-diff hash, source hashes, target, parameters, defines, and constraints;
- `impact-manifest.json`: affected modules/processes, clock/reset domains, forward data, reverse backpressure, sidebands, shared state, constraints, and tests;
- `cycle-contract.json`: accepted/completed edges, latency or window, throughput, alignment, stall, reset, flush, abort, and error behavior;
- `verification-plan.json`: Requirement -> Test -> Checker -> Cover and model independence;
- `run-manifest.json`: exact command, cwd, tool/version, target, seed, exits, libraries, logs, waves, and reports;
- `simulation-evidence.json`: cycle-indexed expected/observed behavior, first failure, checker drain, negative canaries, and proof packets;
- `findings-ledger.json`: stable IDs, snapshot, owner, status, evidence, repair, and reruns.

Use the templates in [workflow artifacts](references/workflow-artifacts.md). Do not create a full proof packet merely because the task is small. Artifacts organize evidence; they never replace source, elaboration, simulation, CDC/RDC, STA, or board results.

## 3. Lead, bounded impact, and specialist routing

The `fpga_architect` freezes the task, impact, and cycle contracts, Requirement -> Design -> Test traceability, ownership, and acceptance. Bound temporal review to one primary clock domain and one transaction/dataflow impact cone, including reverse `ready`/backpressure and aligned data, valid, last/keep, ID/tag, error, enable, reset, stall, flush, abort, FSM, counter, FIFO, and RAM state.

Return `NEEDS_PARTITION` rather than truncating when the cone crosses clock domains, touches shared state or common packages/macros, includes an unknown vendor black box, lacks stable unchanged boundaries, or exceeds the review context. Partition by domain, transaction, or shared resource and merge findings through one ledger. Read [temporal evidence](references/temporal-evidence.md) for the cycle and simulation protocol.

Run only relevant read-only specialists in parallel:

- CDC/RDC, clocks, constraints, STA: `fpga_cdc_timing_reviewer`;
- CSR/commands/IRQ/DMA/firmware contract: `fpga_interface_architect`;
- primitives/IP/wrappers/three-vendor target: `fpga_vendor_platform_reviewer`;
- electrical evidence and bring-up: `fpga_board_validation_engineer`;
- exact manual/model evidence: `hardware_datasheet`;
- cross-domain architecture: `system_architect` when needed;
- bounded cycle/simulation evidence: shadow `fpga_temporal_evidence_reviewer` in `STATIC_CYCLE`, `SIMULATION_EVIDENCE`, or `COMBINED` mode.

The temporal reviewer is the 13th role and is initially `SHADOW`: it is strictly read-only, does not coach repairs, does not replace CDC/RDC or STA, and does not issue the overall final verdict. QUICK does not invoke it by default. See [shadow rollout](references/shadow-rollout.md).

## 4. Single-writer implementation

Skip in ANALYZE. In one checkout, only `fpga_engineer` writes product RTL, constraints, platform wrappers, regmap implementation, or FPGA build scripts. Freeze and summarize its diff when done. If required, run `embedded_engineer` later as a firmware-only batch, then `verification_engineer` as a test-asset-only batch. No overlapping writers in one checkout.

Repairs that answer existing review findings cite their stable IDs. Report a Cycle Contract Delta and affected cone only when observable cycle behavior changes. Verification authors cannot independently sign evidence produced by models/checkers they created or changed. Reviewers never edit findings away.

When the user requests a minimal or narrowly scoped source edit, the product writer briefly states the supported root cause, why the selected location is the narrowest correct owner, what interface/cycle/clock/reset/error behavior remains unchanged, and the smallest useful verification before editing. This is reasoning guidance, not an extra approval gate. Pause only when the proposed change would alter a published interface, observable latency or throughput, clock/reset/CDC behavior, error semantics, electrical safety, or another user-controlled contract.

For long/high-risk work, use stable checkpoints: stop the writer after a coherent slice; freeze diff/hash; have relevant read-only specialists review that exact snapshot; consolidate one repair list; return it to the owning writer; recheck only affected evidence. The final reviewer remains outside implementation coaching.

## 5. Deterministic project toolflow

Generated and formally normalized projects use the exact canonical directories `project/`, `project/par/`, `project/script/`, `simulation/`, `linter/`, `release/`, and `codex_out/` as described in [project layout](references/project-layout.md). Never generate numbered standard directories such as `project2`, `par2`, or `script2`. Existing foreign projects may be inspected or imported, but normalized output uses the canonical names. Keep each visible `script/` directory clean: `run.bat`, settings, canonical lists, and vendor Tcl/do files stay at its root; PowerShell helpers, only when needed, live under `script/ai_run/`. All Codex-generated process files go under project-root `codex_out`; do not use a second default output root or scatter work libraries/databases through source directories.

Automatic vendor selection supports only:

- `project/par/*.xpr` -> AMD/Xilinx Vivado;
- `project/par/*.pds` -> Pango PDS;
- `project/par/*.al` -> Anlogic TD;
- fallback `*.xci` -> Xilinx, `*.idf` -> Pango, and `*.ipc` -> Anlogic only with Anlogic/TD/EG text markers.

Multiple supported vendors, unsupported vendor project markers, or missing evidence fail closed and prompt the user. A generated standard project contains exactly one selected adapter. Use [vendor adapters](references/vendor-adapters.md) and the deterministic helpers in `scripts/`; do not guess commands, fabricate primitive models, silently substitute versions, or modify global tool/library mappings.

Each `run.bat` locates itself with `%~dp0`, updates deterministic RTL/IP/TB file lists, runs preflight, creates an isolated job under `codex_out`, invokes the selected adapter, and returns a meaningful exit code and evidence summary. An official library recipe may compile only for an exact supported vendor/tool/family/simulator tuple into `codex_out/_cache/simlibs`; otherwise fail with a preparation checklist.

## 6. Proportionate evidence profiles

Choose the profile from the claim, not from a desire to maximize process:

- `DIAGNOSTIC_SMOKE`: source discovery, compile, elaboration, bounded run, log collection, or path/tool diagnosis. Record the exact command, tool/version when available, exit codes, important warnings, and output paths. An independent model, full scoreboard, and negative canary are optional. The result is `DIAGNOSTIC_ONLY` or `INCONCLUSIVE`, never `SIMULATION_PASS`.
- `FUNCTIONAL_ACCEPTANCE`: activate the complete simulation-evidence rules below because the result will be used to accept DUT behavior.
- `SPECIALIST_ACCEPTANCE`: activate only the evidence family being claimed—formal, CDC/RDC, implementation/STA, electrical, or release—and keep all other evidence levels `NOT RUN` or `UNVERIFIED`.

The hard gates remain constant: one writer per checkout, no author self-signing their changed acceptance assets, no fabricated evidence, no weakening CDC/electrical safety, and failure routing to the correct owner.

## 7. Simulation evidence integrity

Verification derives from requirements and independent primary evidence, not current DUT behavior. Non-trivial device/protocol models require a [Model Card](references/model-card.md). Do not copy DUT RTL into the reference model, read internal DUT state to change expectations, adapt expected latency to observed implementation, or claim a forced/bypassed function was verified.

For `FUNCTIONAL_ACCEPTANCE`, scoreboards are cycle-indexed: record the accepted input edge and tag, due cycle/window, expected data/sidebands/error, observed edge, and early/late/drop/duplicate/reorder result. Critical acceptance checkers need an isolated negative canary. A `$stop`, clean log, or waveform without an independent checker is not proof of functional acceptance.

Classify failures before routing repairs:

`DUT_FAIL`, `TESTBENCH_FAIL`, `REFERENCE_MODEL_FAIL`, `ASSERTION_FAIL`, `SCRIPT_PATH_FAIL`, `COMPILE_ELAB_FAIL`, `TOOL_ENV_FAIL`, `VENDOR_LIBRARY_FAIL`, `TIMEOUT_HANG`, or `INCONCLUSIVE`.

Only `DUT_FAIL` routes directly to product RTL. Manual waveform evidence that contradicts automation revokes `SIMULATION_PASS` and first repairs/reviews the verification asset. Simulation never signs CDC/RDC or STA.

## 8. Bounded repair and independent sign-off

Use stable finding IDs and these statuses: `OPEN`, `FIXED_PENDING_REVIEW`, `VERIFIED_CLOSED`, `DUPLICATE`, `DISPUTED`, `NOT_APPLICABLE`, and `ACCEPTED_RISK`. Writers do not close their own findings. No new diff or evidence means a finding cannot be renamed and reopened as progress.

Allow at most three automatic repair/re-review rounds. At the first no-progress round, stop blind editing and rebuild the root cause with the architect and affected specialists. At two consecutive no-progress rounds, or after round three with an open BLOCKER/HIGH, stop and report the evidence boundary. Progress means fewer open BLOCKER/HIGH findings, a later first-failure point, an explainable changed failure signature, or added required evidence—not rewording or unrelated diffs.

After all write batches, re-run only affected specialists read-only against the same integrated snapshot. Then invoke separate `fpga_reviewer` when an implemented change or acceptance verdict requires it; add `independent_reviewer` for cross-domain or safety-critical releases. When formal verification is actually used for acceptance, `fpga_reviewer` independently audits the property/harness identity, assumptions, bounds/depth, vacuity and cover evidence, counterexamples, abstractions/black boxes, tool command/version, and author independence. Do not add a formal gate when formal evidence is not part of the requested claim. Shadow findings are specialist input and must be resolved by evidence, not automatically promoted or ignored. Missing critical evidence, failed regressions, disputed blocking findings, or open BLOCKER/HIGH prevents unconditional completion.

## 9. Private fault-library hook and improvement

The workflow improves through curated evidence, not model-weight retraining. A private after-sales fault library may be configured outside the public package. Query it only as a diagnostic lead, store sanitized match output in `codex_out/<run-id>/knowledge/`, and revalidate vendor/tool/version, subsystem, clock/reset, interface, trigger, and counterexamples against the current project. Never put private source documents, customer data, paths, or project facts in the public package, Memory, or global prompts.

Read [private fault library](references/private-fault-library.md) for schema, statuses, and the empty/config/query hook. Only cases with confirmed root cause and verified repair may become reusable; board-confirmed status is recorded separately. Follow [improvement policy](references/improvement-policy.md) and use the blank [evidence ledger](references/improvement-evidence.md).

## Minimum orchestration

- ANALYZE: architect -> relevant specialists -> final reviewer only for a requested sign-off verdict.
- QUICK: architect -> FPGA writer -> verification review -> final reviewer; temporal shadow off by default.
- FULL: architect and stable artifacts -> relevant parallel pre-review -> sequential writers -> isolated validation -> affected specialists and optional temporal shadow -> final reviewer -> cross-domain reviewer when required.

Final output states mode/scope, assumptions/unknowns, roles and conclusions, changed files by write batch, behavior/latency/throughput, clock/reset/CDC/RDC, registers/IRQ/DMA/firmware, vendor/board impact, commands and actual evidence, sign-off verdict, remaining risks, and user board actions. Unexecuted checks are `NOT RUN`; unavailable or unread evidence is `UNVERIFIED`.
