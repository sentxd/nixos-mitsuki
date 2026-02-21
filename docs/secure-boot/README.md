# Secure Boot on NixOS (Lanzaboote + UKI + Windows Compatibility)

## Overview

Secure Boot was enabled on NixOS using **Lanzaboote**, which provides:

- Unified Kernel Images (UKI, Type #2 boot entries)
- systemd-boot integration
- Automatic signing via `sbctl`
- TPM measured boot support
- Compatibility with Windows by retaining Microsoft vendor keys

Goal:
 Enable Secure Boot permanently while allowing seamless SSD swapping between NixOS and Windows (BitLocker enabled).

------

## Configuration Changes

### 1. Add Lanzaboote flake input

```
lanzaboote = {
  url = "github:nix-community/lanzaboote";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Import module:

```
lanzaboote.nixosModules.lanzaboote
```

------

### 2. Replace default systemd-boot module integration

```
{ pkgs, lib, ... }:

{
  boot.loader.efi.canTouchEfiVariables = true;

  # Lanzaboote replaces NixOS systemd-boot integration
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  environment.systemPackages = with pkgs; [
    sbctl
  ];
}
```

------

## Procedure

1. Backup EFI System Partition (`/boot`).

2. `nixos-rebuild switch`

3. Create Secure Boot keys:

   ```
   sbctl create-keys
   ```

4. Rebuild system so Lanzaboote signs boot artifacts.

5. Verify signatures:

   ```
   sbctl verify
   ```

6. Reboot into firmware.

7. Erase Secure Boot settings (enter Setup Mode).

8. Enroll keys including Microsoft vendor keys:

   ```
   sbctl enroll-keys --microsoft
   ```

9. Reboot into firmware.

10. Enable Secure Boot enforcement.

11. Verify:

    ```
    bootctl status
    sbctl status
    ```

------

## Final State

- Secure Boot: **enabled (user mode)**
- Boot entry type: **Type #2 (UKI)**
- systemd-boot signed
- Lanzaboote stub active
- TPM Measured UKI: yes
- Microsoft keys present (Windows compatibility)
- BitLocker resealed successfully after one recovery prompt
- Ventoy certificate re-enrolled

------

## Boot Chain

```
UEFI Firmware
  → Secure Boot (custom PK/KEK/db + Microsoft KEK/db)
  → systemd-boot (signed)
  → Lanzaboote UKI (signed)
  → Linux kernel + initrd + cmdline (bundled)
  → TPM measured boot
```

------

## Notes

- Changing Secure Boot keys will trigger BitLocker recovery once.
- Firmware updates may also trigger BitLocker recovery.
- Regenerating `sbctl` keys will require re-enrollment and may break Windows boot until resealed.
- Private keys under `/var/lib/sbctl` must not be committed or shared.

------

## Recovery Procedure

If boot fails:

1. Enter firmware.

2. Disable Secure Boot enforcement.

3. Boot NixOS.

4. Run:

   ```
   sbctl verify
   nixos-rebuild switch
   ```

------

## Why Lanzaboote Instead of shim/GRUB?

- Native UKI support
- Declarative integration with NixOS
- Automatic signing on rebuild
- Cleaner TPM measurement model
- Minimal moving parts