{inputs, ...}: let
  inherit (inputs.niri-flake.lib.kdl) node leaf plain flag;
in {
  david.programs.niri = {
    enable = true;
    extraConfig = let
      output = node "output";
    in [
      (output "DP-1" [
        (leaf "mode" "2560x1440@169.900")
        (leaf "scale" 1.0)
        (leaf "position" {
          x = 0;
          y = 0;
        })
        (leaf "transform" "normal")
      ])
      (output "eDP-1" [
        (leaf "mode" "2560x1440@165.003")
        (leaf "scale" 1.5)
        (leaf "position" {
          x = 2560;
          y = 0;
        })
        (leaf "transform" "normal")
      ])
    ];
    # settings = {
    #   outputs = {
    #     DP-1 = {
    #       mode = {
    #         width = 2560;
    #         height = 1440;
    #         refresh = 169.900;
    #       };
    #       scale = 1;
    #       position = {
    #         x = 0;
    #         y = 0;
    #       };
    #     };
    #     eDP-1 = {
    #       mode = {
    #         width = 2560;
    #         height = 1440;
    #         refresh = 165.003;
    #       };
    #       scale = 1.5;
    #       position = {
    #         x = 2560;
    #         y = 0;
    #       };
    #     };
    #   };
    # };
  };
}
