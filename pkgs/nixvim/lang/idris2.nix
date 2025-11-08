{pkgs, ...}: {
  extraPackagesAfter = with pkgs; [idris2Packages.idris2Lsp];
  lsp.servers.idris2 = {
    enable = true;
  };
  youthlic.plugins.idris2 = {
    enable = true;
  };
}
