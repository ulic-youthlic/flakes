{
  srcs,
  rustPlatform,
  pkg-config,
  openssl,
  installShellFiles,
  lib,
}: let
  src = srcs.dioxionary;
in
  rustPlatform.buildRustPackage {
    inherit (src) pname src;
    version = "${src.version}";
    cargoLock = src.cargoLock."./Cargo.lock";
    nativeBuildInputs = [
      pkg-config
      installShellFiles
    ];
    buildInputs = [openssl.dev];
    doCheck = false;
    postInstall = ''
      installShellCompletion --cmd dioxionary \
        --bash <($out/bin/dioxionary completion bash) \
        --zsh <($out/bin/dioxionary completion zsh) \
        --fish <($out/bin/dioxionary completion fish)
    '';
    meta = {
      description = "Rusty stardict. Enables terminal-based word lookup and vocabulary memorization using offline or online dictionaries";
      homepage = "https://github.com/vaaandark/dioxionary";
      changelog = "https://github.com/vaaandark/dioxionary/releases/tag/${src.version}";
      license = lib.licenses.gpl2Only;
      maintainers = with lib.maintainers; [ulic-youthlic];
      mainProgram = "dioxionary";
    };
  }
