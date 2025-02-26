# Defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Define the source directories
SRC_DIR = $(PWD)/../src
INC_DIR = $(PWD)/../define

# Source files
VERILOG_SOURCES += $(INC_DIR)/restor_div.svh
VERILOG_SOURCES += $(SRC_DIR)/restoring_division_datapath.sv
VERILOG_SOURCES += $(SRC_DIR)/restoring_division_controller.sv
VERILOG_SOURCES += $(SRC_DIR)/restoring_division.sv
VERILOG_SOURCES += $(PWD)/cocotb.sv

# TOPLEVEL is the name of the top-level module in the Verilog files
TOPLEVEL = cocotb

# MODULE is the basename of the Python test file
MODULE = restoring_division_tb

# Additional Verilator arguments
VERILATOR_ARGS += -I$(INC_DIR) --Wno-WIDTHTRUNC --Wno-LATCH --trace



# Include cocotb's make rules to handle simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
