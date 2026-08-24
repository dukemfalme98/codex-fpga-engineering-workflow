# Codex FPGA Engineering Workflow

[中文](README.md) · [Architecture](docs/en/architecture.md) · [Roles](docs/en/roles.md) · [Installation](docs/en/installation.md) · [Usage](docs/en/usage.md)

An open-source Codex plugin for evidence-driven FPGA/SoC FPGA engineering. It connects requirements, architecture, RTL implementation, verification, CDC/RDC, STA, register/IRQ/DMA contracts, vendor platforms, board evidence, and independent sign-off.

The central model is **parallel read-only expertise, one product-source writer, isolated validation, and independent review**—not many agents editing the same code.

```text
Authorization + project AGENTS/SSOT
                 |
          conversation coordinator
                 |
           fpga_architect lead
                 |
 verification + CDC/STA + interface + vendor/board pre-review
                 |
         one implementation contract
                 |
        fpga_engineer product write
                 |
  stable-diff checkpoint reviews and repairs
                 |
 optional sequential firmware/test-asset batches
                 |
        isolated EDA validation
                 |
      specialist re-review + independent sign-off
```

## Roles

The package includes eight core roles and four conditional roles: architecture, product implementation, verification, CDC/timing, FPGA-firmware interfaces, vendor platforms, board validation, final review, cross-domain architecture, firmware implementation, datasheet evidence, and cross-domain release review. Nine roles are explicitly read-only. Only `fpga_engineer` writes product sources; verification and firmware writers operate later in separate sequential batches.

## Modes

- `ANALYZE`: read-only investigation, design, diagnosis, or review.
- `QUICK`: explicitly authorized, small, interface-preserving, single-clock, low-risk change.
- `FULL`: new RTL, crossings, regmap/IRQ/DMA, constraints, vendor IP, external timing, energy control, or significant refactoring.

## Install

```powershell
pwsh -File .\scripts\install.ps1 -Scope User
pwsh -File .\scripts\verify-install.ps1 -Scope User
```

For project scope, add `-Scope Project -ProjectPath C:\path\to\repo`. The AGENTS template is opt-in through `-InstallAgentsTemplate`; different existing content is not overwritten unless `-Force` is used, which creates a backup first. See [installation](docs/en/installation.md).

## Supervision and evidence

Checkpoint supervision operates on a frozen diff/hash after a coherent implementation slice. Read-only specialists review that stable snapshot; the coordinator consolidates findings; the same writer repairs. It is not character-by-character monitoring and reviewers never edit product code.

The workflow cannot turn simulation into CDC, STA, electrical, or board proof. Missing or unread evidence remains `NOT RUN`/`UNVERIFIED`. Physical wiring, power-up, motion, heat, lasers, relays, high voltage, and other high-energy operations remain qualified human actions.

Version `0.1.0` includes static package validation. Fresh-session discovery, actual EDA synthesis/implementation/STA, and hardware bring-up are **UNVERIFIED**. See [compatibility](COMPATIBILITY.md), [research](docs/research.md), and the [MIT license](LICENSE).
