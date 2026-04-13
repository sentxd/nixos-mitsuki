{ config, lib, ... }:

let
  cfg = config.mitsuki.powerManagement;
in
{
  options.mitsuki.powerManagement = {
    enable = lib.mkEnableOption "Disable unwanted ACPI wake sources at boot";

    wakeDevices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "XHC0" "XHC1" "XHC3" "XHC4" "GPP0" "GPP1" "GPP3" "GPP5" ];
      description = "ACPI wake devices to disable during boot.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.disable-wake-sources = {
      description = "Disable unwanted wake sources";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";

      script = ''
        set -eu
        for dev in ${lib.concatStringsSep " " cfg.wakeDevices}; do
          if grep -q "^$dev[[:space:]].*enabled" /proc/acpi/wakeup; then
            echo "$dev" > /proc/acpi/wakeup
          fi
        done
      '';
    };
  };
}