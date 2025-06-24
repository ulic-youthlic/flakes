{...}: _final: prev: {
  lix = prev.lix.overrideAttrs {
    patches = [./fix-cve-2025-52992.diff];
  };
}
