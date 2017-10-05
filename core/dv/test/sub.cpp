#include "gtest/gtest.h"
#include "core/dv/DutCore.hpp"
#include "core/dv/riscv.h"

namespace sub {

struct test_binop {
  uint64_t result;
  uint64_t value2;
  uint64_t value1;
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
    {0, 13}, {0, 12}, {0, 4},
};

std::vector<test_binop> arithmetic_tests = {
  {0x0000000000000000, 0x0000000000000000, 0x0000000000000000},
  {0x0000000000000000, 0x0000000000000001, 0x0000000000000001},
  {0x0000000000000002, 0x0000000000000003, 0x0000000000000001},  
  {0xfffffffffffffffc, 0x0000000000000003, 0x0000000000000007},
  {0x0000000000008000, 0x0000000000000000, 0xffffffffffff8000},
  {0xffffffff80000000, 0x0000000000000000, 0xffffffff80000000},
  //{0xffffffff80008000, 0xffffffffffff8000,  0xffffffff80000000},
  //{0xffffffffffff8001, 0x0000000000007fff,  0x0000000000000000},
  //{0x000000007fffffff, 0x0000000000000000,  0x000000007fffffff},
  //{0x000000007fff8000, 0x0000000000007fff,  0x000000007fffffff},
  //{0xffffffff7fff8001, 0x0000000000007fff,  0xffffffff80000000},
  //{0x0000000080007fff, 0xffffffffffff8000,  0x000000007fffffff},
  //{0x0000000000000001, 0xffffffffffffffff,  0x0000000000000000},
  //{0xfffffffffffffffe, 0x0000000000000001,  0xffffffffffffffff},
  {0x0000000000000000, 0xffffffffffffffff,  0xffffffffffffffff},
};

std::vector<test_nop_binop> dest_bypass_tests = {
    {0, {2, 13, 11}}, {1, {3, 14, 11}}, {2, {4, 15, 11}},
};

std::vector<test_nops_binop> src12_bypass_tests = {
    {0, 0, {2, 13, 11}}, {0, 1, {3, 14, 11}}, {0, 2, {4, 15, 11}},
    {1, 0, {2, 13, 11}}, {1, 1, {3, 14, 11}}, {2, 0, {4, 15, 11}},
};
}

TEST(Arithmetic, Sub) {
  for (auto t : sub::arithmetic_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticSub.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_op(instruction_memory, &riscv::sub, t.result, t.value1,
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

TEST(Arithmetic, SubSrc1EqDest) {
  for (auto t : sub::arithmetic_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticSubSrc1EqDest.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_src1_eq_dest(instruction_memory, &riscv::sub, t.result,
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
    tfp->close();
  }
}

TEST(Arithmetic, SubSrc2EqDest) {
  for (auto t : sub::arithmetic_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticSubSrc2EqDest.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_src2_eq_dest(instruction_memory, &riscv::sub, t.result,
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
    tfp->close();
  }
}

TEST(Arithmetic, SubSrc12EqDest) {
  for (auto t : sub::same_source_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticSubSrc12EqDest.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_src12_eq_dest(instruction_memory, &riscv::sub, t.result,
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
    tfp->close();
  }
}

TEST(Arithmetic, SubDestBypass) {
  for (auto t : sub::dest_bypass_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticSubDestBypass.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_dest_bypass(instruction_memory, t.nop, &riscv::sub,
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
    tfp->close();
  }
}


TEST(Arithmetic, SubSrc12BypassTest) {
  for (auto t : sub::src12_bypass_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticSubSrc12Bypass.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_src12_bypass(instruction_memory, t.nop1, t.nop2, &riscv::sub,
                             t.binop.result, t.binop.value1, t.binop.value2,
                             32);

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
