#include "obj_dir/VDutCore.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "core/dv/test_combinators.hpp"
#include "core/dv/DutCore.hpp"

#include "riscv.h"

#include <bitset>
#include <iostream>
#include <vector>

namespace DutCore {
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
        if (iaddr >= m.instruction_memory.size()) {
          core->imem_out_res_data = 0x13;
          core->imem_out_res_valid = 1;
          std::cout << "fetch out of bound instruction" << std::endl;
        } else {
          core->imem_out_res_data = m.instruction_memory[iaddr];
          core->imem_out_res_valid = 1;
        }
      }

      // service data memory requests
      uint32_t daddr = core->dmem_in_req_addr / 4;
      core->dmem_out_req_ready = 1;
      if (core->dmem_in_req_valid) {
        if (daddr >= m.data_memory.size()) {
          std::cout << "out of bound data memory" << std::endl;
          switch (core->dmem_in_req_fcn) {
          case 0x0:
	    std::cout << "read" << std::endl;
            core->dmem_out_res_data = 0;
            core->dmem_out_res_valid = 1;
            break;
          case 0x1:
	    std::cout << "write" << std::endl;
	    // do nothing
            break;
          }
        } else {
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
}



