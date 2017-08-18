# ncore

[![Build Status](https://travis-ci.org/cpehle/ncore.svg?branch=master)](https://travis-ci.org/cpehle/ncore)

## Overview

This is (for now) a partial System Verilog port of the five stage
pipeline [riscv-sodor](https://github.com/ucb-bar/riscv-sodor)
microarchitecture. The main motivation for doing
this port was to compare the expressiveness of Chisel to System
Verilog. 

## Building

A work in progress testbench can be found in sc/dv/ it uses
[verilator](http://www.veripool.org/wiki/verilator), once I've figured
how to get the ucb-bar RISCV tests to run, the current setup will
probably be redundant.

The precise steps are as follows: Install verilator and bazel, and
run the following sequence of commands. Tests are organized using
google test + bazel

```
cd core/dv
make -f core.mk
bazel run :dut_core_test
```

In xilinx/ there is an incomplete synthesis flow to a xilinx
bitfile. For this to actually work one would need some more work on
peripheral components.

