PREFIX ?= $(HOME)/.local
BINDIR := $(PREFIX)/bin
SHAREDIR := $(PREFIX)/share
SHELL=zsh

.PHONY: build clean check ci test testall coverage install uninstall help

help:
	@awk '/^#/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_-]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t

## build 'macconfig' script.
build: bin/macconfig

## remove generated files.
clean:
	rm -rf bin/macconfig macconfig.tar.gz coverage .shellspec-quick.log

## run 'shellcheck' against shell scripts.
check:
	shellcheck lib/* spec/* steps/*

## run tests
test:
	$(eval $@_ARGS=--quiet --format d)
	$(eval $@_CACHE=.shellspec-quick.log)
	$(if $(shell find . -type f -name '*sh' -newer $($@_CACHE)),$(shell rm $($@_CACHE)))
	$(if $(shell find . -name $($@_CACHE)),$(eval $@_ARGS+=--only-failures),$(eval $@_ARGS+=--quick))
	shellspec $(if $(filter undefined,$(origin SHELLSPEC_ARGS)),$($@_ARGS),$(SHELLSPEC_ARGS))

## run tests agaist all supported shells.
testall:
	shellspec -s sh
	shellspec -s zsh
	shellspec -s bash

## run test coverage.
coverage:
	shellspec -s $(SHELL) --kcov --kcov-options "--coveralls-id=$(COVERALLS_REPO_TOKEN)"
	$(SHELL) <(curl -s https://codecov.io/bash) -s coverage

## Prepare a package with necessary files to be distributed
dist: build
	tar -C bin -czf macconfig.tar.gz dotfiles

## Deploy macconfig into 'PREFIX' (Default is $(HOME)/.local).
install: build
	mkdir -p $(BINDIR)
	install -m 755 bin/macconfig $(BINDIR)/maccofig
	install -m 755 dotfiles/* $(SHAREDIR)/macconfig

## Remove macconfig from this machine
uninstall:
	rm -f $(BINDIR)/macconfig
	rm -f $(SHAREDIR)/macconfig

bin/macconfig: src/build.sh
	chmod +x src/build.sh
	src/build.sh < src/macconfig > bin/macconfig
	gengetoptions embed --overwrite bin/macconfig
	chmod +x bin/macconfig
