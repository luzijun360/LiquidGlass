SHELL := /bin/bash
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DIST := $(ROOT)/dist
APP  := $(DIST)/LiquidGlass.app

.PHONY: all build install lab clean help

all: build

build:
\tbash $(ROOT)/build.sh

install: build
\tpkill -x LiquidGlass 2>/dev/null; true
\tditto "$(APP)" /Applications/LiquidGlass.app
\topen /Applications/LiquidGlass.app
\t@echo "Installed to /Applications/LiquidGlass.app"

lab:
\tswiftc -O -o /tmp/materiallab "$(ROOT)/tools/material-lab.swift" -framework AppKit && /tmp/materiallab

clean:
\t-rm -rf "$(DIST)"

help:
\t@echo "Targets: build (default), install, lab, clean"
