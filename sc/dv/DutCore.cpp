#include "VDutCore.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <vector>
#include <iostream>

namespace riscv {
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

        uint32_t imm_20_10$1_11_19$12(uint32_t imm) {
                return (imm & 20) | (~(1 << 11) & (imm >> 1)) | (imm & 11) | (~(1 << 9) & (imm >> 12));
        }

        uint32_t imm_12_10$5(uint32_t imm) {
                return (imm & 12) | (~(1 << 7) & (imm >> 5));
        }

        uint32_t imm_4$1_11(uint32_t imm) {
                return (~(1 << 6) & (imm >> 1)) | (imm & 11);
        }

        void lui(std::vector<uint32_t>& instructions, reg rd, uint32_t imm20) {
                uint32_t opcode = 0b0110111;
                instructions.push_back(imm20 << 12 | rd << 7 | opcode);
        }

        void auipc(std::vector<uint32_t>& instructions, reg rd, uint32_t imm20) {
                uint32_t opcode = 0b0010111;
                instructions.push_back(imm20 << 12 | rd << 7 | opcode);
        }

        void jal(std::vector<uint32_t>& instructions, reg rd, uint32_t imm20) {
                uint32_t opcode = 0b1101111;
                instructions.push_back(imm_20_10$1_11_19$12(imm20) << 12 | rd << 7 | opcode);
        }

        void jalr(std::vector<uint32_t>& instructions, reg rd, reg rs1, uint32_t imm12) {
                uint32_t opcode = 0b0010111;
                uint32_t func3 = 0b000;
                instructions.push_back(imm12 << 20 | rs1 << 15 | func3 << 12 | rd << 7 | opcode);
        }

        void beq(std::vector<uint32_t>& instructions, reg rs1, reg rs2, uint32_t imm13) {
                uint32_t opcode = 0b0010111;
                uint32_t func3 = 0b000;
                instructions.push_back(imm_12_10$5(imm13) << 20 | rs1 << 15 | func3 << 12 | imm_4$1_11(imm13) << 7 | opcode);
        }

        void bne(std::vector<uint32_t>& instructions, reg rs1, reg rs2, uint32_t imm13) {
                uint32_t opcode = 0b0010111;
                uint32_t func3 = 0b001;
                instructions.push_back(imm_12_10$5(imm13) << 20 | rs1 << 15 | func3 << 12 | imm_4$1_11(imm13) << 7 | opcode);
        }

        void blt(std::vector<uint32_t>& instructions, reg rs1, reg rs2, uint32_t imm13) {
                uint32_t opcode = 0b0010111;
                uint32_t func3 = 0b100;
                instructions.push_back(imm_12_10$5(imm13) << 20 | rs1 << 15 | func3 << 12 | imm_4$1_11(imm13) << 7 | opcode);
        }

        void bge(std::vector<uint32_t>& instructions, reg rs1, reg rs2, uint32_t imm13) {
                uint32_t opcode = 0b0010111;
                uint32_t func3 = 0b101;
                instructions.push_back(imm_12_10$5(imm13) << 20 | rs1 << 15 | func3 << 12 | imm_4$1_11(imm13) << 7 | opcode);
        }

        void bltu(std::vector<uint32_t>& instructions, reg rs1, reg rs2, uint32_t imm13) {
                uint32_t opcode = 0b0010111;
                uint32_t func3 = 0b110;
                instructions.push_back(imm_12_10$5(imm13) << 20 | rs1 << 15 | func3 << 12 | imm_4$1_11(imm13) << 7 | opcode);
        }

        void bgeu(std::vector<uint32_t>& instructions, reg rs1, reg rs2, uint32_t imm13) {
                uint32_t opcode = 0b0010111;
                uint32_t func3 = 0b111;
                instructions.push_back(imm_12_10$5(imm13) << 20 | rs1 << 15 | func3 << 12 | imm_4$1_11(imm13) << 7 | opcode);
        }

        void lb(std::vector<uint32_t>& instructions, reg rd, reg rs1, uint32_t imm12) {
                uint32_t ins = 0b0000011;
                uint32_t op = 0b000;
                instructions.push_back(imm12 << 20 | rs1 << 15 |  op << 12 | rd << 7 | ins);
        }

        void lh(std::vector<uint32_t>& instructions, reg rd, reg rs1, uint32_t imm12) {
                uint32_t opcode = 0b0000011;
                uint32_t func3 = 0b001;
                instructions.push_back(imm12 << 20 | rs1 << 15 |  func3 << 12 | rd << 7 | opcode);
        }

        void lw(std::vector<uint32_t>& instructions, reg rd, reg rs1, uint32_t imm12) {
                uint32_t ins = 0b0000011;
                uint32_t op = 0b010;
                instructions.push_back(imm12 << 20 | rs1 << 15 |  op << 12 | rd << 7 | ins);
        }

