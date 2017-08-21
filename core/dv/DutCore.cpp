#include "obj_dir/VDutCore.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "gtest/gtest.h"

#include "test_combinators.hpp"

#include "riscv.h"

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
              VerilatedVcdC *tfp) {
  core->clk = 0;
  for (size_t i = 0; i < N; i++) {
    for (int clk = 0; clk < 2; clk++) {
      tfp->dump(2 * i + clk);
      core->clk = !core->clk;

      if (i < 5) {
        core->reset = 1;
      } else {
        core->reset = 0;
      }

      // service instruction memory requests
      uint32_t iaddr = core->imem_in_req_addr / 4;

      core->imem_out_req_ready = 1;
      if (core->imem_in_req_valid) {
        core->imem_out_res_data = m.instruction_memory[iaddr];
        core->imem_out_res_valid = 1;
      }

      // service data memory requests
      uint32_t daddr = core->dmem_in_req_addr / 4;
      core->dmem_out_req_ready = 1;
      if (core->dmem_in_req_valid) {
        switch (core->dmem_in_req_fcn) {
        case 0x0:
          core->dmem_out_res_data = m.data_memory[daddr];
          core->dmem_out_res_valid = 1;
          break;
        case 0x1:
          m.data_memory[daddr] = core->dmem_in_req_data;
          break;
        }
      }

      core->eval();
    }

    if (opt.trace_memory) {
      if (core->dmem_in_req_valid) {
        uint32_t daddr = core->dmem_in_req_addr / 4;
        switch (core->dmem_in_req_fcn) {
        case 0x0:
          std::cout << "r " << daddr << std::endl;
          break;
        case 0x1:
          std::cout << "w " << daddr << " " << core->dmem_in_req_data
                    << std::endl;
          break;
        }
      }
    }
  }
  core->final();
}
};

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
}

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
}

namespace add {

struct test_binop {
  uint64_t result;
  uint64_t value1;
  uint64_t value2;
};

struct test_unop {
  uint64_t result;
  uint64_t value;
};

struct test_nop_binop {
  int nop;
  test_binop binop;
};

struct test_nop_unop {
  int nop;
  test_unop unop;
};

struct test_nops_binop {
  int nop1;
  int nop2;
  test_binop binop;
};

std::vector<test_unop> same_source_tests = {
    {26, 13},
};

std::vector<test_binop> arithmetic_tests = {
    {0x00000000, 0x00000000, 0x00000000},
    {0x00000000, 0x00000000, 0x00000000},
    {0x00000002, 0x00000001, 0x00000001},
    {0x0000000a, 0x00000003, 0x00000007},
    // {0xffffffffffff8000, 0x0000000000000000, 0xffffffffffff8000},
    // {0xffffffff80000000, 0xffffffff80000000, 0x00000000},
    // {0xffffffff7fff8000, 0xffffffff80000000, 0xffffffffffff8000},
    {0x0000000000007fff, 0x0000000000000000, 0x0000000000007fff},
    // {0x000000007fffffff, 0x000000007fffffff, 0x0000000000000000},
    // {0x0000000080007ffe, 0x000000007fffffff, 0x0000000000007fff},
    // {0xffffffff80007fff, 0xffffffff80000000, 0x0000000000007fff},
    // {0x000000007fff7fff, 0x000000007fffffff, 0xffffffffffff8000},
    // {0xffffffffffffffff, 0x0000000000000000, 0xffffffffffffffff},
    // {0x0000000000000000, 0xffffffffffffffff, 0x0000000000000001},
    // {0xfffffffffffffffe, 0xffffffffffffffff, 0xffffffffffffffff},
    // {0x0000000080000000, 0x0000000000000001, 0x000000007fffffff},
};

std::vector<test_nop_binop> dest_bypass_tests = {
  {0, {24, 13, 11}},
  {1, {25, 14, 11}},
  {2, {26, 15, 11}},
};

std::vector<test_nops_binop> src12_bypass_tests = {
    {0, 0, {24, 13, 11}}, {0, 1, {25, 14, 11}}, {0, 2, {26, 15, 11}},
    {1, 0, {24, 13, 11}}, {1, 1, {25, 14, 11}}, {2, 0, {26, 15, 11}},
};
}

TEST(Arithmetic, Add) {
  for (auto t : add::arithmetic_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticAdd.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_op(instruction_memory, &riscv::add, t.result, t.value1,
                   t.value2, 32);

    const uint32_t nop = 0x13;
    for (int i = 0; i < 1000; i++) {
      instruction_memory.push_back(nop);
      data_memory.push_back(0xfefefefe);
    }

    DutCore::Memory m = {instruction_memory, data_memory};
    DutCore::Options opt = {.trace_memory = false};

    simulate(core, m, 100, opt, tfp);
    EXPECT_EQ(0xfefefefe, m.data_memory[1]);
    EXPECT_EQ(110, m.data_memory[2]);
  }
}

