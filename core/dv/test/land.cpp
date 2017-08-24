#include "gtest/gtest.h"
#include "core/dv/DutCore.hpp"
#include "core/dv/riscv.h"

namespace land {
struct test_triple {
  uint64_t result;
  uint64_t value1;
  uint64_t value2;
};

std::vector<test_triple> arithmetic_tests = {
    {0xff & 0xf0, 0xff, 0xf0},
    {0x0f & 0xf0, 0x0f, 0xf0},
    {0xf0f & 0xff0, 0xf0f, 0xff0},
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
    tfp->open("ArithmeticLAnd.vcd");

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

    tfp->close();
  }
}
