{
  pkgs,
  config,
  rootPath,
  ...
}:
{
  services.dae = {
    enable = true;
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
  systemd.services =
    let
      new_proxy = "/etc/dae/proxy.d.new";
      head = "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36";
      update = ''
        num=0
        check=1
        urls="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.url.path})"
        mkdir -p ${new_proxy}
        for url in "''${urls}"; do
          txt=${new_proxy}/''${num}.txt
          config="${new_proxy}/''${num}.dae"
          ${pkgs.curl}/bin/curl -H "${head}" "''${url}" > "''${txt}"
          ${pkgs.coreutils}/bin/echo "" > ''${config}
          ${pkgs.coreutils}/bin/echo 'subscription {' >> ''${config}
          ${pkgs.coreutils}/bin/echo \ \ wget:\ \"file\://proxy.d/''${num}.txt\" >> ''${config}
          ${pkgs.coreutils}/bin/echo } >> ''${config}
          if [[ ! -s ''${txt} ]]; then
            check=0
          fi
          ${pkgs.coreutils}/bin/chmod 0640 ''${txt}
          ${pkgs.coreutils}/bin/chmod 0640 ''${config}
          link=$((link+1))

          if [[ ''${check} -eq 0 ]]; then
            exit -1
          fi
        done
        ${pkgs.coreutils}/bin/rm -r /etc/dae/proxy.d
        ${pkgs.coreutils}/bin/mv ${new_proxy} /etc/dae/proxy.d
      '';
    in
    {
      "update-dae-subscription-immediate" = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        before = [ "dae.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          ExecStart =
            let
              script = pkgs.writeTextFile {
                name = "update-dae-subscription-immediate";
                executable = true;
                destination = "/bin/script";
                text = ''
                  ${pkgs.coreutils}/bin/mkdir -p /etc/proxy.d
                  if [ -z "$(ls -A /etc/dae/proxy.d 2>/dev/null)" ]; then
                    ${pkgs.coreutils}/bin/echo "No subscription file found in /etc/dae/proxy.d. Update now..."
                    ${update}
                  else
                    ${pkgs.coreutils}/bin/echo "Found existing subscription files. Skipping immediate update."
                  fi
                '';
              };
            in
            [
              "${pkgs.bash}/bin/bash ${script}/bin/script"
            ];
        };
        wantedBy = [ "multi-user.target" ];
      };

      # "update-dae-subscription-weekly" = {
      #   after = [ "network-online.target" ];
      #   wants = [ "network-online.target" ];
      #   wantedBy = [ "multi-user.target" ];
      #   serviceConfig = {
      #     Type = "oneshot";
      #     ExecStart =
      #       let
      #         script = pkgs.writeTextFile {
      #           name = "update-dae-subscription-weekly";
      #           executable = true;
      #           destination = "/bin/script";
      #           text = ''
      #             ${pkgs.coreutils}/bin/echo "Force subscription update..."
      #             ${pkgs.coreutils}/bin/mkdir -p /etc/proxy.d
      #             ${update}
      #           '';
      #         };
      #       in
      #       [
      #         "${pkgs.bash}/bin/bash ${script}/bin/script"
      #       ];
      #   };
      # };
    };

  # systemd.timers."dae-update" = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnCalendar = "weekly";
  #     Unit = "dae-update.service";
  #     Persistent = true;
  #   };
  # };
}
