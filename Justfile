FLAKE_HOME := justfile_directory()

default:
    @just --list

switch:
    nh os switch {{FLAKE_HOME}}
update:
    nix flake update | spacer
push host target:
    nixos-rebuild switch --flake {{FLAKE_HOME}}#{{host}} --target-host {{target}} | spacer

alias s := switch
alias u := update
alias p := push
