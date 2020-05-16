PREFIX := $(HOME)/.local

.PHONY: check lint install clean

_build/bin/nixify:
	mkdir -p _build/bin
	gawk -f build.awk nixify.sh > _build/bin/nixify
	chmod +x _build/bin/nixify


check: _build/bin/nixify
	@bats tests/

lint:
	@shellcheck *.sh tests/*.bats

install: _build/bin/nixify
	install -D _build/bin/nixify $(PREFIX)/bin/nixify

clean:
	rm -rf _build
