FLAKE_HOME := justfile_directory()

default:
    @just --list

switch:
    nh os switch {{FLAKE_HOME}}

alias s := switch
