include build/init.mk

all: list-all-targets

MODULE_NAME := ncore
MODULE_PART := xc7z010clg400-1
MODULE_SRCS := \
	../core/src/Bundle.sv\
	../core/src/Instructions.sv\
	../core/src/Alu.sv\
	../core/src/Branch.sv\
	../core/src/ControlPath.sv\
	../core/src/Core.sv\
	../core/src/DataPath.sv\
	../core/src/Register.sv\
	../core/src/RegisterFile.sv\
	../core/src/Top.sv

include build/vivado-bitfile.mk

list-all-targets::
	@echo buildable targets:
	@for x in $(ALL_TARGETS) ; do echo $$x ; done
