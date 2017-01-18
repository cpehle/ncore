#include "verilated.h"
#include "verilated_vcd_c.h"
#include "obj_dir/VDutCore.h"
#include "gtest/gtest.h"

#include "riscv.h"

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

        void simulate(VDutCore* core, Memory& m, const size_t N, const Options opt, VerilatedVcdC* tfp) {
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

                        if (opt.trace_memory) {
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
};


TEST(DutTest,AddStore) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("AddStore.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::addi(instruction_memory,riscv::reg::x5,riscv::reg::x0,30);
        riscv::addi(instruction_memory,riscv::reg::x6,riscv::reg::x0,40);
        riscv::add(instruction_memory,riscv::reg::x7,riscv::reg::x5,riscv::reg::x6);
        riscv::addi(instruction_memory,riscv::reg::x1,riscv::reg::x0,4);
        riscv::sw(instruction_memory,riscv::reg::x1,0,riscv::reg::x7);

        const uint32_t nop = 0x13;
        for (int i = 0; i < 1000; i++) {
                instruction_memory.push_back(nop);
                data_memory.push_back(i);
        }

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = false };

        simulate(core, m, 100, opt, tfp);
        EXPECT_EQ(m.data_memory[1],70);
}

TEST(DutTest,LoadStore) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("LoadStore.vcd");
        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::addi(instruction_memory,riscv::reg::x5,riscv::reg::x0,4);
        riscv::lw(instruction_memory,riscv::reg::x3,riscv::reg::x5,0);
        riscv::addi(instruction_memory,riscv::reg::x1,riscv::reg::x0,8);
        riscv::sw(instruction_memory,riscv::reg::x1,0,riscv::reg::x3);

        const uint32_t nop = 0x13;
        for (int i = 0; i < 1000; i++) {
                instruction_memory.push_back(nop);
                data_memory.push_back(i);
        }

        data_memory[1] = 100;

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = false };

        simulate(core, m, 100, opt, tfp);
        EXPECT_EQ(m.data_memory[2],100);
}


TEST(DutTest,LoadSubStoreWithNop) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("LoadSubStoreWithNop.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::addi(instruction_memory,riscv::reg::x5,riscv::reg::x0,4);
        riscv::lw(instruction_memory,riscv::reg::x3,riscv::reg::x5,0);
        riscv::addi(instruction_memory,riscv::reg::x6,riscv::reg::x0,16);
        riscv::lw(instruction_memory,riscv::reg::x4,riscv::reg::x6,0);
        riscv::nop(instruction_memory);
        riscv::sub(instruction_memory,riscv::reg::x7,riscv::reg::x4,riscv::reg::x3);
        riscv::addi(instruction_memory,riscv::reg::x1,riscv::reg::x0,8);
        riscv::sw(instruction_memory,riscv::reg::x1,0,riscv::reg::x7);

        const uint32_t nop = 0x13;
        for (int i = 0; i < 1000; i++) {
                instruction_memory.push_back(nop);
                data_memory.push_back(0);
        }
        data_memory[1] = 11;
        data_memory[4] = 7;

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = false };

        simulate(core, m, 100, opt, tfp);
        EXPECT_EQ(m.data_memory[2],4);
}

TEST(DutTest,LoadSubStore) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("LoadSubStore.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::addi(instruction_memory,riscv::reg::x5,riscv::reg::x0,4);
        riscv::lw(instruction_memory,riscv::reg::x3,riscv::reg::x5,0);
        riscv::addi(instruction_memory,riscv::reg::x6,riscv::reg::x0,16);
        riscv::lw(instruction_memory,riscv::reg::x4,riscv::reg::x6,0);
        // NOP
        riscv::sub(instruction_memory,riscv::reg::x7,riscv::reg::x4,riscv::reg::x3);
        riscv::addi(instruction_memory,riscv::reg::x1,riscv::reg::x0,8);
        riscv::sw(instruction_memory,riscv::reg::x1,0,riscv::reg::x7);

        const uint32_t nop = 0x13;
        for (int i = 0; i < 10; i++) {
                instruction_memory.push_back(nop);
                data_memory.push_back(0);
        }

        data_memory[1] = 11;
        data_memory[4] = 7;

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = false };

        simulate(core, m, 10, opt, tfp);
        EXPECT_EQ(m.data_memory[2],4);
}

