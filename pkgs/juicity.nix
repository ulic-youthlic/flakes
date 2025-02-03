{ pkgs, ... }:
pkgs.buildGoModule rec {
  name = "juicity";
  version = "unstable-20240514.r132.4af4f68";

  src = pkgs.fetchFromGitHub {
    repo = "juicity";
    owner = "juicity";
    rev = "4af4f68b405a6b86560ebb16963d133a7196af5c";
    hash = "sha256-4sej/nb7d58+hSCaD6KIfDsqiGmgECPIbRKR65TbMBM=";
  };
  env.CGO_ENABLED = 0;

  subPackages = [
    "cmd/server"
    "cmd/client"
  ];
  vendorHash = "sha256-uULJKg1nh6jU0uIgDf4GMu8O00zifLvU2wv65dlHLAs=";
  postInstallPhase = ''
    mv $out/bin/server $out/bin/juicity-server
    mv $out/bin/client $out/bin/juicity-client
  '';

  ldflags = [
    "-s"
    "-w"
    "-X"
    "github.com/juicity/juicity/config.Version=${version}"
  ];
}
