packages = cache_pkg.sv
interfaces =
modules = data_memory_cache_sim.sv tag_memory_cache_sim.sv cache_controller.sv
top_module = dut_cache_controller
CXXFLAGS = -fPIC

verilator:
	verilator -trace --trace-structs --top-module $(top_module) -Wno-fatal -Wall -y ../src/ --cc $(packages) $(interfaces) $(modules) $(top_module).sv
	cd obj_dir && make CXX=$(CXX) CXXFLAGS=$(CXXFLAGS) -f Vdut_cache_controller.mk

clean:
	rm -rf obj_dir
