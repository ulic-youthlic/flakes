{lib, ...}: {
  imports = with lib;
    youthlic.loadImports' ./. (filter (name: !hasSuffix "/top-level" (toString name)));
}
