packages = Bundle.sv
modules = Alu.sv ControlPath.sv DataPath.sv RegisterFile.sv Core.sv

all: obj_dir/VDutCore

obj_dir/VDutCore: DutCore.cpp DutCore.sv
	verilator -trace --trace-structs --top-module DutCore -Wno-fatal -Wall --exe DutCore.cpp -y ../src/ --cc $(packages) $(modules) DutCore.sv
	cd obj_dir && CXXFLAGS=-std=c++14 make  -f VDutCore.mk

run: obj_dir/VDutCore
	./obj_dir/VDutCore

clean:
	rm -rf obj_dir/
