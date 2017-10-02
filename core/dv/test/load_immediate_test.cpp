#include "core/dv/DutCore.hpp"
#include "core/dv/riscv.h"
#include "gtest/gtest.h"

namespace li {

std::vector<uint64_t> tests = {
  //  0xffffffffffffffff,
  //0x00000000000fffff,
  //0x0,
  //0x000000000000ffff,
  0x0000000000000fff,  
};

}

TEST(Compound, LoadImmediate) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadImmediate.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  {
    for (auto t : li::tests) {
      riscv::li(instruction_memory, riscv::reg::x1, t);
    }    
  }
  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0xfefefefe);
  }

  
  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  // EXPECT_EQ(0xfefefefe, m.data_memory[1]);
  // EXPECT_EQ(110, m.data_memory[2]);
  tfp->close();
}

