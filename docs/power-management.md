# Power Management Notes (Framework 13, NixOS)

## Overview

This document describes custom power management tuning applied to prevent unwanted wake events during suspend.

### Goal

Allow wake **only from**:

- Lid open
- Power button
- Keyboard input

Prevent wake from:

- USB devices (mouse, dock, etc.)
- USB-C power (USB-PD plug/unplug)
- PCIe/dock-related events

------

## Problem Description

The laptop would intermittently wake from suspend when:

- Plugging in USB-C power (USB-PD)
- Moving the mouse
- Connecting/disconnecting USB devices or docks

This caused:

- Unintended wake-ups
- Battery drain
- Laptop staying active in bag / on desk

------

## Root Cause

Wake events were being triggered by:

### 1. USB Controllers (`XHC*`)

Responsible for:

- Mouse movement
- USB devices
- Dock interactions

### 2. PCIe Root Ports (`GPP*`)

Responsible for:

- USB-C Power Delivery (charging events)
- Dock-related signals via embedded controller

Even though some devices reported `S4`, they still generated wake events from suspend (S3), likely due to firmware behavior.

------

## Diagnosis

Wake sources were inspected using:

```
cat /proc/acpi/wakeup
```

Relevant entries:

- `XHC*` → USB controllers
- `GPP*` → PCIe root ports
- `NHI*` → Thunderbolt/USB4 (not modified)

------

## Solution

Disable wake capability for:

- All `XHC*` devices (USB)
- All `GPP*` devices (PCIe root ports)

This prevents:

- Mouse wake
- USB wake
- USB-C power (PD) wake

------

## Implementation (NixOS)

A systemd oneshot service is used to disable wake sources at boot.

### Configuration

```
systemd.services.disable-wake-sources = {
  description = "Disable unwanted wake sources";
  wantedBy = [ "multi-user.target" ];
  serviceConfig.Type = "oneshot";
  script = ''
    for dev in XHC0 XHC1 XHC3 XHC4 GPP0 GPP1 GPP3 GPP5; do
      if grep -q "$dev.*enabled" /proc/acpi/wakeup; then
        echo "$dev" > /proc/acpi/wakeup
      fi
    done
  '';
};
```

Apply with:

```
sudo nixos-rebuild switch
```

------

## Result

After applying this configuration:

| Event               | Behavior  |
| ------------------- | --------- |
| Mouse movement      | ❌ No wake |
| USB device activity | ❌ No wake |
| USB-C power plug    | ❌ No wake |
| Lid open            | ✅ Wake    |
| Power button        | ✅ Wake    |
| Keyboard input      | ✅ Wake    |

------

## Notes / Caveats

### Docking Stations

- Some docks rely on PCIe wake signals
- If issues arise, selectively re-enable specific `GPP*` entries

### Firmware Updates

- BIOS updates may change device names or wake behavior
- Re-check wake sources after updates:

```
cat /proc/acpi/wakeup
```

### Device-Specific Wake

If needed, individual devices can be re-enabled manually:

```
echo XHC0 | sudo tee /proc/acpi/wakeup
```

------

## Troubleshooting

To debug unexpected wake events:

```
journalctl -b -1 | grep -i wake
```

And:

```
cat /sys/kernel/debug/wakeup_sources
```

------

## Summary

This setup ensures:

- Predictable suspend behavior
- No unintended wake-ups
- Improved battery life
- Safe “sleep in bag” behavior

------

## Last Updated

- Date: (fill this in)
- Device: Framework 13 Ryzen AI 300
- NixOS: (optional: `nixos-version`)