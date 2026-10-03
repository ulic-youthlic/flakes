{ den, ... }:
{
  # The shared radicle node plus how david opens rad links.
  den.aspects.david.radicle = {
    includes = [ den.aspects.dev.radicle ];
    homeManager.programs.radicle.uri = {
      rad.browser = {
        enable = true;
        preferredNode = "iris.radicle.xyz";
      };
      web-rad = {
        browser = "zen-twilight.desktop";
        enable = true;
      };
    };
  };
}
