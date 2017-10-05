packages = 
interfaces =
modules = 
top_module = HLS_fp32_add
CXXFLAGS = -fPIC

verilator:
	verilator -trace --trace-structs --top-module $(top_module) -Wno-fatal -Wall -y ../src/ --cc $(packages) $(interfaces) $(modules) $(top_module).v
	cd obj_dir && make CXX=$(CXX) CXXFLAGS=$(CXXFLAGS) -f V$(top_module).mk

clean:
	rm -rf obj_dir
