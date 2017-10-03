py_binary(
	name = "core_ex",
	srcs = ["core_ex.py"],
	deps = [":libcore"],
)

test_suite(
    name = "instruction_tests",
    tags = ["instruction"],
)

cc_test(
	name = "branch",	
	srcs = ["test/add.cpp"],
	tags = ["instruction"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)


cc_test(
	name = "load_immediate",	
	srcs = ["test/load_immediate_test.cpp"],
	tags = ["instruction"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)


cc_test(
	name = "land",	
	srcs = ["test/add.cpp"],
	tags = ["instruction"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)

cc_test(
	name = "arithmetic",	
	srcs = ["test/add.cpp"],
	tags = ["instruction"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)

cc_test(
	name = "xor",	
	srcs = ["test/xor.cpp"],
	tags = ["instruction"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)

cc_test(
	name = "sub",	
	srcs = ["test/sub.cpp"],
	tags = ["instruction"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)

cc_test(
	name = "add",	
	srcs = ["test/add.cpp"],
	tags = ["instruction"],
	deps = [":dut_core", ":riscv", ":test_combinators", "@gtest//:main"],
)

cc_test(
	name = "basic",	
	srcs = ["test/basic.cpp"],
	tags = ["instruction"],	
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

py_library(
    name = "libriscv",
    data = [":libriscv.so"],
    imports = ["."],
    visibility = ["//visibility:public"],
)

py_library(
    name = "libcore",
    data = [":libcore.so"],
    imports = ["."],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "libriscv.so",
    srcs = [
    	"riscv.h",
        "py_riscv.cpp",
    ],
    linkshared = 1,
    linkstatic = 1,
    copts = ["-std=c++14", "-fvisibility=hidden"],
    deps = [
        "//util/python:python_headers",
        "@pybind11//:pybind11_cxx",
    ],
)


cc_binary(
    name = "libcore.so",
    srcs = [
        "core.cpp",
    ],   
    linkshared = 1,
    linkstatic = 1,
    copts = ["-std=c++14", "-fvisibility=hidden"],
    deps = [
        ":dut_core",
        "//util/python:python_headers",
        "@pybind11//:pybind11_cxx",
    ],
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
