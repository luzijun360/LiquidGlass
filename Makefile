SHELL := /bin/bash
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DIST := $(ROOT)/dist
APP  := $(DIST)/LiquidGlass.app

.PHONY: all build install lab clean help

all: build

build:
	bash $(ROOT)/build.sh

install: build
	pkill -x LiquidGlass 2>/dev/null; true
	ditto "$(APP)" /Applications/LiquidGlass.app
	open /Applications/LiquidGlass.app
	@echo "Installed to /Applications/LiquidGlass.app"

lab:
	swiftc -O -o /tmp/materiallab "$(ROOT)/tools/material-lab.swift" -framework AppKit && /tmp/materiallab

clean:
	-rm -rf "$(DIST)"

help:
	@echo "Targets: build (default), install, lab, clean"
