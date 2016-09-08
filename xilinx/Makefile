include build/init.mk

all: list-all-targets

MODULE_NAME := ncore
MODULE_PART := xc7z010clg400-1
MODULE_SRCS := \
	../sc/src/Alu.sv\
	../sc/src/Branch.sv\
	../sc/src/Bundle.sv\
	../sc/src/ControlPath.sv\
	../sc/src/Core.sv\
	../sc/src/DataPath.sv\
	../sc/src/Instructions.sv\
	../sc/src/RegisterFile.sv
include build/vivado-bitfile.mk

list-all-targets::
	@echo buildable targets:
	@for x in $(ALL_TARGETS) ; do echo $$x ; done
