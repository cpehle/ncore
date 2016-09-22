# Overview

This is (for now) a partial System Verilog port of the five stage
pipeline [riscv-sodor](https://github.com/ucb-bar/riscv-sodor)
microarchitecture. The main motivation for doing
this port was to compare the expressiveness of Chisel to System
Verilog. 


# Building

A work in progress testbench can be found in sc/dv/ it uses
[verilator](http://www.veripool.org/wiki/verilator), once I've figured
how to get the ucb-bar RISCV tests to run, the current setup will
probably mostly redundant.

In xilinx/ there is an incomplete synthesis flow to a xilinx
bitfile. For this to actually work one would need some more work on
peripheral components.

