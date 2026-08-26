# Contributor instructions

This repository is an installable Codex FPGA workflow, not an FPGA product design.

- Keep public content free of customer names, private paths, secrets, board-specific facts, and historical pass claims.
- Preserve the single-writer model, read-only reviewer independence, evidence labels, and safe-state boundaries.
- Do not weaken CDC/RDC, timing, electrical, licensing, or independent-sign-off gates without an explicit rationale and review.
- Use minimal diffs. Do not edit generated EDA databases or add vendor-generated IP output.
- Run `scripts/validate-package.ps1` before submitting a change.
- Documentation and examples must mark unexecuted checks as `NOT RUN` or `UNVERIFIED`.
- Keep generated-project desktop runtime independent of Codex-private PowerShell. Formal native build state belongs in `project/par`, formal ModelSim/Questa state belongs in `simulation/work`, and Codex diagnostic copies belong in `codex_out`.
