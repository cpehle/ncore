
packages = Bundle.sv
modules = Alu.sv ControlPath.sv DataPath.sv RegisterFile.sv Core.sv

all: obj_dir/VCore

obj_dir/VCore:
	verilator -trace --top-module Core -Wno-fatal -Wall --exe DutCore.cpp -y ../src/ --cc $(packages) $(modules)
	cd obj_dir && make -f VCore.mk

run: obj_dir/VCore
	./obj_dir/VCore

clean:
	rm -rf obj_dir/
