# 使用

## ANALYZE

```text
使用 $run-fpga-workflow，只读分析当前 CDC 报告和 RTL。列出时钟关系、跨域结构、约束证据和阻塞问题，不修改文件，也不要给无证据 PASS。
```

## QUICK

```text
使用 $run-fpga-workflow，以 QUICK 模式修复这个单时钟、接口不变的小型 RTL bug。先保护当前 diff，最小修改，运行项目已有测试，然后独立复核。
```

## FULL

```text
使用 $run-fpga-workflow，以 FULL 模式实现新的异步 FIFO 数据通路。先冻结接口/吞吐/延迟/复位契约，CDC 和验证预审后由唯一产品写入者实现；隔离验证并独立签核。
```

若实现较长，要求在接口骨架、FSM、数据通路、CDC、约束和最终集成处建立稳定 diff 检查点。高频组合逻辑审查必须基于综合/实现 STA；没有报告写 UNVERIFIED。
