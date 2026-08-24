# Safety and evidence

Keep source review, RTL simulation, formal proof, CDC/RDC analysis, synthesis, implementation/STA, instrument measurements, and real board results separate. Each passing claim needs exact command, tool/version, exit status, warnings, and report path. Use NOT RUN and UNVERIFIED honestly.

Wiring, power-up, configuration, movement, heating, lasers, relays, high voltage, and other energy outputs are qualified human actions with prerequisites, expected readings, stop conditions, and recovery. Reset, unconfigured, clock-loss, communication-loss, watchdog, and fault states should be safe. This workflow is not functional-safety certification and contains no default board electrical facts.
