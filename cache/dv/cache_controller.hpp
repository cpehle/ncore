#include "obj_dir/Vcache_controller.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <bitset>
#include <iostream>
#include <vector>

namespace cache_controller {
struct Memory {
  std::vector<uint32_t> memory;
};

struct cache_tag_t {
  bool valid;
  bool dirty;
  uint32_t tag;
};

struct cache_req_t {
  uint16_t index;
  bool we;
};

typedef uint32_t cache_data_t[4];

struct cpu_req_t {
  uint32_t addr;
  uint32_t data;
  bool rw;
  bool valid;
};

typedef struct {
  uint32_t data;
  logic ready;
} cpu_resp_t;

typedef struct {
  uint32_t addr;
  cache_data_t data;
  bool rw;
  bool valid;
} mem_req_t;

typedef struct {
  cache_data_t data;
  logic ready;
} mem_resp_t;

void simulate(Vcache_controller *core, Memory &m, const size_t N,
              VerilatedVcdC *tfp);
}