TEST(DutTest,LoadOrStoreWithNop) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("LoadOrStoreWithNop.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::addi(instruction_memory,riscv::reg::x5,riscv::reg::x0,4);
        riscv::lw(instruction_memory,riscv::reg::x3,riscv::reg::x5,0);
        riscv::addi(instruction_memory,riscv::reg::x6,riscv::reg::x0,16);
        riscv::lw(instruction_memory,riscv::reg::x4,riscv::reg::x6,0);
        riscv::nop(instruction_memory);
        riscv::lor(instruction_memory,riscv::reg::x7,riscv::reg::x4,riscv::reg::x3);
        riscv::addi(instruction_memory,riscv::reg::x1,riscv::reg::x0,8);
        riscv::sw(instruction_memory,riscv::reg::x1,0,riscv::reg::x7);

        const uint32_t nop = 0x13;
        for (int i = 0; i < 1000; i++) {
                instruction_memory.push_back(nop);
                data_memory.push_back(0);
        }
        data_memory[1] = 11;
        data_memory[4] = 7;

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = false };

        simulate(core, m, 100, opt, tfp);
        EXPECT_EQ(m.data_memory[2], 11 | 7);
}

TEST(DutTest,LoadOrStore) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("LoadOrStore.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::addi(instruction_memory,riscv::reg::x5,riscv::reg::x0,4);
        riscv::lw(instruction_memory,riscv::reg::x3,riscv::reg::x5,0);
        riscv::addi(instruction_memory,riscv::reg::x6,riscv::reg::x0,16);
        riscv::lw(instruction_memory,riscv::reg::x4,riscv::reg::x6,0);
        riscv::lor(instruction_memory,riscv::reg::x7,riscv::reg::x4,riscv::reg::x3);
        riscv::addi(instruction_memory,riscv::reg::x1,riscv::reg::x0,8);
        riscv::sw(instruction_memory,riscv::reg::x1,0,riscv::reg::x7);

        const uint32_t nop = 0x13;
        for (int i = 0; i < 1000; i++) {
                instruction_memory.push_back(nop);
                data_memory.push_back(0);
        }

        data_memory[1] = 11;
        data_memory[4] = 7;

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = false };

        simulate(core, m, 100, opt, tfp);
        EXPECT_EQ(m.data_memory[2],11 | 7);
}


TEST(DutTest,LoadAndStoreWithNop) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("LoadAndStoreWithNop.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::addi(instruction_memory,riscv::reg::x5,riscv::reg::x0,4);
        riscv::lw(instruction_memory,riscv::reg::x3,riscv::reg::x5,0);
        riscv::addi(instruction_memory,riscv::reg::x6,riscv::reg::x0,16);
        riscv::lw(instruction_memory,riscv::reg::x4,riscv::reg::x6,0);
        riscv::nop(instruction_memory);
        riscv::land(instruction_memory,riscv::reg::x7,riscv::reg::x4,riscv::reg::x3);
        riscv::addi(instruction_memory,riscv::reg::x1,riscv::reg::x0,8);
        riscv::sw(instruction_memory,riscv::reg::x1,0,riscv::reg::x7);

        const uint32_t nop = 0x13;
        for (int i = 0; i < 1000; i++) {
                instruction_memory.push_back(nop);
                data_memory.push_back(0);
        }
        data_memory[1] = 11;
        data_memory[4] = 7;

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = false };

        simulate(core, m, 100, opt, tfp);
        EXPECT_EQ(m.data_memory[2], 11 & 7);
}

TEST(DutTest,LoadAndStore) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("LoadAndStore.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::addi(instruction_memory,riscv::reg::x5,riscv::reg::x0,4);
        riscv::lw(instruction_memory,riscv::reg::x3,riscv::reg::x5,0);
        riscv::addi(instruction_memory,riscv::reg::x6,riscv::reg::x0,16);
        riscv::lw(instruction_memory,riscv::reg::x4,riscv::reg::x6,0);
        riscv::land(instruction_memory,riscv::reg::x7,riscv::reg::x4,riscv::reg::x3);
        riscv::addi(instruction_memory,riscv::reg::x1,riscv::reg::x0,8);
        riscv::sw(instruction_memory,riscv::reg::x1,0,riscv::reg::x7);

        const uint32_t nop = 0x13;
        for (int i = 0; i < 1000; i++) {
                instruction_memory.push_back(nop);
                data_memory.push_back(0);
        }

        data_memory[1] = 11;
        data_memory[4] = 7;

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = false };

        simulate(core, m, 100, opt, tfp);
        EXPECT_EQ(m.data_memory[2], 11 & 7);
}




