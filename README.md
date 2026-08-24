# Codex FPGA Engineering Workflow

[English](README.en.md) · [架构](docs/zh-CN/architecture.md) · [角色](docs/zh-CN/roles.md) · [安装](docs/zh-CN/installation.md) · [用法](docs/zh-CN/usage.md)

一个面向 Codex 的开源 FPGA/SoC FPGA 多角色工程插件。它把需求、架构、RTL 实现、验证、CDC/RDC、STA、寄存器/IRQ/DMA、厂商平台、板级证据和独立签核组织成可追溯流程。

核心不是“让很多 Agent 同时改代码”，而是：**多专家并行只读分析，唯一产品源码写入者集中实现，隔离验证，独立签核。**

## 架构

```text
用户授权 + 项目 AGENTS/SSOT
             |
        主会话协调者
             |
      fpga_architect Lead
             |
   +---------+----------+----------+
   |         |          |          |
验证预审   CDC/STA    接口/寄存器   厂商/板级
   +---------+----------+----------+
             |
       唯一实现契约
             |
       fpga_engineer 写产品
             |
   [稳定 diff 检查点并行只读复查]
             |
 固件批次(按需) -> 测试资产批次(按需)
             |
        隔离 EDA 验证
             |
       专项复查 + 独立终审
```

所谓“近实时监督”是稳定检查点：实现者完成可理解的小切片后暂停，冻结 diff/hash，多名只读专家批判性复查，再由同一实现者集中修正。它不是逐字符监控，也不允许多人同时改同一 checkout。

## 12 个角色

| 角色 | 职责 | 权限 |
|---|---|---|
| `fpga_architect` | 需求、微架构、性能预算、验收 | 只读 |
| `fpga_engineer` | RTL/约束/wrapper/构建实现 | 唯一默认产品写入者 |
| `verification_engineer` | 测试计划、TB、断言、模型、回归 | 产品只读；测试资产顺序写入 |
| `fpga_cdc_timing_reviewer` | Clock/Reset/CDC/RDC/STA/约束 | 只读 |
| `fpga_interface_architect` | CSR、命令、IRQ、DMA、兼容性 | 只读 |
| `fpga_vendor_platform_reviewer` | IP/原语/wrapper/target | 只读 |
| `fpga_board_validation_engineer` | 电气前提、仪器证据、安全上板 | 只读 |
| `fpga_reviewer` | 独立最终签核 | 只读 |
| `system_architect` | FPGA/硬件/固件跨域拆分 | 只读、条件调用 |
| `embedded_engineer` | FPGA 接口相关固件实现 | 固件顺序写入 |
| `hardware_datasheet` | 精确手册和电气证据 | 只读、条件调用 |
| `independent_reviewer` | 跨领域/安全关键发布签核 | 只读、条件调用 |

九个严格只读角色在 TOML 中显式设置 `sandbox_mode = "read-only"`。任何实现者都不能给自己签发最终 PASS。

## 三种模式

- `ANALYZE`：只读诊断、方案或代码/发布评审。
- `QUICK`：明确授权、接口不变、单时钟、低风险小改。
- `FULL`：新增 RTL、CDC/RDC、寄存器、约束、厂商 IP、外部时序、高能量输出或较大变更。

风险不能扩大写入授权；跨域、公开接口、约束、数据丢失或安全问题不得降级 QUICK。

## 安装

PowerShell：

```powershell
pwsh -File .\scripts\install.ps1 -Scope User
pwsh -File .\scripts\verify-install.ps1 -Scope User
```

项目级安装：

```powershell
pwsh -File .\scripts\install.ps1 -Scope Project -ProjectPath C:\path\to\repo
```

默认安装 12 个角色和 Skill，不安装或覆盖 AGENTS 模板。只有显式添加 `-InstallAgentsTemplate` 才安装模板；不同内容默认拒绝覆盖，`-Force` 会先备份。卸载只删除 manifest 记录且 SHA-256 未变化的精确文件。详见[安装说明](docs/zh-CN/installation.md)。

## 示例

```text
使用 $run-fpga-workflow，以 FULL 模式为这个 AXI-Stream 跨时钟模块建立需求基线、实现最小 RTL、隔离验证，并由独立 reviewer 签核。不要猜时钟关系。
```

更多提示词见 [examples](examples)。

## 能做与不能证明

它能建立证据门禁、角色边界、可审查实现、验证计划和报告追踪；不能凭提示词证明 CDC 正确、时序闭合、电气安全或真实上板通过。未执行/未读取的证据必须是 `NOT RUN`/`UNVERIFIED`。物理接线、上电、运动、加热、激光、继电器、高压及其他能量输出始终由合格人员执行。

## 状态

版本 `0.1.0`。已提供静态包验证；全新 Codex 会话中的端到端发现、实际 EDA 综合/实现/STA 和板级验证保持 **UNVERIFIED**。兼容环境与边界见 [COMPATIBILITY.md](COMPATIBILITY.md)，开源调研见 [docs/research.md](docs/research.md)。许可证：[MIT](LICENSE)。
