{inputs, ...}: let
  inherit (inputs.niri-flake.lib.kdl) node leaf plain flag;
in {
  david.programs.niri = {
    enable = true;
    extraConfig = let
      output = node "output";
    in [
      (output "eDP-1" [
        (leaf "mode" "1920x1200@60.018")
        (leaf "scale" 1.0)
        (flag "focus-at-startup")
        (leaf "position" {
          x = 0;
          y = 0;
        })
        (leaf "transform" "normal")
      ])
    ];
  };
}
