#include "gtest/gtest.h"

TEST(Branch, UnconditionalBranch) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("UnconditionalBranch.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::jal(instruction_memory, riscv::reg::x0, 4 * 5);
  /// code should be jumped over
  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 40);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x5, riscv::reg::x6);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 4);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);
  /// this code should be executed
  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 80);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x5, riscv::reg::x6);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(0, m.data_memory[1]);
  EXPECT_EQ(30 + 80, m.data_memory[2]);
  tfp->close();
}

TEST(Branch, BranchEQ) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("BranchEQ.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x10, riscv::reg::x0, 40);
  riscv::addi(instruction_memory, riscv::reg::x11, riscv::reg::x0, 40);
  riscv::beq(instruction_memory, riscv::reg::x10, riscv::reg::x11, 5 * 4);
  /// code should be jumped over
  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 40);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x5,
             riscv::reg::x6);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 4);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);
  /// this code should be executed
  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 80);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x5,
             riscv::reg::x6);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(0, m.data_memory[1]);
  EXPECT_EQ(30 + 80, m.data_memory[2]);
  tfp->close();
}

TEST(Branch, BranchNE) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("BranchNE.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 100);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 50);
  riscv::bne(instruction_memory, riscv::reg::x5, riscv::reg::x6, 5 * 4);
  /// code should be jumped over
  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 40);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x5,
             riscv::reg::x6);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 4);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);
  /// this code should be executed
  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 80);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x5,
             riscv::reg::x6);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(0, m.data_memory[1]);
  EXPECT_EQ(30 + 80, m.data_memory[2]);
  tfp->close();
}

TEST(Branch, BranchLT) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("BranchLT.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 55);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 77);
  riscv::blt(instruction_memory, riscv::reg::x5, riscv::reg::x6, 5 * 4);
  /// code should be jumped over
  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 40);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x5,
             riscv::reg::x6);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 4);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);
  /// this code should be executed
  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 80);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x5,
             riscv::reg::x6);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(30 + 80, m.data_memory[2]);
  EXPECT_EQ(0, m.data_memory[1]);
  tfp->close();
}

TEST(Branch, BranchGT) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("BranchGT.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 99);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 22);
  riscv::bge(instruction_memory, riscv::reg::x5, riscv::reg::x6, 5 * 4);
  /// code should be jumped over
  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 40);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x5,
             riscv::reg::x6);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 4);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);
  /// this code should be executed
  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 80);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x5,
             riscv::reg::x6);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(0, m.data_memory[1]);
  EXPECT_EQ(30 + 80, m.data_memory[2]);
  tfp->close();
}
