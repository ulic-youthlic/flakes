{inputs, ...}: final: prev: let
  inherit (final.stdenv.hostPlatform) system;
in {
  nur =
    prev.nur
    // {
      repos =
        prev.nur.repos
        // {
          ataraxiasjel =
            prev.nur.repos.ataraxiasjel
            // {
              inherit (inputs.nur-ataraxiasjel.packages.${system}) waydroid-script;
            };
        };
    };
}
