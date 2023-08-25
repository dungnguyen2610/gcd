# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

TOPLEVEL_LANG ?= verilog

PWD = $(shell pwd)

export PYTHONPATH := $(PWD)/../env:$(PYTHONPATH)
export PYTHONPATH := $(PWD)/../tests/sequence:$(PYTHONPATH)

VERILOG_SOURCES += $(shell pwd)/../../src/ifc_gcd.sv
VERILOG_SOURCES += $(shell pwd)/../../src/master.sv
VERILOG_SOURCES += $(shell pwd)/../../src/gcdControl.sv
VERILOG_SOURCES += $(shell pwd)/../../src/gcdDatapath.sv
VERILOG_SOURCES += $(shell pwd)/../../src/slave.sv
VERILOG_SOURCES += $(shell pwd)/../../src/dff.sv
VERILOG_SOURCES += $(shell pwd)/../../src/mux21.sv
VERILOG_SOURCES += $(shell pwd)/../../src/mux41.sv
VERILOG_SOURCES += $(shell pwd)/../../src/FIFO1.sv
VERILOG_SOURCES += $(shell pwd)/../../src/FIFO2.sv

MODULE = test_gcd
TOPLEVEL = ifc_gcd

include $(shell cocotb-config --makefiles)/Makefile.sim
