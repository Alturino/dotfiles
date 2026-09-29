# WSL Disk Switch Design

## Overview

A single PowerShell script that moves a removable USB disk between Windows and WSL 2, because Windows cannot mount its ext4 partition and `wsl --mount` refuses to touch a disk Windows still has open.

The disk has two partitions:

| Part | Filesystem | Owner |
|------|-----------|-------|
| 1 | NTFS | Windows (needs the disk online) |
| 2 | ext4 | WSL (needs the disk offlined and attached) |

The script flips the disk between those two states.

## Goals

- One command to give the disk to WSL, one command to give it back to Windows
- Auto-detect candidate disks and prompt for selection (drive numbers drift between replugs)
- Idempotent: running an action that is already true is a no-op, not an error
- Stateless: disk `IsOffline` is the source of truth, no marker files
- Never touch the boot/system disk
- Fail with actionable messages, never leave the disk half-switched

## Non-Goals

- No config files, logging framework, or fstab/symlink setup
- No `-WhatIf` plumbing (a hand-rolled `-DryRun` covers testing)
- No support for the Windows boot disk (impossible by WSL design)
- No `usbipd` integration (documented as a fallback error hint only)

## Placement

`windows/disk-switch.ps1` — a new top-level directory that is **not** added to `stow_packages` in `ansible/vars/common.yml`, so stow and the Linux side ignore it entirely.

The repo root acts as `$HOME` for stow; top-level directories are stow packages. `windows/` stays out of the allowlist.

## Interface

```
.\disk-switch.ps1 wsl      # take disk from Windows, mount partition 2 in WSL
.\disk-switch.ps1 windows  # unmount from WSL, hand disk back to Windows
.\disk-switch.ps1 status   # show state of candidate disks, do nothing
```

### Parameters

| Param | Default | Purpose |
|---|---|---|
| `-DiskNumber <int>` | (prompt) | skip the picker |
| `-PartitionIndex <int>` | `2` | the ext4 partition |
| `-DryRun` | off | print planned actions without executing |

### Exit codes

| Code | Meaning |
|---|---|
| 0 | success, or already in the requested state |
| 1 | action failed |
| 2 | no candidate disks found |

## Detection

A disk is a candidate only if **all** hold:

```
-not IsBoot -and -not IsSystem -and -not IsClustered
-and contains no partition holding the Windows/EFI volume
-and has >=1 NTFS-or-ReFS partition                 (partition 1)
-and has >=1 partition with no Windows filesystem   (partition 2, ext4/raw)
```

This filter is a hard rule, not a prompt: the script cannot be coaxed into offlining a system disk.

`Get-Disk` and `Get-Partition` still list an offline disk, so detection works in both states. That is what makes `windows` and `status` possible.

Filesystem per partition comes from `Get-Volume` when it returns one; a partition Windows cannot identify is reported as `no Windows FS`.

## Picker UX

`-DiskNumber` skips the numbered list but still shows the confirmation block. `-DryRun` skips the confirmation too, since it cannot change anything. There is no force/`-Yes` flag: with `-DiskNumber` plus `-DryRun` you can script it.

```
Found 2 candidate disks:

  #  Bus  Size      Model                     Partitions
  1  USB  465.76GB  Samsung Portable SSD T5   1:NTFS 465.7GB  |  2:no Windows FS
  2  USB  1.82TB    Seagate Expansion         1:NTFS 1.82TB   |  2:no Windows FS

Select disk [1-2]: 1

Disk 1 (Samsung Portable SSD T5, \\.\PHYSICALDRIVE3)
  will be OFFLINED in Windows, partition 2 mounted in WSL.
  Close any open files on E: first.
Proceed? [Y/n]:
```

The partition numbers shown are the same 1-based numbers passed to `wsl --mount --partition`. What you see is what gets mounted.

`--type ext4` is hardcoded rather than detected: Windows cannot identify the filesystem of partition 2 (that is the whole problem), so there is nothing to detect. `-PartitionIndex` exists because partition numbering is the only part of the layout likely to change.

## State Machine

```
Windows mode:  disk online,  not WSL-attached  -> NTFS part 1 usable in Explorer
WSL mode:      disk offline, WSL-attached      -> ext4 part 2 at /mnt/wsl/PHYSICALDRIVE<n>p2
```

