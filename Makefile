.PHONY: build test check

# Development build for this Mac, at build/<NAME>.app (Scripts/build.sh).
build:
	@./Scripts/build.sh

test:
	@swift build

# Everything that must pass before a commit.
check: test release-checks

# Release (written by release-kit). `check` should depend on release-checks.
.PHONY: release-checks package release-dry-run release clean-dist

# The release notes' shape and the incident ledger.
release-checks:
	@./Scripts/check_release_notes.sh
	@python3 Scripts/check_incidents.py

# What a release ships, without publishing anything: dist/<NAME>.{app,dmg,zip}.
package:
	@./Scripts/package.sh

# Preflight only; changes nothing.
release-dry-run:
	@./Scripts/release.sh --dry-run

release:
	@./Scripts/release.sh

clean-dist:
	rm -rf dist
