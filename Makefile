BUILD := _build
PREFIX := $(HOME)/.local

.PHONY: build check lint install clean

build:
	mkdir -p $(BUILD)/bin
	gawk -f build.awk nixify.sh > $(BUILD)/bin/nixify
	chmod +x $(BUILD)/bin/nixify

check:
	@bats tests/

lint:
	@shellcheck *.sh tests/*.bats

install: build
	install -D $(BUILD)/bin/nixify $(PREFIX)/bin/nixify

clean:
	rm -rf $(BUILD)
