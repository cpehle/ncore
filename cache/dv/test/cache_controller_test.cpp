#include "cache/dv/cache_controller.hpp"
#include "gtest/gtest.h"

TEST(Cache, RW) {
  Vcache_controller *cache = new Vcache_controler("cache");
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  core->trace(tfp, 99);
  tfp->open("cache_rw.vcd");

  std::vector<uint32_t> memory_data(10000);
  cache_controller::Memory memory = { memory_data } ;
  cache_controller::simulate(cache, memory, 1000, tfp);
}
