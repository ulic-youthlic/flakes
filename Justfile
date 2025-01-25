FLAKE_HOME := justfile_directory()
DEFAULT_SPECIALISATION := "default"

default:
    @just --list

switch specialisation=DEFAULT_SPECIALISATION:
    nh os switch {{ FLAKE_HOME }} {{ if specialisation == DEFAULT_SPECIALISATION { "-S" } else { "-s " + specialisation } }}

update:
    nix flake update | spacer

push host target:
    nixos-rebuild switch --flake {{ FLAKE_HOME }}#{{ host }} --target-host {{ target }} | spacer

alias s := switch
alias u := update
alias p := push
