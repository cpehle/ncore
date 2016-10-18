packages = Bundle.sv
modules = Alu.sv ControlPath.sv DataPath.sv RegisterFile.sv Core.sv

GTEST_DIR =	googletest/googletest/

CPPFLAGS += -isystem $(GTEST_DIR)/include
CXXFLAGS = -std=c++14 -I/usr/local/include -Wall -Wextra -pthread
GTEST_HEADERS = $(GTEST_DIR)/include/gtest/*.h $(GTEST_DIR)/include/gtest/internal/*.h
# Usually you shouldn't tweak such internal variables, indicated by a
# trailing _.
GTEST_SRCS_ = $(GTEST_DIR)/src/*.cc $(GTEST_DIR)/src/*.h $(GTEST_HEADERS)

all: obj_dir/VDutCore

# For simplicity and to avoid depending on Google Test's
# implementation details, the dependencies specified below are
# conservative and not optimized.  This is fine as Google Test
# compiles fast and for ordinary users its source rarely changes.
gtest-all.o : $(GTEST_SRCS_)
	$(CXX) $(CPPFLAGS) -I$(GTEST_DIR) $(CXXFLAGS) -c \
	$(GTEST_DIR)/src/gtest-all.cc

gtest_main.o : $(GTEST_SRCS_)
	$(CXX) $(CPPFLAGS) -I$(GTEST_DIR) $(CXXFLAGS) -c \
	$(GTEST_DIR)/src/gtest_main.cc

gtest.a : gtest-all.o
	$(AR) $(ARFLAGS) $@ $^

gtest_main.a : gtest-all.o gtest_main.o
	$(AR) $(ARFLAGS) $@ $^


VERILATOR_GTEST_DIR = ../googletest/googletest/
VERILATOR_CPPFLAGS = "-I$(VERILATOR_GTEST_DIR)/include  -I/usr/local/include"
VERILATOR_CXXFLAGS = "-std=c++14 -Wall -Wextra -pthread"

obj_dir/VDutCore: DutCore.cpp DutCore.sv $(GTEST_HEADERS) gtest_main.a
	verilator -trace --trace-structs --top-module DutCore -Wno-fatal -Wall --exe DutCore.cpp -y ../src/ --cc $(packages) $(modules) DutCore.sv
	cd obj_dir && CPPFLAGS=${VERILATOR_CPPFLAGS} CXXFLAGS=${VERILATOR_CXXFLAGS} LDFLAGS="-L/usr/local/lib ../gtest_main.a" make -f VDutCore.mk

run: obj_dir/VDutCore
	./obj_dir/VDutCore

clean:
	rm -rf obj_dir/
