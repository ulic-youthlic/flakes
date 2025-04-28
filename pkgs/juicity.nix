{
  buildGoModule,
  srcs,
  ...
}:
buildGoModule rec {
  name = "juicity";
  version = "unstable-${srcs.juicity.date}.${srcs.juicity.version}";

  src = srcs.juicity.src;
  env.CGO_ENABLED = 0;

  subPackages = [
    "cmd/server"
    "cmd/client"
  ];
  vendorHash = "sha256-PdX9GENqdTPpNWVRG3cTgZfAlEU85MVgDOJdcVT4gnw=";
  fixupPhase = ''
    runHook preFixup

    mv $out/bin/server $out/bin/juicity-server
    mv $out/bin/client $out/bin/juicity-client

    runHook postFixup
  '';

  ldflags = [
    "-s"
    "-w"
    "-X"
    "github.com/juicity/juicity/config.Version=${version}"
  ];
}
