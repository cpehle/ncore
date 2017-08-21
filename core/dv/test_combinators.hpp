#pragma once

#include "riscv.h"
#include <vector>

namespace tc {

uint32_t sext_imm(uint32_t x) { return ((x) | (-(((x) >> 11) & 1) << 11)); }

void insert_nops(std::vector<uint32_t> ins, int n) {
  for (int i = 0; i < n; i++) {
    riscv::nop(ins);
  }
}

void test_result(std::vector<uint32_t>& i, riscv::reg test_reg,
                 uint64_t correct_value) {
  riscv::lui(i, riscv::reg::x29, correct_value);
  riscv::bne(i, test_reg, riscv::reg::x29, 4);
  riscv::sw(i, riscv::reg::x0, 0, riscv::reg::x0);
  riscv::sw(i, riscv::reg::x0, 4, riscv::reg::x0);
}

// tests for instructions with register-register operands
void test_rr_op(std::vector<uint32_t>& i,
                void(ins)(std::vector<uint32_t>&, riscv::reg, riscv::reg,
                          riscv::reg),
                uint64_t result, uint64_t val1, uint64_t val2) {
  riscv::lui(i, riscv::reg::x1, val1);
  riscv::lui(i, riscv::reg::x2, val2);
  ins(i, riscv::reg::x30, riscv::reg::x1, riscv::reg::x2);
  test_result(i, riscv::reg::x30, result);
}

void test_rr_src1_eq_dest(std::vector<uint32_t>& i,
                          void(ins)(std::vector<uint32_t>&, riscv::reg,
                                    riscv::reg, riscv::reg),
                          uint64_t result, uint64_t val1, uint64_t val2) {
  riscv::lui(i, riscv::reg::x1, val1);
  riscv::lui(i, riscv::reg::x2, val2);
  ins(i, riscv::reg::x1, riscv::reg::x1, riscv::reg::x2);
  test_result(i, riscv::reg::x1, result);
}

void test_rr_src2_eq_dest(std::vector<uint32_t> i,
                          void(ins)(std::vector<uint32_t>, riscv::reg,
                                    riscv::reg, riscv::reg),
                          uint64_t result, uint64_t val1, uint64_t val2) {
  riscv::lui(i, riscv::reg::x1, val1);
  riscv::lui(i, riscv::reg::x2, val2);
  ins(i, riscv::reg::x2, riscv::reg::x1, riscv::reg::x2);
  test_result(i, riscv::reg::x2, result);
}

void test_rr_src12_eq_dest(std::vector<uint32_t> i,
                           void(ins)(std::vector<uint32_t>, riscv::reg,
                                     riscv::reg, riscv::reg),
                           uint64_t result, uint64_t val1) {
  riscv::lui(i, riscv::reg::x1, val1);
  ins(i, riscv::reg::x1, riscv::reg::x1, riscv::reg::x1);
  test_result(i, riscv::reg::x1, result);
}

void test_rr_dest_bypass(std::vector<uint32_t> i, uint32_t nop_cycles,
                         void(inst)(std::vector<uint32_t>, riscv::reg,
                                    riscv::reg, riscv::reg),
                         uint64_t result, uint64_t val1, uint64_t val2) {
  riscv::lui(i, riscv::reg::x4, 0);
  // Branch back here
  riscv::lui(i, riscv::reg::x1, val1);
  riscv::lui(i, riscv::reg::x2, val2);
  inst(i, riscv::reg::x30, riscv::reg::x1, riscv::reg::x2);
  insert_nops(i, nop_cycles);
  riscv::addi(i, riscv::reg::x6, riscv::reg::x30, 0);
  riscv::addi(i, riscv::reg::x4, riscv::reg::x4, 1);
  riscv::lui(i, riscv::reg::x5, 2);
  riscv::bne(i, riscv::x4, riscv::x5, -6 * 4 - nop_cycles * 4);
  test_result(i, riscv::reg::x6, result);
}

void test_rr_src12_bypass(std::vector<uint32_t> i, uint32_t src1_nops,
                          uint32_t src2_nops,
                          void(inst)(std::vector<uint32_t>, riscv::reg,
                                     riscv::reg, riscv::reg),
                          uint64_t result, uint64_t val1, uint64_t val2) {

  riscv::lui(i, riscv::reg::x4, 0);
  // Branch back here
  riscv::lui(i, riscv::reg::x1, val1);
  insert_nops(i, src1_nops);
  riscv::lui(i, riscv::reg::x2, val2);
  insert_nops(i, src2_nops);
  inst(i, riscv::reg::x30, riscv::reg::x1, riscv::reg::x2);
  riscv::addi(i, riscv::reg::x4, riscv::reg::x4, 1);
  riscv::lui(i, riscv::reg::x5, 2);
  riscv::bne(i, riscv::x4, riscv::x5, -(6 + src1_nops + src2_nops) * 4);
  test_result(i, riscv::reg::x30, result);
}

void test_rr_src21_bypass(std::vector<uint32_t> i, uint32_t src1_nops,
                          uint32_t src2_nops,
                          void(inst)(std::vector<uint32_t>, riscv::reg,
                                     riscv::reg, riscv::reg),
                          uint64_t result, uint64_t val1, uint64_t val2) {

  riscv::lui(i, riscv::reg::x4, 0);
  // Branch back here
  riscv::lui(i, riscv::reg::x2, val2);
  insert_nops(i, src1_nops);
  riscv::lui(i, riscv::reg::x1, val1);
  insert_nops(i, src2_nops);
  inst(i, riscv::reg::x30, riscv::reg::x1, riscv::reg::x2);
  riscv::addi(i, riscv::reg::x4, riscv::reg::x4, 1);
  riscv::lui(i, riscv::reg::x5, 2);
  riscv::bne(i, riscv::x4, riscv::x5, -(6 + src1_nops + src2_nops) * 4);
  test_result(i, riscv::reg::x30, result);
}

void test_rr_zerosrc1(std::vector<uint32_t> i,
                      void(inst)(std::vector<uint32_t>, riscv::reg, riscv::reg,
                                 riscv::reg),
                      uint64_t result, uint64_t val) {
  riscv::lui(i, riscv::reg::x1, val);
  inst(i, riscv::reg::x2, riscv::reg::x0, riscv::reg::x1);
  test_result(i, riscv::reg::x2, result);
}

void test_rr_zerosrc2(std::vector<uint32_t> i,
                      void(inst)(std::vector<uint32_t>, riscv::reg, riscv::reg,
                                 riscv::reg),
                      uint64_t result, uint64_t val) {
  riscv::lui(i, riscv::reg::x1, val);
  inst(i, riscv::reg::x2, riscv::reg::x1, riscv::reg::x0);
  test_result(i, riscv::reg::x2, result);
}

void test_rr_zerosrc12(std::vector<uint32_t> i,
                       void(inst)(std::vector<uint32_t>, riscv::reg, riscv::reg,
                                  riscv::reg),
                       uint64_t result, uint64_t val) {
  inst(i, riscv::reg::x1, riscv::reg::x0, riscv::reg::x0);
  test_result(i, riscv::reg::x1, result);
}

// test memory instructions

//   #define TEST_LD_OP( testnum, inst, result, offset, base ) \
//     TEST_CASE( testnum, x30, result, \
//       la  x1, base; \
//       inst x30, offset(x1); \
//     )

void test_st_op(std::vector<uint32_t> i,
                void(store_inst)(std::vector<uint32_t>, riscv::reg, riscv::reg,
                                 uint32_t),
                void(load_inst)(std::vector<uint32_t>, riscv::reg, riscv::reg,
                                uint32_t),
                uint64_t result, uint32_t offset, uint64_t base) {
  riscv::lui(i, riscv::reg::x1, base);
  riscv::lui(i, riscv::reg::x2, result);
  store_inst(i, riscv::reg::x2, riscv::reg::x1, offset);
  load_inst(i, riscv::reg::x30, riscv::reg::x1, offset);
  test_result(i, riscv::reg::x30, result);
}

// #define TEST_ST_OP( testnum, load_inst, store_inst, result, offset, base ) \
//     TEST_CASE( testnum, x30, result, \
//       la  x1, base; \
//       li  x2, result; \
//       store_inst x2, offset(x1); \
//       load_inst x30, offset(x1); \
//     )

// #define TEST_LD_DEST_BYPASS( testnum, nop_cycles, inst, result, offset, base ) \
// test_ ## testnum: \
//     li  TESTNUM, testnum; \
//     li  x4, 0; \
// 1:  la  x1, base; \
//     inst x30, offset(x1); \
//     TEST_INSERT_NOPS_ ## nop_cycles \
//     addi  x6, x30, 0; \
//     li  x29, result; \
//     bne x6, x29, fail; \
//     addi  x4, x4, 1; \
//     li  x5, 2; \
//     bne x4, x5, 1b; \

// #define TEST_LD_SRC1_BYPASS( testnum, nop_cycles, inst, result, offset, base ) \
// test_ ## testnum: \
//     li  TESTNUM, testnum; \
//     li  x4, 0; \
// 1:  la  x1, base; \
//     TEST_INSERT_NOPS_ ## nop_cycles \
//     inst x30, offset(x1); \
//     li  x29, result; \
//     bne x30, x29, fail; \
//     addi  x4, x4, 1; \
//     li  x5, 2; \
//     bne x4, x5, 1b \

// #define TEST_ST_SRC12_BYPASS( testnum, src1_nops, src2_nops, load_inst, store_inst, result, offset, base ) \
// test_ ## testnum: \
//     li  TESTNUM, testnum; \
//     li  x4, 0; \
// 1:  li  x1, result; \
//     TEST_INSERT_NOPS_ ## src1_nops \
//     la  x2, base; \
//     TEST_INSERT_NOPS_ ## src2_nops \
//     store_inst x1, offset(x2); \
//     load_inst x30, offset(x2); \
//     li  x29, result; \
//     bne x30, x29, fail; \
//     addi  x4, x4, 1; \
//     li  x5, 2; \
//     bne x4, x5, 1b \

// #define TEST_ST_SRC21_BYPASS( testnum, src1_nops, src2_nops, load_inst, store_inst, result, offset, base ) \
// test_ ## testnum: \
//     li  TESTNUM, testnum; \
//     li  x4, 0; \
// 1:  la  x2, base; \
//     TEST_INSERT_NOPS_ ## src1_nops \
//     li  x1, result; \
//     TEST_INSERT_NOPS_ ## src2_nops \
//     store_inst x1, offset(x2); \
//     load_inst x30, offset(x2); \
//     li  x29, result; \
//     bne x30, x29, fail; \
//     addi  x4, x4, 1; \
//     li  x5, 2; \
//     bne x4, x5, 1b \

// #define TEST_BR2_OP_TAKEN( testnum, inst, val1, val2 ) \
// test_ ## testnum: \
//     li  TESTNUM, testnum; \
//     li  x1, val1; \
//     li  x2, val2; \
//     inst x1, x2, 2f; \
//     bne x0, TESTNUM, fail; \
// 1:  bne x0, TESTNUM, 3f; \
// 2:  inst x1, x2, 1b; \
//     bne x0, TESTNUM, fail; \
// 3:

// #define TEST_BR2_OP_NOTTAKEN( testnum, inst, val1, val2 ) \
// test_ ## testnum: \
//     li  TESTNUM, testnum; \
//     li  x1, val1; \
//     li  x2, val2; \
//     inst x1, x2, 1f; \
//     bne x0, TESTNUM, 2f; \
// 1:  bne x0, TESTNUM, fail; \
// 2:  inst x1, x2, 1b; \
// 3:

// #define TEST_BR2_SRC12_BYPASS( testnum, src1_nops, src2_nops, inst, val1, val2 ) \
// test_ ## testnum: \
//     li  TESTNUM, testnum; \
//     li  x4, 0; \
// 1:  li  x1, val1; \
//     TEST_INSERT_NOPS_ ## src1_nops \
//     li  x2, val2; \
//     TEST_INSERT_NOPS_ ## src2_nops \
//     inst x1, x2, fail; \
//     addi  x4, x4, 1; \
//     li  x5, 2; \
//     bne x4, x5, 1b \

// #define TEST_BR2_SRC21_BYPASS( testnum, src1_nops, src2_nops, inst, val1, val2 ) \
// test_ ## testnum: \
//     li  TESTNUM, testnum; \
//     li  x4, 0; \
// 1:  li  x2, val2; \
//     TEST_INSERT_NOPS_ ## src1_nops \
//     li  x1, val1; \
//     TEST_INSERT_NOPS_ ## src2_nops \
//     inst x1, x2, fail; \
//     addi  x4, x4, 1; \
//     li  x5, 2; \
//     bne x4, x5, 1b \

}
