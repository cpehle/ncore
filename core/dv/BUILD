cc_test(
	name = "dut_core_test",	
	srcs = ["DutCore.cpp"],
	deps = [":dut_core", ":riscv", "@gtest//:main"],
)

cc_library(
	name = "riscv",
	hdrs = ["riscv.h"],	
)	

cc_library(
    name = "dut_core",
    srcs = [
        "obj_dir/VDutCore__ALL.a",
    ],
    hdrs = [
        "obj_dir/VDutCore.h",
    ],
    includes = [
        "obj_dir/",
    ],
    deps = [
        "@verilator//:verilated",
        "@verilator//:verilated_vcd_c",
    ],
)
