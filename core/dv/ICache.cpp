#include <stdint.h>

#include <array>

namespace core {
        class ICache {

                ICache() : state(Ready) {

                }

                enum State {
                        Ready,
                        Request,
                        RefillWait,
                        Refill
                };
                State state;

                void req(uint32_t addr) {

                }

                 void resp() {

                }



                std::array<bool,32> tag_cache;
                std::array<bool,32> tag_array;

        };
}
