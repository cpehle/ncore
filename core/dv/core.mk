packages = Bundle.sv
interfaces =
modules = Alu.sv ControlPath.sv DataPath.sv RegisterFile.sv Core.sv
top_module = DutCore
CXXFLAGS = -fPIC

verilator:
	verilator -trace --trace-structs --top-module $(top_module) -Wno-fatal -Wall -y ../src/ --cc $(packages) $(interfaces) $(modules) $(top_module).sv
	cd obj_dir && make CXX=$(CXX) CXXFLAGS=$(CXXFLAGS) -f VDutCore.mk

clean:
	rm -rf obj_dir

