/*
  * File: networking.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, lib, config, pkgs, ... }:

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
    hostName = "REPLACE_HOSTNAME";
    # https://www.rfc-editor.org/rfc/rfc8375.html
    domain = "REPLACE_DOMAIN";
    # Firewall (iptables)
    firewall = {
      enable = true;
      # Select ports
      allowedTCPPorts = [ 80 443 9122 9123 ];
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
        ### Accept loopback
        iptables -A INPUT -i lo -j ACCEPT
        ### First packet has to be TCP SYN
        iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
        ### Drop all invalid packets
        iptables -A INPUT -m state --state INVALID -j DROP
        iptables -A FORWARD -m state --state INVALID -j DROP
        iptables -A OUTPUT -m state --state INVALID -j DROP
        ### Block packets with bogus TCP flags
        iptables -A INPUT -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
        iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
        iptables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
        iptables -A INPUT -p tcp --tcp-flags FIN,ACK FIN -j DROP
        iptables -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP
        iptables -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP
        ### Drop NULL packets
        iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
        ### Drop XMAS packets
        iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
        ### Drop excessive TCP RST packets
        iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
        iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
        ### Drop SYN-FLOOD packets
        iptables -A INPUT -p tcp -m state --state NEW -m limit --limit 2/second --limit-burst 2 -j ACCEPT
        iptables -A INPUT -p tcp -m state --state NEW -j DROP
        ### Drop fragments
        iptables -A INPUT -f -j DROP
        iptables -A FORWARD -f -j DROP
        iptables -A OUTPUT -f -j DROP
        ### Drop SYN packets with suspicious MSS value
        iptables -A INPUT -p tcp -m state --state NEW -m tcpmss ! --mss 536:65535 -j DROP
        ### Block spoofed packets
        iptables -A INPUT -s 127.0.0.0/8 ! -i lo -j DROP
        ### Drop ICMP
        iptables -A INPUT -p icmp -j DROP
        ### Allow established connections
        iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
        ### Set default policies for chains
        iptables -P INPUT DROP
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT
        ## ipv6
        ### Accept loopback
        ip6tables -A INPUT -i lo -j ACCEPT
        ### First packet has to be TCP SYN
        ip6tables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
        ### Drop all invalid packets
        ip6tables -A INPUT -m state --state INVALID -j DROP
        ip6tables -A FORWARD -m state --state INVALID -j DROP
        ip6tables -A OUTPUT -m state --state INVALID -j DROP
        ### Block packets with bogus TCP flags
        ip6tables -A INPUT -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
        ip6tables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
        ip6tables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
        ip6tables -A INPUT -p tcp --tcp-flags FIN,ACK FIN -j DROP
        ip6tables -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP
        ip6tables -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP
        ### Drop NULL packets
        ip6tables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
        ### Drop XMAS packets
        ip6tables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
        ### Drop excessive TCP RST packets
        ip6tables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
        ip6tables -A INPUT -p tcp --tcp-flags RST RST -j DROP
        ### Drop SYN-FLOOD packets
        ip6tables -A INPUT -p tcp -m state --state NEW -m limit --limit 2/second --limit-burst 2 -j ACCEPT
        ip6tables -A INPUT -p tcp -m state --state NEW -j DROP
        ### Drop fragments
        ip6tables -A INPUT -m frag -j DROP
        ip6tables -A FORWARD -m frag -j DROP
        ip6tables -A OUTPUT -m frag -j DROP
        ### Drop SYN packets with suspicious MSS value
        ip6tables -A INPUT -p tcp -m state --state NEW -m tcpmss ! --mss 536:65535 -j DROP
        ### Block spoofed packets
        ip6tables -A INPUT -s ::1/128 ! -i lo -j DROP
        ### Drop ICMP
        ip6tables -A INPUT -p icmp -j DROP
        ### Allow established connections
        ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
        ### Set default policies for chains
        ip6tables -P INPUT DROP
        ip6tables -P FORWARD ACCEPT
        ip6tables -P OUTPUT ACCEPT
      '';
    };
  };
}
