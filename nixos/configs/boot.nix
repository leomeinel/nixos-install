/*
  File: boot.nix
  Author: Leopold Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Meinel & contributors
  SPDX ID: MIT
  URL: https://opensource.org/licenses/MIT
  -----
*/

{
  pkgs,
  ...
}:

{
  # Boot options
  boot = {
    # Kernel parameters
    consoleLogLevel = 3;
    kernelParams = [
      "audit_backlog_limit=8192"
      "bgrt_disable"
      "iommu=pt"
      "zswap.enabled=0"
    ];
    # Blacklist kernel modules
    blacklistedKernelModules = [
      "pcspkr"
      "snd_pcsp"
      "cramfs"
      "hfs"
      "hfsplus"
      "jffs2"
      "squashfs"
      "udf"
    ];
    extraModprobeConfig = ''
      install cramfs ${pkgs.coreutils-full}/bin/true
      install dccp ${pkgs.coreutils-full}/bin/true
      install firewire_core ${pkgs.coreutils-full}/bin/true
      install firewire_ohci ${pkgs.coreutils-full}/bin/true
      install hfs ${pkgs.coreutils-full}/bin/true
      install hfsplus ${pkgs.coreutils-full}/bin/true
      install jffs2 ${pkgs.coreutils-full}/bin/true
      install rds ${pkgs.coreutils-full}/bin/true
      install sctp ${pkgs.coreutils-full}/bin/true
      install squashfs ${pkgs.coreutils-full}/bin/true
      install tipc ${pkgs.coreutils-full}/bin/true
      install udf ${pkgs.coreutils-full}/bin/true
    '';
    # EFI boot options (/etc/loader/loader.conf)
    loader = {
      timeout = 4;
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/efi";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 12;
        consoleMode = "max";
        editor = false;
      };
    };
    # Kernel sysctl parameters
    kernel.sysctl = {
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/net.html#bpf-jit-enable
      "net.core.bpf_jit_harden" = 2;
      # https://sysctl-explorer.net/net/ipv4/accept_redirects/
      "net.ipv4.conf.all.accept_redirects" = 0;
      # https://sysctl-explorer.net/net/ipv4/accept_source_route/
      "net.ipv4.conf.all.accept_source_route" = 0;
      # https://sysctl-explorer.net/net/ipv4/bootp_relay/
      "net.ipv4.conf.all.bootp_relay" = 0;
      # https://sysctl-explorer.net/net/ipv4/forwarding/
      "net.ipv4.conf.all.forwarding" = 0;
      # https://sysctl-explorer.net/net/ipv4/log_martians/
      "net.ipv4.conf.all.log_martians" = 1;
      # https://sysctl-explorer.net/net/ipv4/mc_forwarding/
      "net.ipv4.conf.all.mc_forwarding" = 0;
      # https://sysctl-explorer.net/net/ipv4/proxy_arp/
      "net.ipv4.conf.all.proxy_arp" = 0;
      # https://sysctl-explorer.net/net/ipv4/rp_filter/
      # INFO: Any changes to this value will not get applied. This is just here if that ever changes in the future.
      "net.ipv4.conf.all.rp_filter" = 1;
      # https://sysctl-explorer.net/net/ipv4/secure_redirects/
      "net.ipv4.conf.all.secure_redirects" = 0;
      # https://sysctl-explorer.net/net/ipv4/send_redirects/
      "net.ipv4.conf.all.send_redirects" = 0;
      # https://sysctl-explorer.net/net/ipv4/accept_redirects/
      "net.ipv4.conf.default.accept_redirects" = 0;
      # https://sysctl-explorer.net/net/ipv4/accept_source_route/
      "net.ipv4.conf.default.accept_source_route" = 0;
      # https://sysctl-explorer.net/net/ipv4/log_martians/
      "net.ipv4.conf.default.log_martians" = 1;
      # https://sysctl-explorer.net/net/ipv4/rp_filter/
      "net.ipv4.conf.default.rp_filter" = 1;
      # https://sysctl-explorer.net/net/ipv4/secure_redirects/
      "net.ipv4.conf.default.secure_redirects" = 0;
      # https://sysctl-explorer.net/net/ipv4/send_redirects/
      "net.ipv4.conf.default.send_redirects" = 0;
      # https://sysctl-explorer.net/net/ipv4/icmp_echo_ignore_all/
      "net.ipv4.icmp_echo_ignore_all" = 1;
      # https://sysctl-explorer.net/net/ipv4/icmp_echo_ignore_broadcasts/
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      # https://sysctl-explorer.net/net/ipv4/icmp_ignore_bogus_error_responses/
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html#tcp-variables (search tcp_rfc1337)
      "net.ipv4.tcp_rfc1337" = 1;
      # https://sysctl-explorer.net/net/ipv4/tcp_syncookies/
      "net.ipv4.tcp_syncookies" = 1;
      # https://sysctl-explorer.net/net/ipv4/tcp_timestamps/
      "net.ipv4.tcp_timestamps" = 0;
      # https://sysctl-explorer.net/net/ipv6/accept_redirects/
      "net.ipv6.conf.all.accept_redirects" = 0;
      # https://sysctl-explorer.net/net/ipv6/accept_source_route/
      "net.ipv6.conf.all.accept_source_route" = 0;
      # https://sysctl-explorer.net/net/ipv6/accept_redirects/
      "net.ipv6.conf.default.accept_redirects" = 0;
      # https://sysctl-explorer.net/net/ipv6/accept_source_route/
      "net.ipv6.conf.default.accept_source_route" = 0;
      # https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html#proc-sys-net-ipv6-variables (search echo_ignore_all)
      "net.ipv6.icmp.echo_ignore_all" = 1;
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#core-uses-pid
      "kernel.core_uses_pid" = 1;
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#core-pattern
      "kernel.core_pattern" = "|${pkgs.coreutils-full}/bin/false";
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#ctrl-alt-del
      "kernel.ctrl-alt-del" = 0;
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#dmesg-restrict
      "kernel.dmesg_restrict" = 1;
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#kexec-load-disabled
      "kernel.kexec_load_disabled" = 1;
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#kptr-restrict
      "kernel.kptr_restrict" = 2;
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#modules-disabled
      # INFO: kernel.modules_disabled=1 prevents system from booting
      "kernel.modules_disabled" = 0;
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#perf-event-paranoid
      "kernel.perf_event_paranoid" = 3;
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#randomize-va-space
      "kernel.randomize_va_space" = 2;
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#sysrq
      "kernel.sysrq" = 0;
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#unprivileged-bpf-disabled
      "kernel.unprivileged_bpf_disabled" = 1;
      # https://www.kernel.org/doc/Documentation/security/Yama.txt
      "kernel.yama.ptrace_scope" = 1;
      # https://github.com/torvalds/linux/blob/master/drivers/tty/Kconfig (search dev.tty.ldisc_autoload)
      "dev.tty.ldisc_autoload" = 0;
      # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-fifos
      "fs.protected_fifos" = 2;
      # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-hardlinks
      "fs.protected_hardlinks" = 1;
      # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-regular
      "fs.protected_regular" = 2;
      # https://docs.kernel.org/admin-guide/sysctl/fs.html#protected-symlinks
      "fs.protected_symlinks" = 1;
      # https://docs.kernel.org/admin-guide/sysctl/fs.html#suid-dumpable
      "fs.suid_dumpable" = 0;
      # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/vm.html#overcommit-memory
      "vm.overcommit_memory" = 1;
    };
  };
}
