# Convenience frontend. The real build definition is in CMakeLists.txt.
CMAKE ?= cmake
BUILD_DIR ?= build

.PHONY: configure build kernel verify iso run debug clean help
configure:
	$(CMAKE) -S . -B $(BUILD_DIR)

build kernel: configure
	$(CMAKE) --build $(BUILD_DIR) --target kernel

verify: configure
	$(CMAKE) --build $(BUILD_DIR) --target verify

iso: configure
	$(CMAKE) --build $(BUILD_DIR) --target iso

run: configure
	$(CMAKE) --build $(BUILD_DIR) --target run

debug: configure
	$(CMAKE) --build $(BUILD_DIR) --target debug

clean:
	$(CMAKE) -E rm -rf $(BUILD_DIR)

help:
	@printf '%s\n' 'Targets: configure, build, kernel, verify, iso, run, debug, clean'
