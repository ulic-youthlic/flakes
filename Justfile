FLAKE_HOME := justfile_directory()
DEFAULT_SPECIALISATION := "default"

default:
    @just --list

switch specialisation=DEFAULT_SPECIALISATION:
    nh os switch {{ FLAKE_HOME }} {{ if specialisation == DEFAULT_SPECIALISATION { "-S" } else { "-s " + specialisation } }}

update:
    nix flake update | spacer

deploy host:
    deploy {{ FLAKE_HOME }}#{{ host }}

alias s := switch
alias u := update
alias d := deploy
