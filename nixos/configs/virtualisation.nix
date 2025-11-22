/*
  File: virtualisation.nix
  Author: Leopold Johannes Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Johannes Meinel & contributors
  SPDX ID: Apache-2.0
  URL: https://www.apache.org/licenses/LICENSE-2.0
*/

{
  installEnv,
  ...
}:

{
  # Virtualisation options
  virtualisation = {
    podman = {
      enable = true;
      dockerSocket.enable = false;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [
          "-a"
        ];
      };
    };
    oci-containers = {
      backend = "podman";
      containers = {
        certbot = {
          # https://hub.docker.com/r/certbot/dns-cloudflare
          # update-equivalent: docker.io/certbot/dns-cloudflare:latest
          image = "docker.io/certbot/dns-cloudflare:v5.1.0";
          pull = "newer";
          # INFO: This is started automatically by certbot-start.service
          autoStart = false;
          cmd = [
            "certonly"
            "-n"
            "--dns-cloudflare"
            "--dns-cloudflare-credentials"
            "/cloudflare.ini"
            "--dns-cloudflare-propagation-seconds"
            "60"
            "-d"
            "${installEnv.HOSTNAME}.${installEnv.CERTBOT_TLD}"
            "-d"
            "*.${installEnv.HOSTNAME}.${installEnv.CERTBOT_TLD}"
            "--no-eff-email"
            "-m"
            "${installEnv.HOSTNAME}@${installEnv.CERTBOT_TLD}"
            "--agree-tos"
          ];
          extraOptions = [
            "--replace"
          ];
          volumes = [
            "certbot_letsencrypt:/etc/letsencrypt"
            "/run/secrets/containers/volumes/certbot/cloudflare.ini:/cloudflare.ini:ro"
          ];
        };
        certs-reverse-proxy = {
          # https://code.forgejo.org/oci/-/packages/container/alpine/latest
          # update-equivalent: code.forgejo.org/oci/alpine:latest
          image = "code.forgejo.org/oci/alpine:3.22";
          pull = "newer";
          cmd = [
            "/bin/sh"
            "-c"
            "/scripts/certs.sh"
          ];
          extraOptions = [
            "--replace"
          ];
          volumes = [
            "/etc/containers/src/volumes/certs-reverse-proxy:/scripts:ro"
            "certs-reverse-proxy_certs:/certs"
          ];
        };
        reverse-proxy = {
          # https://hub.docker.com/_/nginx
          # update-equivalent: docker.io/nginx:stable-alpine
          image = "docker.io/nginx:1.28-alpine";
          pull = "newer";
          extraOptions = [
            "--replace"
            "--pod=reverse-proxy-pod"
          ];
          volumes = [
            "certbot_letsencrypt:/etc/letsencrypt:ro"
            "certs-reverse-proxy_certs:/etc/self-signed:ro"
            "/run/secrets/containers/volumes/reverse-proxy/certs:/etc/nginx/certs:ro"
            "/etc/containers/src/volumes/reverse-proxy/conf.d/sites-available:/etc/nginx/conf.d/sites-available:ro"
            "/etc/containers/src/volumes/reverse-proxy/conf.d/sites-enabled:/etc/nginx/conf.d/sites-enabled:ro"
            "/etc/containers/src/volumes/nginx/nginx.conf:/etc/nginx/nginx.conf:ro"
            "/etc/containers/src/volumes/nginx/includes:/etc/nginx/includes:ro"
          ];
        };
      };
    };
  };
}
