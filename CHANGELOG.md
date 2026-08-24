# Changelog

All notable changes follow Keep a Changelog. Versions follow Semantic Versioning.

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
