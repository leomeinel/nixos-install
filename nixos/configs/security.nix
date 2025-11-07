/*
  File: security.nix
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

let
  # Custom shell scripts
  wrapped-notify-ssh-login = pkgs.writeShellScriptBin "notify-ssh-login" ''
    # Fail on error
    set -eo pipefail

    # notify-log
    if [ "''${PAM_TYPE}" = "open_session" ]; then
        ${pkgs.curl}/bin/curl -s -F "title=''${PAM_USER}@${installEnv.HOSTNAME}: SSH login" -F "priority=10" -F "message=From: ''${PAM_RHOST}" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /etc/access/keys/gotify-${installEnv.HOSTNAME}-ssh-login.pass)"
    fi
  '';
in
{
  # Security options
  security = {
    # Select programs
    auditd.enable = true;
    sudo.enable = false;
    # doas options (/etc/doas.conf)
    doas = {
      enable = true;
      extraRules = [
        {
          persist = true;
          setEnv = [
            "LANG"
            "LC_ALL"
            "LOCALE_ARCHIVE"
          ];
          groups = [ "wheel" ];
        }
      ];
    };
    # FIXME: Find a way to implement these
    #        Issue: https://discourse.nixos.org/t/enforcing-strong-passwords-on-nixos-pam-pwquality-so-module-not-known/36420
    # FIXME: /etc/security/faillock.conf
    # pam options
    pam = {
      #  # Equivalent to /etc/security/limits.conf
      #  loginLimits = [
      #    {
      #      domain = "*";
      #      type = "hard";
      #      item = "core";
      #      value = "0";
      #    }
      #  ];
      # Services in /etc/pam.d/
      services = {
        #    "passwd".text = lib.mkForce (
        #      ''
        #        # passwd defaults from nixos-install
        #        password required pam_pwquality.so shadowretry=3 minlen=12 difok=6 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1 enforce_for_root
        #        password required pam_unix.so use_authtok shadow
        #      ''
        #    );
        #    "system-login".text = lib.mkDefault (
        #      lib.mkAfter ''
        #        auth optional pam_faildelay.so delay=8000000
        #      ''
        #    );
        #    "su".text = lib.mkDefault (
        #      lib.mkAfter ''
        #        auth required pam_wheel.so use_uid
        #      ''
        #    );
        #    "su-l".text = lib.mkDefault (
        #      lib.mkAfter ''
        #        auth required pam_wheel.so use_uid
        #      ''
        #    );
        "sshd".text = lib.mkDefault (
          lib.mkAfter ''
            # Custom
            session optional pam_exec.so ${wrapped-notify-ssh-login}/bin/notify-ssh-login
          ''
        );
      };
    };
    # FIXME: /etc/audit/auditd.conf
    # audit options (/etc/audit/audit.rules)
    audit = {
      enable = true;
      rules = [
        "-D"
        "-b 8192"
        "-f 1"
        "-i"
        "-w /var/log/audit/ -p wra -k auditlog"
        "-w /var/audit/ -p wra -k auditlog"
        "-w /etc/audit/ -p wa -k auditconfig"
        "-w /etc/libaudit.conf -p wa -k auditconfig"
        "-w /etc/audisp/ -p wa -k audispconfig"
        "-w ${pkgs.audit}/bin/auditctl -p x -k audittools"
        "-w ${pkgs.audit}/bin/auditd -p x -k audittools"
        "-w ${pkgs.audit}/bin/augenrules -p x -k audittools"
        "-a always,exit -F path=${pkgs.audit}/bin/ausearch -F perm=x -k audittools"
        "-a always,exit -F path=${pkgs.audit}/bin/aureport -F perm=x -k audittools"
        "-a always,exit -F path=${pkgs.audit}/bin/aulast -F perm=x -k audittools"
        #"-a always,exit -F path=/usr/sbin/aulastlogin -F perm=x -k audittools"
        "-a always,exit -F path=${pkgs.audit}/bin/auvirt -F perm=x -k audittools"
        "-a always,exclude -F msgtype=AVC"
        "-a always,exclude -F msgtype=CWD"
        "-a never,user -F subj_type=crond_t"
        "-a never,exit -F subj_type=crond_t"
        "-a never,exit -F arch=b64 -S adjtimex -F auid=-1 -F uid=chrony -F subj_type=chronyd_t"
        "-a always,exclude -F msgtype=CRYPTO_KEY_USER"
        #"-a exit,never -F arch=b64 -S all -F exe=/usr/bin/vmtoolsd"
        "-a never,exit -F arch=b64 -F dir=/dev/shm -k sharedmemaccess"
        "-a never,exit -F arch=b64 -F dir=/var/lock/lvm -k locklvm"
        "-a never,exit -F arch=b64 -F path=/opt/filebeat -k filebeat"
        "-w /etc/sysctl.conf -p wa -k sysctl"
        "-w /etc/sysctl.d -p wa -k sysctl"
        "-a always,exit -F perm=x -F auid!=-1 -F path=${pkgs.kmod}/bin/insmod -k modules"
        "-a always,exit -F perm=x -F auid!=-1 -F path=${pkgs.kmod}/bin/modprobe -k modules"
        "-a always,exit -F perm=x -F auid!=-1 -F path=${pkgs.kmod}/bin/rmmod -k modules"
        "-a always,exit -F arch=b64 -S finit_module -S init_module -S delete_module -F auid!=-1 -k modules"
        "-w /etc/modprobe.conf -p wa -k modprobe"
        "-w /etc/modprobe.d -p wa -k modprobe"
        "-a always,exit -F arch=b64 -S kexec_load -k KEXEC"
        "-a always,exit -F arch=b64 -S mknod -S mknodat -k specialfiles"
        "-a always,exit -F arch=b64 -S mount -S umount2 -F auid!=-1 -k mount"
        #"-a always,exit -F path=/sbin/mount.nfs -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts"
        #"-a always,exit -F path=/usr/sbin/mount.nfs -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts"
        "-a always,exit -F arch=b64 -S swapon -S swapoff -F auid!=-1 -k swap"
        "-a always,exit -F arch=b64 -F uid!=ntp -S adjtimex -S settimeofday -S clock_settime -k time"
        "-w /etc/localtime -p wa -k localtime"
        #"-w /usr/sbin/stunnel -p x -k stunnel"
        #"-w /usr/bin/stunnel -p x -k stunnel"
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
        "-w /run/wrappers/bin/passwd -p x -k passwd_modification" # CUSTOM
        "-w ${pkgs.shadow}/bin/groupadd -p x -k group_modification"
        "-w ${pkgs.shadow}/bin/groupmod -p x -k group_modification"
        #"-w /usr/sbin/addgroup -p x -k group_modification"
        "-w ${pkgs.shadow}/bin/useradd -p x -k user_modification"
        "-w ${pkgs.shadow}/bin/userdel -p x -k user_modification"
        "-w ${pkgs.shadow}/bin/usermod -p x -k user_modification"
        #"-w /usr/sbin/adduser -p x -k user_modification"
        "-w /etc/login.defs -p wa -k login"
        "-w /etc/securetty -p wa -k login"
        "-w /var/log/faillog -p wa -k login"
        "-w /var/log/lastlog -p wa -k login"
        "-w /var/log/tallylog -p wa -k login"
        "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications"
        "-a always,exit -F arch=b64 -F exe=${pkgs.bashInteractive}/bin/bash -F success=1 -S connect -k \"remote_shell\""
        "-a always,exit -F arch=b64 -S connect -F a2=16 -F success=1 -F key=network_connect_4"
        "-a always,exit -F arch=b64 -S connect -F a2=28 -F success=1 -F key=network_connect_6"
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
        "-w /etc/security/limits.conf -p wa  -k pam"
        "-w /etc/security/limits.d -p wa  -k pam"
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
        "-w ${pkgs.systemd}/bin/systemctl -p x -k systemd"
        "-w /etc/systemd/ -p wa -k systemd"
        "-w /usr/lib/systemd -p wa -k systemd"
        "-w /etc/systemd/system-generators/ -p wa -k systemd_generator"
        "-w /usr/local/lib/systemd/system-generators/ -p wa -k systemd_generator"
        "-w /usr/lib/systemd/system-generators -p wa -k systemd_generator"
        "-w /etc/systemd/user-generators/ -p wa -k systemd_generator"
        "-w /usr/local/lib/systemd/user-generators/ -p wa -k systemd_generator"
        "-w /lib/systemd/system-generators/ -p wa -k systemd_generator"
        "-w /etc/selinux/ -p wa -k mac_policy"
        "-a always,exit -F arch=b64 -S open -F dir=/etc -F success=0 -k unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/bin -F success=0 -k unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/sbin -F success=0 -k unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/usr/bin -F success=0 -k unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/usr/sbin -F success=0 -k unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/var -F success=0 -k unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/home -F success=0 -k unauthedfileaccess"
        "-a always,exit -F arch=b64 -S open -F dir=/srv -F success=0 -k unauthedfileaccess"
        "-w /run/wrappers/bin/su -p x -k priv_esc" # CUSTOM
        #"-w /usr/bin/sudo -p x -k priv_esc"
        "-w ${pkgs.systemd}/bin/shutdown -p x -k power"
        "-w ${pkgs.systemd}/bin/poweroff -p x -k power"
        "-w ${pkgs.systemd}/bin/reboot -p x -k power"
        "-w ${pkgs.systemd}/bin/halt -p x -k power"
        "-w /var/run/utmp -p wa -k session"
        "-w /var/log/btmp -p wa -k session"
        "-w /var/log/wtmp -p wa -k session"
        "-a always,exit -F arch=b64 -S chmod  -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S chown -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S fchmod -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S fchmodat -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S fchown -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S fchownat -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S fremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S fsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S lchown -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S lremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S lsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S removexattr -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-a always,exit -F arch=b64 -S setxattr -F auid>=1000 -F auid!=-1 -k perm_mod"
        "-w ${pkgs.coreutils-full}/bin/whoami -p x -k recon"
        "-w ${pkgs.coreutils-full}/bin/id -p x -k recon"
        "-w ${pkgs.inetutils}/bin/hostname -p x -k recon"
        "-w ${pkgs.coreutils-full}/bin/uname -p x -k recon"
        "-w /etc/issue -p r -k recon"
        "-w /etc/hostname -p r -k recon"
        "-w ${pkgs.wget}/bin/wget -p x -k susp_activity"
        "-w ${pkgs.curl}/bin/curl -p x -k susp_activity"
        "-w ${pkgs.coreutils-full}/bin/base64 -p x -k susp_activity"
        "-w ${pkgs.netcat-openbsd}/bin/nc -p x -k susp_activity"
        #"-w /bin/netcat -p x -k susp_activity"
        #"-w /usr/bin/ncat -p x -k susp_activity"
        "-w ${pkgs.iproute2}/bin/ss -p x -k susp_activity"
        "-w ${pkgs.nettools}/bin/netstat -p x -k susp_activity"
        "-w ${pkgs.openssh}/bin/ssh -p x -k susp_activity"
        "-w ${pkgs.nettools}/bin/scp -p x -k susp_activity"
        "-w ${pkgs.nettools}/bin/sftp -p x -k susp_activity"
        "-w ${pkgs.inetutils}/bin/ftp -p x -k susp_activity"
        #"-w /usr/bin/socat -p x -k susp_activity"
        #"-w /usr/bin/wireshark -p x -k susp_activity"
        #"-w /usr/bin/tshark -p x -k susp_activity"
        #"-w /usr/bin/rawshark -p x -k susp_activity"
        #"-w /usr/bin/rdesktop -p x -k susp_activity"
        #"-w /usr/local/bin/rdesktop -p x -k susp_activity"
        #"-w /usr/bin/wlfreerdp -p x -k susp_activity"
        #"-w /usr/bin/xfreerdp -p x -k susp_activity"
        #"-w /usr/local/bin/xfreerdp -p x -k susp_activity"
        #"-w /usr/bin/nmap -p x -k susp_activity"
        #"-w /usr/bin/uftp -p x -k susp_activity"
        #"-w /usr/sbin/uftp -p x -k susp_activity"
        "-w /lib/systemd/system/uftp.service -k susp_activity"
        #"-w /usr/lib/systemd/system/uftp.service -k susp_activity"
        #"-w /usr/bin/atftpd -p x -k susp_activity"
        #"-w /usr/sbin/atftpd -p x -k susp_activity"
        #"-w /usr/bin/in.tftpd -p x -k susp_activity"
        #"-w /usr/sbin/in.tftpd -p x -k susp_activity"
        "-w /lib/systemd/system/atftpd.service -k susp_activity"
        "-w /usr/lib/systemd/system/atftpd.service -k susp_activity"
        "-w /lib/systemd/system/atftpd.socket -k susp_activity"
        "-w /usr/lib/systemd/system/atftpd.socket -k susp_activity"
        "-a always,exit -F path=/usr/libexec/sssd/p11_child -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts"
        "-a always,exit -F path=/usr/libexec/sssd/krb5_child -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts"
        "-a always,exit -F path=/usr/libexec/sssd/ldap_child -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts"
        "-a always,exit -F path=/usr/libexec/sssd/selinux_child -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts"
        "-a always,exit -F path=/usr/libexec/sssd/proxy_child -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts"
        "-a always,exit -F path=/lib64/vte-2.91/gnome-pty-helper -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts"
        "-a always,exit -F path=/usr/lib64/vte-2.91/gnome-pty-helper -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts"
        #"-w /usr/bin/zip -p x -k Data_Compressed"
        "-w ${pkgs.gzip}/bin/gzip -p x -k Data_Compressed"
        "-w ${pkgs.gnutar}/bin/tar -p x -k Data_Compressed"
        "-w ${pkgs.bzip2}/bin/bzip2 -p x -k Data_Compressed"
        #"-w /usr/bin/lzip -p x -k Data_Compressed"
        #"-w /usr/local/bin/lzip -p x -k Data_Compressed"
        #"-w /usr/bin/lz4 -p x -k Data_Compressed"
        #"-w /usr/local/bin/lz4 -p x -k Data_Compressed"
        "-w ${pkgs.lzop}/bin/lzop -p x -k Data_Compressed"
        #"-w /usr/bin/plzip -p x -k Data_Compressed"
        #"-w /usr/local/bin/plzip -p x -k Data_Compressed"
        #"-w /usr/bin/pbzip2 -p x -k Data_Compressed"
        #"-w /usr/local/bin/pbzip2 -p x -k Data_Compressed"
        #"-w /usr/bin/lbzip2 -p x -k Data_Compressed"
        #"-w /usr/local/bin/lbzip2 -p x -k Data_Compressed"
        #"-w /usr/bin/pixz -p x -k Data_Compressed"
        #"-w /usr/local/bin/pixz -p x -k Data_Compressed"
        #"-w /usr/bin/pigz -p x -k Data_Compressed"
        #"-w /usr/local/bin/pigz -p x -k Data_Compressed"
        #"-w /usr/bin/unpigz -p x -k Data_Compressed"
        #"-w /usr/local/bin/unpigz -p x -k Data_Compressed"
        "-w ${pkgs.zstd}/bin/zstd -p x -k Data_Compressed"
        #"-w /bin/nc.openbsd -p x -k susp_activity"
        #"-w /bin/nc.traditional -p x -k susp_activity"
        "-w ${pkgs.iptables}/bin/iptables -p x -k sbin_susp"
        "-w ${pkgs.iptables}/bin/ip6tables -p x -k sbin_susp"
        "-w ${pkgs.inetutils}/bin/ifconfig -p x -k sbin_susp"
        "-w ${pkgs.iptables}/bin/arptables -p x -k sbin_susp"
        "-w ${pkgs.iptables}/bin/ebtables -p x -k sbin_susp"
        "-w ${pkgs.iptables}/bin/xtables-nft-multi -p x -k sbin_susp"
        #"-w /usr/sbin/nft -p x -k sbin_susp"
        #"-w /usr/sbin/tcpdump -p x -k sbin_susp"
        "-w ${pkgs.inetutils}/bin/traceroute -p x -k sbin_susp"
        #"-w /usr/sbin/ufw -p x -k sbin_susp"
        "-a always,exit -F path=/usr/libexec/kde4/kpac_dhcp_helper -F perm=x -F auid>=1000 -F auid!=4294967295 -k T1078_Valid_Accounts"
        "-a always,exit -F path=/usr/libexec/kde4/kdesud -F perm=x -F auid>=1000 -F auid!=4294967295 -k T1078_Valid_Accounts"
        "-w ${pkgs.dbus}/bin/dbus-send -p x -k dbus_send"
        #"-w /usr/bin/gdbus -p x -k gdubs_call"
        #"-a always,exit -F path=/usr/bin/setfiles -F perm=x -F auid>=500 -F auid!=4294967295 -k -F T1078_Valid_Accounts"
        #"-a always,exit -F path=/usr/sbin/setfiles -F perm=x -F auid>=500 -F auid!=4294967295 -k -F T1078_Valid_Accounts"
        "-a always,exit -F path=/lib64/dbus-1/dbus-daemon-launch-helper -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts"
        "-a always,exit -F path=/usr/lib64/dbus-1/dbus-daemon-launch-helper -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts"
        "-w /run/wrappers/bin/pkexec -p x -k pkexec" # CUSTOM
        #"-w /bin/ash -p x -k susp_shell"
        #"-w /bin/csh -p x -k susp_shell"
        #"-w /bin/fish -p x -k susp_shell"
        #"-w /bin/tcsh -p x -k susp_shell"
        #"-w /bin/tclsh -p x -k susp_shell"
        #"-w /bin/xonsh -p x -k susp_shell"
        #"-w /usr/local/bin/xonsh -p x -k susp_shell"
        #"-w /bin/open -p x -k susp_shell"
        #"-w /bin/rbash -p x -k susp_shell"
        #"-w /bin/wish -p x -k susp_shell"
        #"-w /usr/bin/wish -p x -k susp_shell"
        #"-w /bin/yash -p x -k susp_shell"
        #"-w /usr/bin/yash -p x -k susp_shell"
        "-a always,exit -F arch=b64 -S execve -F euid=33 -k detect_execve_www"
        #"-w /bin/clush -p x -k susp_shell"
        #"-w /usr/local/bin/clush -p x -k susp_shell"
        "-w /etc/clustershell/clush.conf -p x -k susp_shell"
        #"-w /bin/tmux -p x -k susp_shell"
        #"-w /usr/local/bin/tmux -p x -k susp_shell"
        "-w /etc/profile.d/ -p wa -k shell_profiles"
        "-w /etc/profile -p wa -k shell_profiles"
        "-w /etc/shells -p wa -k shell_profiles"
        "-w /etc/bashrc -p wa -k shell_profiles"
        "-w /etc/csh.cshrc -p wa -k shell_profiles"
        "-w /etc/csh.login -p wa -k shell_profiles"
        "-w /etc/fish/ -p wa -k shell_profiles"
        "-w /etc/zsh/ -p wa -k shell_profiles"
        #"-w /usr/local/bin/xxh.bash -p x -k susp_shell"
        #"-w /usr/local/bin/xxh.xsh -p x -k susp_shell"
        #"-w /usr/local/bin/xxh.zsh -p x -k susp_shell"
        "-a always,exit -F arch=b64 -S ptrace -F a0=0x4 -k code_injection"
        "-a always,exit -F arch=b64 -S ptrace -F a0=0x5 -k data_injection"
        "-a always,exit -F arch=b64 -S ptrace -F a0=0x6 -k register_injection"
        "-a always,exit -F arch=b64 -S ptrace -k tracing"
        "-a always,exit -F arch=b64 -S memfd_create -F key=anon_file_create"
        "-a always,exit -F dir=/home -F auid=0 -F auid>=1000 -F auid!=-1 -C auid!=obj_uid -k power_abuse"
        "-a always,exit -F arch=b32 -S socket -F a0=2  -k network_socket_created"
        "-a always,exit -F arch=b64 -S socket -F a0=2  -k network_socket_created"
        "-a always,exit -F arch=b32 -S socket -F a0=10 -k network_socket_created"
        "-a always,exit -F arch=b64 -S socket -F a0=10 -k network_socket_created"
        #"-w /usr/bin/rpm -p x -k software_mgmt"
        #"-w /usr/bin/yum -p x -k software_mgmt"
        #"-w /usr/bin/dnf -p x -k software_mgmt"
        #"-w /sbin/yast -p x -k software_mgmt"
        #"-w /sbin/yast2 -p x -k software_mgmt"
        #"-w /bin/rpm -p x -k software_mgmt"
        #"-w /usr/bin/zypper -k software_mgmt"
        #"-w /usr/bin/dpkg -p x -k software_mgmt"
        #"-w /usr/bin/apt -p x -k software_mgmt"
        #"-w /usr/bin/apt-add-repository -p x -k software_mgmt"
        #"-w /usr/bin/apt-get -p x -k software_mgmt"
        #"-w /usr/bin/aptitude -p x -k software_mgmt"
        #"-w /usr/bin/wajig -p x -k software_mgmt"
        #"-w /usr/bin/snap -p x -k software_mgmt"
        #"-w /usr/bin/pip -p x -k third_party_software_mgmt"
        #"-w /usr/local/bin/pip -p x -k third_party_software_mgmt"
        #"-w /usr/bin/pip3 -p x -k third_party_software_mgmt"
        #"-w /usr/local/bin/pip3 -p x -k third_party_software_mgmt"
        #"-w /usr/bin/pipx -p x -k third_party_software_mgmt"
        #"-w /usr/local/bin/pipx -p x -k third_party_software_mgmt"
        #"-w /usr/bin/npm -p x -k third_party_software_mgmt"
        "-w ${pkgs.perl}/bin/cpan -p x -k third_party_software_mgmt"
        #"-w /usr/bin/gem -p x -k third_party_software_mgmt"
        #"-w /usr/bin/luarocks -p x -k third_party_software_mgmt"
        "-w /etc/pacman.conf -p x -k third_party_software_mgmt"
        "-w /etc/pacman.d -p x -k third_party_software_mgmt"
        "-w /etc/puppet/ssl -p wa -k puppet_ssl"
        "-a always,exit -F arch=b64 -S open -F dir=/opt/BESClient -F success=0 -k soft_besclient"
        "-w /var/opt/BESClient/ -p wa -k soft_besclient"
        "-w /etc/chef -p wa -k soft_chef"
        "-w /etc/salt -p wa -k soft_salt"
        "-w /usr/local/etc/salt -p wa -k soft_salt"
        "-w /etc/otter -p wa -k soft_otter"
        "-w ${pkgs.gnugrep}/bin/grep -p x -k string_search"
        "-w ${pkgs.gnugrep}/bin/egrep -p x -k string_search"
        #"-w /usr/bin/ugrep -p x -k string_search"
        #"-w /usr/local/bin/ugrep -p x -k string_search"
        #"-w /usr/bin/bgrep -p x -k string_search"
        #"-w /usr/local/bin/bgrep -p x -k string_search"
        "-w ${pkgs.ripgrep}/bin/rg -p x -k string_search"
        #"-w /usr/bin/cgrep -p x -k string_search"
        #"-w /usr/local/bin/cgrep -p x -k string_search"
        #"-w /usr/bin/ngrep -p x -k string_search"
        #"-w /usr/local/bin/ngrep -p x -k string_search"
        #"-w /usr/bin/vgrep -p x -k string_search"
        #"-w /usr/local/bin/vgrep -p x -k string_search"
        #"-w /usr/bin/pt -p x -k string_search"
        #"-w /usr/local/bin/pt -p x -k string_search"
        #"-w /usr/bin/ucg -p x -k string_search"
        #"-w /usr/local/bin/ucg -p x -k string_search"
        #"-w /usr/bin/ag -p x -k string_search"
        #"-w /usr/local/bin/ag -p x -k string_search"
        #"-w /usr/bin/ack -p x -k string_search"
        #"-w /usr/local/bin/ack -p x -k string_search"
        #"-w /usr/bin/semgrep -p x -k string_search"
        #"-w /usr/local/bin/semgrep -p x -k string_search"
        #"-w /usr/bin/dockerd -k docker"
        #"-w /usr/bin/docker -k docker"
        #"-w /usr/bin/docker-containerd -k docker"
        #"-w /usr/bin/docker-runc -k docker"
        "-w /var/lib/docker -p wa -k docker"
        "-w /etc/docker -k docker"
        "-w /etc/sysconfig/docker -k docker"
        "-w /etc/sysconfig/docker-storage -k docker"
        "-w /usr/lib/systemd/system/docker.service -k docker"
        "-w /usr/lib/systemd/system/docker.socket -k docker"
        #"-w /usr/bin/qemu-system-x86_64 -p x -k qemu-system-x86_64"
        #"-w /usr/bin/qemu-img -p x -k qemu-img"
        #"-w /usr/bin/qemu-kvm -p x -k qemu-kvm"
        #"-w /usr/bin/qemu -p x -k qemu"
        #"-w /usr/bin/virtualbox -p x -k virtualbox"
        #"-w /usr/bin/virt-manager -p x -k virt-manager"
        #"-w /usr/bin/VBoxManage -p x -k VBoxManage"
        #"-w /usr/local/bin/VirtualBox -p x -k virt_tool"
        #"-w /usr/local/bin/VirtualBoxVM -p x -k virt_tool"
        #"-w /usr/local/bin/VBoxManage -p x -k virt_tool"
        #"-w /usr/local/bin/VBoxVRDP -p x -k virt_tool"
        #"-w /usr/local/bin/VBoxHeadless -p x -k virt_tool"
        #"-w /usr/local/bin/vboxwebsrv -p x -k virt_tool"
        #"-w /usr/local/bin/VBoxBugReport -p x -k virt_tool"
        #"-w /usr/local/bin/VBoxBalloonCtrl -p x -k virt_tool"
        #"-w /usr/local/bin/VBoxAutostart -p x -k virt_tool"
        #"-w /usr/local/bin/VBoxDTrace -p x -k virt_tool"
        #"-w /usr/local/bin/vbox-img -p x -k virt_tool"
        "-w /Library/LaunchDaemons/org.virtualbox.startup.plist -p x -k virt_tool"
        "-w /Library/Application Support/VirtualBox/LaunchDaemons/ -p x -k virt_tool"
        "-w /Library/Application Support/VirtualBox/VBoxDrv.kext/ -p x -k virt_tool"
        "-w /Library/Application Support/VirtualBox/VBoxUSB.kext/ -p x -k virt_tool"
        "-w /Library/Application Support/VirtualBox/VBoxNetFlt.kext/ -p x -k virt_tool"
        "-w /Library/Application Support/VirtualBox/VBoxNetAdp.kext/ -p x -k virt_tool"
        #"-w /usr/local/bin/prl_convert -p x -k virt_tool"
        #"-w /usr/local/bin/prl_disk_tool -p x -k virt_tool"
        #"-w /usr/local/bin/prl_perf_ctl -p x -k virt_tool"
        #"-w /usr/local/bin/prlcore2dmp -p x -k virt_tool"
        #"-w /usr/local/bin/prlctl -p x -k virt_tool"
        #"-w /usr/local/bin/prlexec -p x -k virt_tool"
        #"-w /usr/local/bin/prlsrvctl -p x -k virt_tool"
        #"-w /Library/Preferences/Parallels -p x -k virt_tool"
        #"-w /usr/local/bin/qemu-edid -p x -k virt_tool"
        #"-w /usr/local/bin/qemu-img -p x -k virt_tool"
        #"-w /usr/local/bin/qemu-io -p x -k virt_tool"
        #"-w /usr/local/bin/qemu-nbd -p x -k virt_tool"
        #"-w /usr/local/bin/qemu-system-x86_64 -p x -k virt_tool"
        #"-w /usr/bin/kubelet -k kubelet"
        "-a always,exit -F arch=b64 -S msgctl -k Inter-Process_Communication"
        "-a always,exit -F arch=b64 -S msgget -k Inter-Process_Communication"
        "-a always,exit -F arch=b64 -S semctl -k Inter-Process_Communication"
        "-a always,exit -F arch=b64 -S semget -k Inter-Process_Communication"
        "-a always,exit -F arch=b64 -S semop -k Inter-Process_Communication"
        "-a always,exit -F arch=b64 -S semtimedop -k Inter-Process_Communication"
        "-a always,exit -F arch=b64 -S shmctl -k Inter-Process_Communication"
        "-a always,exit -F arch=b64 -S shmget -k Inter-Process_Communication"
        "-w ${pkgs.bashInteractive}/bin/bash -p x -k susp_shell"
        #"-w /bin/dash -p x -k susp_shell"
        #"-w /bin/busybox -p x -k susp_shell"
        #"-w /bin/zsh -p x -k susp_shell"
        "-w ${pkgs.bashInteractive}/bin/sh -p x -k susp_shell"
        #"-w /bin/ksh -p x -k susp_shell"
        "-a always,exit -F arch=b64 -F euid=0 -F auid>=1000 -F auid!=-1 -S execve -k rootcmd"
        "-a always,exit -F arch=b64 -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=-1 -k delete"
        "-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k file_access"
        "-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k file_access"
        "-a always,exit -F arch=b64 -S mkdir,creat,link,symlink,mknod,mknodat,linkat,symlinkat -F exit=-EACCES -k file_creation"
        "-a always,exit -F arch=b64 -S mkdir,link,symlink,mkdirat -F exit=-EPERM -k file_creation"
        "-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EACCES -k file_modification"
        "-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EPERM -k file_modification"
        "-a always,exit -F arch=b32 -S all -k 32bit_api"
      ];
    };
  };
}
