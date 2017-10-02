#include "core/dv/cache_controller.hpp"

namespace cache_controller {

void simulate(Vcache_controller *core, Memory &m, const size_t N,
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

      core->cpu_req
      core->mem_data

      core->mem_req
      core->cpu_resp


      
    }

    core->eval();
  }
}
core->final();
}
}
