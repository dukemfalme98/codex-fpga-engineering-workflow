# FPGA task profiles

Load only the relevant profile.

## Datapath or FSM

Define ports, throughput, latency, backpressure, buffers, precision, overflow/saturation, illegal-state recovery, and unchanged boundaries. Freeze an impact cone and cycle contract. For pipeline/FSM/FIFO/RAM changes, run the temporal reviewer in shadow mode against one bounded clock-domain cone. Acceptance includes directed boundaries, reset, random backpressure, a cycle-indexed checker, and synthesis/STA when structure or target timing may change.

## Registers, commands, IRQ, or DMA

Find the single register source. Review address units, alignment, width, endianness, byte enables, reset values, RO/RW/W1C/RC/self-clear, reserved bits, side effects, versioning, and atomic snapshots. Explicitly define W1C concurrent-event priority, IRQ raw/status/mask/clear/reassert, and DMA alignment/boundaries/ownership/cache/backpressure/abort/recovery. Do not hand-edit duplicated generated views.

## CDC, reset, or timing

Use CDC/timing and verification pre-review; add vendor/board review for clock primitives or external clocks. Match crossing type to synchronizer, handshake/toggle, stable multi-bit protocol, Gray counter, or async FIFO. Check reconvergence, reset release, pulse visibility, data stability, attributes, MTBF assumptions, generated clocks, I/O delays, and narrow exceptions. Structural and constraint correctness require separate evidence.

## Multi-vendor platform

Keep product behavior in common RTL. Wrap PLL/clock/I/O/SERDES/delay/RAM/FIFO/DDR/transceiver/boot/debug and target constraints. Select portable or vendor-optimized implementations by target, not scattered conditionals. Each target needs exact device/tool/IP data, an independent build/report row, and equivalence tests.

Automatic scripts support only Xilinx (`.xpr`/`.xci`), Pango (`.pds`/`.idf`), and Anlogic (`.al`/marked `.ipc`). Conflicts and other vendors fail closed. A generated formal project contains exactly one adapter and one `codex_out` output root.

## Board or high-energy output

Require exact manuals/schematics and safe defaults before physical steps. Separate simulation, static implementation evidence, instrument capture, unloaded tests, and controlled load tests. Wiring, power-up, movement, heat, laser, relay, high voltage, and energy enable are USER ACTIONS with prerequisites, stop conditions, and recovery.

## File ownership

- Product RTL/constraints/wrappers/build/regmap implementation: `fpga_engineer` only.
- Firmware/drivers: `embedded_engineer` in a later sequential batch.
- Testbench/assertions/reference models: `verification_engineer` in a later sequential batch.
- Reviews: read-only; reviewers never fix findings.
- EDA output: unique ignored `codex_out/<run-id>/...` directory per job; never commit vendor databases or generated IP.

## Minimum sign-off evidence

Requirements and unknowns are explicit; user changes are protected; integrated diff is reviewable; affected tests have real results; CDC/RDC, synthesis, implementation, and STA are present when affected or clearly UNVERIFIED; interfaces agree across domains; high-energy actions retain a human safety gate.
