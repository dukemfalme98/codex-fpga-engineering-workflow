# Changelog

All notable changes follow Keep a Changelog. Versions follow Semantic Versioning.

## [0.3.0] - 2026-08-26

### Added

- Added the shadow-only, strictly read-only `fpga_temporal_evidence_reviewer` for bounded cycle and simulation-evidence review.
- Added stable workflow artifacts, Model Cards, findings-ledger convergence, simulation-failure classification, and hard repair-loop stops.
- Added deterministic Xilinx/Pango/Anlogic detection, RTL/IP/TB file-list generation, preflight, official-library recipe hooks, and a clean formal-project scaffold.
- Added a private after-sales fault-library schema and empty/config/query hook without shipping private data.

### Changed

- Standardized generated Codex process output beneath project-root `codex_out`.
- Expanded English documentation with formal directory structure, one-click `run.bat`, temporal evidence, model independence, and local-first shadow rollout.
- Updated package/install validation for 13 roles: 10 strict read-only roles and 3 potential sequential writers.

## [0.2.0] - 2026-08-24

### Changed

- Made `README.md` the sole canonical English landing page.
- Added a GitHub-focused hero, status badges, quick start, architecture overview, complete role table, use cases, limitations, and adoption calls to action.
- Expanded the English architecture, roles, installation, usage, and safety/evidence guides.
- Normalized the FPGA architect's output headings and improved public terminology.
- Updated package validation to derive the plugin version from `VERSION`, require the English documentation set, and reject CJK text or stale localized-document references.

### Removed

- Removed the duplicate English README and localized documentation copies in favor of one maintainable English documentation path.

## [0.1.0] - 2026-08-24

### Added

- Twelve FPGA/SoC FPGA roles with explicit read/write boundaries.
- ANALYZE, QUICK, and FULL workflow modes.
- Stable-diff checkpoint supervision, isolated EDA evidence, and independent sign-off.
- User/project installation, verification, validation, and safe uninstallation scripts.
- Initial bilingual documentation, prompts, research ledger, and contribution templates.
