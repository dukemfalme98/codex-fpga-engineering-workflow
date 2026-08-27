# Compatibility

Package version: **0.3.3**

## Package format

This release uses Codex plugin discovery through `.codex-plugin/plugin.json`, custom agents under `.codex/agents/`, and the canonical plugin skill under `skills/run-fpga-workflow/`. The installer deploys that skill to `.agents/skills/run-fpga-workflow/` for user or project use.

## Environment exercised on 2026-08-24

- Codex CLI: 0.147.0
- PowerShell: 7.6.4
- Git: 2.54.0.windows.1
- Operating system: Windows

Static package validation is included. The helpers support vendor detection for AMD/Xilinx Vivado, Pango PDS, and Anlogic TD; exact EDA commands and official libraries remain local project/tool-version facts. The native-runtime contract was exercised on Windows with Vivado 2020.2 and ModelSim SE-64 2020.4 using an isolated, non-shipped FPGA fixture. A separate Vivado canary confirmed a depth-0 `project/par/<name>.xpr` with same-name direct sibling databases. Version 0.3.3 also requires process-local PATH setup and canonical command-name invocation instead of embedded absolute executable files. This does not validate every target, licensed vendor flow, DUT function, STA, CDC/RDC, bitstream, or board result.
