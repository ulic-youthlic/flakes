{
  den.overlays.ddcci-handler =
    {
      final,
      prev,
      buildBashTool,
    }:
    {
      ddcci-handler = buildBashTool {
        pname = "ddcci-handler";
        runtimeInputs = with prev; [
          coreutils
          ddcutil
        ];
        meta = {
          description = "Attach ddcci to a display's i2c device";
          platforms = prev.lib.platforms.linux;
        };
      };
    };
}
