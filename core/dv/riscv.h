#pragma once

#include <vector>

namespace riscv {
// Namespace: riscv
enum reg {
  x0 = 0,
  x1 = 1,
  x2 = 2,
  x3 = 3,
  x4 = 4,
  x5 = 5,
  x6 = 6,
  x7 = 7,
  x8 = 8,
  x9 = 9,
  x10 = 10,
  x11 = 11,
  x12 = 12,
  x13 = 13,
  x14 = 14,
  x15 = 15,
  x16 = 16,
  x17 = 17,
  x18 = 18,
  x19 = 19,
  x20 = 20,
  x21 = 21,
  x22 = 22,
  x23 = 23,
  x24 = 24,
  x25 = 25,
  x26 = 26,
  x27 = 27,
  x28 = 28,
  x29 = 29,
  x30 = 30,
  x31 = 31
};

uint32_t bits(uint32_t imm, int start, int number) {
  uint32_t mask = 0xffffffff;
  return (imm >> start) & (mask >> (32 - number));
}

// imm[20] imm[10:1] imm[11] imm[19:12]
uint32_t imm_ujtype(uint32_t imm) {
  uint32_t imm_20 = (imm >> 20) & 0x1;
  uint32_t imm_10_1 = bits(imm, 1, 10);
  uint32_t imm_11 = (imm >> 11) & 0x1;
  uint32_t imm_19_12 = bits(imm, 12, 8);
  return (imm_20 << 19) | (imm_10_1 << 9) | (imm_11 << 8) | imm_19_12;
}

uint32_t imm_utype(uint32_t imm) { return bits(imm, 12, 20); }

struct branch_offset {
  uint32_t upper;
  uint32_t lower;
};

branch_offset offset_branch(uint32_t imm) {
  uint32_t imm_12 = bits(imm, 12, 1);
  uint32_t imm_10_5 = bits(imm, 5, 6);
  uint32_t imm_11 = bits(imm, 11, 1);
  uint32_t imm_4_1 = bits(imm, 1, 4);
  return {(imm_12 << 6) | imm_10_5, ((imm_4_1 << 1) | imm_11)};
}

reg regs[] = {x0,  x1,  x2,  x3,  x4,  x5,  x6,  x7,  x8,  x9,  x10,
              x11, x12, x14, x15, x16, x17, x18, x19, x20, x21, x22,
              x23, x24, x25, x26, x27, x28, x29, x30, x31};

uint32_t imm_12_10$5(uint32_t imm) {
  uint32_t imm_12 = bits(imm, 12, 1);
  uint32_t imm_10_5 = bits(imm, 5, 6);
  return (imm_12 << 7) | imm_10_5;
}

uint32_t imm_4$1_11(uint32_t imm) {
  uint32_t imm_4_1 = bits(imm, 1, 4);
  uint32_t imm_11 = (imm >> 11) & 0x1;
  return (imm_4_1 << 1) | (imm_11);
}

void nop(std::vector<uint32_t> &instructions) { instructions.push_back(0x13); }

void lui(std::vector<uint32_t> &instructions, reg rd, uint32_t imm20) {
  uint32_t opcode = 0b0110111;
  instructions.push_back(imm_utype(imm20) << 12 | rd << 7 | opcode);
}

void auipc(std::vector<uint32_t> &instructions, reg rd, uint32_t imm20) {
  uint32_t opcode = 0b0010111;
  instructions.push_back(imm20 << 12 | rd << 7 | opcode);
}

void jal(std::vector<uint32_t> &instructions, reg rd, uint32_t imm20) {
  uint32_t opcode = 0b1101111;
  instructions.push_back(imm_ujtype(imm20) << 12 | rd << 7 | opcode);
}

void jalr(std::vector<uint32_t> &instructions, reg rd, reg rs1,
          uint32_t imm12) {
  uint32_t opcode = 0b0010111;
  uint32_t func3 = 0b000;
  instructions.push_back(imm12 << 20 | rs1 << 15 | func3 << 12 | rd << 7 |
                         opcode);
}

void beq(std::vector<uint32_t> &instructions, reg rs1, reg rs2,
         uint32_t imm13) {
  uint32_t opcode = 0b1100011;
  uint32_t func3 = 0b000;
  auto offset = offset_branch(imm13);
  instructions.push_back(offset.upper << 25 | rs2 << 20 | rs1 << 15 |
                         func3 << 12 | offset.lower << 7 | opcode);
}

void bne(std::vector<uint32_t> &instructions, reg rs1, reg rs2,
         uint32_t imm13) {
  uint32_t opcode = 0b1100011;
  uint32_t func3 = 0b001;
  auto offset = offset_branch(imm13);
  instructions.push_back(offset.upper << 25 | rs2 << 20 | rs1 << 15 |
                         func3 << 12 | offset.lower << 7 | opcode);
}

void blt(std::vector<uint32_t> &instructions, reg rs1, reg rs2,
         uint32_t imm13) {
  uint32_t opcode = 0b1100011;
  uint32_t func3 = 0b100;
  auto offset = offset_branch(imm13);
  instructions.push_back(offset.upper << 25 | rs2 << 20 | rs1 << 15 |
                         func3 << 12 | offset.lower << 7 | opcode);
}

void bge(std::vector<uint32_t> &instructions, reg rs1, reg rs2,
         uint32_t imm13) {
  uint32_t opcode = 0b1100011;
  uint32_t func3 = 0b101;
  auto offset = offset_branch(imm13);
  instructions.push_back(offset.upper << 25 | rs2 << 20 | rs1 << 15 |
                         func3 << 12 | offset.lower << 7 | opcode);
}

void bltu(std::vector<uint32_t> &instructions, reg rs1, reg rs2,
          uint32_t imm13) {
  uint32_t opcode = 0b0010111;
  uint32_t func3 = 0b110;
  auto offset = offset_branch(imm13);
  instructions.push_back(offset.upper << 25 | rs2 << 20 | rs1 << 15 |
                         func3 << 12 | offset.lower << 7 | opcode);
}

void bgeu(std::vector<uint32_t> &instructions, reg rs1, reg rs2,
          uint32_t imm13) {
  uint32_t opcode = 0b0010111;
  uint32_t func3 = 0b111;
  auto offset = offset_branch(imm13);
  instructions.push_back(offset.upper << 25 | rs2 << 20 | rs1 << 15 |
                         func3 << 12 | offset.lower << 7 | opcode);
}

void lb(std::vector<uint32_t> &instructions, reg rd, reg rs1, uint32_t imm12) {
  uint32_t ins = 0b0000011;
  uint32_t op = 0b000;
  instructions.push_back(imm12 << 20 | rs1 << 15 | op << 12 | rd << 7 | ins);
}

void lh(std::vector<uint32_t> &instructions, reg rd, reg rs1, uint32_t imm12) {
  uint32_t opcode = 0b0000011;
  uint32_t func3 = 0b001;
  instructions.push_back(imm12 << 20 | rs1 << 15 | func3 << 12 | rd << 7 |
                         opcode);
}

void lw(std::vector<uint32_t> &instructions, reg rd, reg rs1, uint32_t imm12) {
  uint32_t ins = 0b0000011;
  uint32_t op = 0b010;
  instructions.push_back(imm12 << 20 | rs1 << 15 | op << 12 | rd << 7 | ins);
}

void lbu(std::vector<uint32_t> &instructions, reg rd, reg rs1, uint32_t imm12) {
  uint32_t ins = 0b0000011;
  uint32_t op = 0b100;
  instructions.push_back(imm12 << 20 | rs1 << 15 | op << 12 | rd << 7 | ins);
}

void lhu(std::vector<uint32_t> &instructions, reg rd, reg rs1, uint32_t imm12) {
  uint32_t ins = 0b0000011;
  uint32_t op = 0b101;
  instructions.push_back(imm12 << 20 | rs1 << 15 | op << 12 | rd << 7 | ins);
}

void sb(std::vector<uint32_t> &instructions, reg rs1, uint32_t imm, reg rs2) {
  uint32_t opcode = 0b100011;
  uint32_t funct3 = 0b000;
  instructions.push_back((imm >> 5) << 25 | rs2 << 20 | rs1 << 15 |
                         funct3 << 12 | (imm & ~(1 << 6)) << 7 | opcode);
}

void sh(std::vector<uint32_t> &instructions, reg rs1, uint32_t imm, reg rs2) {
  uint32_t opcode = 0b100011;
  uint32_t funct3 = 0b001;
  instructions.push_back((imm >> 5) << 25 | rs2 << 20 | rs1 << 15 |
                         funct3 << 12 | (imm & ~(1 << 6)) << 7 | opcode);
}

void sw(std::vector<uint32_t> &instructions, reg rs1, uint32_t imm, reg rs2) {
  uint32_t opcode = 0b100011;
  uint32_t funct3 = 0b010;
  instructions.push_back((imm >> 5) << 25 | rs2 << 20 | rs1 << 15 |
                         funct3 << 12 | (imm & ~(1 << 6)) << 7 | opcode);
}

void addi(std::vector<uint32_t> &instructions, reg rd, reg rs1,
          uint32_t imm12) {
  uint32_t opcode = 0b0010011;
  uint32_t funct3 = 0b000;
  instructions.push_back(bits(imm12,0,12) << 20 | rs1 << 15 | funct3 << 12 | rd << 7 |
                         opcode);
}

void ori(std::vector<uint32_t> &instructions, reg rd, reg rs1,
          uint32_t imm12) {
  uint32_t opcode = 0b0010011;
  uint32_t funct3 = 0b110;
  instructions.push_back(bits(imm12,0,12) << 20 | rs1 << 15 | funct3 << 12 | rd << 7 |
                         opcode);
}
 

void add(std::vector<uint32_t> &instructions, reg rd, reg rs2, reg rs1) {
  uint32_t opcode = 0b0110011;
  uint32_t funct7 = 0b0000000;
  uint32_t funct3 = 0b000;
  instructions.push_back(funct7 << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 |
                         rd << 7 | opcode);
}

void sub(std::vector<uint32_t> &instructions, reg rd, reg rs2, reg rs1) {
  uint32_t opcode = 0b0110011;
  uint32_t funct7 = 0b0100000;
  uint32_t funct3 = 0b000;
  instructions.push_back(funct7 << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 |
                         rd << 7 | opcode);
}

void xor_op(std::vector<uint32_t> &instructions, reg rd, reg rs2, reg rs1) {
  uint32_t opcode = 0b0110011;
  uint32_t funct7 = 0b0000000;
  uint32_t funct3 = 0b100;
  instructions.push_back(funct7 << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 |
                         rd << 7 | opcode);
}

void sll(std::vector<uint32_t> &instructions, reg rd, reg rs2, reg rs1) {
  uint32_t opcode = 0b0110011;
  uint32_t funct7 = 0b0000000;
  uint32_t funct3 = 0b001;
  instructions.push_back(funct7 << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 |
                         rd << 7 | opcode);
}

void sra(std::vector<uint32_t> &instructions, reg rd, reg rs2, reg rs1) {
  uint32_t opcode = 0b0110011;
  uint32_t funct7 = 0b0100000;
  uint32_t funct3 = 0b101;
  instructions.push_back(funct7 << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 |
                         rd << 7 | opcode);
}

void srl(std::vector<uint32_t> &instructions, reg rd, reg rs2, reg rs1) {
  uint32_t opcode = 0b0110011;
  uint32_t funct7 = 0b0000000;
  uint32_t funct3 = 0b101;
  instructions.push_back(funct7 << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 |
                         rd << 7 | opcode);
}

void land(std::vector<uint32_t> &instructions, reg rd, reg rs2, reg rs1) {
  uint32_t opcode = 0b0110011;
  uint32_t funct7 = 0b0000000;
  uint32_t funct3 = 0b111;
  instructions.push_back(funct7 << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 |
                         rd << 7 | opcode);
}

void lor(std::vector<uint32_t> &instructions, reg rd, reg rs2, reg rs1) {
  uint32_t opcode = 0b0110011;
  uint32_t funct7 = 0b0000000;
  uint32_t funct3 = 0b110;
  instructions.push_back(funct7 << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 |
                         rd << 7 | opcode);
}

void lxor(std::vector<uint32_t> &instructions, reg rd, reg rs2, reg rs1) {
  uint32_t opcode = 0b0110011;
  uint32_t funct7 = 0b0000000;
  uint32_t funct3 = 0b100;
  instructions.push_back(funct7 << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 |
                         rd << 7 | opcode);
}

void li(std::vector<uint32_t> &instructions, reg rd, uint32_t imm) {
  lui(instructions, rd, imm);
  ori(instructions, rd, rd, bits(imm,0,12));
}
}
