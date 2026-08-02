{ pkgs, ... }:

let
  user = "sentinel";
  home = "/home/${user}";
  nasMount = "/mnt/sara/sentinel";
  repository = "${nasMount}/Kopia/mitsuki";
  configFile = "${home}/.config/kopia/repository.config";
  passwordFile = "/var/lib/kopia/backup.env";
in
{
  environment.systemPackages = with pkgs; [
    kopia
    kopia-ui
  ];

  # The password file is created manually; see docs/kopia.md.
  systemd.tmpfiles.rules = [
    "d /var/lib/kopia 0700 root root -"
  ];

  systemd.services.kopia-home-snapshot = {
    description = "Kopia snapshot of ${home}";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    # Do nothing until the password and an explicit repository connection exist.
    unitConfig = {
      RequiresMountsFor = nasMount;
      ConditionPathExists = [
        passwordFile
        configFile
        repository
      ];
    };

    serviceConfig = {
      Type = "oneshot";
      User = user;
      EnvironmentFile = passwordFile;
      Environment = [
        "HOME=${home}"
        "KOPIA_CONFIG_PATH=${configFile}"
      ];
      ExecStartPre = [ "${pkgs.util-linux}/bin/mountpoint --quiet ${nasMount}" ];
      ExecStart = "${pkgs.kopia}/bin/kopia snapshot create ${home}";
      Nice = 10;
      IOSchedulingClass = "idle";
      UMask = "0077";
    };
  };

  systemd.timers.kopia-home-snapshot = {
    description = "Hourly Kopia home snapshot";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "10m";
      Unit = "kopia-home-snapshot.service";
    };
  };
}
