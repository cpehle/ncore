#pragma once

#include "riscv.h"
#include <vector>

namespace tc {

uint64_t mask_xlen(uint64_t x, uint32_t xlen) {
  return x & ((1 << (xlen - 1) << 1) - 1);
}

uint64_t sext_imm(uint64_t x) { return ((x) | (-(((x) >> 11) & 1) << 11)); }

void insert_nops(std::vector<uint32_t>& ins, int n) {
  for (int i = 0; i < n; i++) {
    riscv::nop(ins);
  }
}

void test_result(std::vector<uint32_t> &i, riscv::reg test_reg,
                 uint64_t correct_value, uint32_t xlen) {
  riscv::li(i, riscv::reg::x29, mask_xlen(correct_value, xlen));
  /// the magic constant 6 * 4 is the number of instructions
  riscv::beq(i, test_reg, riscv::reg::x29, 6 * 4);
  /// code should be jumped over
  riscv::addi(i, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(i, riscv::reg::x6, riscv::reg::x0, 40);
  riscv::add(i, riscv::reg::x7, riscv::reg::x5, riscv::reg::x6);
  riscv::addi(i, riscv::reg::x1, riscv::reg::x0, 4);
  riscv::sw(i, riscv::reg::x1, 0, riscv::reg::x7);
  /// this code should be executed
  riscv::addi(i, riscv::reg::x5, riscv::reg::x0, 30);
  riscv::addi(i, riscv::reg::x6, riscv::reg::x0, 80);
  riscv::add(i, riscv::reg::x7, riscv::reg::x5, riscv::reg::x6);
  riscv::addi(i, riscv::reg::x1, riscv::reg::x0, 8);
  riscv::sw(i, riscv::reg::x1, 0, riscv::reg::x7);
}

//  tests for instructions with intermediate operand
void test_imm_op(std::vector<uint32_t> &i,
                 void(ins)(std::vector<uint32_t> &, riscv::reg, riscv::reg,
                           uint32_t imm),
                 uint64_t result, uint64_t val1, uint32_t imm,
                 uint32_t xlen = 32) {
  riscv::li(i, riscv::reg::x1, mask_xlen(val1, xlen));
  ins(i, riscv::reg::x30, riscv::reg::x1, sext_imm(imm));
  test_result(i, riscv::reg::x30, result, xlen);
}

void test_imm_src1_eq_dest(std::vector<uint32_t> &i,
                 void(ins)(std::vector<uint32_t> &, riscv::reg, riscv::reg,
                           uint32_t imm),
                 uint64_t result, uint64_t val1, uint32_t imm,
                 uint32_t xlen = 32) {
  riscv::li(i, riscv::reg::x1, mask_xlen(val1, xlen));
  ins(i, riscv::reg::x1, riscv::reg::x1, sext_imm(imm));
  test_result(i, riscv::reg::x1, result, xlen);
}
  
// tests for instructions with register-register operands
void test_rr_op(std::vector<uint32_t> &i,
                void(ins)(std::vector<uint32_t> &, riscv::reg, riscv::reg,
                          riscv::reg),
                uint64_t result, uint64_t val1, uint64_t val2,
                uint32_t xlen = 32) {
  riscv::li(i, riscv::reg::x1, mask_xlen(val1, xlen));
  riscv::li(i, riscv::reg::x2, mask_xlen(val2, xlen));
  ins(i, riscv::reg::x30, riscv::reg::x1, riscv::reg::x2);
  test_result(i, riscv::reg::x30, result, xlen);
}

void test_rr_src1_eq_dest(std::vector<uint32_t> &i,
                          void(ins)(std::vector<uint32_t> &, riscv::reg,
                                    riscv::reg, riscv::reg),
                          uint64_t result, uint64_t val1, uint64_t val2,
                          uint32_t xlen = 32) {
  riscv::li(i, riscv::reg::x1, mask_xlen(val1, xlen));
  riscv::li(i, riscv::reg::x2, mask_xlen(val2, xlen));
  ins(i, riscv::reg::x1, riscv::reg::x1, riscv::reg::x2);
  test_result(i, riscv::reg::x1, result, xlen);
}

void test_rr_src2_eq_dest(std::vector<uint32_t>& i,
                          void(ins)(std::vector<uint32_t>&, riscv::reg,
                                    riscv::reg, riscv::reg),
                          uint64_t result, uint64_t val1, uint64_t val2,
                          uint32_t xlen = 32) {
  riscv::li(i, riscv::reg::x1, mask_xlen(val1, xlen));
  riscv::li(i, riscv::reg::x2, mask_xlen(val2, xlen));
  ins(i, riscv::reg::x2, riscv::reg::x1, riscv::reg::x2);
  test_result(i, riscv::reg::x2, result, xlen);
}

void test_rr_src12_eq_dest(std::vector<uint32_t>& i,
                           void(ins)(std::vector<uint32_t>&, riscv::reg,
                                     riscv::reg, riscv::reg),
                           uint64_t result, uint64_t val1, uint32_t xlen = 32) {
  riscv::li(i, riscv::reg::x1, mask_xlen(val1, xlen));
  ins(i, riscv::reg::x1, riscv::reg::x1, riscv::reg::x1);
  test_result(i, riscv::reg::x1, result, xlen);
}

void test_rr_dest_bypass(std::vector<uint32_t>& i, uint32_t nop_cycles,
                         void(inst)(std::vector<uint32_t>&, riscv::reg,
                                    riscv::reg, riscv::reg),
                         uint64_t result, uint64_t val1, uint64_t val2,
                         uint32_t xlen = 32) {
  riscv::li(i, riscv::reg::x4, 0);
  // Branch back here
  riscv::li(i, riscv::reg::x1, mask_xlen(val1, xlen));
  riscv::li(i, riscv::reg::x2, mask_xlen(val2, xlen));
  inst(i, riscv::reg::x30, riscv::reg::x1, riscv::reg::x2);
  insert_nops(i, nop_cycles);
  riscv::addi(i, riscv::reg::x6, riscv::reg::x30, 0);
  riscv::addi(i, riscv::reg::x4, riscv::reg::x4, 1);
  riscv::addi(i, riscv::reg::x5, riscv::reg::x0, 2);
  riscv::bne(i, riscv::x4, riscv::x5, -6 * 4 - nop_cycles * 4);
  test_result(i, riscv::reg::x6, result, xlen);
}

void test_rr_src12_bypass(
    std::vector<uint32_t>& i, uint32_t src1_nops, uint32_t src2_nops,
    void(inst)(std::vector<uint32_t>&, riscv::reg, riscv::reg, riscv::reg),
    uint64_t result, uint64_t val1, uint64_t val2, uint32_t xlen = 32) {  
  riscv::li(i, riscv::reg::x4, 0);
  // Branch back here
  riscv::li(i, riscv::reg::x1, mask_xlen(val1, xlen));
  insert_nops(i, src1_nops);
  riscv::li(i, riscv::reg::x2, mask_xlen(val2, xlen));
  insert_nops(i, src2_nops);
  inst(i, riscv::reg::x30, riscv::reg::x1, riscv::reg::x2);
  riscv::addi(i, riscv::reg::x4, riscv::reg::x4, 1);
  riscv::addi(i, riscv::reg::x5, riscv::reg::x0, 2);
  riscv::bne(i, riscv::x4, riscv::x5, -(2 + 2 + 1 + 1 + 1 + 1 + src1_nops + src2_nops) * 4);
  test_result(i, riscv::reg::x30, result, xlen);
}

void test_rr_src21_bypass(
    std::vector<uint32_t> i, uint32_t src1_nops, uint32_t src2_nops,
    void(inst)(std::vector<uint32_t>, riscv::reg, riscv::reg, riscv::reg),
    uint64_t result, uint64_t val1, uint64_t val2, uint32_t xlen) {

  riscv::li(i, riscv::reg::x4, 0);
  // Branch back here
  riscv::li(i, riscv::reg::x2, mask_xlen(val2, xlen));
  insert_nops(i, src1_nops);
  riscv::li(i, riscv::reg::x1, mask_xlen(val1, xlen));
  insert_nops(i, src2_nops);
  inst(i, riscv::reg::x30, riscv::reg::x1, riscv::reg::x2);
  riscv::addi(i, riscv::reg::x4, riscv::reg::x4, 1);
  riscv::li(i, riscv::reg::x5, 2);
  riscv::bne(i, riscv::x4, riscv::x5, -(6 + src1_nops + src2_nops) * 4);
  test_result(i, riscv::reg::x30, result, xlen);
}

void test_rr_zerosrc1(std::vector<uint32_t> i,
                      void(inst)(std::vector<uint32_t>, riscv::reg, riscv::reg,
                                 riscv::reg),
                      uint64_t result, uint64_t val, uint32_t xlen) {
  riscv::li(i, riscv::reg::x1, mask_xlen(val, xlen));
  inst(i, riscv::reg::x2, riscv::reg::x0, riscv::reg::x1);
  test_result(i, riscv::reg::x2, result, xlen);
}

void test_rr_zerosrc2(std::vector<uint32_t> i,
                      void(inst)(std::vector<uint32_t>, riscv::reg, riscv::reg,
                                 riscv::reg),
                      uint64_t result, uint64_t val, uint32_t xlen) {
  riscv::li(i, riscv::reg::x1, mask_xlen(val, xlen));
  inst(i, riscv::reg::x2, riscv::reg::x1, riscv::reg::x0);
  test_result(i, riscv::reg::x2, result, xlen);
}

void test_rr_zerosrc12(std::vector<uint32_t> i,
                       void(inst)(std::vector<uint32_t>, riscv::reg, riscv::reg,
                                  riscv::reg),
                       uint64_t result, uint64_t val, uint32_t xlen) {
  inst(i, riscv::reg::x1, riscv::reg::x0, riscv::reg::x0);
  test_result(i, riscv::reg::x1, result, xlen);
}

void test_st_op(
    std::vector<uint32_t> i,
    void(store_inst)(std::vector<uint32_t>, riscv::reg, riscv::reg, uint32_t),
    void(load_inst)(std::vector<uint32_t>, riscv::reg, riscv::reg, uint32_t),
    uint64_t result, uint32_t offset, uint64_t base, uint32_t xlen) {
  riscv::li(i, riscv::reg::x1, base);
  riscv::li(i, riscv::reg::x2, result);
  store_inst(i, riscv::reg::x2, riscv::reg::x1, offset);
  load_inst(i, riscv::reg::x30, riscv::reg::x1, offset);
  test_result(i, riscv::reg::x30, result, xlen);
}


}