        void lbu(std::vector<uint32_t>& instructions, reg rd, reg rs1, uint32_t imm12) {
                uint32_t ins = 0b0000011;
                uint32_t op = 0b100;
                instructions.push_back(imm12 << 20 | rs1 << 15 |  op << 12 | rd << 7 | ins);
        }

        void lhu(std::vector<uint32_t>& instructions, reg rd, reg rs1, uint32_t imm12) {
                uint32_t ins = 0b0000011;
                uint32_t op = 0b101;
                instructions.push_back(imm12 << 20 | rs1 << 15 |  op << 12 | rd << 7 | ins);
        }

        void sb(std::vector<uint32_t>& instructions, reg rs1, uint32_t imm, reg rs2) {
                uint32_t opcode = 0b100011;
                uint32_t funct3 = 0b000;
                instructions.push_back((imm >> 4) << 25 | rs2 << 20 | rs1 << 15 |  funct3 << 12 | (imm & ~(1 << 6)) << 7 | opcode);
        }

        void sh(std::vector<uint32_t>& instructions, reg rs1, uint32_t imm, reg rs2) {
                uint32_t opcode = 0b100011;
                uint32_t funct3 = 0b001;
                instructions.push_back((imm >> 4) << 25 | rs2 << 20 | rs1 << 15 |  funct3 << 12 | (imm & ~(1 << 6)) << 7 | opcode);
        }

        void sw(std::vector<uint32_t>& instructions, reg rs1, uint32_t imm, reg rs2) {
                uint32_t opcode = 0b100011;
                uint32_t funct3 = 0b010;
                instructions.push_back((imm >> 4) << 25 | rs2 << 20 | rs1 << 15 |  funct3 << 12 | (imm & ~(1 << 6)) << 7 | opcode);
        }

        void addi(std::vector<uint32_t>& instructions, reg rd, reg rs1, uint32_t imm12) {
                uint32_t opcode = 0b0010011;
                uint32_t funct3 = 0b000;
                instructions.push_back(imm12 << 20 | rs1 << 15 |  funct3 << 12 | rd << 7 | opcode);
        }

        void add(std::vector<uint32_t>& instructions, reg rd, reg rs2, reg rs1) {
                uint32_t opcode = 0b0110011;
                uint32_t funct7 = 0b0000000;
                uint32_t funct3 = 0b000;
                instructions.push_back(funct7 << 25 | rs2 << 20 | rs1 << 15 |  funct3 << 12 | rd << 7 | opcode);
        }

        void sub(std::vector<uint32_t>& instructions, reg rd, reg rs2, reg rs1) {
                uint32_t opcode = 0b0110011;
                uint32_t funct7 = 0b0100000;
                uint32_t funct3 = 0b000;
                instructions.push_back(funct7 << 25 | rs2 << 20 | rs1 << 15 |  funct3 << 12 | rd << 7 | opcode);
        }




}

namespace DutCore {
        struct Memory {
                std::vector<uint32_t> instruction_memory;
                std::vector<uint32_t> data_memory;
        };

        void simulate(VDutCore* core, Memory& m, const size_t N, VerilatedVcdC* tfp) {
                core->clk = 0;
                for (size_t i = 0; i < N; i++) {
                        for (int clk = 0; clk < 2; clk++) {
                                tfp->dump(2*i+clk);
                                core->clk = !core->clk;
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

                        if (core->dmem_in_req_valid) {
                                uint32_t daddr = core->dmem_in_req_addr/4;
                                switch (core->dmem_in_req_fcn) {
                                case 0x0:
                                        std::cout << "r " << daddr << std::endl;
                                        break;
                                case 0x1:
                                        std::cout << "w " << daddr  << " " << core->dmem_in_req_data << std::endl;
                                        break;
                                }
                        }

                }

        }
}


int main(int argc, char** argv) {
        Verilated::commandArgs(argc, argv);
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;

        core->trace(tfp, 99);
        tfp->open("core.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::addi(instruction_memory,riscv::reg::x5,riscv::reg::x0,30);
        riscv::addi(instruction_memory,riscv::reg::x6,riscv::reg::x0,40);
        riscv::add(instruction_memory,riscv::reg::x7,riscv::reg::x5,riscv::reg::x6);
        riscv::addi(instruction_memory,riscv::reg::x1,riscv::reg::x0,4);
        //
        // riscv::lw(instruction_memory,riscv::reg::x2,riscv::reg::x0,5);
        // riscv::add(instruction_memory,riscv::reg::x1,riscv::reg::x2,riscv::reg::x3);
        riscv::sw(instruction_memory,riscv::reg::x1,0,riscv::reg::x7);
        riscv::lw(instruction_memory,riscv::reg::x3,riscv::reg::x0,0);

        for (int i = 0; i < 1000; i++) {
                instruction_memory.push_back(0x00000013);
                data_memory.push_back(i*4);
        }

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };

        simulate(core, m, 100, tfp);

        for (int i = 0; i < 10; i++) {
                std::cout << m.data_memory[i] << std::endl;
        }

        tfp->close();
}
