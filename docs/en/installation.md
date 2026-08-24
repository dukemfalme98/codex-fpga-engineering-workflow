# Installation

Use PowerShell 7 from the repository root:

```powershell
pwsh -File .\scripts\validate-package.ps1
pwsh -File .\scripts\install.ps1 -Scope User
pwsh -File .\scripts\verify-install.ps1 -Scope User
```

For project scope add `-Scope Project -ProjectPath C:\path\to\repo`. The installer deploys agents and the skill. The AGENTS template is opt-in via `-InstallAgentsTemplate`. Different existing content is refused by default; `-Force` backs it up first. `-WhatIf` previews changes.

`uninstall.ps1` removes only manifest-listed exact files whose SHA-256 is unchanged; modified files remain. No broad recursive directory deletion is used. Start a new Codex session after installation. Fresh-session discovery is UNVERIFIED for 0.1.0.
