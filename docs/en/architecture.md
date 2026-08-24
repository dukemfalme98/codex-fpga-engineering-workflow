# Architecture

The conversation coordinator controls authorization, mode, evidence baseline, role scheduling, conflict resolution, sequential write batches, isolated validation, and reporting. `fpga_architect` is the technical lead. Specialists pre-review in parallel but read-only. `fpga_engineer` is the sole default product-source writer. Optional firmware and test-asset writers run later in separate batches. Independent reviewers sign off the integrated diff and actual evidence.

Parallelism is for analysis, review, and fully isolated EDA jobs—not overlapping writers in one checkout. Checkpoint supervision reviews a frozen diff/hash after a coherent slice. The final reviewer does not coach implementation. Project SSOT remains authoritative for device, pins, clocks, resets, regmap, commands, and acceptance facts.
