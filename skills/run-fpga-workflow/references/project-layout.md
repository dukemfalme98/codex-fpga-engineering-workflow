# Formal FPGA project layout

The scaffold creates a clean, vendor-specific project. Optional directories are created only when requested.

```text
<project-root>/
|-- README.md
|-- AGENTS.md
|-- .gitignore
|-- document/
|-- project/
|   |-- rtl/
|   |-- ip/                    optional
|   |-- sdc/
|   |-- par/
|   `-- script/
|       |-- run.bat
|       |-- run.ps1
|       |-- preflight.ps1
|       |-- update_filelist.ps1
|       |-- src_list.txt
|       |-- product_list.txt
|       |-- ip_list.txt
|       |-- compile_order.txt
|       |-- include_dirs.txt
|       |-- toolchain.local.psd1.example
|       `-- <one selected vendor adapter>
|-- simulation/
|   |-- tb/
|   |   `-- case/
|   `-- script/
|       |-- run.bat
|       |-- run.ps1
|       |-- src_list.txt
|       |-- model_list.txt
|       |-- ip_list.txt
|       |-- compile_order.txt
|       |-- include_dirs.txt
|       `-- <one selected vendor simulator adapter>
|-- linter/
|   |-- lint_bb/               optional
|   `-- script/
|       |-- run.bat
|       |-- run.ps1
|       `-- lint_list.txt
|-- release/
|   |-- golden/                optional
|   `-- output/
`-- codex_out/                 generated and ignored
```

## One-click contract

The user double-clicks one of the three `run.bat` files. Each wrapper anchors itself with `%~dp0`, invokes its neighboring PowerShell runner, updates deterministic file lists, runs preflight, creates a unique job below `codex_out`, invokes only the selected vendor adapter, preserves the exit code, and prints `PASS`, `FAIL`, or `UNVERIFIED`.

Canonical lists separate build product HDL (`project/script/src_list.txt`), simulation product HDL after model substitution (`simulation/script/product_list.txt`), vendor IP configs, testbench HDL, simulation-only models, includes/defines, and lint HDL. Generated lines are project-relative, forward-slash normalized, stable, unique, and checked for existence. Headers become include directories instead of independent compile units. Export authoritative product and simulation order to the neighboring `compile_order.txt`; dependency-sensitive package/VHDL sets fail closed when that order is absent. Root-level vendor IP HDL is accepted only as a config-matched `<name>.*` synthesis file or `<name>_sim.*` replacement model; matching design units are removed from the simulation product view so the two implementations are never compiled together. Otherwise place HDL explicitly under `project/ip/synth` or `project/ip/sim`.

Passing jobs may remove large work/database caches while retaining commands, versions, logs, reports, result JSON, and proof packets. Failed jobs retain their complete reproducer. Cleanup is allowed only after resolving and verifying that the target is strictly beneath `codex_out`.
