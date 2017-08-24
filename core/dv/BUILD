cc_test(
	name = "branch",	
	srcs = ["test/add.cpp"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)

cc_test(
	name = "land",	
	srcs = ["test/add.cpp"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)

cc_test(
	name = "arithmetic",	
	srcs = ["test/add.cpp"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)

cc_test(
	name = "add",	
	srcs = ["test/add.cpp"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)

cc_test(
	name = "basic",	
	srcs = ["test/basic.cpp"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)

cc_library(
	name = "riscv",
	hdrs = ["riscv.h"],	
)

cc_library(
	name = "test_combinators",
	hdrs = ["test_combinators.hpp"],
	deps = [":riscv"],
)    

cc_library(
    name = "dut_core",
    srcs = [
        "DutCore.cpp",
        "obj_dir/VDutCore__ALL.a",
    ],
    hdrs = [
        "DutCore.hpp",
        "obj_dir/VDutCore.h",
    ],
    includes = [
        "obj_dir/",
    ],
    deps = [
        ":test_combinators",
        "@verilator//:verilated",
        "@verilator//:verilated_vcd_c",
    ],
)