TEST(Arithmetic, AddSrc1EqDest) {
  for (auto t : add::arithmetic_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticAdd.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_src1_eq_dest(instruction_memory, &riscv::add, t.result,
                             t.value1, t.value2, 32);

    const uint32_t nop = 0x13;
    for (int i = 0; i < 1000; i++) {
      instruction_memory.push_back(nop);
      data_memory.push_back(0xfefefefe);
    }

    DutCore::Memory m = {instruction_memory, data_memory};
    DutCore::Options opt = {.trace_memory = false};

    // std::cout << "simulating " << t.result << " " << t.value1 << " " <<
    // t.value2 << std::endl;
    simulate(core, m, 100, opt, tfp);
    EXPECT_EQ(0xfefefefe, m.data_memory[1]);
    EXPECT_EQ(110, m.data_memory[2]);
  }
}

TEST(Arithmetic, AddSrc2EqDest) {
  for (auto t : add::arithmetic_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticAdd.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_src2_eq_dest(instruction_memory, &riscv::add, t.result,
                             t.value1, t.value2, 32);

    const uint32_t nop = 0x13;
    for (int i = 0; i < 1000; i++) {
      instruction_memory.push_back(nop);
      data_memory.push_back(0xfefefefe);
    }

    DutCore::Memory m = {instruction_memory, data_memory};
    DutCore::Options opt = {.trace_memory = false};

    simulate(core, m, 100, opt, tfp);
    EXPECT_EQ(0xfefefefe, m.data_memory[1]);
    EXPECT_EQ(110, m.data_memory[2]);
  }
}

TEST(Arithmetic, AddSrc12EqDest) {
  for (auto t : add::same_source_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticAdd.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_src12_eq_dest(instruction_memory, &riscv::add, t.result,
                              t.value, 32);

    const uint32_t nop = 0x13;
    for (int i = 0; i < 1000; i++) {
      instruction_memory.push_back(nop);
      data_memory.push_back(0xfefefefe);
    }

    DutCore::Memory m = {instruction_memory, data_memory};
    DutCore::Options opt = {.trace_memory = false};

    simulate(core, m, 100, opt, tfp);
    EXPECT_EQ(0xfefefefe, m.data_memory[1]);
    EXPECT_EQ(110, m.data_memory[2]);
  }
}

TEST(Arithmetic, AddDestBypass) {
  for (auto t : add::dest_bypass_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticAddDestBypass.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_dest_bypass(instruction_memory, t.nop, &riscv::add,
                            t.binop.result, t.binop.value1, t.binop.value2, 32);

    const uint32_t nop = 0x13;
    for (int i = 0; i < 1000; i++) {
      instruction_memory.push_back(nop);
      data_memory.push_back(0xfefefefe);
    }

    DutCore::Memory m = {instruction_memory, data_memory};
    DutCore::Options opt = {.trace_memory = false};

    simulate(core, m, 100, opt, tfp);
    EXPECT_EQ(0xfefefefe, m.data_memory[1]);
    EXPECT_EQ(110, m.data_memory[2]);
    core->final();
  }
}

namespace land {
struct test_triple {
  uint64_t result;
  uint64_t value1;
  uint64_t value2;
};

std::vector<test_triple> arithmetic_tests = {
    {0xff & 0xf0, 0xff, 0xf0},
    // {0x0f000f00, 0xff00ff00, 0x0f0f0f0f},
    // {0x00f000f0, 0x0ff00ff0, 0xf0f0f0f0},
    // {0x000f000f, 0x00ff00ff, 0x0f0f0f0f},
    // {0xf000f000, 0xf00ff00f, 0xf0f0f0f0},
};
}

TEST(Arithmetic, LAnd) {
  for (auto t : land::arithmetic_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticAnd.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_op(instruction_memory, &riscv::land, t.result, t.value1,
                   t.value2, 32);

    const uint32_t nop = 0x13;
    for (int i = 0; i < 1000; i++) {
      instruction_memory.push_back(nop);
      data_memory.push_back(0xfefefefe);
    }

    DutCore::Memory m = {instruction_memory, data_memory};
    DutCore::Options opt = {.trace_memory = false};

    simulate(core, m, 100, opt, tfp);
    EXPECT_EQ(0xfefefefe, m.data_memory[1]);
    EXPECT_EQ(110, m.data_memory[2]);
  }
}
