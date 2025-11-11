/*
  File: systemd.nix
  Author: Leopold Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Meinel & contributors
  SPDX ID: MIT
  URL: https://opensource.org/licenses/MIT
  -----
*/

{
  installEnv,
  lib,
  pkgs,
  ...
}:

{
  # systemd options (/etc/systemd/)
  systemd = {
    coredump.extraConfig = ''
      ProcessSizeMax=0
      Storage=none
    '';
    network = {
      enable = true;
      wait-online.enable = true;
      networks."10-en" = {
        matchConfig.Name = "${installEnv.NETWORK_INTERFACE}";
        networkConfig.DHCP = "ipv4";
        address = [
          "${installEnv.IPV6_ADDRESS}"
        ];
        routes = [
          { Gateway = "fe80::1"; }
        ];
      };
    };
    # Services
    services = {
      # System services
      systemd-logind = {
        serviceConfig.SupplementaryGroups = lib.mkForce "proc";
      };

      # Container pods
      create-reverse-proxy-pod = {
        description = "Create reverse-proxy-pod";
        serviceConfig.Type = "exec";
        wantedBy = [
          "multi-user.target"
        ];
        script = ''
          ${pkgs.podman}/bin/podman pod create --replace --ip=10.88.10.10 -p=80:80 -p=443:443 -n=reverse-proxy-pod --hostname=reverse-proxy-pod
        '';
      };

      # Container services
      podman-certbot = {
        serviceConfig.Restart = lib.mkForce "on-failure";
      };
      podman-certs-reverse-proxy = {
        serviceConfig.Restart = lib.mkForce "on-failure";
      };

      # Container additional services
      certbot-start = {
        description = "Start podman-certbot.service";
        serviceConfig.Type = "exec";
        wantedBy = [
          "multi-user.target"
        ];
        after = [
          "network.target"
        ];
        script = ''
          # Update certificates
          ${pkgs.systemd}/bin/systemctl start podman-certbot.service
        '';
      };

      # Container backups
      backup-container-volumes = {
        description = "Backup container volumes";
        serviceConfig = {
          Type = "exec";
          TimeoutStartSec = 10800;
        };
        onSuccess = [
          "backup-container-volumes-log-success.service"
        ];
        onFailure = [
          "backup-container-volumes-log-failure.service"
        ];
        script = ''
          # Fail on error
          set -eo pipefail

          # notify-log
          ${pkgs.curl}/bin/curl -s -F "title=${installEnv.HOSTNAME}-backup-container-volumes" -F "priority=0" -F "message=Started backup" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-backup-container-volumes.pass)"

          # Cleanup old files
          ${pkgs.coreutils-full}/bin/rm -f /root/backup/${installEnv.HOSTNAME}/tmp/*
          cleanup() {
              ## Create array of files older than $1 days
              FILES_LENGTH="''${#FILES[@]}"
              DATE="$(${pkgs.coreutils-full}/bin/date +"%F%H" -d "-''${1}day" | ${pkgs.gnused}/bin/sed "s/-//g")"
              for ((i = 0; i < FILES_LENGTH; i++)); do
                  FILE=$(${pkgs.gnused}/bin/sed "s/\.tar\.zst\.enc$//;s/-//g" <<<"''${FILES[''${i}]}")
                  if [[ "''${FILE}" -gt "''${DATE}" ]]; then
                      unset 'FILES[''${i}]'
                      continue
                  fi
                  FILES=("''${FILES[@]}")
              done
              ## Remove files older than $1 days
              FILES_LENGTH="''${#FILES[@]}"
              if [[ "''${FILES_LENGTH}" -gt 0 ]]; then
                  for ((i = 0; i < "''${FILES_LENGTH}"; i++)); do
                      FILES[i]="$(${pkgs.gnused}/bin/sed "s/^/.\/container-volumes\//" <<<"''${FILES[''${i}]}")"
                  done
                  MESSAGE="$(${pkgs.coreutils-full}/bin/printf '%s\n' "''${FILES[@]}")"
                  if [[ "$2" = "remote" ]]; then
                      ## local-log
                      ${pkgs.coreutils-full}/bin/echo "${installEnv.STORAGE_USER}@${installEnv.STORAGE_DOMAIN}: Removing files"
                      ${pkgs.coreutils-full}/bin/echo "''${MESSAGE}"
                      ## notify-log
                      ${pkgs.curl}/bin/curl -s -F "title=${installEnv.STORAGE_USER}@${installEnv.STORAGE_DOMAIN}: Removing files" -F "priority=10" -F "message=''${MESSAGE}" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-backup-container-volumes.pass)"
                      ${pkgs.openssh}/bin/ssh -p${installEnv.STORAGE_PORT} -i /root/.ssh/id_ed25519_${installEnv.HOSTNAME}-containers.bak_${installEnv.STORAGE_USER} ${installEnv.STORAGE_USER}@${installEnv.STORAGE_DOMAIN} rm -f "''${FILES[@]}"
                  else
                      ## local-log
                      ${pkgs.coreutils-full}/bin/echo "root@${installEnv.HOSTNAME}: Removing files"
                      ${pkgs.coreutils-full}/bin/echo "''${MESSAGE}"
                      ## notify-log
                      ${pkgs.curl}/bin/curl -s -F "title=root@${installEnv.HOSTNAME}: Removing files" -F "priority=10" -F "message=''${MESSAGE}" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-backup-container-volumes.pass)"
                      ${pkgs.coreutils-full}/bin/rm -f "''${FILES[@]}"
                  fi
              fi
          }
          readarray -t FILES < <(${pkgs.openssh}/bin/ssh -p${installEnv.STORAGE_PORT} -i /root/.ssh/id_ed25519_${installEnv.HOSTNAME}-containers.bak_${installEnv.STORAGE_USER} ${installEnv.STORAGE_USER}@${installEnv.STORAGE_DOMAIN} ls -A1 ./container-volumes | ${pkgs.gnugrep}/bin/grep .tar.zst.enc)
          cleanup 256 "remote"
          cd /root/backup/${installEnv.HOSTNAME}
          readarray -t FILES < <(${pkgs.coreutils-full}/bin/ls -A1 ./container-volumes | ${pkgs.gnugrep}/bin/grep .tar.zst.enc)
          cleanup 8 "local"

          # Backup volumes
          DATE="$(${pkgs.coreutils-full}/bin/date +"%F-%H")"
          VOLUMES=(
          )
          for volume in "''${VOLUMES[@]}"; do
              ${pkgs.podman}/bin/podman run --rm --name "${installEnv.HOSTNAME}-containers_''${volume}.bak-''${RANDOM}" -v /root/backup/${installEnv.HOSTNAME}/tmp:/backup -v "''${volume}":/data "docker.io/alpine" tar -cf /backup/"''${DATE}-${installEnv.HOSTNAME}-containers_''${volume}".tar /data
          done
          # Internal backup
          cd /root/backup/${installEnv.HOSTNAME}/tmp
          ${pkgs.gnutar}/bin/tar -cpf - ./*.tar | ${pkgs.zstd}/bin/zstd -T0 -9 -zqo /root/backup/${installEnv.HOSTNAME}/tmp/"''${DATE}".tar.zst
          ${pkgs.openssl}/bin/openssl enc -e -aes-256-cbc -pbkdf2 -salt -pass file:/run/secrets/keys/${installEnv.HOSTNAME}-containers.bak.pass -in /root/backup/${installEnv.HOSTNAME}/tmp/"''${DATE}".tar.zst -out /root/backup/${installEnv.HOSTNAME}/container-volumes/"''${DATE}".tar.zst.enc
          # External backup
          ${pkgs.openssl}/bin/openssl enc -e -aes-256-cbc -pbkdf2 -salt -pass file:/run/secrets/keys/${installEnv.HOSTNAME}-containers.bak_${installEnv.STORAGE_USER}.pass -in /root/backup/${installEnv.HOSTNAME}/tmp/"''${DATE}".tar.zst -out /root/backup/${installEnv.HOSTNAME}/tmp/"''${DATE}".tar.zst.enc
          ${pkgs.rsync}/bin/rsync -qe "${pkgs.openssh}/bin/ssh -p${installEnv.STORAGE_PORT} -i /root/.ssh/id_ed25519_${installEnv.HOSTNAME}-containers.bak_${installEnv.STORAGE_USER}" /root/backup/${installEnv.HOSTNAME}/tmp/"''${DATE}".tar.zst.enc ${installEnv.STORAGE_USER}@${installEnv.STORAGE_DOMAIN}:container-volumes

          # Cleanup old files
          ${pkgs.coreutils-full}/bin/rm -f /root/backup/${installEnv.HOSTNAME}/tmp/*
        '';
      };
      backup-container-volumes-log-success = {
        description = "Log success of service: backup-container-volumes";
        serviceConfig.Type = "exec";
        script = ''
          # Sleep 5 seconds to make sure this is sent last
          ${pkgs.coreutils-full}/bin/sleep 5

          # notify-log
          ${pkgs.curl}/bin/curl -s -F "title=${installEnv.HOSTNAME}-backup-container-volumes" -F "priority=0" -F "message=Completed backup successfully" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-backup-container-volumes.pass)"
        '';
      };
      backup-container-volumes-log-failure = {
        description = "Log failure of service: backup-container-volumes";
        serviceConfig.Type = "exec";
        script = ''
          # Sleep 5 seconds to make sure this is sent last
          ${pkgs.coreutils-full}/bin/sleep 5

          # Cleanup old files
          ${pkgs.coreutils-full}/bin/rm -f /root/backup/${installEnv.HOSTNAME}/tmp/*

          # notify-log
          ${pkgs.curl}/bin/curl -s -F "title=${installEnv.HOSTNAME}-backup-container-volumes" -F "priority=10" -F "message=Service failed: backup-container-volumes" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-backup-container-volumes.pass)"
        '';
      };

      # System monitoring
      monitor-updates = {
        description = "Monitor system updates";
        serviceConfig = {
          Type = "exec";
          TimeoutSec = 3600;
        };
        onSuccess = [
          "monitor-updates-log-success.service"
        ];
        onFailure = [
          "monitor-updates-log-failure.service"
        ];
        script = ''
          # Fail on error
          set -euo pipefail

          # Set environment
          PATH="''${PATH}:${pkgs.git}/bin:${pkgs.inetutils}/bin"

          # notify-log
          ${pkgs.curl}/bin/curl -s -F "title=${installEnv.HOSTNAME}-monitor-updates" -F "priority=0" -F "message=Started monitoring updates" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-monitor-updates.pass)"

          # Get ''${UPDATES[@]}
          TMP_DIR="$(${pkgs.coreutils-full}/bin/mktemp -d /tmp/monitor-updates.service-XXXXXX)"
          ${pkgs.git}/bin/git clone --depth 1 --reference /root/src/nixos-install /root/src/nixos-install "''${TMP_DIR}"
          cd "''${TMP_DIR}"
          ${pkgs.nix}/bin/nix flake update
          ${pkgs.nix}/bin/nix build ".#nixosConfigurations.${installEnv.HOSTNAME}.config.system.build.toplevel"
          readarray -t UPDATES < <(${pkgs.nvd}/bin/nvd --color=never --version-highlight=none diff /run/current-system ./result | grep "^\[[A-Z]" | awk '{print $3}')
          UPDATES_LENGTH="''${#UPDATES[@]}"

          # List number of outdated packages
          if [[ "''${UPDATES_LENGTH}" -ne 0 ]]; then
              MESSAGE="$(${pkgs.coreutils-full}/bin/printf '%s\n' "''${UPDATES[@]}")"
              # notify-log
              ${pkgs.curl}/bin/curl -s -F "title=''${UPDATES_LENGTH} packages are out of date!" -F "priority=10" -F "message=''${MESSAGE}" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-monitor-updates.pass)"
          fi

          # Remove TMP_DIR
          ${pkgs.coreutils-full}/bin/rm -rf "''${TMP_DIR}"
        '';
      };
      monitor-updates-log-success = {
        description = "Log success of service: monitor-updates";
        serviceConfig.Type = "exec";
        script = ''
          # Sleep 5 seconds to make sure this is sent last
          ${pkgs.coreutils-full}/bin/sleep 5

          # notify-log
          ${pkgs.curl}/bin/curl -s -F "title=${installEnv.HOSTNAME}-monitor-updates" -F "priority=0" -F "message=Completed monitoring updates successfully" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-monitor-updates.pass)"
        '';
      };
      monitor-updates-log-failure = {
        description = "Log failure of service: monitor-updates";
        serviceConfig.Type = "exec";
        script = ''
          # Sleep 5 seconds to make sure this is sent last
          ${pkgs.coreutils-full}/bin/sleep 5

          # notify-log
          ${pkgs.curl}/bin/curl -s -F "title=${installEnv.HOSTNAME}-monitor-updates" -F "priority=10" -F "message=Service failed: monitor-updates" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-monitor-updates.pass)"
        '';
      };

      # Container monitoring
      monitor-container-updates = {
        description = "Monitor container updates";
        serviceConfig = {
          Type = "exec";
          TimeoutSec = 3600;
        };
        onSuccess = [
          "monitor-container-updates-log-success.service"
        ];
        onFailure = [
          "monitor-container-updates-log-failure.service"
        ];
        script = ''
          # Fail on error
          set -eu

          # notify-log
          ${pkgs.curl}/bin/curl -s -F "title=${installEnv.HOSTNAME}-monitor-container-updates" -F "priority=0" -F "message=Started monitoring updates" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-monitor-container-updates.pass)"

          # Get ''${UPDATES[@]}
          REPO_DIR=/root/src/nixos-install
          readarray -t IMAGES_LOCAL < <(${pkgs.gnugrep}/bin/grep 'image = ".*";$' "''${REPO_DIR}"/nixos/configs/virtualisation.nix | ${pkgs.gnused}/bin/sed 's/image = "//' | ${pkgs.gnused}/bin/sed 's/";$//' | ${pkgs.coreutils-full}/bin/tr -d "[:blank:]" | ${pkgs.coreutils-full}/bin/sort -u)
          readarray -t IMAGES_REMOTE < <(${pkgs.gnugrep}/bin/grep '# update-equivalent: .*:.*$' "''${REPO_DIR}"/nixos/configs/virtualisation.nix | ${pkgs.gnused}/bin/sed 's/# update-equivalent: //' | ${pkgs.coreutils-full}/bin/tr -d "[:blank:]" | ${pkgs.coreutils-full}/bin/sort -u)
          UPDATES=()
          IMAGES_LOCAL_LENGTH="''${#IMAGES_LOCAL[@]}"
          for ((i = 0; i < IMAGES_LOCAL_LENGTH; i++)); do
              MATCHES=""
              local_digest="$(${pkgs.skopeo}/bin/skopeo inspect containers-storage:"''${IMAGES_LOCAL[''${i}]}" | ${pkgs.jq}/bin/jq -r ".Digest")"
              [[ -z "''${local_digest}" ]] &&
                  continue
              readarray -t remote_digests < <(${pkgs.skopeo}/bin/skopeo inspect --raw docker://"''${IMAGES_REMOTE[''${i}]}" | ${pkgs.jq}/bin/jq -r '.manifests[].digest')
              for digest in "''${remote_digests[@]}"; do
                  if [[ "$local_digest" == "$digest" ]]; then
                      MATCHES="true"
                      continue
                  fi
              done
              [[ -z "''${MATCHES}" ]] &&
                  UPDATES+=("''${IMAGES_REMOTE[''${i}]}")
          done
          UPDATES_LENGTH="''${#UPDATES[@]}"

          # List number of outdated containers
          if [[ "''${UPDATES_LENGTH}" -ne 0 ]]; then
              MESSAGE="$(${pkgs.coreutils-full}/bin/printf '%s\n' "''${UPDATES[@]}")"
              # notify-log
              ${pkgs.curl}/bin/curl -s -F "title=''${UPDATES_LENGTH} containers are out of date!" -F "priority=10" -F "message=''${MESSAGE}" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-monitor-container-updates.pass)"
          fi
        '';
      };
      monitor-container-updates-log-success = {
        description = "Log success of service: monitor-container-updates";
        serviceConfig.Type = "exec";
        script = ''
          # Sleep 5 seconds to make sure this is sent last
          ${pkgs.coreutils-full}/bin/sleep 5

          # notify-log
          ${pkgs.curl}/bin/curl -s -F "title=${installEnv.HOSTNAME}-monitor-container-updates" -F "priority=0" -F "message=Completed monitoring updates successfully" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-monitor-container-updates.pass)"
        '';
      };
      monitor-container-updates-log-failure = {
        description = "Log failure of service: monitor-container-updates";
        serviceConfig.Type = "exec";
        script = ''
          # Sleep 5 seconds to make sure this is sent last
          ${pkgs.coreutils-full}/bin/sleep 5

          # notify-log
          ${pkgs.curl}/bin/curl -s -F "title=${installEnv.HOSTNAME}-monitor-container-updates" -F "priority=10" -F "message=Service failed: monitor-container-updates" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-monitor-container-updates.pass)"
        '';
      };
    };

    # Timers
    timers = {
      # Container additional timers
      certbot-start = {
        description = "Start podman-certbot.service";
        wantedBy = [
          "timers.target"
        ];
        timerConfig = {
          OnCalendar = "*-*-* 00:00:00";
        };
      };

      # Container backups
      backup-container-volumes = {
        description = "Backup volumes";
        wantedBy = [
          "timers.target"
        ];
        timerConfig = {
          OnCalendar = "*-*-* 00,12:00:00";
        };
      };

      # System monitoring
      monitor-updates = {
        description = "Monitor updates";
        wantedBy = [
          "timers.target"
        ];
        timerConfig = {
          OnCalendar = "*-*-* 12:00:00";
        };
      };

      # System monitoring
      monitor-container-updates = {
        description = "Monitor container updates";
        wantedBy = [
          "timers.target"
        ];
        timerConfig = {
          OnCalendar = "*-*-* 12:00:00";
        };
      };
    };
  };
}
