/*
  File: security.nix
  Author: Leopold Johannes Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Johannes Meinel & contributors
  SPDX ID: Apache-2.0
  URL: https://www.apache.org/licenses/LICENSE-2.0
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
        ${pkgs.curl}/bin/curl -s -F "title=''${PAM_USER}@${installEnv.HOSTNAME}: SSH login" -F "priority=10" -F "message=From: ''${PAM_RHOST}" "https://${installEnv.NOTIFY_DOMAIN}/message?token=$(${pkgs.coreutils-full}/bin/cat /run/secrets/keys/gotify-${installEnv.HOSTNAME}-ssh-login.pass)"
    fi
  '';
in
{
  # Security options
  security = {
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
            "DIFFPROG"
            "JAVA_HOME"
            "MANPAGER"
            "MANROFFOPT"
            "MYSQL_HOME"
            "PAGER"
            "VISUAL"
          ];
          groups = [ "wheel" ];
        }
      ];
    };
    # /etc/login.defs
    loginDefs.settings = {
      YESCRYPT_COST_FACTOR = "11";
      UMASK = "027";
      HOME_MODE = "0700";
      SHA_CRYPT_MIN_ROUNDS = "99999999";
      SHA_CRYPT_MAX_ROUNDS = "999999999";
    };
    # FIXME: Find a way to implement pam.d restrictions
    # See: https://github.com/NixOS/nixpkgs/issues/287420
    # See: https://discourse.nixos.org/t/enforcing-strong-passwords-on-nixos-pam-pwquality-so-module-not-known/36420
    # FIXME: /etc/security/faillock.conf
    # pam options
    pam = {
      #  # Equivalent to /etc/security/limits.conf
      loginLimits = [
        {
          domain = "*";
          type = "hard";
          item = "core";
          value = "0";
        }
        {
          domain = "*";
          type = "soft";
          item = "nproc";
          value = "10000";
        }
        {
          domain = "*";
          type = "hard";
          item = "nproc";
          value = "20000";
        }
      ];
      # Services in /etc/pam.d/
      services = {
        "sshd".text = lib.mkDefault (
          lib.mkAfter ''
            # Custom
            session optional pam_exec.so ${wrapped-notify-ssh-login}/bin/notify-ssh-login
          ''
        );
      };
    };
    auditd = {
      enable = true;
      # FIXME: Enable this immediately after 25.11 upgrade
      # settings = {
      #   log_group = "audit";
      #   log_format = "RAW";
      #   max_log_file = "100";
      #   num_logs = "10";
      # };
    };
    # audit options (/etc/audit/audit.rules)
    audit = {
      enable = "lock";
      failureMode = "printk";
      backlogLimit = 8192;
      # INFO: These rules were modified and are based on rules normally found in: /etc/audit/rules.d/ and arch-install
      rules = [
        "--backlog_wait_time 60000"
        "--loginuid-immutable"
        "-i"
        "-a always,exclude -F msgtype=AVC"
        "-a always,exclude -F msgtype=CRYPTO_KEY_USER"
        "-a always,exclude -F msgtype=CWD"
        "-a always,exclude -F msgtype=EOE"
        "-a always,exclude -F msgtype=EXECVE"
        "-a always,exclude -F msgtype=OBJ_PID"
        "-a always,exclude -F msgtype=PATH"
        "-a always,exclude -F msgtype=SOCKADDR"
        "-a always,exclude -F msgtype=USER_AUTH"
        "-a always,exclude -F msgtype=USER_LOGIN"
        "-a always,exit -F arch=b32 -S all -F key=32bit-abi"
        "-a never,filesystem -F fstype=tracefs"
        "-a never,filesystem -F fstype=debugfs"
        "-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b32 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b32 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b64 -S open -F a1&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b32 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b64 -S creat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-create"
        "-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b32 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b64 -S open -F a1&01003 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b32 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b64 -S truncate,ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-modification"
        "-a always,exit -F arch=b32 -S open,openat,openat2,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-access"
        "-a always,exit -F arch=b64 -S open,openat,openat2,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-access"
        "-a always,exit -F arch=b32 -S open,openat,openat2,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-access"
        "-a always,exit -F arch=b64 -S open,openat,openat2,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-access"
        "-a always,exit -F arch=b32 -S unlink,unlinkat,rename,renameat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-delete"
        "-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-delete"
        "-a always,exit -F arch=b32 -S unlink,unlinkat,rename,renameat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-delete"
        "-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-delete"
        "-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat,setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr,fchmodat2,setxattrat,removexattrat,file_setattr -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-perm-change"
        "-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat,setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr,fchmodat2,setxattrat,removexattrat,file_setattr -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-perm-change"
        "-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat,setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr,fchmodat2,setxattrat,removexattrat,file_setattr -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-perm-change"
        "-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat,setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr,fchmodat2,setxattrat,removexattrat,file_setattr -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-perm-change"
        "-a always,exit -F arch=b32 -S lchown,fchown,chown,fchownat,file_setattr -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-owner-change"
        "-a always,exit -F arch=b64 -S lchown,fchown,chown,fchownat,file_setattr -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccessful-owner-change"
        "-a always,exit -F arch=b32 -S lchown,fchown,chown,fchownat,file_setattr -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-owner-change"
        "-a always,exit -F arch=b64 -S lchown,fchown,chown,fchownat,file_setattr -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccessful-owner-change"
        "-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b32 -S open -F a1&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -S open -F a1&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b32 -S openat,open_by_handle_at -F a2&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -S openat,open_by_handle_at -F a2&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b32 -S open -F a1&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -S open -F a1&03 -F path=/etc/shadow -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b32 -F path=/etc/passwd -F perm=wa -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -F path=/etc/passwd -F perm=wa -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b32 -F path=/etc/shadow -F perm=wa -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b64 -F path=/etc/shadow -F perm=wa -F auid>=1000 -F auid!=unset -F key=user-modify"
        "-a always,exit -F arch=b32 -F path=/etc/group -F perm=wa -F auid>=1000 -F auid!=unset -F key=group-modify"
        "-a always,exit -F arch=b64 -F path=/etc/group -F perm=wa -F auid>=1000 -F auid!=unset -F key=group-modify"
        "-a always,exit -F arch=b32 -F path=/etc/gshadow -F perm=wa -F auid>=1000 -F auid!=unset -F key=group-modify"
        "-a always,exit -F arch=b64 -F path=/etc/gshadow -F perm=wa -F auid>=1000 -F auid!=unset -F key=group-modify"
        "-a always,exit -F arch=b32 -F path=/run/wrappers/bin/unix_chkpwd -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/unix_chkpwd -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b32 -F path=/usr/sbin/usernetctl -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b64 -F path=/usr/sbin/usernetctl -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b32 -F path=/usr/sbin/userhelper -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b64 -F path=/usr/sbin/userhelper -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b32 -F path=/usr/sbin/seunshare -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b64 -F path=/usr/sbin/seunshare -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -F path=/run/wrappers/bin/mount -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/mount -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -F path=/run/wrappers/bin/newgrp -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/newgrp -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -F path=/run/wrappers/bin/newuidmap -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/newuidmap -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -F path=${pkgs.shadow}/bin/gpasswd -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -F path=${pkgs.shadow}/bin/gpasswd -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -F path=/run/wrappers/bin/newgidmap -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/newgidmap -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -F path=/run/wrappers/bin/umount -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/umount -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -F path=/run/wrappers/bin/passwd -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/passwd -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b32 -F path=/usr/bin/crontab -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b64 -F path=/usr/bin/crontab -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b32 -F path=/usr/bin/at -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b64 -F path=/usr/bin/at -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b32 -F path=/usr/sbin/grub2-set-bootflag -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        # "-a always,exit -F arch=b64 -F path=/usr/sbin/grub2-set-bootflag -F perm=x -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -S mount_setattr -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -S mount_setattr -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -S landlock_create_ruleset -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -S landlock_create_ruleset -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -S landlock_add_rule -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -S landlock_add_rule -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -S landlock_restrict_self -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -S landlock_restrict_self -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -S lsm_set_self_attr -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b64 -S lsm_set_self_attr -F auid>=1000 -F auid!=unset -F key=special-config-changes"
        "-a always,exit -F arch=b32 -F path=${pkgs.systemd}/bin/systemd-run -F perm=x -F auid!=unset -F key=maybe-escalation"
        "-a always,exit -F arch=b64 -F path=${pkgs.systemd}/bin/systemd-run -F perm=x -F auid!=unset -F key=maybe-escalation"
        "-a always,exit -F arch=b32 -F path=/run/wrappers/bin/pkexec -F perm=x -F key=maybe-escalation"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/pkexec -F perm=x -F key=maybe-escalation"
        "-a always,exit -F arch=b32 -F path=/etc/sudoers -F perm=wa -F key=special-config-changes"
        "-a always,exit -F arch=b64 -F path=/etc/sudoers -F perm=wa -F key=special-config-changes"
        "-a always,exit -F arch=b32 -F dir=/etc/sudoers.d/ -F perm=wa -F key=special-config-changes"
        "-a always,exit -F arch=b64 -F dir=/etc/sudoers.d/ -F perm=wa -F key=special-config-changes"
        "-a always,exit -F arch=b32 -F dir=/var/log/audit/ -F perm=r -F auid>=1000 -F auid!=unset -F key=access-audit-trail"
        "-a always,exit -F arch=b64 -F dir=/var/log/audit/ -F perm=r -F auid>=1000 -F auid!=unset -F key=access-audit-trail"
        "-a always,exit -F arch=b32 -F path=/var/run/utmp -F perm=wa -F auid>=1000 -F auid!=unset -F key=session"
        "-a always,exit -F arch=b64 -F path=/var/run/utmp -F perm=wa -F auid>=1000 -F auid!=unset -F key=session"
        "-a always,exit -F arch=b32 -F path=/var/log/btmp -F perm=wa -F auid>=1000 -F auid!=unset -F key=session"
        "-a always,exit -F arch=b64 -F path=/var/log/btmp -F perm=wa -F auid>=1000 -F auid!=unset -F key=session"
        "-a always,exit -F arch=b32 -F path=/var/log/wtmp -F perm=wa -F auid>=1000 -F auid!=unset -F key=session"
        "-a always,exit -F arch=b64 -F path=/var/log/wtmp -F perm=wa -F auid>=1000 -F auid!=unset -F key=session"
        "-a always,exit -F arch=b32 -F dir=/etc/selinux/ -F perm=wa -F auid>=1000 -F auid!=unset -F key=MAC-policy"
        "-a always,exit -F arch=b64 -F dir=/etc/selinux/ -F perm=wa -F auid>=1000 -F auid!=unset -F key=MAC-policy"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/unix_chkpwd -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/umount -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/su -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/sg -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/polkit-agent-helper-1 -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/pkexec -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/passwd -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/newuidmap -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/newgrp -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/newgidmap -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/mount -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/fusermount3 -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/fusermount -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/doas -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/dbus-daemon-launch-helper -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F arch=b64 -F path=/run/wrappers/bin/chsh -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged"
        "-a always,exit -F dir=/home -F uid=0 -F auid>=1000 -F auid!=unset -C auid!=obj_uid -F key=power-abuse"
        "-a always,exit -F arch=b32 -S clone -F a0&0x7C020000 -F key=container-create"
        "-a always,exit -F arch=b64 -S clone -F a0&0x7C020000 -F key=container-create"
        "-a always,exit -F arch=b32 -S unshare,setns -F key=container-config"
        "-a always,exit -F arch=b64 -S unshare,setns -F key=container-config"
        "-a always,exit -F arch=b64 -S ptrace -F key=tracing"
        "-a always,exit -F arch=b32 -S ptrace -F a0=0x4 -F key=code-injection"
        "-a always,exit -F arch=b64 -S ptrace -F a0=0x4 -F key=code-injection"
        "-a always,exit -F arch=b32 -S ptrace -F a0=0x5 -F key=data-injection"
        "-a always,exit -F arch=b64 -S ptrace -F a0=0x5 -F key=data-injection"
        "-a always,exit -F arch=b32 -S ptrace -F a0=0x6 -F key=register-injection"
        "-a always,exit -F arch=b64 -S ptrace -F a0=0x6 -F key=register-injection"
        "-a always,exit -F arch=b32 -S init_module,finit_module -F key=module-load"
        "-a always,exit -F arch=b64 -S init_module,finit_module -F key=module-load"
        "-a always,exit -F arch=b32 -S delete_module -F key=module-unload"
        "-a always,exit -F arch=b64 -S delete_module -F key=module-unload"
        # "-a always,exit -F arch=b32 -F perm=x -F path=/usr/bin/dnf-3 -F key=software-installer"
        # "-a always,exit -F arch=b64 -F perm=x -F path=/usr/bin/dnf-3 -F key=software-installer"
        # "-a always,exit -F arch=b32 -F perm=x -F path=/usr/bin/yum -F key=software-installer"
        # "-a always,exit -F arch=b64 -F perm=x -F path=/usr/bin/yum -F key=software-installer"
        # "-a always,exit -F arch=b32 -F perm=x -F path=/usr/bin/pip -F key=software-installer"
        # "-a always,exit -F arch=b64 -F perm=x -F path=/usr/bin/pip -F key=software-installer"
        # "-a always,exit -F arch=b32 -F perm=x -F path=/usr/bin/npm -F key=software-installer"
        # "-a always,exit -F arch=b64 -F perm=x -F path=/usr/bin/npm -F key=software-installer"
        "-a always,exit -F arch=b32 -F perm=x -F path=${pkgs.perl}/bin/cpan -F key=software-installer"
        "-a always,exit -F arch=b64 -F perm=x -F path=${pkgs.perl}/bin/cpan -F key=software-installer"
        # "-a always,exit -F arch=b32 -F perm=x -F path=/usr/bin/gem -F key=software-installer"
        # "-a always,exit -F arch=b64 -F perm=x -F path=/usr/bin/gem -F key=software-installer"
        # "-a always,exit -F arch=b32 -F perm=x -F path=/usr/bin/luarocks -F key=software-installer"
        # "-a always,exit -F arch=b64 -F perm=x -F path=/usr/bin/luarocks -F key=software-installer"
      ];
    };
  };
}
