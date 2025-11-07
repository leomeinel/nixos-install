/*
  File: networking.nix
  Author: Leopold Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Meinel & contributors
  SPDX ID: MIT
  URL: https://opensource.org/licenses/MIT
  -----
*/

{
  installEnv,
  pkgs,
  ...
}:

{
  # Networking options
  networking = {
    # Select programs
    useNetworkd = true;
    useDHCP = false;
    # https://www.rfc-editor.org/rfc/rfc1178.html
    # Network devices: elements
    # Servers: colors
    # Clients: flowers
    hostName = "${installEnv.HOSTNAME}";
    # https://www.rfc-editor.org/rfc/rfc8375.html
    domain = "${installEnv.DOMAIN}";
    # Firewall (iptables)
    firewall = {
      enable = true;
      # Select ports
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      # Ping
      allowPing = false;
      # iptables commands
      extraCommands = ''
        # Configure iptables
        # FIXME: Replace with nftables
        # References
        #
        # https://networklessons.com/uncategorized/iptables-example-configuration
        # https://linoxide.com/block-common-attacks-iptables/
        # https://serverfault.com/questions/199421/how-to-prevent-ip-spoofing-within-iptables
        # https://www.cyberciti.biz/tips/linux-iptables-10-how-to-block-common-attack.html
        # https://javapipe.com/blog/iptables-ddos-protection/
        # https://danielmiessler.com/study/iptables/
        # https://inai.de/documents/Perfect_Ruleset.pdf
        # https://unix.stackexchange.com/questions/108169/what-is-the-difference-between-m-conntrack-ctstate-and-m-state-state
        # https://gist.github.com/jirutka/3742890
        # https://www.ripe.net/publications/docs/ripe-431
        # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security_guide/sect-security_guide-firewalls-malicious_software_and_spoofed_ip_addresses
        #
        ## ipv4
        ### Allow established connections
        ${pkgs.iptables}/bin/iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        ### Accept loopback
        ${pkgs.iptables}/bin/iptables -A INPUT -i lo -j ACCEPT
        ### Allow established connections on NETAVARK_FORWARD
        ${pkgs.iptables}/bin/iptables -N NETAVARK_FORWARD
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -d 10.88.0.0/16 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        ### First packet has to be TCP SYN
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
        ### Drop all invalid packets
        ${pkgs.iptables}/bin/iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
        ${pkgs.iptables}/bin/iptables -A FORWARD -m conntrack --ctstate INVALID -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -m conntrack --ctstate INVALID -j DROP
        ${pkgs.iptables}/bin/iptables -A OUTPUT -m conntrack --ctstate INVALID -j DROP
        ### Block packets with bogus TCP flags
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --tcp-flags FIN,ACK FIN -j DROP
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp --tcp-flags FIN,ACK FIN -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp --tcp-flags ACK,URG URG -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp --tcp-flags ACK,PSH PSH -j DROP
        ### Drop NULL packets
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp --tcp-flags ALL NONE -j DROP
        ### Drop XMAS packets
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp --tcp-flags ALL ALL -j DROP
        ### Drop fragments
        ${pkgs.iptables}/bin/iptables -A INPUT -f -j DROP
        ${pkgs.iptables}/bin/iptables -A FORWARD -f -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -f -j DROP
        ${pkgs.iptables}/bin/iptables -A OUTPUT -f -j DROP
        ### Drop SYN packets with suspicious MSS value
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
        ### Block spoofed packets
        ${pkgs.iptables}/bin/iptables -A INPUT -s 127.0.0.0/8 ! -i lo -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -s 127.0.0.0/8 ! -i lo -j DROP
        ### Drop ICMP
        ${pkgs.iptables}/bin/iptables -A INPUT -p icmp -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p icmp -j DROP
        ### Drop excessive TCP RST packets
        ${pkgs.iptables}/bin/iptables -N INPUT_PREROUTING
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j INPUT_PREROUTING
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
        #### Allow established connections on NETAVARK_FORWARD_PREROUTING
        ${pkgs.iptables}/bin/iptables -N NETAVARK_FORWARD_PREROUTING
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD_PREROUTING -d 10.88.0.0/16 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j NETAVARK_FORWARD_PREROUTING
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp --tcp-flags RST RST -j DROP
        ### Drop SYN-FLOOD packets
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 2/second --limit-burst 2 -j INPUT_PREROUTING
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp -m conntrack --ctstate NEW -m limit --limit 2/second --limit-burst 2 -j NETAVARK_FORWARD_PREROUTING
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -p tcp -m conntrack --ctstate NEW -j DROP
        ### Rate-limit UDP packets
        ${pkgs.iptables}/bin/iptables -A INPUT -p udp -m conntrack --ctstate NEW -m limit --limit 2/second --limit-burst 2 -j INPUT_PREROUTING
        ${pkgs.iptables}/bin/iptables -A INPUT -p udp -m conntrack --ctstate NEW -j DROP
        ### Allow SSH
        #### Set LOCAL_DOMAINS
        read -rd '\0' LOCAL_DOMAINS <<EOF
        10.0.0.0/8
        172.16.0.0/12
        192.168.0.0/16
        127.0.0.0/8
        \0
        EOF
        ####
        for local_domain in $LOCAL_DOMAINS; do
            ${pkgs.iptables}/bin/iptables -A INPUT_PREROUTING -p tcp --dport 9122 -s "$local_domain" -j ACCEPT
        done
        ${pkgs.iptables}/bin/iptables -A INPUT_PREROUTING -p tcp --dport 9122 -j DROP
        ### Jump to nixos-fw
        ${pkgs.iptables}/bin/iptables -N nixos-fw || true
        ${pkgs.iptables}/bin/iptables -A INPUT_PREROUTING -j nixos-fw
        ### Allow http & https
        #### Remote
        DOMAINS="$(${pkgs.curl}/bin/curl -s -X GET --url https://api.cloudflare.com/client/v4/ips -H 'Content-Type: application/json' | ${pkgs.jq}/bin/jq -r '.result.ipv4_cidrs[]' 2>/dev/null)"
        if [[ -z "$DOMAINS" ]]; then
            read -rd '\0' DOMAINS <<EOF
            173.245.48.0/20
            103.21.244.0/22
            103.22.200.0/22
            103.31.4.0/22
            141.101.64.0/18
            108.162.192.0/18
            190.93.240.0/20
            188.114.96.0/20
            197.234.240.0/22
            198.41.128.0/17
            162.158.0.0/15
            104.16.0.0/13
            104.24.0.0/14
            172.64.0.0/13
            131.0.72.0/22
            \0
        EOF
        fi
        for domain in $DOMAINS; do
            ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD_PREROUTING -p tcp --dport 80 -s "$domain" -d 10.88.0.0/16 -j ACCEPT
            ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD_PREROUTING -p tcp --dport 443 -s "$domain" -d 10.88.0.0/16 -j ACCEPT
        done
        #### Local
        for local_domain in $LOCAL_DOMAINS; do
            ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD_PREROUTING -p tcp --dport 80 -s "$local_domain" -d 10.88.0.0/16 -j ACCEPT
            ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD_PREROUTING -p tcp --dport 443 -s "$local_domain" -d 10.88.0.0/16 -j ACCEPT
        done
        ### Allow local network traffic on NETAVARK_FORWARD chains
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -s 10.88.0.0/16 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD_PREROUTING -s 10.88.0.0/16 -j ACCEPT
        ### Drop other traffic on NETAVARK_FORWARD chains
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD -j DROP
        ${pkgs.iptables}/bin/iptables -A NETAVARK_FORWARD_PREROUTING -j DROP
        ### Set default policies for chains
        ${pkgs.iptables}/bin/iptables -P INPUT DROP
        ${pkgs.iptables}/bin/iptables -P FORWARD DROP
        ${pkgs.iptables}/bin/iptables -P OUTPUT ACCEPT
        ## ipv6
        ### Allow established connections
        ${pkgs.iptables}/bin/ip6tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        ### Accept loopback
        ${pkgs.iptables}/bin/ip6tables -A INPUT -i lo -j ACCEPT
        ### Allow established connections on NETAVARK_FORWARD
        ${pkgs.iptables}/bin/ip6tables -N NETAVARK_FORWARD
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -d fe80::/10 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        ### First packet has to be TCP SYN
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
        ### Drop all invalid packets
        ${pkgs.iptables}/bin/ip6tables -A INPUT -m conntrack --ctstate INVALID -j DROP
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -m conntrack --ctstate INVALID -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -m conntrack --ctstate INVALID -j DROP
        ${pkgs.iptables}/bin/ip6tables -A OUTPUT -m conntrack --ctstate INVALID -j DROP
        ### Block packets with bogus TCP flags
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp --tcp-flags FIN,ACK FIN -j DROP
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp --tcp-flags FIN,ACK FIN -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp --tcp-flags ACK,URG URG -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp --tcp-flags ACK,PSH PSH -j DROP
        ### Drop NULL packets
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp --tcp-flags ALL NONE -j DROP
        ### Drop XMAS packets
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp --tcp-flags ALL ALL -j DROP
        ### Drop SYN packets with suspicious MSS value
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
        ### Block spoofed packets
        ${pkgs.iptables}/bin/ip6tables -A INPUT -s ::1/128 ! -i lo -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -s ::1/128 ! -i lo -j DROP
        ### Drop ICMP
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p icmp -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p icmp -j DROP
        ### Drop excessive TCP RST packets
        ${pkgs.iptables}/bin/ip6tables -N INPUT_PREROUTING
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j INPUT_PREROUTING
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp --tcp-flags RST RST -j DROP
        #### Allow established connections on NETAVARK_FORWARD_PREROUTING
        ${pkgs.iptables}/bin/ip6tables -N NETAVARK_FORWARD_PREROUTING
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD_PREROUTING -d fe80::/10 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j NETAVARK_FORWARD_PREROUTING
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp --tcp-flags RST RST -j DROP
        ### Drop SYN-FLOOD packets
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 2/second --limit-burst 2 -j INPUT_PREROUTING
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp -m conntrack --ctstate NEW -m limit --limit 2/second --limit-burst 2 -j NETAVARK_FORWARD_PREROUTING
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -p tcp -m conntrack --ctstate NEW -j DROP
        ### Rate-limit UDP packets
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -m limit --limit 2/second --limit-burst 2 -j INPUT_PREROUTING
        ${pkgs.iptables}/bin/ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -j DROP
        ### Allow SSH
        ${pkgs.iptables}/bin/ip6tables -A INPUT_PREROUTING -p tcp --dport 9122 -s fe80::/10 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -A INPUT_PREROUTING -p tcp --dport 9122 -j DROP
        ### Jump to nixos-fw
        ${pkgs.iptables}/bin/ip6tables -N nixos-fw || true
        ${pkgs.iptables}/bin/ip6tables -A INPUT_PREROUTING -j nixos-fw
        ### Allow http & https
        #### Remote
        DOMAINS="$(${pkgs.curl}/bin/curl -s -X GET --url https://api.cloudflare.com/client/v4/ips -H 'Content-Type: application/json' | ${pkgs.jq}/bin/jq -r '.result.ipv6_cidrs[]' 2>/dev/null)"
        if [[ -z "$DOMAINS" ]]; then
            read -rd '\0' DOMAINS <<EOF
            2400:cb00::/32
            2606:4700::/32
            2803:f800::/32
            2405:b500::/32
            2405:8100::/32
            2a06:98c0::/29
            2c0f:f248::/32
            \0
        EOF
        fi
        for domain in $DOMAINS; do
            ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD_PREROUTING -p tcp --dport 80 -s "$domain" -d fe80::/10 -j ACCEPT
            ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD_PREROUTING -p tcp --dport 443 -s "$domain" -d fe80::/10 -j ACCEPT
        done
        #### Local
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD_PREROUTING -p tcp --dport 80 -s fe80::/10 -d fe80::/10 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD_PREROUTING -p tcp --dport 443 -s fe80::/10 -d fe80::/10 -j ACCEPT
        ### Allow local network traffic on NETAVARK_FORWARD chains
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -s fe80::/10 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD_PREROUTING -s fe80::/10 -j ACCEPT
        ### Drop other traffic on NETAVARK_FORWARD chains
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD -j DROP
        ${pkgs.iptables}/bin/ip6tables -A NETAVARK_FORWARD_PREROUTING -j DROP
        ### Set default policies for chains
        ${pkgs.iptables}/bin/ip6tables -P INPUT DROP
        ${pkgs.iptables}/bin/ip6tables -P FORWARD DROP
        ${pkgs.iptables}/bin/ip6tables -P OUTPUT ACCEPT
      '';
    };
  };
}
