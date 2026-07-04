{
  lib,
  config,
  ...
}:
let
  cfg = config.david.programs.kanshi;
in
{
  options = {
    david.programs.kanshi = {
      enable = lib.mkEnableOption "kanshi";
    };
  };
  config = lib.mkIf cfg.enable {
    services.kanshi = {
      enable = true;
      settings = [
        {
          output = {
            criteria = "Chimei Innolux Corporation 0x1540 Unknown";
            mode = "2560x1440@165.003Hz";
            scale = 1.5;
            adaptiveSync = true;
          };
        }
        {
          output = {
            criteria = "HKC OVERSEAS LIMITED IG27Q 0000000000001";
            mode = "2560x1440@169.900";
            scale = 1.0;
          };
        }
        {
          profile.outputs = [
            {
              criteria = "Chimei Innolux Corporation 0x1540 Unknown";
              position = "0,0";
            }
          ];
        }
        {
          profile.outputs = [
            {
              criteria = "Chimei Innolux Corporation 0x1540 Unknown";
              position = "2560,0";
            }
            {
              criteria = "HKC OVERSEAS LIMITED IG27Q 0000000000001";
              position = "0,0";
            }
          ];
        }
      ];
    };
  };
}
