ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
BUILD_DIR := $(ROOT_DIR)/build/minisoc_uvm

UVM_HOME := /Tools/synopsys/vcs/X-2025.06-SP2/etc/uvm-1.2
VLOGAN := /Tools/synopsys/vcs/X-2025.06-SP2/bin/vlogan
VCS := /Tools/synopsys/vcs/X-2025.06-SP2/bin/vcs

UVM_PKG := $(UVM_HOME)/uvm_pkg.sv

INCDIRS := \
+incdir+$(UVM_HOME) \
+incdir+$(ROOT_DIR)/verif/tb/agents/clock \
+incdir+$(ROOT_DIR)/verif/tb/agents/reset \
+incdir+$(ROOT_DIR)/verif/tb/env \
+incdir+$(ROOT_DIR)/verif/tb/tests

RTL_FILES := \
	$(ROOT_DIR)/frontend/rtl/minisoc_aes/minisoc_aes_key_exp.sv \
	$(ROOT_DIR)/frontend/rtl/minisoc_aes/minisoc_aes_dp.sv \
	$(ROOT_DIR)/frontend/rtl/minisoc_aes/minisoc_aes_top.sv \
	$(ROOT_DIR)/frontend/rtl/minisoc_mem/minisoc_memory.sv \
	$(ROOT_DIR)/frontend/rtl/minisoc_pll/minisoc_pll_mock.sv \
	$(ROOT_DIR)/frontend/rtl/minisoc_spi/minisoc_spi.sv \
	$(ROOT_DIR)/frontend/rtl/minisoc_top.sv

TB_FILES := \
	$(ROOT_DIR)/verif/tb/agents/clock/clock_if.sv \
	$(ROOT_DIR)/verif/tb/agents/clock/clock_agent_pkg.sv \
	$(ROOT_DIR)/verif/tb/agents/reset/reset_if.sv \
	$(ROOT_DIR)/verif/tb/agents/reset/reset_agent_pkg.sv \
	$(ROOT_DIR)/verif/tb/env/minisoc_env_pkg.sv \
	$(ROOT_DIR)/verif/tb/tests/minisoc_tests_pkg.sv \
	$(ROOT_DIR)/verif/tb/top_tb.sv

VLOGAN_FLAGS := -full64 -sverilog -timescale=1ns/1ps
VCS_FLAGS := -full64 -ntb_opts uvm-1.2

.PHONY: prepare

prepare:
	@mkdir -p $(BUILD_DIR)
.PHONY: compile

compile: prepare
	cd $(BUILD_DIR) && $(VLOGAN) $(VLOGAN_FLAGS) $(INCDIRS) \
	$(UVM_PKG) $(RTL_FILES) $(TB_FILES)

.PHONY: elab

elab: compile
	cd $(BUILD_DIR) && $(VCS) $(VCS_FLAGS) top_tb -o simv_top_dut

.PHONY: run

run: elab
	cd $(BUILD_DIR) && ./simv_top_dut +UVM_TESTNAME=minisoc_smoke_test