TEST(DutTest,LoadAddStoreWithNop) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("LoadAddStoreWithNop.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::addi(instruction_memory,riscv::reg::x5,riscv::reg::x0,4);
        riscv::lw(instruction_memory,riscv::reg::x3,riscv::reg::x5,0);
        riscv::addi(instruction_memory,riscv::reg::x6,riscv::reg::x0,16);
        riscv::lw(instruction_memory,riscv::reg::x4,riscv::reg::x6,0);
        riscv::nop(instruction_memory);
        riscv::add(instruction_memory,riscv::reg::x7,riscv::reg::x4,riscv::reg::x3);
        riscv::addi(instruction_memory,riscv::reg::x1,riscv::reg::x0,8);
        riscv::sw(instruction_memory,riscv::reg::x1,0,riscv::reg::x7);

        const uint32_t nop = 0x13;
        for (int i = 0; i < 1000; i++) {
                instruction_memory.push_back(nop);
                data_memory.push_back(0);
        }
        data_memory[1] = 11;
        data_memory[4] = 7;

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = false };

        simulate(core, m, 100, opt, tfp);
        EXPECT_EQ(m.data_memory[2],11 + 7);
}

TEST(DutTest,LoadAddStore) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("LoadAddStore.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::addi(instruction_memory,riscv::reg::x5,riscv::reg::x0,4);
        riscv::lw(instruction_memory,riscv::reg::x3,riscv::reg::x5,0);
        riscv::addi(instruction_memory,riscv::reg::x6,riscv::reg::x0,20);
        riscv::lw(instruction_memory,riscv::reg::x4,riscv::reg::x6,0);
        riscv::add(instruction_memory,riscv::reg::x7,riscv::reg::x4,riscv::reg::x3);
        riscv::addi(instruction_memory,riscv::reg::x1,riscv::reg::x0,8);
        riscv::sw(instruction_memory,riscv::reg::x1,0,riscv::reg::x7);

        const uint32_t nop = 0x13;
        for (int i = 0; i < 1000; i++) {
                instruction_memory.push_back(nop);
                data_memory.push_back(0);
        }

        data_memory[1] = 2;
        data_memory[5] = 3;

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = false };

        simulate(core, m, 100, opt, tfp);
        EXPECT_EQ(m.data_memory[2],2+3);
}

TEST(DutTest,StoreWord) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("StoreWord.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;


        riscv::sw(instruction_memory,riscv::reg::x0,8,riscv::reg::x0);

        for (int i = 0; i < 1000; i++) {
                riscv::nop(instruction_memory);
                data_memory.push_back(0xffff);
        }

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = true };

        simulate(core, m, 100, opt, tfp);
        EXPECT_EQ(m.data_memory[0],0);
}


TEST(DutTest,LoadAddStoreImm) {
        VDutCore* core = new VDutCore("Core");
        Verilated::traceEverOn(true);
        VerilatedVcdC* tfp = new VerilatedVcdC;
        core->trace(tfp, 99);
        tfp->open("LoadAddStore.vcd");

        std::vector<uint32_t> instruction_memory;
        std::vector<uint32_t> data_memory;

        riscv::lw(instruction_memory,riscv::reg::x3,riscv::reg::x0,4);
        riscv::lw(instruction_memory,riscv::reg::x4,riscv::reg::x0,20);
        riscv::add(instruction_memory,riscv::reg::x7,riscv::reg::x4,riscv::reg::x3);
        riscv::sw(instruction_memory,riscv::reg::x0,8,riscv::reg::x7);

        const uint32_t nop = 0x13;
        for (int i = 0; i < 1000; i++) {
                instruction_memory.push_back(nop);
                data_memory.push_back(0);
        }

        data_memory[1] = 2;
        data_memory[5] = 3;

        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };
        DutCore::Options opt = { .trace_memory = false };

        simulate(core, m, 100, opt, tfp);
        EXPECT_EQ(m.data_memory[2],2+3);
}
