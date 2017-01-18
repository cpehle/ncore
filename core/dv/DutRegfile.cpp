#include "verilated.h"
#include "verilated_vcd_c.h"
#include "obj_dir/VDutRegfile.h"
#include "gtest/gtest.h"

namespace DutRegfile {
        struct Regfile {
                std::vector<uint32_t> reg;
        };

        void simulate(VDutRegfile* regfile, Regfile& r, const size_t N, VerilatedVcdC* tfp) {
                core->clk = 0;
                for (size_t i = 0; i < N; i++) {
                        for (int clk = 0; clk < 2; clk++) {
                                tfp->dump(2*i+clk);
                                regfile->clk = !regfile->clk;
                                regfile->rf_in_rs1_addr =
                                regfile->rf_in_rs2_addr =
                                regfile->rf_in_waddr =
                                regfile->rf_in_we =
                                regfile->rf_in_wdata =
                                regfile->eval();
                        }
                }
        }


};

namespace {
        class DutTest : public ::testing::Test {
        protected:
                DutTest() {
                }

                virtual ~DutTest() {
                }

                virtual void SetUp() {
                }

                virtual void TearDown() {
                }
        };
};

int main(int argc, char** argv) {
        ::testing:InitGoogleTest(&argc, argv);
        return RUN_ALL_TESTS();
}