No marker files. If the script crashes mid-way, `status` reports reality and either action can be run to converge.

## Flows

### `wsl` action

1. Preflight: admin, `wsl.exe` present, `wsl --version` reports WSL 2.
2. Detect candidates -> pick -> confirm.
3. Idempotency: if disk is offline **and** `/mnt/wsl/PHYSICALDRIVE<n>p<PartitionIndex>` exists inside WSL -> print path, exit 0.
4. `Set-Disk -Number n -IsOffline $true`
5. Verify `IsOffline -eq $true`.
6. `wsl.exe --mount \\.\PHYSICALDRIVE<n> --partition <PartitionIndex> --type ext4`
7. Verify with `wsl.exe -e ls /mnt/wsl/PHYSICALDRIVE<n>p<PartitionIndex>`.
8. Print the mount path and the exact reverse command.

### `windows` action

1. Detect -> pick -> confirm (same picker; offline disks are still visible).
2. Idempotency: if disk is already online -> print "already in Windows mode", exit 0.
3. `wsl.exe --unmount \\.\PHYSICALDRIVE<n>` — always path-scoped, never a bare `wsl --unmount`, so other attached disks survive. Non-zero exit is tolerated with "not attached (ok)".
4. `Set-Disk -Number n -IsOffline $false`
5. Verify online; list the drive letters that came back (that is NTFS partition 1).

### `status` action

For each candidate, print: disk number, bus, model, size, `IsOffline`, whether `/mnt/wsl/PHYSICALDRIVE<n>p*` is visible inside WSL, and each partition with its filesystem and drive letter. Never modifies anything.

### Ordering safety

- `wsl`: offline the disk **before** `wsl --mount`.
- `windows`: `wsl --unmount` **before** `Set-Disk -IsOffline $false`. Never online a disk WSL still owns.
- Every step is verified before the next runs.

## Elevation

If not running as administrator, prompt and relaunch with `Start-Process -Verb RunAs`, passing the same arguments through.

## Error Handling

| Failure | Behavior |
|---|---|
| Not admin | Prompt -> relaunch elevated with same args |
| `wsl.exe` missing / default distro is WSL 1 | Error before touching the disk |
| No candidates | Print `Get-Disk` hint, exit 2 |
| `Set-Disk -IsOffline` throws (open handle) | Name the offending drive letters, "close files on E: and retry", exit 1, **disk left online** |
| `wsl --mount` returns `0x80070020` | Disk not fully released; print `wsl -e dmesg \| tail -n 20` |
| `wsl --mount` returns `0x8007000f` | Likely the USB-flash limitation (WSL#6011) or a drifted disk number; say so and suggest `usbipd` |
| `wsl --unmount` fails | Suggest `wsl --shutdown`, then retry `windows` |

## Known Risk: USB flash drives

`wsl --mount` reliably attaches USB **disks** (HDD/SSD enclosures) but fails for many USB **flash** sticks and SD readers — see [microsoft/WSL#6011](https://github.com/microsoft/WSL/issues/6011), still open. The script detects this signature (`0x8007000f` after a successful offline) and prints an explicit message pointing at `usbipd-win` rather than failing opaquely.

## Verification

PowerShell cannot execute on this workstation, so verification is split:

1. **`-DryRun`** prints the exact commands each action would run. Assert those strings against this spec — the detection, ordering, and `--partition`/`--type` arguments are what need checking.
2. **`Invoke-ScriptAnalyzer`** (`PSScriptAnalyzer`) as a lint pass, if available on the Windows side.
3. **Manual runbook** on the Windows machine:
   - `.\disk-switch.ps1 status` — both partitions listed, disk online
   - `.\disk-switch.ps1 wsl` — pick disk, confirm; then in WSL: `ls /mnt/wsl/PHYSICALDRIVE<n>p2` shows content
   - `.\disk-switch.ps1 wsl` again — exits 0 immediately (idempotency)
   - `.\disk-switch.ps1 windows` — NTFS partition returns with a drive letter in Explorer
   - Failure drill: hold a file open on the NTFS volume, run `wsl` -> clean error naming that drive letter, disk still online
   - Failure drill: run `status` from a non-elevated prompt -> elevation prompt appears
