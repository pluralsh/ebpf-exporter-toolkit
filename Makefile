include ./Makefile.libbpf

.DEFAULT_GOAL := build

CLANG_FORMAT_FILES = $(shell find src -regextype awk -regex ".+\.[h|c]")

# * cachestat-pre-kernel-5.16 fails to attach in newer kernels (see code)
# * llcstat requires real hardware to attach perf events, which is not present in ci
CONFIGS_TO_IGNORE_IN_CHECK := cachestat-pre-kernel-5.16 llcstat
# * cgroup-rstat-flushing depend on kernel v6.10, which is not yet on CI system
CONFIGS_TO_IGNORE_IN_CHECK += cgroup-rstat-flushing
CONFIGS_TO_CHECK := $(filter-out $(CONFIGS_TO_IGNORE_IN_CHECK), ${patsubst config/%.yaml, %, ${wildcard config/*.yaml}})

.PHONY: markdown-link-check
markdown-link-check:
	@docker run --rm -v $(shell pwd):/tmp/check:ro -w /tmp/check --entrypoint /bin/sh ghcr.io/tcort/markdown-link-check:3.12.2 -c 'markdown-link-check --config .markdown-link-check.json $$(find . -name \*.md | grep -v ^\./libbpf)'

.PHONY: jsonschema
jsonschema:
	@./scripts/jsonschema.sh

.PHONY: clang-format-check
clang-format-check:
	@./scripts/clang-format-check.sh $(CLANG_FORMAT_FILES)

.PHONY: config-check
config-check: build
	@docker run --rm --privileged -v $(PWD)/dist:/dist ghcr.io/cloudflare/ebpf_exporter:latest --capabilities.keep=none --config.check --config.strict --config.dir=/dist --config.names=$(shell echo $(CONFIGS_TO_CHECK) | tr ' ' ',')

.PHONY: clean
clean:
	@echo "Cleaning up eBPF programs..."
	@rm -rf dist
	@echo "Cleaned up dist directory"

.PHONY: build
build: clean
	@echo "Building eBPF programs in Docker..."
	@docker build -t ebpf-builder .
	@docker run --rm -v $(PWD)/dist:/output ebpf-builder sh -c "cp -r /build/ebpf_exporter/dist/* /output && chown -R $(shell id -u):$(shell id -g) /output"
	@echo "Copied eBPF programs to dist directory"
	@cp -r config/* dist/
	@echo "Copied config files to dist directory"