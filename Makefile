DEST := ./_build
PREFIX := /usr/local

.PHONY: check install clean

install:
	install -D nixify.fish $(DEST)$(PREFIX)/bin/nixify

clean:
	rm -rf ./_build
