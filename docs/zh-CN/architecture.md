# 整体架构

主会话是控制面：确认授权和模式、读取项目证据、调度角色、解决证据冲突、控制写入批次、隔离验证并汇总结果。`fpga_architect` 是技术 Lead；专项角色并行只读预审；`fpga_engineer` 是同一 checkout 的唯一默认产品源码写入者；固件与测试资产只能在后续独立批次写入；最终由未参与实现的 reviewer 签核。

```text
facts/requirements -> Lead -> parallel read-only pre-review
                                     |
                           implementation contract
                                     |
                              one product writer
                                     |
                stable diff -> parallel checkpoint review
                                     |
                      sequential auxiliary write batches
                                     |
                         isolated validation evidence
                                     |
                    specialist re-review -> final review
```

并行发生在分析、复查和完全隔离的 EDA job；同一 checkout 不并行写。检查点监督只审稳定快照。最终 reviewer 不参与实现指导，以保持独立性。项目 SSOT 决定器件、引脚、时钟、复位、寄存器和命令等项目事实。
