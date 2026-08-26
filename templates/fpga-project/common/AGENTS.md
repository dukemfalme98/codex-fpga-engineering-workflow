# FPGA project instructions

- Treat project specifications, target files, constraints, register sources, and current reports as authoritative.
- Use one product-source writer per checkout and keep review roles read-only.
- For synchronous changes, reason from pre-edge state through RHS evaluation, NBA commit, combinational settling, and the next sampling edge.
- Preserve latency, throughput, backpressure, data/sideband alignment, reset, flush, abort, and error behavior unless the approved contract changes them.
- Put Codex-generated process files only under `codex_out/`; never commit vendor databases or fabricated vendor models.
- Keep generated standard directories canonical: `project/`, `project/par/`, `project/script/`, `simulation/`, `linter/`, `release/`, and `codex_out/`. Do not create numbered variants such as `project2`, `par2`, or `script2`.
- Keep visible `script/` roots clean. Put PowerShell helpers under `script/ai_run/` and keep `run.bat` anchored with `%~dp0`.
- Run only project-confirmed commands. Unexecuted checks are `NOT RUN`; missing or unread evidence is `UNVERIFIED`.
- Keep smoke compile/elaborate/run evidence lightweight and label it `DIAGNOSTIC_ONLY`; activate full simulation, formal, CDC/STA, or release gates only for claims that depend on them.
