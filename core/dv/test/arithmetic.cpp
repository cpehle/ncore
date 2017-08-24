#include "gtest/gtest.h"
#include "core/dv/DutCore.hpp"
#include "core/dv/riscv.h"

TEST(LSArithmeticWithNop, LoadSubStoreWithNop) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadSubStoreWithNop.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::nop(instruction_memory);
  riscv::sub(instruction_memory, riscv::reg::x7, riscv::reg::x4,
             riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }
  data_memory[1] = 11;
  data_memory[4] = 7;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[2], 4);
}

TEST(LSArithmetic, LoadSubStore) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadSubStore.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::sub(instruction_memory, riscv::reg::x7, riscv::reg::x4,
             riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }
  data_memory[1] = 11;
  data_memory[4] = 7;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[2], 11 - 7);
}

TEST(LSArithmetic, LoadLShiftStore) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadLShiftStore.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::sll(instruction_memory, riscv::reg::x7, riscv::reg::x4,
             riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }
  data_memory[1] = 11;
  data_memory[4] = 7;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[2], 11 << 7);
}

TEST(LSArithmetic, LoadRShiftStore) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadRShiftStore.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::srl(instruction_memory, riscv::reg::x7, riscv::reg::x4,
             riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }
  data_memory[1] = 11;
  data_memory[4] = 7;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[2], 11 >> 7);
}

TEST(LSArithmetic, LoadXorStore) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadXorStore.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::xor_op(instruction_memory, riscv::reg::x7, riscv::reg::x4,
                riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }
  data_memory[1] = 11;
  data_memory[4] = 7;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[2], 11 ^ 7);
}

TEST(LSArithmeticWithNop, LoadOrStoreWithNop) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadOrStoreWithNop.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::nop(instruction_memory);
  riscv::lor(instruction_memory, riscv::reg::x7, riscv::reg::x4,
             riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }
  data_memory[1] = 11;
  data_memory[4] = 7;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[2], 11 | 7);
}

TEST(LSArithmetic, LoadOrStore) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadOrStore.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::lor(instruction_memory, riscv::reg::x7, riscv::reg::x4,
             riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }

  data_memory[1] = 11;
  data_memory[4] = 7;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[2], 11 | 7);
}

TEST(LSArithmeticWithNop, LoadAndStoreWithNop) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadAndStoreWithNop.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::nop(instruction_memory);
  riscv::land(instruction_memory, riscv::reg::x7, riscv::reg::x4,
              riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }
  data_memory[1] = 11;
  data_memory[4] = 7;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[2], 11 & 7);
}

TEST(LSArithmetic, LoadAndStore) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadAndStore.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::land(instruction_memory, riscv::reg::x7, riscv::reg::x4,
              riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }

  data_memory[1] = 11;
  data_memory[4] = 7;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[2], 11 & 7);
}

TEST(LSArithmeticWithNop, LoadAddStoreWithNop) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("LoadAddStoreWithNop.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);

  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::nop(instruction_memory);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x4,
             riscv::reg::x3);

  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }
  data_memory[1] = 2;
  data_memory[4] = 3;

  DutCore::Memory m = {instruction_memory, data_memory};
  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 100, opt, tfp);
  EXPECT_EQ(m.data_memory[2], 2 + 3);
}

TEST(LSArithmetic, LoadAddStore) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 200);
  tfp->open("LoadAddStore.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::add(instruction_memory, riscv::reg::x7, riscv::reg::x4,
             riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }

  data_memory[1] = 2;
  data_memory[4] = 3;

  DutCore::Memory m = {instruction_memory, data_memory};

  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 1000, opt, tfp);
  EXPECT_EQ(2 + 3, m.data_memory[2]);
}

TEST(LSArithmetic, LoadSRAStore) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 200);
  tfp->open("LoadSRAStore.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::sra(instruction_memory, riscv::reg::x7, riscv::reg::x4,
             riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }

  data_memory[1] = 0xff;
  data_memory[4] = 3;

  DutCore::Memory m = {instruction_memory, data_memory};

  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 1000, opt, tfp);
  EXPECT_EQ(0xff >> 3, m.data_memory[2]);
  tfp->close();
}

TEST(LSArithmetic, LoadSRLStore) {
  VDutCore *core = new VDutCore("Core");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 200);
  tfp->open("LoadSRAStore.vcd");

  std::vector<uint32_t> instruction_memory;
  std::vector<uint32_t> data_memory;

  riscv::addi(instruction_memory, riscv::reg::x5, riscv::reg::x0, 4);
  riscv::lw(instruction_memory, riscv::reg::x3, riscv::reg::x5, 0);
  riscv::addi(instruction_memory, riscv::reg::x6, riscv::reg::x0, 16);
  riscv::lw(instruction_memory, riscv::reg::x4, riscv::reg::x6, 0);
  riscv::srl(instruction_memory, riscv::reg::x7, riscv::reg::x4,
             riscv::reg::x3);
  riscv::addi(instruction_memory, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(instruction_memory, riscv::reg::x1, 0, riscv::reg::x7);

  const uint32_t nop = 0x13;
  for (int i = 0; i < 1000; i++) {
    instruction_memory.push_back(nop);
    data_memory.push_back(0);
  }

  data_memory[1] = 0xff;
  data_memory[4] = 3;

  DutCore::Memory m = {instruction_memory, data_memory};

  DutCore::Options opt = {.trace_memory = false};

  simulate(core, m, 1000, opt, tfp);
  EXPECT_EQ(0xff >> 3, m.data_memory[2]);
  tfp->close();
}
