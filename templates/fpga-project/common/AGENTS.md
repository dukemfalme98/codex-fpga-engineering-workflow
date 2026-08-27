# FPGA project instructions

- Treat project specifications, target files, constraints, register sources, and current reports as authoritative.
- Use one product-source writer per checkout and keep review roles read-only.
- For synchronous changes, reason from pre-edge state through RHS evaluation, NBA commit, combinational settling, and the next sampling edge.
- Preserve latency, throughput, backpressure, data/sideband alignment, reset, flush, abort, and error behavior unless the approved contract changes them.
- Put formal vendor build state under `project/par`, formal ModelSim/Questa state under `simulation/work`, and Codex-created diagnostic variants under `codex_out`; never commit vendor databases or fabricated vendor models.
- Keep generated standard directories canonical: `project/`, `project/par/`, `project/script/`, `simulation/`, `linter/`, `release/`, and `codex_out/`. Do not create numbered variants such as `project2`, `par2`, or `script2`.
- Keep visible `script/` roots clean. Generated-project runtime uses `%~dp0`-anchored BAT plus confirmed native Tcl/DO/CLI and must not require Codex-private PowerShell.
- Run only project-confirmed commands. Unexecuted checks are `NOT RUN`; missing or unread evidence is `UNVERIFIED`.
- Keep smoke compile/elaborate/run evidence lightweight and label it `DIAGNOSTIC_ONLY`; activate full simulation, formal, CDC/STA, or release gates only for claims that depend on them.
- When this scaffold becomes a formal target, create one real depth-0 launcher at `project/par/__PROJECT_NAME__.xpr`, `.pds`, or `.al`. Do not place it below `par/vivado_project`, `par/build`, or a random job directory, and do not fabricate a marker before target facts are confirmed.
- Configure a tool root or vendor environment and invoke canonical commands through the BAT process PATH. Do not hard-code absolute executable files or persist PATH changes.
