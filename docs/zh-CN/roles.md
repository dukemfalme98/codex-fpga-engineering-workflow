# 角色分工

## 核心角色

- `fpga_architect`：只读 Lead，定义微架构、接口、预算、验收和所有权。
- `fpga_engineer`：唯一默认产品源码写入者；不能自我签核。
- `verification_engineer`：独立验证；产品只读，测试资产仅在顺序批次写。
- `fpga_cdc_timing_reviewer`：只读 Clock/Reset/CDC/RDC/约束/STA 复核。
- `fpga_interface_architect`：只读 CSR/命令/IRQ/DMA/兼容性复核。
- `fpga_vendor_platform_reviewer`：只读 IP/原语/wrapper/target 复核。
- `fpga_board_validation_engineer`：只读电气前提、仪器证据和安全步骤。
- `fpga_reviewer`：独立只读最终签核，不参与修复。

## 条件角色

- `system_architect`：跨 FPGA/硬件/固件责任拆分，只读。
- `embedded_engineer`：接口确认后的固件顺序写入者。
- `hardware_datasheet`：精确型号、文档版本和页码证据，只读。
- `independent_reviewer`：跨领域或安全关键发布终审，只读。

九个只读 TOML 显式限制 sandbox。写入顺序默认是 FPGA 产品 -> 固件（按需）-> 测试资产（按需）。任何 finding 都退回相应实现角色；reviewer 不自行修复。
