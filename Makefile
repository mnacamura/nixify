DEST := ./_build
PREFIX := /usr/local

.PHONY: lint install clean

lint:
	shellcheck nixify.sh

install:
	install -D nixify.sh $(DEST)$(PREFIX)/bin/nixify

clean:
	rm -rf ./_build
