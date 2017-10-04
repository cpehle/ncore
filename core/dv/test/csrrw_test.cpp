#include "core/dv/DutCore.hpp"
#include "core/dv/riscv.h"
#include "gtest/gtest.h"

namespace csrrw {
}

TEST(Compound, CSRRW) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("CSRRW.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  {
    riscv::li(instruction_memory, riscv::reg::x1, 0xffff);
    riscv::csrrw(instruction_memory, riscv::reg::x2, 0xf, riscv::reg::x1);
    riscv::csrrw(instruction_memory, riscv::reg::x3, 0xf, riscv::reg::x0);    
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

