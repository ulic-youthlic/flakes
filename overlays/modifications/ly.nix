{ ... }: final: prev: {
  ly = prev.ly.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "1.5.0-rc1";
      src = final.fetchFromCodeberg {
        owner = "fairyglade";
        repo = "ly";
        tag = "v${finalAttrs.version}";
        hash = "sha256-DerU/tGSqPm0RKV/Tu7ZizxXiyvNyTFUjRDUZkIRONU=";
      };
      zigDeps = final.zig_0_16.fetchDeps {
        inherit (finalAttrs) src pname version;
        fetchAll = true;
        hash = "sha256-rBr6Zu3mUWSOdscrHh3yW54H6ap0LCV0t0KuUgUbH5s=";
      };

      # The release tarball omits .git, so upstream drops the prerelease suffix.
      postPatch = (prevAttrs.postPatch or "") + ''
        substituteInPlace build.zig \
          --replace-fail 'const version_str = b.fmt("{d}.{d}.{d}", .{ version.major, version.minor, version.patch });' \
            'const version_str = "${finalAttrs.version}";'
      '';
    }
  );
}
