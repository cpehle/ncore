#include "obj_dir/VDutCore.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "riscv.h"
#include "test_combinators.hpp"

#include <bitset>
#include <iostream>
#include <vector>

namespace DutCore {
struct Memory {
  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;
};

struct Options {
  bool trace_memory;
};

void simulate(VDutCore *core, Memory &m, const size_t N, const Options opt,
              VerilatedVcdC *tfp);
} // namespace DutCore
