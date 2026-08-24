# 安装

需要 PowerShell 7。先在仓库根目录运行静态检查：

```powershell
pwsh -File .\scripts\validate-package.ps1
```

用户级：

```powershell
pwsh -File .\scripts\install.ps1 -Scope User
pwsh -File .\scripts\verify-install.ps1 -Scope User
```

项目级：

```powershell
pwsh -File .\scripts\install.ps1 -Scope Project -ProjectPath C:\path\to\repo
pwsh -File .\scripts\verify-install.ps1 -Scope Project -ProjectPath C:\path\to\repo
```

默认只安装 `.codex/agents/*.toml` 和 `.agents/skills/run-fpga-workflow`。添加 `-InstallAgentsTemplate` 才把模板安装为目标根目录 `AGENTS.md`。已有不同内容默认报错；`-Force` 会先生成时间戳备份。`-WhatIf` 可预览。

卸载：

```powershell
pwsh -File .\scripts\uninstall.ps1 -Scope User
```

卸载根据 JSON manifest 的精确相对路径和 SHA-256 工作；用户修改过的文件保留。脚本不递归删除宽目录。安装后新开 Codex 会话验证发现；0.1.0 的端到端新会话发现仍标为 UNVERIFIED。
