#include "gtest/gtest.h"
#include "core/dv/DutCore.hpp"
#include "core/dv/riscv.h"

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
    {26, 13}, {24, 12}, {8, 4},
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
    {0, {24, 13, 11}}, {1, {25, 14, 11}}, {2, {26, 15, 11}},
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
    tfp->close();
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
    tfp->close();
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
    tfp->close();
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
    tfp->close();
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
    tfp->close();
  }
}

TEST(Arithmetic, AddSrc12BypassTest) {
  for (auto t : add::src12_bypass_tests) {
    VDutCore *core = new VDutCore("Core");
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    core->trace(tfp, 99);
    tfp->open("ArithmeticAddSrc12Bypass.vcd");

    std::vector<uint32_t> instruction_memory;
    std::vector<uint32_t> data_memory;
    tc::test_rr_src12_bypass(instruction_memory, t.nop1, t.nop2, &riscv::add,
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
