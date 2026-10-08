#!/usr/bin/env -S just --justfile

FLAKE_HOME := justfile_directory()
DEFAULT_SPECIALISATION := "default"
DEFAULT_KEEP_SINCE := "1w"

default:
    @just --list

switch specialisation=DEFAULT_SPECIALISATION:
    nh os switch {{ FLAKE_HOME }} {{ if specialisation == DEFAULT_SPECIALISATION { "-S" } else { "-s " + specialisation } }}

update:
    nix flake update --log-format internal-json 2>&1 | nom --json

updatePkgs:
    nvfetcher

# Check every Go package in the shared root module.
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

# Resolve dependencies and regenerate the root gomod2nix.toml.
go-lock:
    go mod tidy
    gomod2nix

build specialisation=DEFAULT_SPECIALISATION:
    nh os build {{ FLAKE_HOME }} {{ if specialisation == DEFAULT_SPECIALISATION { "-S" } else { "-s " + specialisation } }}

deploy host:
    deploy {{ FLAKE_HOME }}#{{ host }}

clean keepSince=DEFAULT_KEEP_SINCE:
    nh clean all --verbose -K {{ keepSince }} -k 5

deadNix:
    nix run github:astro/deadnix -- . --exclude ./_sources/generated.nix ./host/{Akun,Tytonidae,Cape}/_hardware-configuration.nix

sign:
    jj sign --revisions '::@ & ~root() & ~signed() & ~@' --ignore-immutable

patch revision="HEAD":
    git push rad {{ revision }}:refs/patches

push:
    jj git push -b dev --remote all
    jj git fetch --all-remotes

rebase revision="dev":
    jj rebase -b 'heads(all()) & ~signed() &~@' -d {{ revision }}

alias s := switch
alias u := update
alias d := deploy
alias c := clean
alias b := build
alias U := updatePkgs
