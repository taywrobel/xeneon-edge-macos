.PHONY: build test test-full lint verify diagnose install uninstall status package

build:
	swift build

test:
	swift run xeneon-smoke-tests

test-full:
	swift test

lint:
	swift format lint --recursive --strict Sources Tests Package.swift

verify: lint test

diagnose:
	swift run xeneon-touch diagnose

install:
	./scripts/install.sh

uninstall:
	./scripts/uninstall.sh

status:
	@launchctl print gui/$$(id -u)/com.github.xeneon-edge.touch

package:
	./scripts/package-release.sh
