#!/usr/bin/env -S just --justfile

set shell := ["bash", "-euo", "pipefail", "-c"]

FLAKE_HOME := justfile_directory()
DEFAULT_SPECIALISATION := "default"
DEFAULT_KEEP_SINCE := "1w"

# List available recipes by group.
default:
    @just --list

# Build and activate a local NixOS specialisation.
[group('system')]
switch specialisation=DEFAULT_SPECIALISATION:
    nh os switch {{ quote(FLAKE_HOME) }} {{ if specialisation == DEFAULT_SPECIALISATION { "-S" } else { "-s " + quote(specialisation) } }}

# Update flake inputs, displaying progress with nix-output-monitor.
[group('maintenance')]
update:
    nix flake update --log-format internal-json 2>&1 | nom --json

# Refresh package sources managed by nvfetcher.
[group('maintenance')]
updatePkgs:
    nvfetcher

# Format Go sources and organize imports.
[group('go')]
go-fmt:
    goimports -w go-modules

# Run the default golangci-lint checks.
[group('go')]
go-lint:
    golangci-lint run ./...

# Check every Go package in the shared root module.
[group('go')]
go-check:
    #!/usr/bin/env bash
    set -euo pipefail
    packages=$(go list ./...)
    if [[ -z "$packages" ]]; then
        echo "No Go packages yet."
        exit 0
    fi
    go vet ./...
    go test ./...

# Run Go tests with race detection and coverage reporting.
[group('go')]
go-test:
    gotestsum -- -race -cover ./...

# Check Go dependencies against the vulnerability database.
[group('go')]
go-vuln:
    govulncheck ./...

# Resolve dependencies and regenerate the root gomod2nix.toml.
[group('go')]
go-lock:
    go mod tidy
    gomod2nix

# Build a local NixOS specialisation without activating it.
[group('system')]
build specialisation=DEFAULT_SPECIALISATION:
    nh os build {{ quote(FLAKE_HOME) }} {{ if specialisation == DEFAULT_SPECIALISATION { "-S" } else { "-s " + quote(specialisation) } }}

# Deploy a configured host.
[group('system')]
deploy host:
    deploy {{ quote(FLAKE_HOME + "#" + host) }}

# Clean old generations, retaining at least five and those within keepSince.
[group('maintenance')]
clean keepSince=DEFAULT_KEEP_SINCE:
    nh clean all --verbose -K {{ quote(keepSince) }} -k 5

# Sign unsigned mutable revisions before the working copy.
[group('vcs')]
sign:
    jj sign --revisions '::@ & ~root() & ~signed() & ~@' --ignore-immutable

# Publish a revision as a Radicle patch.
[group('vcs')]
patch revision="HEAD":
    git push rad {{ quote(revision + ":refs/patches") }}

# Push the dev bookmark and fetch all remotes.
[group('vcs')]
push:
    jj git push -b dev --remote all
    jj git fetch --all-remotes

# Rebase unsigned heads onto the selected revision.
[group('vcs')]
rebase revision="dev":
    jj rebase -b 'heads(all()) & ~signed() &~@' -d {{ quote(revision) }}

alias s := switch
alias u := update
alias d := deploy
alias c := clean
alias b := build
alias U := updatePkgs
