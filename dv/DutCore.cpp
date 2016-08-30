#include "VDutCore.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <vector>
#include <stdio.h>

namespace DutCore {
        struct Memory {
                std::vector<uint32_t> instruction_memory;
                std::vector<uint32_t> data_memory;
        };

        void simulate(VDutCore* core, Memory m, const size_t N, VerilatedVcdC* tfp) {
                core->clk = 0;
                for (size_t i = 0; i < N; i++) {
                        for (int clk = 0; clk < 2; clk++) {
                                tfp->dump(2*i+clk);
                                core->clk = !core->clk;
                                // service instruction memory requests
                                uint32_t iaddr = core->imem_in_req_addr;
                                core->imem_out_req_ready = 1;
                                if (core->imem_in_req_valid) {
                                        core->imem_out_res_data = m.instruction_memory[iaddr];
                                        core->imem_out_res_valid = 1;
                                }

                                // service data memory requests
                                uint32_t daddr = core->dmem_in_req_addr;
                                core->dmem_out_req_ready = 1;
                                if (core->dmem_in_req_valid) {
                                        core->dmem_out_res_data = m.data_memory[daddr];
                                        core->dmem_out_res_valid = 1;
                                }

                                core->eval();
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
        DutCore::Memory m = {
                instruction_memory,
                data_memory
        };

        for (int i = 0; i < 10000; i++) {
                m.instruction_memory.push_back(0x0);
                m.data_memory.push_back(0x0);
        }

        simulate(core, m, 1000, tfp);
        tfp->close();
}
