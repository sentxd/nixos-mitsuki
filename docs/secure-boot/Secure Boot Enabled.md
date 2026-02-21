# Secure Boot Enabled

Enabled: 21 Feb 2026

I setup Secure Boot on NixOS to enable seamless swapping between my Windows 11 SSD and NixOS SSD. I wanted to keep Windows 11 up to date by swapping it into Mitsuki every month and running Windows Update. However, every time I needed to enable Secure Boot and it would catch me out. 

So today with the help of ChatGPT, I stepped through enabling it on NixOS.

## 🔐 Secure Boot Enablement Summary (NixOS + Lanzaboote)

- Backed up the EFI System Partition (`/boot`) for recovery.
- Added **Lanzaboote** as a flake input.
- Imported `lanzaboote.nixosModules.lanzaboote` in `flake.nix`.
- Updated `configuration.nix`:
  - Forced `boot.loader.systemd-boot.enable = lib.mkForce false;`
  - Enabled `boot.lanzaboote.enable = true;`
  - Set `boot.lanzaboote.pkiBundle = "/var/lib/sbctl";`
  - Ensured `boot.loader.efi.canTouchEfiVariables = true;`
- Created Secure Boot keys:
  - `sbctl create-keys`
- Rebuilt system to install signed UKIs via Lanzaboote.
- Verified boot artifacts:
  - `sbctl verify`
- Entered firmware and **erased Secure Boot settings** (entered Setup Mode).
- Enrolled custom keys + Microsoft keys:
  - `sbctl enroll-keys --microsoft`
- Rebooted into firmware and enabled **Secure Boot enforcement**.
- Verified final state:
  - `bootctl status`
  - `sbctl status`
- Confirmed:
  - NixOS boots under Secure Boot.
  - Windows boots (BitLocker resealed after one recovery prompt).
  - Ventoy certificate re-enrolled and working.
  - SSD swapping works without toggling Secure Boot.

------

## 🎯 Result

