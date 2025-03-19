#!/usr/bin/env -S just --justfile

FLAKE_HOME := justfile_directory()
DEFAULT_SPECIALISATION := "default"
DEFAULT_KEEP_SINCE := "1w"
DEFAULT_USER := env('USER')
DEFAULT_HOST := shell('hostname')

default:
    @just --list

switch specialisation=DEFAULT_SPECIALISATION:
    nh os switch {{ FLAKE_HOME }} {{ if specialisation == DEFAULT_SPECIALISATION { "-S" } else { "-s " + specialisation } }}

update:
    nix flake update --log-format internal-json 2>&1 | nom --json

updatePkgs:
    cd pkgs && nvfetcher

build specialisation=DEFAULT_SPECIALISATION:
    nh os build {{ FLAKE_HOME }} {{ if specialisation == DEFAULT_SPECIALISATION { "-S" } else { "-s " + specialisation } }}

deploy host:
    deploy {{ FLAKE_HOME }}#{{ host }}

clean keepSince=DEFAULT_KEEP_SINCE:
    nh clean all --verbose -K {{ keepSince }} -k 5

switchHome host=DEFAULT_HOST $USER=DEFAULT_USER:
    @echo USER: $USER
    @echo HOST: {{ host }}
    nh home switch -b backup {{ if host != DEFAULT_HOST { "-c \"" + USER + "@" + host + "\"" } else { "" } }} {{ FLAKE_HOME }}

buildHome host=DEFAULT_HOST $USER=DEFAULT_USER:
    @echo USER: $USER
    @echo HOST: {{ host }}
    nh home build -b backup {{ if host != DEFAULT_HOST { "-c \"" + USER + "@" + host + "\"" } else { "" } }} {{ FLAKE_HOME }}

alias s := switch
alias u := update
alias d := deploy
alias c := clean
alias b := build
alias H := switchHome
alias B := buildHome
alias U := updatePkgs
