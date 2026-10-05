# NixoS / Home-mangeR ConfiguratioN

Hey, you. This is my nixos configurations.

---

|  Machine  | Users |  OS   |
| :-------: | :---: | :---: |
| Tytonidae | david | NixOS |
|   Akun    | david | NixOS |
|   Cape    | alice | NixOS |

---

- david@Tytonidae

| Specialisation | DE / WM |       Shell       |   Editor    |      Terminal       |     Launcher      |   Browser   | DM  |
| :------------: | :-----: | :---------------: | :---------: | :-----------------: | :---------------: | :---------: | :-: |
|    default     |  niri   | fish + bash + ion | helix + zed | ghostty + alacritty | noctalia launcher | zen-browser | ly  |

- david@Akun

| Specialisation | DE / WM |    Shell    |   Editor    |      Terminal       |     Launcher      |   Browser   | DM  |
| :------------: | :-----: | :---------: | :---------: | :-----------------: | :---------------: | :---------: | :-: |
|    default     |  niri   | fish + bash | helix + zed | ghostty + alacritty | noctalia launcher | zen-browser | ly  |

- alice@Cape

| Specialisation | DE / WM |    Shell    | Editor | Terminal | Launcher | Browser | DM  |
| :------------: | :-----: | :---------: | :----: | :------: | :------: | :-----: | :-: |
|    default     |    -    | fish + bash | helix  |    -     |    -     |    -    |  -  |

## FlakE OutputS and StructurE

The flake is built with [den](https://github.com/denful/den) on flake-parts.
`flake.nix` loads every `.nix` file in the repository with import-tree, except
paths containing `/_`, which hold plain NixOS or home-manager modules.

| path                       | contents                                                                                   |
| :------------------------- | :----------------------------------------------------------------------------------------- |
| `./core`                   | flake-level wiring: den, `den.default`, deploy-rs nodes, packages, overlays, formatter     |
| `./host/${machine}.nix`    | the machine in `den.hosts`, the aspects it includes and its settings                       |
| `./host/${machine}/_*.nix` | machine-local NixOS modules: hardware, disks, boot, networking                             |
| `./users/${user}.nix`      | the user account and the aspects the user includes on every machine                        |
| `./users/${user}/*.nix`    | the user's own aspects, `den.aspects.${user}.<name>`                                       |
| `./aspects/<feature>*`     | shared feature aspects, `den.aspects.<name>`, each with `nixos` and/or `homeManager` parts |
| `./overlays`               | overlays, defined with den-overlays and composed into `overlays.default`                   |

A machine-specific setting for a user goes in the machine's
`den.aspects.${machine}.provides.${user}`.

| `outputs` field                           | description                                                            | source                |
| :---------------------------------------- | :--------------------------------------------------------------------- | :-------------------- |
| `nixosConfigurations.${machine}`          | machine NixOS configuration, home-manager included                     | `./host/${machine}*`  |
| `deploy.nodes.${machine}.profiles.system` | deploy-rs profile for machines with `deploy.enable`                    | `./core/deploy.nix`   |
| `overlays`                                | each overlay, plus `default` composing all of them                     | `./overlays`          |
| `packages`, `legacyPackages`              | packages the overlays add or change, and the patched, overlaid nixpkgs | `./core/packages.nix` |
| `checks`, `formatter`, `devShells`        | package builds and treefmt; the development shell                      | `./core`              |