- Secure Boot: **enabled (user mode)**
- UKI-based boot chain (Type #2)
- TPM measured boot active
- Microsoft keys retained for Windows compatibility
- Seamless Windows ↔ NixOS SSD swapping achieved

------

## Snapshots

```shell
[sentinel@mitsuki:~/nixos-mitsuki]$ bootctl status
System:
      Firmware: UEFI 2.90 (INSYDE Corp. 0.773)
 Firmware Arch: x64
   Secure Boot: enabled (user)
  TPM2 Support: yes
  Measured UKI: yes
  Boot into FW: supported

Current Boot Loader:
       Product: systemd-boot 258.3
     Features: ✓ Boot counting
               ✓ Menu timeout control
               ✓ One-shot menu timeout control
               ✓ Default entry control
               ✓ One-shot entry control
               ✓ Support for XBOOTLDR partition
               ✓ Support for passing random seed to OS
               ✓ Load drop-in drivers
               ✓ Support Type #1 sort-key field
               ✓ Support @saved pseudo-entry
               ✓ Support Type #1 devicetree field
               ✓ Enroll SecureBoot keys
               ✓ Retain SHIM protocols
               ✓ Menu can be disabled
               ✓ Multi-Profile UKIs are supported
               ✓ Loader reports network boot URL
               ✓ Support Type #1 uki field
               ✓ Support Type #1 uki-url field
               ✓ Loader reports TPM2 active PCR banks
     Partition: /dev/disk/by-partuuid/a3124442-5271-414f-91b8-b9a94248df36
        Loader: └─/boot//EFI/BOOT/BOOTX64.EFI
 Current Entry: nixos-generation-50-fwzg7iy7viiipem2brkjpqz3r5u3qauthpbkwjy3zndkfvhhbdaa.efi

Current Stub:
      Product: lanzastub 1.0.0
     Features: ✓ Stub reports loader partition information
               ✗ Stub reports stub partition information
               ✗ Stub reports network boot URL
               ✗ Picks up credentials from boot partition
               ✗ Picks up system extension images from boot partition
               ✗ Picks up configuration extension images from boot partition
               ✗ Measures kernel+command line+sysexts
               ✗ Support for passing random seed to OS
               ✗ Pick up .cmdline from addons
               ✗ Pick up .cmdline from SMBIOS Type 11
               ✗ Pick up .dtb from addons
               ✗ Stub understands profile selector

Random Seed:
 System Token: set
       Exists: yes

Available Boot Loaders on ESP:
          ESP: /boot (/dev/disk/by-partuuid/a3124442-5271-414f-91b8-b9a94248df36)
         File: ├─/boot//EFI/systemd/systemd-bootx64.efi (systemd-boot 258.3)
               └─/boot//EFI/BOOT/BOOTX64.EFI (systemd-boot 258.3)

No boot loaders listed in EFI Variables.

Boot Loader Entry Locations:
          ESP: /boot (/dev/disk/by-partuuid/a3124442-5271-414f-91b8-b9a94248df36, $BOOT)
       config: /boot//loader/loader.conf
        token: nixos

Default Boot Loader Entry:
         type: Boot Loader Specification Type #2 (UKI, .efi)
        title: NixOS Yarara 26.05.20260126.bfc1b8a (Linux 6.18.7) (Generation 51, 2026-02-21)
           id: nixos-generation-51-syvcf4dtfyrqd6yrunow7snvwlhv376yvyqdl2h2jtowenxmg25a.efi
       source: /boot//EFI/Linux/nixos-generation-51-syvcf4dtfyrqd6yrunow7snvwlhv376yvyqdl2h2jtowenxmg25a.efi (on the EFI System Partition)
     sort-key: lanza
      version: Generation 51, 2026-02-21
        linux: /boot//EFI/Linux/nixos-generation-51-syvcf4dtfyrqd6yrunow7snvwlhv376yvyqdl2h2jtowenxmg25a.efi
      options: init=/nix/store/jk3c5zags37zsdxwy97wi5zxl924f16p-nixos-system-mitsuki-26.05.20260126.bfc1b8a/init amd_pstate=active amdgpu.dcdebugmask=0x10 loglevel=4 lsm=landlock,yama,bpf

[sentinel@mitsuki:~/nixos-mitsuki]$
```

```shell
[sentinel@mitsuki:~/nixos-mitsuki/docs/secure-boot]$ sudo sbctl status
Place your finger on the fingerprint reader
Failed to match fingerprint
Place your finger on the fingerprint reader
Installed:      ✓ sbctl is installed
Owner GUID:     14a14f24-515a-4ffd-9b31-2feca8ccd9b8
Setup Mode:     ✓ Disabled
Secure Boot:    ✓ Enabled
Vendor Keys:    microsoft
```

```shell
[sentinel@mitsuki:~/nixos-mitsuki/docs/secure-boot]$ sudo sbctl list-enrolled-keys
PK:
  Platform Key
KEK:
  Key Exchange Key
  Microsoft Corporation Third Party Marketplace Root
  Microsoft RSA Devices Root CA 2021
DB:
  Database Key
  Microsoft Corporation Third Party Marketplace Root
  Microsoft Root Certificate Authority 2010
  Microsoft RSA Devices Root CA 2021
  Microsoft RSA Devices Root CA 2021
  Microsoft Root Certificate Authority 2010
```

## Notes

- BitLocker recovery requested once after Secure Boot key change
- Second boot succeeded normally
- Ventoy certificate re-enrolled after Secure Boot key reset

## Recovery Steps

If system fails to boot:

1. Enter firmware
2. Disable Secure Boot enforcement
3. Boot NixOS
4. Run `sbctl verify`

## Warnings

Regenerating sbctl keys will break Windows Secure Boot until re-enrolled and may trigger BitLocker recovery again.