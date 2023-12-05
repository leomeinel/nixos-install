/*
  * File: security.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, lib, config, pkgs, ... }:

{
  # Security options
  security = {
    # Select programs
    auditd.enable = true;
    sudo.enable = false;
    # doas options
    doas = {
      enable = true;
      extraRules = [{
        persist = true;
        setEnv = [ "LANG" "LC_ALL" "LOCALE_ARCHIVE" ];
        groups = [ "wheel" ];
      }];
    };
    # FIXME: Find a way to implement these
    #        Issue: https://discourse.nixos.org/t/enforcing-strong-passwords-on-nixos-pam-pwquality-so-module-not-known/36420
    # FIXME: /etc/security/faillock.conf
    # pam options
    #pam = {
    #  # Equivalent to /etc/security/limits.conf
    #  loginLimits = [
    #    {
    #      domain = "*";
    #      type = "hard";
    #      item = "core";
    #      value = "0";
    #    }
    #  ];
    #  # Services in /etc/pam.d/
    #  services = {
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
    #  };
    #};
    # FIXME: /etc/audit/auditd.conf
    # Audit options
    audit = {
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
  };
}
