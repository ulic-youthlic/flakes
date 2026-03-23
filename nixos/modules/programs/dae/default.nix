{
  config,
  rootPath,
  pkgs,
  lib,
  ...
}: let
  cfg = config.youthlic.programs.dae;
in {
  options = {
    youthlic.programs.dae = {
      enable = lib.mkEnableOption "dae";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.dae = {
        enable = true;
        package = pkgs.dae;
        openFirewall = {
          enable = true;
          port = 12345;
        };
        disableTxChecksumIpGeneric = false;
        config = builtins.readFile ./config.dae;
      };
      sops.secrets.url = {
        mode = "0444";
        sopsFile = rootPath + "/secrets/general.yaml";
      };
      systemd.services = let
        update = ''
          head="user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36"
          new_proxy=/etc/dae/proxy.d.new
          num=0
          check=1
          urls="$(cat ${config.sops.secrets.url.path})"
          mkdir -p ''${new_proxy}
          for url in ''${urls}; do
            txt=''${new_proxy}/''${num}.txt
            config="''${new_proxy}/''${num}.dae"
            echo \'curl -LH \""''${head}"\" \""''${url}"\" -o \""''${txt}"\"\'
            curl -LH "''${head}" "''${url}" -o "''${txt}"
            echo End curl
            echo "" > ''${config}
            {
              echo 'subscription {'
              echo \ \ wget:\ \"file://proxy.d/''${num}.txt\"
              echo "}"
            } >> ''${config}
            if [[ ! -s ''${txt} ]]; then
              check=0
            fi
            chmod 0640 ''${txt}
            chmod 0640 ''${config}
            num=$((num+1))

            if [[ ''${check} -eq 0 ]]; then
              echo "''${txt}" is empty
              exit 103
            fi
          done
          if [[ -d /etc/dae/proxy.d ]]; then
            rm -rf /etc/proxy.d.old
            mv /etc/dae/proxy.d /etc/dae/proxy.d.old
          fi
          mv ''${new_proxy} /etc/dae/proxy.d
        '';
        updateScript = pkgs.writeShellApplication {
          name = "update.sh";
          runtimeInputs = with pkgs; [
            coreutils
            curl
          ];
          text = ''
            mkdir -p /etc/proxy.d
            if [ -z "$(ls -A /etc/dae/proxy.d 2>/dev/null)" ]; then
              echo "No subscription file found in /etc/dae/proxy.d. Update now..."
              ${update}
            else
              echo "Found existing subscription files. Skipping immediate update."
            fi
          '';
        };
        updateForceScript = pkgs.writeShellApplication {
          name = "update-force.sh";
          runtimeInputs = with pkgs; [
            coreutils
            curl
          ];
          text = ''
            ${update}
          '';
        };
      in {
        "update-dae-subscription-immediate" = {
          after = ["network-online.target"];
          wants = ["network-online.target"];
          before = ["dae.service"];
          serviceConfig = {
            Type = "oneshot";
            User = "root";
            ExecStart = [
              "${updateScript}/bin/update.sh"
            ];
          };
          wantedBy = ["multi-user.target"];
        };
        "update-dae-subscription-force" = {
          serviceConfig = {
            Type = "oneshot";
            User = "root";
            ExecStartPre = [
              "-${pkgs.systemd}/bin/systemctl stop dae.service"
            ];
            ExecStartPost = [
              "-${pkgs.systemd}/bin/systemctl start dae.service"
            ];
            ExecStart = [
              "${updateForceScript}/bin/update-force.sh"
            ];
          };
        };
      };
    })
    (lib.mkIf (cfg.enable && config.youthlic.programs.juicity.client.enable) {
      environment.etc."dae/local.d/0.dae" = {
        text = ''
          node {
            local: 'socks5://127.0.0.1:7890/'
          }
        '';
        mode = "0440";
      };
    })
  ];
}
