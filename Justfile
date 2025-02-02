FLAKE_HOME := justfile_directory()
DEFAULT_SPECIALISATION := "default"

default:
    @just --list

switch specialisation=DEFAULT_SPECIALISATION:
    nh os switch {{ FLAKE_HOME }} {{ if specialisation == DEFAULT_SPECIALISATION { "-S" } else { "-s " + specialisation } }}

update:
    nix flake update --log-format internal-json 2>&1 | nom --json

deploy host:
    deploy {{ FLAKE_HOME }}#{{ host }}

clean:
    nh clean all --verbose -K 1w

alias s := switch
alias u := update
alias d := deploy
alias c := clean
