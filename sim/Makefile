SHELL := /bin/bash

SIM ?= iverilog
BUILD_DIR ?= build
VCD_FILE ?= $(BUILD_DIR)/waves.vcd
RUN_TB ?= tb_cache_top
TB_SRCS := $(wildcard ../tb/*.sv)
TB_NAMES := $(patsubst ../tb/%.sv,%,$(TB_SRCS))
RTL_SRCS := $(wildcard ../rtl/*.sv)
VVP_TARGETS := $(patsubst %, $(BUILD_DIR)/%.vvp, $(TB_NAMES))

.PHONY: all compile run run_all clean waves check-env
all: compile

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

check-env:
ifeq ($(SIM),iverilog)
	@command -v iverilog >/dev/null 2>&1 || { echo "ERROR: iverilog is required for SIM=iverilog." >&2; exit 1; }
	@command -v vvp >/dev/null 2>&1 || { echo "ERROR: vvp is required for SIM=iverilog." >&2; exit 1; }
else ifeq ($(SIM),xsim)
	@command -v xvlog >/dev/null 2>&1 || { echo "ERROR: xvlog is required for SIM=xsim." >&2; exit 1; }
	@command -v xelab >/dev/null 2>&1 || { echo "ERROR: xelab is required for SIM=xsim." >&2; exit 1; }
	@command -v xsim >/dev/null 2>&1 || { echo "ERROR: xsim is required for SIM=xsim." >&2; exit 1; }
else
	@echo "ERROR: Unsupported SIM=$(SIM). Supported values: iverilog, xsim." >&2
	@exit 1
endif

compile: check-env | $(BUILD_DIR) $(VVP_TARGETS)
	@echo "Compilation complete. Generated artifacts in $(BUILD_DIR)."

$(BUILD_DIR)/%.vvp: ../tb/%.sv | $(BUILD_DIR)
ifeq ($(SIM),iverilog)
	@echo "Compiling testbench $< with SIM=$(SIM)..."
	iverilog -g2012 -o $@ $(RTL_SRCS) $<
else ifeq ($(SIM),xsim)
	@echo "Compiling testbench $< with SIM=$(SIM)..."
	cd $(BUILD_DIR) && xvlog -sv ../rtl/*.sv ../tb/$*.sv >/dev/null
	cd $(BUILD_DIR) && xelab -debug typical $* -s $*.sim >/dev/null
else
	@echo "ERROR: Unsupported SIM=$(SIM)." >&2
	@exit 1
endif

run: check-env | $(BUILD_DIR)/$(RUN_TB).vvp
ifeq ($(SIM),iverilog)
	@echo "Running testbench $(RUN_TB) with SIM=$(SIM)..."
	vvp $(BUILD_DIR)/$(RUN_TB).vvp +dumpfile=$(VCD_FILE) +dumpvars
	@echo "Simulation complete. VCD written to $(VCD_FILE)."
else ifeq ($(SIM),xsim)
	@echo "Running testbench $(RUN_TB) with SIM=$(SIM)..."
	cd $(BUILD_DIR) && xsim $(RUN_TB).sim -R
else
	@echo "ERROR: Unsupported SIM=$(SIM)." >&2
	@exit 1
endif

run_all: check-env | compile
	@echo "Executing all testbenches sequentially..."
	@for tb in $(TB_NAMES); do \
		echo "--- Running $$tb ---"; \
		vvp $(BUILD_DIR)/$$tb.vvp +dumpfile=$(BUILD_DIR)/waves_$$tb.vcd +dumpvars > $(BUILD_DIR)/$$tb.log 2>&1; \
		echo "  Completed $$tb -> $(BUILD_DIR)/waves_$$tb.vcd"; \
	done
	@echo "All testbenches executed. Logs and wave files are in $(BUILD_DIR)."

waves:
	@command -v gtkwave >/dev/null 2>&1 || { echo "ERROR: gtkwave is required for waves target." >&2; exit 1; }
	@if [ ! -f "$(VCD_FILE)" ]; then echo "ERROR: Waveform file $(VCD_FILE) not found. Run make run first." >&2; exit 1; fi
	gtkwave $(VCD_FILE)

clean:
	rm -rf $(BUILD_DIR)
	@echo "Clean finished. Removed $(BUILD_DIR)."
