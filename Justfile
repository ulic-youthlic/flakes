FLAKE_HOME := justfile_directory()

default:
    @just --list

switch:
    nh os switch {{FLAKE_HOME}}
update:
    nix flake update

alias s := switch
alias u := update
