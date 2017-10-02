packages = Bundle.sv
modules = Alu.sv ControlPath.sv DataPath.sv RegisterFile.sv Core.sv


all: obj_dir/VDutCore

VERILATOR_CPPFLAGS = "-I../../../third_party/include/  -I/usr/local/include"
VERILATOR_CXXFLAGS = "-std=c++14 -Wall -Wextra -pthread"

obj_dir/VDutCore: DutCore.cpp DutCore.sv
	verilator -trace --trace-structs --top-module DutCore -Wno-fatal -Wall --exe DutCore.cpp -y ../src/ --cc $(packages) $(modules) DutCore.sv
	cd obj_dir && CPPFLAGS=${VERILATOR_CPPFLAGS} CXXFLAGS=${VERILATOR_CXXFLAGS} LDFLAGS="-L/usr/local/lib -L../../../third_party/lib/" LIBS="-lgtest -lgtest_main" make -f VDutCore.mk

run: obj_dir/VDutCore
	./obj_dir/VDutCore

clean:
	rm -rf obj_dir/

test: obj_dir/VDutCore
	./obj_dir/VDutCore
