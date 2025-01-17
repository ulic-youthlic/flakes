# NixoS / Home-mangeR ConfiguratioN

Hey, you. This is my nixos configurations.

---

| Machine   | Users |
| --------- | ----- |
| Tytonidae | david |

---

- david@Tytonidae

| Specialisation | DE / WM   | Shell       | Editor | Termianal | Launcher        | Browser | DM             |
| -------------- | --------- | ----------- | ------ | --------- | --------------- | ------- | -------------- |
| default        | cosmic de | fish + bash | helix  | ghostty   | cosmic-launcher | firefox | cosmic-greeter |
| niri           | niri      | fish + bash | helix  | ghostty   | fuzzel          | firefox | gdm            |

## FlakE OutputS and StructurE

| `outputs` field                           | description                                                                 | source                                   |
| ----------------------------------------- | --------------------------------------------------------------------------- | ---------------------------------------- |
| `packages`                                | packages imported or wrapped from elsewhere                                 | ./pkgs                                   |
| `overlays.modifications`                  | the overlays modify `<nixpkgs>`                                             | ./overlays/modifications                 |
| `overlays.additions`                      | the ovelrays add packages in `<nixpkgs>`                                    | ./overlays/additions                     |
| `nixosModules.default`                    | nixos modules shared on different nixos machines                            | ./nixos/modules                          |
| `nixosConfigurations.${machine}`          | machine-local nixos config                                                  | ./nixos/configurations/${machine}        |
| `homeManagerModules.default`              | home-manager modules shared between different user and machine combinations | ./home/modules                           |
| `homeManagerModules.${user}`              | home-manager modules shared between different users                         | ./home/${user}/modules                   |
| `homeConfigurations."${user}@${machine}"` | home-manager config for different user and machine combinations             | ./home/${user}/configurations/${machine} |
