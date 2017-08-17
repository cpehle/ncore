#include <array>
#include <bitset>

namespace core {

struct ICacheReq {
  uint32_t addr;
};

struct ICacheResp {
  uint32_t data;
  std::array<uint32_t, 8> datablock;
};

template <int nWays, int nSets> class ICache {
        std::bitset<nWays * nSets> vb_array;
        uint32_t refill_address;
        uint32_t s1_vaddr;
        bool s1_valid;
        bool invalidated;
        enum State { Ready, Request, RefillWait, Refill } state;

        void req() {

        }

        resp() {

        }
};
}
