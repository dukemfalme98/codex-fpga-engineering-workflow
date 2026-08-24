# Compatibility

## Package format

This release uses Codex plugin discovery through `.codex-plugin/plugin.json`, custom agents under `.codex/agents/`, and the canonical plugin skill under `skills/run-fpga-workflow/`. The installer deploys that skill to `.agents/skills/run-fpga-workflow/` for user or project use.

## Environment exercised on 2026-08-24

- Codex CLI: 0.147.0
- PowerShell: 7.6.4
- Git: 2.54.0.windows.1
- Operating system: Windows

Static package validation is included. End-to-end discovery in a fresh Codex session remains **UNVERIFIED** for 0.1.0 until a clean installation is exercised. Codex custom-agent and plugin schemas may evolve; pin a release and re-run `scripts/verify-install.ps1` after Codex updates.
