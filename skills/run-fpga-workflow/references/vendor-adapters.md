# Three-vendor adapter contract

Automatic selection is intentionally narrow.

| Evidence | Vendor |
|---|---|
| `project/par/*.xpr` | AMD/Xilinx Vivado |
| `project/par/*.pds` | Pango PDS |
| `project/par/*.al` | Anlogic TD |
| fallback `*.xci` | AMD/Xilinx |
| fallback `*.idf` | Pango |
| fallback `*.ipc` containing Anlogic, TD, or EG-family text | Anlogic |

Ignore `codex_out`, `release`, backups, old copies, and generated tool databases. Two detected vendors are `VENDOR_CONFLICT`; an Intel/Quartus or Lattice project marker is `UNSUPPORTED_VENDOR`; no evidence is `UNKNOWN_VENDOR`. All three fail closed and ask the user rather than choosing by file count or timestamp.

A formal generated project contains only one selected adapter. The adapter receives separate product, testbench, vendor-IP, simulation-model, include, define, and library inputs plus local tool configuration. Dependency-sensitive source sets require an exported authoritative `compile_order.txt`; the helper does not claim to infer arbitrary vendor project order. Formal build adapters write native state under `project/par`; formal ModelSim/Questa adapters write under `simulation/work`; Codex diagnostic variants write under `codex_out`. Adapters preserve exact tool exits and never modify global `PATH`, registry, simulator mappings, or source files. A zero tool exit is command completion, not report-based FPGA acceptance. Tool commands that are not confirmed by project evidence remain configurable and `UNVERIFIED`.

An official simulation-library recipe may run only for an exact, tested vendor/tool/family/simulator tuple. Codex-built cache libraries use a source-hashed key below `codex_out/_cache/simlibs`; a confirmed user-maintained compiled library may remain at its established location and be referenced only through a local simulator mapping. Without a recipe or official source, return `MISSING_VENDOR_LIBRARY` with a preparation checklist. Never fabricate a behavioral primitive or substitute a nearby version.

Generated-project desktop runtime uses `%~dp0`-anchored BAT plus confirmed vendor-native Tcl/DO/CLI. It must not require a `pwsh.exe` visible only inside Codex. Build defaults to a bounded compile checkpoint. Simulation defaults to the configured GUI and the same BAT supports `batch`. For Xilinx plus ModelSim/Questa, generate IP output products, export IP user/static files, inspect the actual Windows export artifact, and use a job-local `modelsim.ini`. Vivado can emit `.sh + compile.do` rather than `compile.bat`; the Windows wrapper must create required parent libraries, invoke the emitted compile DO, propagate compile failure, and never continue to load/run after that failure.
