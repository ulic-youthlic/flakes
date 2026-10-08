{
  lib,
  buildGoTool,
}:
buildGoTool {
  pname = "webdav-proxy";
  version = "0.1.0";
  __darwinAllowLocalNetworking = true;
  meta = {
    description = "Local WebDAV CORS proxy";
    platforms = lib.platforms.unix;
    mainProgram = "webdav-proxy";
  };
}
