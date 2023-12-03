/*
  * File: configuration.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, lib, config, pkgs, ... }:

let
  # FIXME: Use variable
  HOSTNAME = "red";
  # FIXME: Use variable
  DOMAIN = "cloud.arpa";
in
{
  imports = [
    ./hardware-configuration.nix
    ./home-manager.nix
  ];

  boot.kernelParams = [
    "bgrt_disable"
    "iommu=pt"
    "zswap.enabled=0"
  ];
  boot.consoleLogLevel = 3;
  boot.kernel.sysctl = {
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/net.html#bpf-jit-enable
    "net.core.bpf_jit_harden" = "2";
    # https://sysctl-explorer.net/net/ipv4/accept_redirects/
    "net.ipv4.conf.all.accept_redirects" = "0";
    # https://sysctl-explorer.net/net/ipv4/accept_source_route/
    "net.ipv4.conf.all.accept_source_route" = "0";
    # https://sysctl-explorer.net/net/ipv4/bootp_relay/
    "net.ipv4.conf.all.bootp_relay" = "0";
    # https://sysctl-explorer.net/net/ipv4/forwarding/
    "net.ipv4.conf.all.forwarding" = "0";
    # https://sysctl-explorer.net/net/ipv4/log_martians/
    "net.ipv4.conf.all.log_martians" = "1";
    # https://sysctl-explorer.net/net/ipv4/mc_forwarding/
    "net.ipv4.conf.all.mc_forwarding" = "0";
    # https://sysctl-explorer.net/net/ipv4/proxy_arp/
    "net.ipv4.conf.all.proxy_arp" = "0";
    # https://sysctl-explorer.net/net/ipv4/rp_filter/
    "net.ipv4.conf.all.rp_filter" = "1";
    # https://sysctl-explorer.net/net/ipv4/secure_redirects/
    "net.ipv4.conf.all.secure_redirects" = "0";
    # https://sysctl-explorer.net/net/ipv4/send_redirects/
    "net.ipv4.conf.all.send_redirects" = "0";
    # https://sysctl-explorer.net/net/ipv4/accept_redirects/
    "net.ipv4.conf.default.accept_redirects" = "0";
    # https://sysctl-explorer.net/net/ipv4/accept_source_route/
    "net.ipv4.conf.default.accept_source_route" = "0";
    # https://sysctl-explorer.net/net/ipv4/log_martians/
    "net.ipv4.conf.default.log_martians" = "1";
    # https://sysctl-explorer.net/net/ipv4/secure_redirects/
    "net.ipv4.conf.default.secure_redirects" = "0";
    # https://sysctl-explorer.net/net/ipv4/send_redirects/
    "net.ipv4.conf.default.send_redirects" = "0";
    # https://sysctl-explorer.net/net/ipv4/icmp_echo_ignore_all/
    "net.ipv4.icmp_echo_ignore_all" = "1";
    # https://sysctl-explorer.net/net/ipv4/icmp_echo_ignore_broadcasts/
    "net.ipv4.icmp_echo_ignore_broadcasts" = "1";
    # https://sysctl-explorer.net/net/ipv4/icmp_ignore_bogus_error_responses/
    "net.ipv4.icmp_ignore_bogus_error_responses" = "1";
    # https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html#tcp-variables (search tcp_rfc1337)
    "net.ipv4.tcp_rfc1337" = "1";
    # https://sysctl-explorer.net/net/ipv4/tcp_syncookies/
    "net.ipv4.tcp_syncookies" = "1";
    # https://sysctl-explorer.net/net/ipv4/tcp_timestamps/
    "net.ipv4.tcp_timestamps" = "0";
    # https://sysctl-explorer.net/net/ipv6/accept_redirects/
    "net.ipv6.conf.all.accept_redirects" = "0";
    # https://sysctl-explorer.net/net/ipv6/accept_source_route/
    "net.ipv6.conf.all.accept_source_route" = "0";
    # https://sysctl-explorer.net/net/ipv6/accept_redirects/
    "net.ipv6.conf.default.accept_redirects" = "0";
    # https://sysctl-explorer.net/net/ipv6/accept_source_route/
    "net.ipv6.conf.default.accept_source_route" = "0";
    # https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html#proc-sys-net-ipv6-variables (search echo_ignore_all)
    "net.ipv6.icmp.echo_ignore_all" = "1";
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#core-uses-pid
    "kernel.core_uses_pid" = "1";
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#ctrl-alt-del
    "kernel.ctrl-alt-del" = "0";
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#dmesg-restrict
    "kernel.dmesg_restrict" = "1";
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#kexec-load-disabled
    "kernel.kexec_load_disabled" = "1";
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#kptr-restrict
    "kernel.kptr_restrict" = "2";
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#modules-disabled
    # INFO: kernel.modules_disabled=1 prevents system from booting
    "kernel.modules_disabled" = "0";
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#perf-event-paranoid
    "kernel.perf_event_paranoid" = "3";
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#randomize-va-space
    "kernel.randomize_va_space" = "2";
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#sysrq
    "kernel.sysrq" = "0";
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#unprivileged-bpf-disabled
    "kernel.unprivileged_bpf_disabled" = "1";
    # https://www.kernel.org/doc/Documentation/security/Yama.txt
    "kernel.yama.ptrace_scope" = "1";
    # https://github.com/torvalds/linux/blob/master/drivers/tty/Kconfig (search dev.tty.ldisc_autoload)
    "dev.tty.ldisc_autoload" = "0";
    # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-fifos
    "fs.protected_fifos" = "2";
    # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-hardlinks
    "fs.protected_hardlinks" = "1";
    # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-regular
    "fs.protected_regular" = "2";
    # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-symlinks
    "fs.protected_symlinks" = "1";
    # https://docs.kernel.org/admin-guide/sysctl/fs.html#suid-dumpable
    "fs.suid_dumpable" = "0";
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/vm.html#overcommit-memory
    "vm.overcommit_memory" = "1";
  };
  boot.blacklistedKernelModules = [
    "pcspkr"
    "snd_pcsp"
  ];
  boot.extraModprobeConfig = ''
    install dccp /bin/true
    install firewire_core /bin/true
    install firewire_ohci /bin/true
    install rds /bin/true
    install sctp /bin/true
    install tipc /bin/true
  '';
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/efi";
    };
    systemd-boot = {
      enable = true;
      configurationLimit = 12;
      consoleMode = "max";
      editor = false;
    };
    timeout = 4;
  };

  fileSystems =
    {
      # CODEGEN: fileSystems #
      # tmpfs
      "/dev/shm" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "rw" "noexec" "nodev" "nosuid" ];
      };
      "/tmp" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "rw" "noexec" "nodev" "nosuid" "uid=0" "gid=0" "mode=1700" ];
      };
    };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
  };

  networking = {
    # https://www.rfc-editor.org/rfc/rfc1178.html
    # Network devices: elements
    # Servers: colors
    # Clients: flowers
    hostName = "${HOSTNAME}";
    # https://www.rfc-editor.org/rfc/rfc8375.html
    domain = "${DOMAIN}";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 9122 9123 ];
      allowedUDPPorts = [ ];
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
      allowPing = false;
    };
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network = {
    enable = true;
    networks."10-wan" = {
      # FIXME: Use variable
      matchConfig.Name = "enp1s0";
      networkConfig.DHCP = "ipv4";
      address = [
        # FIXME: Use variable
        "2a01:4f8:1c1b:8520::1/64"
      ];
      routes = [
        { routeConfig.Gateway = "fe80::1"; }
      ];
    };
  };
  systemd.coredump.enable = false;
  systemd.network.wait-online.enable = true;

  # FIXME: Use variable
  time.timeZone = "Etc/UTC";

  # FIXME: Use variables
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "de_DE.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8" "fr_FR.UTF-8/UTF-8" "nl_NL.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LANGUAGE = "en_US.UTF-8:en_US:en:C";
      LC_ADDRESS = "en_US.UTF-8";
      LC_COLLATE = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_TIME = "en_DK.UTF-8";
      LC_MEASUREMENT = "en_DK.UTF-8";
      LC_PAPER = "nl_NL.UTF-8";
      LC_TELEPHONE = "nl_NL.UTF-8";
      LC_IDENTIFICATION = "nl_NL.UTF-8";
    };
  };

  # FIXME: Use variable
  console.keyMap = "de-latin1";

  security.audit = {
    enable = true;
    rules = [
      "-D"
      "-b 8192"
      "-f 1"
      "-i"
      "-w /var/log/audit/ -p wra -k auditlog"
      "-w /var/log/audit/ -p wra -k T1005_Data_From_Local_System_audit_log"
      "-w /var/audit/ -p wra -k T1005_Data_From_Local_System_audit_log"
      "-w /etc/audit/ -p wa -k auditconfig"
      "-w /etc/libaudit.conf -p wa -k auditconfig"
      "-w /etc/audisp/ -p wa -k audispconfig"
      "-w /sbin/auditctl -p x -k audittools"
      "-w /sbin/auditd -p x -k audittools"
      "-w /usr/sbin/auditd -p x -k audittools"
      "-w /usr/sbin/augenrules -p x -k audittools"
      "-a always,exit -F path=/usr/sbin/ausearch -F perm=x -k T1005_Data_From_Local_System_audit_log"
      "-a always,exit -F path=/usr/sbin/aureport -F perm=x -k T1005_Data_From_Local_System_audit_log"
      "-a always,exit -F path=/usr/sbin/aulast -F perm=x -k T1005_Data_From_Local_System_audit_log"
      "-a always,exit -F path=/usr/sbin/aulastlogin -F perm=x -k T1005_Data_From_Local_System_audit_log"
      "-a always,exit -F path=/usr/sbin/auvirt -F perm=x -k T1005_Data_From_Local_System_audit_log"
      "-a always,exclude -F msgtype=AVC"
      "-a always,exclude -F msgtype=CWD"
      "-a never,user -F subj_type=crond_t"
      "-a never,exit -F subj_type=crond_t"
      "-a never,exit -F arch=b32 -S adjtimex -F auid=unset -F uid=chrony -F subj_type=chronyd_t"
      "-a never,exit -F arch=b64 -S adjtimex -F auid=unset -F uid=chrony -F subj_type=chronyd_t"
      "-a always,exclude -F msgtype=CRYPTO_KEY_USER"
      "-a never,exit -F arch=b32 -S fork -F success=0 -F path=/usr/lib/vmware-tools -F subj_type=initrc_t -F exit=-2"
      "-a never,exit -F arch=b64 -S fork -F success=0 -F path=/usr/lib/vmware-tools -F subj_type=initrc_t -F exit=-2"
      "-a exit,never -F arch=b32 -S all -F exe=/usr/bin/vmtoolsd"
      "-a exit,never -F arch=b64 -S all -F exe=/usr/bin/vmtoolsd"
      "-a never,exit -F arch=b32 -F dir=/dev/shm -k sharedmemaccess"
      "-a never,exit -F arch=b64 -F dir=/dev/shm -k sharedmemaccess"
      "-a never,exit -F arch=b32 -F dir=/var/lock/lvm -k locklvm"
      "-a never,exit -F arch=b64 -F dir=/var/lock/lvm -k locklvm"
      "-a never,exit -F arch=b32 -F path=/opt/filebeat -k filebeat"
      "-a never,exit -F arch=b64 -F path=/opt/filebeat -k filebeat"
      "-w /etc/sysctl.conf -p wa -k sysctl"
      "-w /etc/sysctl.d -p wa -k sysctl"
      "-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/insmod -k modules"
      "-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/modprobe -k modules"
      "-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/rmmod -k modules"
      "-a always,exit -F arch=b64 -S finit_module -S init_module -S delete_module -F auid!=-1 -k modules"
      "-a always,exit -F arch=b32 -S finit_module -S init_module -S delete_module -F auid!=-1 -k modules"
      "-w /etc/modprobe.conf -p wa -k modprobe"
      "-w /etc/modprobe.d -p wa -k modprobe"
      "-a always,exit -F arch=b64 -S kexec_load -k KEXEC"
      "-a always,exit -F arch=b32 -S sys_kexec_load -k KEXEC"
      "-a always,exit -F arch=b32 -S mknod -S mknodat -k specialfiles"
      "-a always,exit -F arch=b64 -S mknod -S mknodat -k specialfiles"
      "-a always,exit -F arch=b64 -S mount -S umount2 -F auid!=-1 -k mount"
      "-a always,exit -F arch=b32 -S mount -S umount -S umount2 -F auid!=-1 -k mount"
      "-a always,exit -F arch=b64 -S swapon -S swapoff -F auid!=-1 -k swap"
      "-a always,exit -F arch=b32 -S swapon -S swapoff -F auid!=-1 -k swap"
      "-a always,exit -F arch=b32 -F uid!=ntp -S adjtimex -S settimeofday -S clock_settime -k time"
      "-a always,exit -F arch=b64 -F uid!=ntp -S adjtimex -S settimeofday -S clock_settime -k time"
      "-w /etc/localtime -p wa -k localtime"
      "-w /usr/sbin/stunnel -p x -k stunnel"
      "-w /usr/bin/stunnel -p x -k stunnel"
      "-w /etc/cron.allow -p wa -k cron"
      "-w /etc/cron.deny -p wa -k cron"
      "-w /etc/cron.d/ -p wa -k cron"
      "-w /etc/cron.daily/ -p wa -k cron"
      "-w /etc/cron.hourly/ -p wa -k cron"
      "-w /etc/cron.monthly/ -p wa -k cron"
      "-w /etc/cron.weekly/ -p wa -k cron"
      "-w /etc/crontab -p wa -k cron"
      "-w /var/spool/cron/ -p wa -k cron"
      "-w /etc/group -p wa -k etcgroup"
      "-w /etc/passwd -p wa -k etcpasswd"
      "-w /etc/gshadow -k etcgroup"
      "-w /etc/shadow -k etcpasswd"
      "-w /etc/security/opasswd -k opasswd"
      "-w /etc/sudoers -p wa -k actions"
      "-w /etc/sudoers.d/ -p wa -k actions"
      "-w /usr/bin/passwd -p x -k passwd_modification"
      "-w /usr/sbin/groupadd -p x -k group_modification"
      "-w /usr/sbin/groupmod -p x -k group_modification"
      "-w /usr/sbin/addgroup -p x -k group_modification"
      "-w /usr/sbin/useradd -p x -k user_modification"
      "-w /usr/sbin/userdel -p x -k user_modification"
      "-w /usr/sbin/usermod -p x -k user_modification"
      "-w /usr/sbin/adduser -p x -k user_modification"
      "-w /etc/login.defs -p wa -k login"
      "-w /etc/securetty -p wa -k login"
      "-w /var/log/faillog -p wa -k login"
      "-w /var/log/lastlog -p wa -k login"
      "-w /var/log/tallylog -p wa -k login"
      "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k network_modifications"
      "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications"
      "-a always,exit -F arch=b32 -F exe=/bin/bash -F success=1 -S connect -k \"remote_shell\""
      "-a always,exit -F arch=b64 -F exe=/bin/bash -F success=1 -S connect -k \"remote_shell\""
      "-a always,exit -F arch=b32 -F exe=/usr/bin/bash -F success=1 -S connect -k \"remote_shell\""
      "-a always,exit -F arch=b64 -F exe=/usr/bin/bash -F success=1 -S connect -k \"remote_shell\""
      "-a always,exit -F arch=b64 -S connect -F a2=16 -F success=1 -F key=network_connect_4"
      "-a always,exit -F arch=b32 -S connect -F a2=16 -F success=1 -F key=network_connect_4"
      "-a always,exit -F arch=b64 -S connect -F a2=28 -F success=1 -F key=network_connect_6"
      "-a always,exit -F arch=b32 -S connect -F a2=28 -F success=1 -F key=network_connect_6"
      "-w /etc/hosts -p wa -k network_modifications"
      "-w /etc/sysconfig/network -p wa -k network_modifications"
      "-w /etc/sysconfig/network-scripts -p w -k network_modifications"
      "-w /etc/network/ -p wa -k network"
      "-a always,exit -F dir=/etc/NetworkManager/ -F perm=wa -k network_modifications"
      "-w /etc/issue -p wa -k etcissue"
      "-w /etc/issue.net -p wa -k etcissue"
      "-w /etc/inittab -p wa -k init"
      "-w /etc/init.d/ -p wa -k init"
      "-w /etc/init/ -p wa -k init"
      "-w /etc/ld.so.conf -p wa -k libpath"
      "-w /etc/ld.so.conf.d -p wa -k libpath"
      "-w /etc/ld.so.preload -p wa -k systemwide_preloads"
      "-w /etc/pam.d/ -p wa -k pam"
      "-w /etc/security/limits.conf -p wa -k pam"
      "-w /etc/security/limits.d -p wa -k pam"
      "-w /etc/security/pam_env.conf -p wa -k pam"
      "-w /etc/security/namespace.conf -p wa -k pam"
      "-w /etc/security/namespace.d -p wa -k pam"
      "-w /etc/security/namespace.init -p wa -k pam"
      "-w /etc/aliases -p wa -k mail"
      "-w /etc/postfix/ -p wa -k mail"
      "-w /etc/exim4/ -p wa -k mail"
      "-w /etc/ssh/sshd_config -k sshd"
      "-w /etc/ssh/sshd_config.d -k sshd"
      "-w /root/.ssh -p wa -k rootkey"
      "-w /bin/systemctl -p x -k systemd"
      "-w /etc/systemd/ -p wa -k systemd"
      "-w /usr/lib/systemd -p wa -k systemd"
      "-w /etc/selinux/ -p wa -k mac_policy"
      "-a always,exit -F arch=b64 -S open -F dir=/etc -F success=0 -k unauthedfileaccess"
      "-a always,exit -F arch=b64 -S open -F dir=/bin -F success=0 -k unauthedfileaccess"
      "-a always,exit -F arch=b64 -S open -F dir=/sbin -F success=0 -k unauthedfileaccess"
      "-a always,exit -F arch=b64 -S open -F dir=/usr/bin -F success=0 -k unauthedfileaccess"
      "-a always,exit -F arch=b64 -S open -F dir=/usr/sbin -F success=0 -k unauthedfileaccess"
      "-a always,exit -F arch=b64 -S open -F dir=/var -F success=0 -k unauthedfileaccess"
      "-a always,exit -F arch=b64 -S open -F dir=/home -F success=0 -k unauthedfileaccess"
      "-a always,exit -F arch=b64 -S open -F dir=/srv -F success=0 -k unauthedfileaccess"
      "-w /bin/su -p x -k priv_esc"
      "-w /usr/bin/sudo -p x -k priv_esc"
      "-w /etc/sudoers -p rw -k priv_esc"
      "-w /etc/sudoers.d -p rw -k priv_esc"
      "-w /sbin/shutdown -p x -k power"
      "-w /sbin/poweroff -p x -k power"
      "-w /sbin/reboot -p x -k power"
      "-w /sbin/halt -p x -k power"
      "-w /var/run/utmp -p wa -k session"
      "-w /var/log/btmp -p wa -k session"
      "-w /var/log/wtmp -p wa -k session"
      "-a always,exit -F arch=b32 -S chmod -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S chown -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S fchmod -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S fchmodat -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S fchown -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S fchownat -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S fremovexattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S fsetxattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S lchown -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S lremovexattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S lsetxattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S removexattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b32 -S setxattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S chmod -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S chown -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S fchmod -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S fchmodat -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S fchown -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S fchownat -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S fremovexattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S fsetxattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S lchown -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S lremovexattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S lsetxattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S removexattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-a always,exit -F arch=b64 -S setxattr -F auid -F auid!=-1 -k perm_mod >=1000"
      "-w /usr/bin/whoami -p x -k recon"
      "-w /usr/bin/id -p x -k recon"
      "-w /bin/hostname -p x -k recon"
      "-w /bin/uname -p x -k recon"
      "-w /etc/issue -p r -k recon"
      "-w /etc/hostname -p r -k recon"
      "-w /usr/bin/wget -p x -k susp_activity"
      "-w /usr/bin/curl -p x -k susp_activity"
      "-w /usr/bin/base64 -p x -k susp_activity"
      "-w /bin/nc -p x -k susp_activity"
      "-w /bin/netcat -p x -k susp_activity"
      "-w /usr/bin/ncat -p x -k susp_activity"
      "-w /usr/bin/ss -p x -k susp_activity"
      "-w /usr/bin/netstat -p x -k susp_activity"
      "-w /usr/bin/ssh -p x -k susp_activity"
      "-w /usr/bin/scp -p x -k susp_activity"
      "-w /usr/bin/sftp -p x -k susp_activity"
      "-w /usr/bin/ftp -p x -k susp_activity"
      "-w /usr/bin/socat -p x -k susp_activity"
      "-w /usr/bin/wireshark -p x -k susp_activity"
      "-w /usr/bin/tshark -p x -k susp_activity"
      "-w /usr/bin/rawshark -p x -k susp_activity"
      "-w /usr/bin/rdesktop -p x -k T1219_Remote_Access_Tools"
      "-w /usr/local/bin/rdesktop -p x -k T1219_Remote_Access_Tools"
      "-w /usr/bin/wlfreerdp -p x -k susp_activity"
      "-w /usr/bin/xfreerdp -p x -k T1219_Remote_Access_Tools"
      "-w /usr/local/bin/xfreerdp -p x -k T1219_Remote_Access_Tools"
      "-w /usr/bin/nmap -p x -k susp_activity"
      "-w /usr/bin/zip -p x -k T1002_Data_Compressed"
      "-w /usr/bin/gzip -p x -k T1002_Data_Compressed"
      "-w /usr/bin/tar -p x -k T1002_Data_Compressed"
      "-w /usr/bin/bzip2 -p x -k T1002_Data_Compressed"
      "-w /usr/bin/lzip -p x -k T1002_Data_Compressed"
      "-w /usr/local/bin/lzip -p x -k T1002_Data_Compressed"
      "-w /usr/bin/lz4 -p x -k T1002_Data_Compressed"
      "-w /usr/local/bin/lz4 -p x -k T1002_Data_Compressed"
      "-w /usr/bin/lzop -p x -k T1002_Data_Compressed"
      "-w /usr/local/bin/lzop -p x -k T1002_Data_Compressed"
      "-w /usr/bin/plzip -p x -k T1002_Data_Compressed"
      "-w /usr/local/bin/plzip -p x -k T1002_Data_Compressed"
      "-w /usr/bin/pbzip2 -p x -k T1002_Data_Compressed"
      "-w /usr/local/bin/pbzip2 -p x -k T1002_Data_Compressed"
      "-w /usr/bin/lbzip2 -p x -k T1002_Data_Compressed"
      "-w /usr/local/bin/lbzip2 -p x -k T1002_Data_Compressed"
      "-w /usr/bin/pixz -p x -k T1002_Data_Compressed"
      "-w /usr/local/bin/pixz -p x -k T1002_Data_Compressed"
      "-w /usr/bin/pigz -p x -k T1002_Data_Compressed"
      "-w /usr/local/bin/pigz -p x -k T1002_Data_Compressed"
      "-w /usr/bin/unpigz -p x -k T1002_Data_Compressed"
      "-w /usr/local/bin/unpigz -p x -k T1002_Data_Compressed"
      "-w /usr/bin/zstd -p x -k T1002_Data_Compressed"
      "-w /usr/local/bin/zstd -p x -k T1002_Data_Compressed"
      "-w /bin/nc.openbsd -p x -k susp_activity"
      "-w /bin/nc.traditional -p x -k susp_activity"
      "-w /sbin/iptables -p x -k sbin_susp"
      "-w /sbin/ip6tables -p x -k sbin_susp"
      "-w /sbin/ifconfig -p x -k sbin_susp"
      "-w /usr/sbin/arptables -p x -k sbin_susp"
      "-w /usr/sbin/ebtables -p x -k sbin_susp"
      "-w /sbin/xtables-nft-multi -p x -k sbin_susp"
      "-w /usr/sbin/nft -p x -k sbin_susp"
      "-w /usr/sbin/tcpdump -p x -k sbin_susp"
      "-w /usr/sbin/traceroute -p x -k sbin_susp"
      "-w /usr/sbin/ufw -p x -k sbin_susp"
      "-w /usr/bin/dbus-send -p x -k dbus_send"
      "-w /usr/bin/gdbus -p x -k gdubs_call"
      "-w /usr/bin/pkexec -p x -k pkexec"
      "-w /bin/ash -p x -k susp_shell"
      "-w /bin/csh -p x -k susp_shell"
      "-w /bin/fish -p x -k susp_shell"
      "-w /bin/tcsh -p x -k susp_shell"
      "-w /bin/tclsh -p x -k susp_shell"
      "-w /bin/xonsh -p x -k susp_shell"
      "-w /usr/local/bin/xonsh -p x -k susp_shell"
      "-w /bin/open -p x -k susp_shell"
      "-w /bin/rbash -p x -k susp_shell"
      "-a always,exit -F arch=b32 -S execve -F euid=33 -k detect_execve_www"
      "-a always,exit -F arch=b64 -S execve -F euid=33 -k detect_execve_www"
      "-w /bin/clush -p x -k susp_shell"
      "-w /usr/local/bin/clush -p x -k susp_shell"
      "-w /etc/clustershell/clush.conf -p x -k susp_shell"
      "-w /bin/tmux -p x -k susp_shell"
      "-w /usr/local/bin/tmux -p x -k susp_shell"
      "-w /etc/profile.d/ -p wa -k shell_profiles"
      "-w /etc/profile -p wa -k shell_profiles"
      "-w /etc/shells -p wa -k shell_profiles"
      "-w /etc/bashrc -p wa -k shell_profiles"
      "-w /etc/csh.cshrc -p wa -k shell_profiles"
      "-w /etc/csh.login -p wa -k shell_profiles"
      "-w /etc/fish/ -p wa -k shell_profiles"
      "-w /etc/zsh/ -p wa -k shell_profiles"
      "-w /usr/local/bin/xxh.bash -p x -k susp_shell"
      "-w /usr/local/bin/xxh.xsh -p x -k susp_shell"
      "-w /usr/local/bin/xxh.zsh -p x -k susp_shell"
      "-a always,exit -F arch=b32 -S ptrace -F a0=0x4 -k code_injection"
      "-a always,exit -F arch=b64 -S ptrace -F a0=0x4 -k code_injection"
      "-a always,exit -F arch=b32 -S ptrace -F a0=0x5 -k data_injection"
      "-a always,exit -F arch=b64 -S ptrace -F a0=0x5 -k data_injection"
      "-a always,exit -F arch=b32 -S ptrace -F a0=0x6 -k register_injection"
      "-a always,exit -F arch=b64 -S ptrace -F a0=0x6 -k register_injection"
      "-a always,exit -F arch=b32 -S ptrace -k tracing"
      "-a always,exit -F arch=b64 -S ptrace -k tracing"
      "-a always,exit -F arch=b64 -S memfd_create -F key=anon_file_create"
      "-a always,exit -F arch=b32 -S memfd_create -F key=anon_file_create"
      "-a always,exit -F dir=/home -F uid=0 -F auid -F auid!=-1 -C auid!=obj_uid -k power_abuse >=1000"
      "-a always,exit -F arch=b32 -S socket -F a0=2 -k T1011_Exfiltration_Over_Other_Network_Medium"
      "-a always,exit -F arch=b64 -S socket -F a0=2 -k T1011_Exfiltration_Over_Other_Network_Medium"
      "-a always,exit -F arch=b32 -S socket -F a0=10 -k T1011_Exfiltration_Over_Other_Network_Medium"
      "-a always,exit -F arch=b64 -S socket -F a0=10 -k T1011_Exfiltration_Over_Other_Network_Medium"
      "-w /usr/bin/rpm -p x -k software_mgmt"
      "-w /usr/bin/yum -p x -k software_mgmt"
      "-w /usr/bin/dnf -p x -k software_mgmt"
      "-w /sbin/yast -p x -k software_mgmt"
      "-w /sbin/yast2 -p x -k software_mgmt"
      "-w /bin/rpm -p x -k software_mgmt"
      "-w /usr/bin/zypper -k software_mgmt"
      "-w /usr/bin/dpkg -p x -k software_mgmt"
      "-w /usr/bin/apt -p x -k software_mgmt"
      "-w /usr/bin/apt-add-repository -p x -k software_mgmt"
      "-w /usr/bin/apt-get -p x -k software_mgmt"
      "-w /usr/bin/aptitude -p x -k software_mgmt"
      "-w /usr/bin/wajig -p x -k software_mgmt"
      "-w /usr/bin/snap -p x -k software_mgmt"
      "-w /usr/bin/pip -p x -k T1072_third_party_software"
      "-w /usr/local/bin/pip -p x -k T1072_third_party_software"
      "-w /usr/bin/pip3 -p x -k T1072_third_party_software"
      "-w /usr/local/bin/pip3 -p x -k T1072_third_party_software"
      "-w /usr/bin/npm -p x -k T1072_third_party_software"
      "-w /usr/bin/cpan -p x -k T1072_third_party_software"
      "-w /usr/bin/gem -p x -k T1072_third_party_software"
      "-w /usr/bin/luarocks -p x -k T1072_third_party_software"
      "-w /etc/pacman.conf -p x -k T1072_third_party_software"
      "-w /etc/pacman.d -p x -k T1072_third_party_software"
      "-w /etc/puppet/ssl -p wa -k puppet_ssl"
      "-a always,exit -F arch=b64 -S open -F dir=/opt/BESClient -F success=0 -k soft_besclient"
      "-w /var/opt/BESClient/ -p wa -k soft_besclient"
      "-w /etc/chef -p wa -k soft_chef"
      "-w /etc/salt -p wa -k soft_salt"
      "-w /usr/local/etc/salt -p wa -k soft_salt"
      "-w /etc/otter -p wa -k soft_otter"
      "-w /usr/bin/grep -p x -k T1081_Credentials_In_Files"
      "-w /usr/bin/egrep -p x -k T1081_Credentials_In_Files"
      "-w /usr/bin/ugrep -p x -k T1081_Credentials_In_Files"
      "-w /usr/local/bin/grep -p x -k T1081_Credentials_In_Files"
      "-w /usr/local/bin/egrep -p x -k T1081_Credentials_In_Files"
      "-w /usr/local/bin/ugrep -p x -k T1081_Credentials_In_Files"
      "-w /usr/bin/bgrep -p x -k T1081_Credentials_In_Files"
      "-w /usr/local/bin/bgrep -p x -k T1081_Credentials_In_Files"
      "-w /usr/bin/rg -p x -k T1081_Credentials_In_Files"
      "-w /usr/local/bin/rg -p x -k T1081_Credentials_In_Files"
      "-w /usr/bin/pt -p x -k T1081_Credentials_In_Files"
      "-w /usr/local/bin/pt -p x -k T1081_Credentials_In_Files"
      "-w /usr/bin/ucg -p x -k T1081_Credentials_In_Files"
      "-w /usr/local/bin/ucg -p x -k T1081_Credentials_In_Files"
      "-w /usr/bin/ag -p x -k T1081_Credentials_In_Files"
      "-w /usr/local/bin/ag -p x -k T1081_Credentials_In_Files"
      "-w /usr/bin/ack -p x -k T1081_Credentials_In_Files"
      "-w /usr/local/bin/ack -p x -k T1081_Credentials_In_Files"
      "-w /usr/bin/semgrep -p x -k T1081_Credentials_In_Files"
      "-w /usr/local/bin/semgrep -p x -k T1081_Credentials_In_Files"
      "-w /usr/bin/dockerd -k docker"
      "-w /usr/bin/docker -k docker"
      "-w /usr/bin/docker-containerd -k docker"
      "-w /usr/bin/docker-runc -k docker"
      "-w /var/lib/docker -k docker"
      "-w /etc/docker -k docker"
      "-w /etc/sysconfig/docker -k docker"
      "-w /etc/sysconfig/docker-storage -k docker"
      "-w /usr/lib/systemd/system/docker.service -k docker"
      "-w /usr/lib/systemd/system/docker.socket -k docker"
      "-w /usr/bin/qemu-system-x86_64 -p x -k qemu-system-x86_64"
      "-w /usr/bin/qemu-img -p x -k qemu-img"
      "-w /usr/bin/qemu-kvm -p x -k qemu-kvm"
      "-w /usr/bin/qemu -p x -k qemu"
      "-w /usr/bin/virtualbox -p x -k virtualbox"
      "-w /usr/bin/virt-manager -p x -k virt-manager"
      "-w /usr/bin/VBoxManage -p x -k VBoxManage"
      "-w /usr/local/bin/VirtualBox -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/VirtualBoxVM -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/VBoxManage -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/VBoxVRDP -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/VBoxHeadless -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/vboxwebsrv -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/VBoxBugReport -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/VBoxBalloonCtrl -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/VBoxAutostart -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/VBoxDTrace -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/vbox-img -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /Library/LaunchDaemons/org.virtualbox.startup.plist -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /Library/Application Support/VirtualBox/LaunchDaemons/ -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /Library/Application Support/VirtualBox/VBoxDrv.kext/ -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /Library/Application Support/VirtualBox/VBoxUSB.kext/ -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /Library/Application Support/VirtualBox/VBoxNetFlt.kext/ -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /Library/Application Support/VirtualBox/VBoxNetAdp.kext/ -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/prl_convert -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/prl_disk_tool -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/prl_perf_ctl -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/prlcore2dmp -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/prlctl -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/prlexec -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/prlsrvctl -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /Library/Preferences/Parallels -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/qemu-edid -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/qemu-img -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/qemu-io -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/qemu-nbd -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/local/bin/qemu-system-x86_64 -p x -k T1497_Virtualization_Sandbox_Evasion_System_Checks"
      "-w /usr/bin/kubelet -k kubelet"
      "-a always,exit -F arch=b64 -S msgctl -k T1559_Inter-Process_Communication"
      "-a always,exit -F arch=b64 -S msgget -k T1559_Inter-Process_Communication"
      "-a always,exit -F arch=b64 -S semctl -k T1559_Inter-Process_Communication"
      "-a always,exit -F arch=b64 -S semget -k T1559_Inter-Process_Communication"
      "-a always,exit -F arch=b64 -S semop -k T1559_Inter-Process_Communication"
      "-a always,exit -F arch=b64 -S semtimedop -k T1559_Inter-Process_Communication"
      "-a always,exit -F arch=b64 -S shmctl -k T1559_Inter-Process_Communication"
      "-a always,exit -F arch=b64 -S shmget -k T1559_Inter-Process_Communication"
      "-w /bin/bash -p x -k susp_shell"
      "-w /bin/dash -p x -k susp_shell"
      "-w /bin/busybox -p x -k susp_shell"
      "-w /bin/zsh -p x -k susp_shell"
      "-w /bin/sh -p x -k susp_shell"
      "-w /bin/ksh -p x -k susp_shell"
      "-a always,exit -F arch=b64 -F euid=0 -F auid -F auid!=4294967295 -S execve -k rootcmd >=1000"
      "-a always,exit -F arch=b32 -F euid=0 -F auid -F auid!=4294967295 -S execve -k rootcmd >=1000"
      "-a always,exit -F arch=b32 -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid -F auid!=-1 -k delete >=1000"
      "-a always,exit -F arch=b64 -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid -F auid!=-1 -k delete >=1000"
      "-a always,exit -F arch=b32 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EACCES -F auid -F auid!=-1 -k file_access >=1000"
      "-a always,exit -F arch=b32 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EPERM -F auid -F auid!=-1 -k file_access >=1000"
      "-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EACCES -F auid -F auid!=-1 -k file_access >=1000"
      "-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EPERM -F auid -F auid!=-1 -k file_access >=1000"
      "-a always,exit -F arch=b32 -S creat,link,mknod,mkdir,symlink,mknodat,linkat,symlinkat -F exit=-EACCES -k file_creation"
      "-a always,exit -F arch=b64 -S mkdir,creat,link,symlink,mknod,mknodat,linkat,symlinkat -F exit=-EACCES -k file_creation"
      "-a always,exit -F arch=b32 -S link,mkdir,symlink,mkdirat -F exit=-EPERM -k file_creation"
      "-a always,exit -F arch=b64 -S mkdir,link,symlink,mkdirat -F exit=-EPERM -k file_creation"
      "-a always,exit -F arch=b32 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EACCES -k file_modification"
      "-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EACCES -k file_modification"
      "-a always,exit -F arch=b32 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EPERM -k file_modification"
      "-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EPERM -k file_modification"
      "-a always,exit -F arch=b32 -S all -k 32bit_api"
    ];
  };
  security.auditd.enable = true;
  security.doas = {
    enable = true;
    extraRules = [{
      persist = true;
      setEnv = [ "LANG" "LC_ALL" ];
      groups = [ "wheel" ];
    }];
  };
  security.sudo.enable = false;
  security.pam = {
    loginLimits = [
      {
        domain = "*";
        type = "hard";
        item = "core";
        value = "0";
      }
    ];
    services = {
      # FIXME: This needs to overwrite, not append
      "passwd".text = lib.mkDefault (
        ''
          # passwd defaults from nixos-install
          password required pam_pwquality.so shadowretry=3 minlen=12 difok=6 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1 enforce_for_root
          password required pam_unix.so use_authtok shadow
        ''
      );
      "system-login".text = lib.mkDefault (
        lib.mkAfter ''
          auth optional pam_faildelay.so delay=8000000
        ''
      );
      "su".text = lib.mkDefault (
        lib.mkAfter ''
          auth required pam_wheel.so use_uid
        ''
      );
      "su-l".text = lib.mkDefault (
        lib.mkAfter ''
          auth required pam_wheel.so use_uid
        ''
      );
    };
  };

  # FIXME: Use system groups
  users.groups = {
    audit = { };
    usbguard = { };
  };
  users.users = {
    root = {
      # FIXME: Use variable
      initialPassword = "2cuddly-Slum";
    };
    systux = {
      isNormalUser = true;
      extraGroups = [ "adm" "audit" "systemd-journal" "usbguard" "wheel" "video" ];
      # FIXME: Use variable
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGswEJVocQdIFn8ePBbiRXnKjvHZ51xkpZy5UFbljj93 virt@tulip" ];
      # FIXME: Use variable
      initialPassword = "2cuddly-Slum";
    };
    virt = {
      isNormalUser = true;
      extraGroups = [ "podman" "video" ];
      # FIXME: Use variable
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHtjvtgP4b3vEl9QcNkRKg0w+snCkcnxeRgtkNolfL9 virt@tulip" ];
      # FIXME: Use variable
      initialPassword = "2cuddly-Slum";
    };
    leo = {
      isNormalUser = true;
      extraGroups = [ "video" ];
      # FIXME: Use variable
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAeyG1LTUIvtKmiasP0f/ulrChmwINR9jrHBxrJV57gG virt@tulip" ];
      # FIXME: Use variable
      initialPassword = "2cuddly-Slum";
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; })) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  environment.systemPackages = with pkgs; [
    bash-completion
    bat
    bc
    dosfstools
    du-dust
    duf
    ethtool
    eza
    fd
    git-extras
    glow
    gptfdisk
    hwinfo
    hyperfine
    inetutils
    jpegoptim
    jq
    libpwquality
    lrzip
    lshw
    lsof
    lzop
    macchina
    mtools
    netcat-openbsd
    ntfs3g
    oxipng
    p7zip
    podman-compose
    procs
    quilt
    rename
    ripgrep
    rsync
    screen
    tokei
    tree
    unar
    unixtools.xxd
    unzip
    wget
    xdg-ninja
    yq
  ];
  environment.etc = {
    "issue".text =
      ''
        #################################################################
        #                      _    _           _   _                   #
        #                     / \\  | | ___ _ __| |_| |                  #
        #                    / _ \\ | |/ _ \\ '__| __| |                  #
        #                   / ___ \\| |  __/ |  | |_|_|                  #
        #                  /_/   \\_\\_|\\___|_|   \\__(_)                  #
        #                                                               #
        #  You are entering into a secured area! Your IP, Login Time,   #
        #    Username has been noted and has been sent to the server    #
        #                        administrator!                         #
        #   This service is restricted to authorized users only. All    #
        #             activities on this system are logged.             #
        #  Unauthorized access will be fully investigated and reported  #
        #          to the appropriate law enforcement agencies.         #
        #################################################################
      '';
    "issue.net".text =
      ''
        #################################################################
        #                      _    _           _   _                   #
        #                     / \  | | ___ _ __| |_| |                  #
        #                    / _ \ | |/ _ \ '__| __| |                  #
        #                   / ___ \| |  __/ |  | |_|_|                  #
        #                  /_/   \_\_|\___|_|   \__(_)                  #
        #                                                               #
        #  You are entering into a secured area! Your IP, Login Time,   #
        #    Username has been noted and has been sent to the server    #
        #                        administrator!                         #
        #   This service is restricted to authorized users only. All    #
        #             activities on this system are logged.             #
        #  Unauthorized access will be fully investigated and reported  #
        #          to the appropriate law enforcement agencies.         #
        #################################################################
      '';
    "motd".text =
      ''
        #################################################################
        #                      _    _           _   _                   #
        #                     / \  | | ___ _ __| |_| |                  #
        #                    / _ \ | |/ _ \ '__| __| |                  #
        #                   / ___ \| |  __/ |  | |_|_|                  #
        #                  /_/   \_\_|\___|_|   \__(_)                  #
        #                                                               #
        #  You are entering into a secured area! Your IP, Login Time,   #
        #    Username has been noted and has been sent to the server    #
        #                        administrator!                         #
        #   This service is restricted to authorized users only. All    #
        #             activities on this system are logged.             #
        #  Unauthorized access will be fully investigated and reported  #
        #          to the appropriate law enforcement agencies.         #
        #################################################################
      '';
    # FIXME: Figure out how to overwrite /etc/hosts without using environment.etc
    "hosts".text = lib.mkForce
      (
        ''
          127.0.0.1  localhost
          127.0.1.1  ${HOSTNAME}.${DOMAIN}  ${HOSTNAME}
          ::1  ip6-localhost ip6-loopback
          ff02::1  ip6-allnodes
          ff02::2  ip6-allrouters
        ''
      );
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.nano.enable = false;
  programs.starship.enable = true;
  programs.htop.enable = true;
  # TODO: Install and configure per user
  programs.git.enable = true;
  # TODO: Install and configure per user
  programs.neovim.enable = true;

  fonts.fontconfig.enable = false;

  services.openssh = {
    enable = true;
    ports = [ 9122 ];
    settings = {
      PasswordAuthentication = false;
      AuthenticationMethods = "publickey";
      PermitRootLogin = "no";
      AllowTcpForwarding = "no";
      ClientAliveCountMax = 2;
      LogLevel = "VERBOSE";
      MaxAuthTries = 3;
      MaxSessions = 2;
      TCPKeepAlive = "no";
      AllowAgentForwarding = "no";
      Banner = "/etc/issue.net";
    };
    allowSFTP = true;
  };
  services.postfix = {
    enable = true;
    extraConfig = ''
      disable_vrfy_command = yes
      inet_interfaces = loopback-only
      smtpd_banner = "$myhostname ESMTP"
    '';
  };
  services.usbguard = {
    enable = true;
    IPCAllowedGroups = [ "usbguard" ];
  };
  services.fwupd.enable = true;
  services.qemuGuest.enable = true;
  services.logrotate.enable = true;
  services.sysstat.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
