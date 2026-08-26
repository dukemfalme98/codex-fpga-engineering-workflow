# Compatibility

Package version: **0.3.1**

## Package format

This release uses Codex plugin discovery through `.codex-plugin/plugin.json`, custom agents under `.codex/agents/`, and the canonical plugin skill under `skills/run-fpga-workflow/`. The installer deploys that skill to `.agents/skills/run-fpga-workflow/` for user or project use.

## Environment exercised on 2026-08-24

- Codex CLI: 0.147.0
- PowerShell: 7.6.4
- Git: 2.54.0.windows.1
- Operating system: Windows

Static package validation is included. The helpers support vendor detection for AMD/Xilinx Vivado, Pango PDS, and Anlogic TD; exact EDA commands and official libraries remain local project/tool-version facts. Package validation exercises structure and script parsing, not every licensed vendor flow. End-to-end discovery and real vendor EDA execution remain target-specific and **UNVERIFIED** for 0.3.1 until exercised in the intended environment. Codex custom-agent and plugin schemas may evolve; pin a release and re-run `scripts/verify-install.ps1` after Codex updates.
