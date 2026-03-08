VIVADO_MODE ?= batch
VIVADO_TASK ?= all
TIMESTAMP := $(shell date -u +"%y%m%dT%H%M%SZ")
VIVADO_BUILD_DIR := synth__$(TIMESTAMP)
TIMESTAMP := $(shell date -u +"%y%m%dT%H%M%SZ")
SV_SOURCES := $(filter-out shell.sv, $(wildcard *.sv))
VIVADO_FLAGS := -notrace -nojournal -mode $(VIVADO_MODE) -script ../vivado.tcl

all: synth_vivado

.PHONY: synth_vivado
synth_vivado:
	mkdir -p $(VIVADO_BUILD_DIR)
	cd $(VIVADO_BUILD_DIR) && vivado $(VIVADO_FLAGS)

.PHONY: clean
clean:
	$(RM) -r synth__*
