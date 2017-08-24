#include "gtest/gtest.h"
#include "core/dv/DutCore.hpp"
#include "core/dv/riscv.h"

TEST(Basic, AddStore) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("AddStore.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 40);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x5,
             riscv::reg::x6);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 4);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(i);
  }

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[1], 70);
}

TEST(Basic, LoadStore) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadStore.vcd");
  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x3);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(i);
  }

  data_memory[1] = 100;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[2], 100);
}

TEST(Basic, LoadImmediate) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadImmediate.vcd");
  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::li(instruction_memory, riscv::reg::x3, 1 << 12 | 1);
  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(i);
  }

  data_memory[1] = 100;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
}

TEST(Basic, StoreWord) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("StoreWord.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::sw(instruction_memory, riscv::reg::x0, 8, riscv::reg::x0);

  for (int i = 0; i < 1000; i++) {
    riscv::nop(instruction_memory);
    data_memory.push_back(0xffff);
  }

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(0, m.data_memory[2]);
  tfp->close();
}
