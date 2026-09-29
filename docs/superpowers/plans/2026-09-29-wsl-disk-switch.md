# WSL Disk Switch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A single PowerShell script that moves a removable USB disk between Windows (NTFS partition 1) and WSL 2 (ext4 partition 2), in both directions.

**Architecture:** One file, `windows/disk-switch.ps1`, holding pure decision functions (candidate filter, state machine, action-plan builder) separated from thin side-effecting executors. Both `-DryRun` rendering and real execution consume the *same* ordered plan objects, so the dry-run output cannot drift from actual behaviour. Tests run here on Linux via Docker + Pester; only the manual runbook runs on Windows.

**Tech Stack:** PowerShell 7-compatible script (also works on Windows PowerShell 5.1), Pester 5, PSScriptAnalyzer, `mcr.microsoft.com/powershell:latest`, Docker.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-09-29-wsl-disk-switch-design.md`
- Path: `windows/disk-switch.ps1` — `windows/` must **not** be added to `stow_packages` in `ansible/vars/common.yml` (it is an allowlist; do not touch that file)
- CLI: `.\disk-switch.ps1 <wsl|windows|status> [-DiskNumber n] [-PartitionIndex n] [-DryRun]`
- Exit codes: `0` success/already-done, `1` action failed, `2` no candidate disks
- Defaults: `-PartitionIndex 2`, `--type ext4` hardcoded, mount path `/mnt/wsl/PHYSICALDRIVE<n>p<PartitionIndex>`
- Ordering is mandatory: **offline → mount** for `wsl`; **unmount → online** for `windows`
- Never touch a disk where `IsBoot`, `IsSystem`, `IsClustered`, or holding the Windows volume
- Every state change is verified before the next step runs
- `--partition` is 1-based and matches Windows partition numbering
- Known risk: `wsl --mount` fails on USB *flash* drives ([WSL#6011](https://github.com/microsoft/WSL/issues/6011)); error `0x8007000f` after a successful offline must name this explicitly

## File Structure

```
windows/
├── disk-switch.ps1            # the script — param, pure fns, executors, Main
├── README.md                  # usage + manual Windows runbook (Task 7)
└── tests/
    ├── run.sh                 # docker + Pester + PSScriptAnalyzer entry point
    └── disk-switch.Tests.ps1  # all Pester tests
```

Three files of consequence; `README.md` last. Everything lives under `windows/`, which stow ignores.

---

### Task 1: Harness, skeleton, and the dot-source guard

**Files:**
- Create: `windows/tests/run.sh`
- Create: `windows/disk-switch.ps1`
- Create: `windows/tests/disk-switch.Tests.ps1`

**Interfaces:**
- Produces: `Get-WslMountPath -DiskNumber <int> -PartitionIndex <int> -> string`; `Get-DiskMode -IsOffline <bool> -WslMounted <bool> -> 'wsl'|'windows'|'unknown'`; `Main -Action <string> -DiskNumber <int> -PartitionIndex <int> -DryRun <bool> -> int`
- Produces: the dot-source guard, which every later task relies on so tests can load the script without executing it

- [ ] **Step 1: Write the test runner**

```bash
#!/usr/bin/env bash
# windows/tests/run.sh — run the Pester suite and PSScriptAnalyzer in Docker
set -euo pipefail
cd "$(dirname "$0")/../.."

IMAGE="mcr.microsoft.com/powershell:latest"

docker run --rm -v "$PWD":/repo -w /repo "$IMAGE" -NoProfile -Command '
$ErrorActionPreference = "Stop"
Write-Host "== Installing Pester + PSScriptAnalyzer =="
Install-Module Pester -MinimumVersion 5.5.0 -Force -Scope CurrentUser -SkipPublisherCheck
Install-Module PSScriptAnalyzer -Force -Scope CurrentUser -SkipPublisherCheck

Write-Host "== Pester =="
$cfg = New-PesterConfiguration
$cfg.Run.Path = "windows/tests"
$cfg.Output.Verbosity = "Detailed"
$cfg.Run.Exit = $true
Invoke-Pester -Configuration $cfg

Write-Host "== PSScriptAnalyzer =="
$findings = Invoke-ScriptAnalyzer -Path "windows/disk-switch.ps1" -Severity Warning, Error
if ($findings) {
    $findings | Format-Table -AutoSize RuleName, Severity, Line, Message | Out-String | Write-Host
    exit 1
}
Write-Host "No analyzer findings."
'
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x windows/tests/run.sh`
Expected: no output, file mode becomes `-rwxr-xr-x`

- [ ] **Step 3: Write the failing tests**

```powershell
# windows/tests/disk-switch.Tests.ps1
BeforeAll {
    $script:Sut = Join-Path (Split-Path $PSScriptRoot -Parent) 'disk-switch.ps1'
    . $script:Sut
}

Describe 'Get-WslMountPath' {
    It 'builds the default automount path for a disk/partition pair' {
        Get-WslMountPath -DiskNumber 3 -PartitionIndex 2 |
            Should -Be '/mnt/wsl/PHYSICALDRIVE3p2'
    }
    It 'uses 1-based partition numbering' {
        Get-WslMountPath -DiskNumber 0 -PartitionIndex 1 |
            Should -Be '/mnt/wsl/PHYSICALDRIVE0p1'
    }
}

Describe 'Get-DiskMode' {
    It 'is windows when online and not attached' {
        Get-DiskMode -IsOffline $false -WslMounted $false | Should -Be 'windows'
    }
    It 'is wsl when offline and attached' {
        Get-DiskMode -IsOffline $true -WslMounted $true | Should -Be 'wsl'
    }
    It 'is unknown when offline but not attached (interrupted run)' {
        Get-DiskMode -IsOffline $true -WslMounted $false | Should -Be 'unknown'
    }
    It 'prefers wsl when WSL holds the disk regardless of online state' {
        Get-DiskMode -IsOffline $false -WslMounted $true | Should -Be 'wsl'
    }
}

Describe 'Dot-source guard' {
    It 'loads the script without running Main' {
        # If the guard were missing, dot-sourcing would print usage and call exit,
        # which would kill this Pester run instead of reaching this assertion.
        $true | Should -BeTrue
    }
}
```

- [ ] **Step 4: Run the test to verify it fails**

Run: `./windows/tests/run.sh`
Expected: FAIL — `Get-WslMountPath : The term 'Get-WslMountPath' is not recognized` (script does not exist yet). Docker will also pull the image on first run (~500 MB).

- [ ] **Step 5: Write the script skeleton**

```powershell
#Requires -Version 5.1
<#
.SYNOPSIS
  Move a removable disk between Windows and WSL 2.

.DESCRIPTION
  Windows cannot mount the ext4 partition, and wsl --mount refuses a disk Windows
  still holds open. This script flips the disk between the two states.

  wsl      - take the disk from Windows, mount partition 2 inside WSL
  windows  - detach from WSL, hand the disk back to Windows
  status   - report candidate disks without changing anything

  Full runbook: README.md next to this script.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('wsl', 'windows', 'status')]
    [string]$Action,

    [int]$DiskNumber = -1,

    [ValidateRange(1, 128)]
    [int]$PartitionIndex = 2,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-WslMountPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$DiskNumber,
        [Parameter(Mandatory)][int]$PartitionIndex
    )
    return '/mnt/wsl/PHYSICALDRIVE{0}p{1}' -f $DiskNumber, $PartitionIndex
}

function Get-DiskMode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][bool]$IsOffline,
        [Parameter(Mandatory)][bool]$WslMounted
    )
    if ($WslMounted) { return 'wsl' }
    if ($IsOffline)  { return 'unknown' }
    return 'windows'
}

function Main {
    [CmdletBinding()]
    param(
        [string]$Action,
        [int]$DiskNumber = -1,
        [int]$PartitionIndex = 2,
        [switch]$DryRun
    )

    if ([string]::IsNullOrWhiteSpace($Action)) {
        Write-Host ''
        Write-Host 'Usage: .\disk-switch.ps1 <wsl|windows|status> [-DiskNumber <n>] [-PartitionIndex <n>] [-DryRun]'
        Write-Host ''
        return 1
    }

    Write-Host "TODO: implement action '$Action'"
    return 1
}

if ($MyInvocation.InvocationName -ne '.') {
    $exitCode = 1
    try {
        $exitCode = Main -Action $Action -DiskNumber $DiskNumber `
                         -PartitionIndex $PartitionIndex -DryRun:$DryRun
    } catch {
        Write-Host ''
        [Console]::Error.WriteLine("ERROR: " + $_.Exception.Message)
        $exitCode = 1
    }
    exit $exitCode
}
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `./windows/tests/run.sh`
Expected: PASS — 5 passed, 0 failed. Then confirm the guard locally with:

```bash
docker run --rm -v "$PWD":/repo -w /repo mcr.microsoft.com/powershell:latest -NoProfile -Command '. ./windows/disk-switch.ps1; Get-WslMountPath -DiskNumber 1 -PartitionIndex 2'
```

Expected output: `/mnt/wsl/PHYSICALDRIVE1p2`

- [ ] **Step 7: Commit**

```bash
git add windows/disk-switch.ps1 windows/tests/run.sh windows/tests/disk-switch.Tests.ps1
git commit -m "feat(windows): add disk-switch skeleton and test harness"
```

---

### Task 2: Action plan — ordering and `-DryRun`

**Files:**
- Modify: `windows/disk-switch.ps1` (add after `Get-DiskMode`)
- Modify: `windows/tests/disk-switch.Tests.ps1`

**Interfaces:**
- Consumes: `Get-WslMountPath` (Task 1)
- Produces: `Get-ActionPlan -Action <'wsl'|'windows'> -DiskNumber <int> -PartitionIndex <int> -DiskIsOffline <bool> -WslMounted <bool> -> object[]`; `Format-Step -Step <object> -> string`; `Format-ActionPlan -Plan <object[]> -> string[]`
- Plan step shape: `[pscustomobject]@{ Kind; DiskNumber; PartitionIndex }` where `Kind` ∈ `OfflineDisk|OnlineDisk|WslMount|WslUnmount|VerifyWslMount|VerifyDiskOnline`

- [ ] **Step 1: Write the failing tests**

Append to `windows/tests/disk-switch.Tests.ps1`:

```powershell
Describe 'Get-ActionPlan' {
    BeforeAll {
        $newPlan = {
            param($Action, $Offline, $Mounted, $Partition = 2)
            Get-ActionPlan -Action $Action -DiskNumber 3 -PartitionIndex $Partition `
                           -DiskIsOffline $Offline -WslMounted $Mounted
        }
    }

    It 'for wsl on an online, unmounted disk goes offline then mounts then verifies' {
        $plan = & $newPlan 'wsl' $false $false
        $plan | ForEach-Object Kind | Should -Be @('OfflineDisk', 'WslMount', 'VerifyWslMount')
    }

    It 'for wsl on an already-offline disk skips the offline step' {
        $plan = & $newPlan 'wsl' $true $false
        $plan | ForEach-Object Kind | Should -Be @('WslMount', 'VerifyWslMount')
    }

    It 'for wsl on an already-mounted disk returns an empty plan' {
        $plan = & $newPlan 'wsl' $true $true
        $plan | Should -HaveCount 0
    }

    It 'for windows on an offline, mounted disk unmounts before onlining' {
        $plan = & $newPlan 'windows' $true $true
        $plan | ForEach-Object Kind | Should -Be @('WslUnmount', 'OnlineDisk', 'VerifyDiskOnline')
    }

    It 'for windows on an offline disk that never mounted still onlines it' {
        $plan = & $newPlan 'windows' $true $false
        $plan | ForEach-Object Kind | Should -Be @('OnlineDisk', 'VerifyDiskOnline')
    }

    It 'for windows on a healthy disk returns an empty plan' {
        $plan = & $newPlan 'windows' $false $false
        $plan | Should -HaveCount 0
    }

    It 'never places a mount before its offline step' {
        $plan = & $newPlan 'wsl' $false $false
        $kinds = @($plan | ForEach-Object Kind)
        [array]::IndexOf($kinds, 'OfflineDisk') |
            Should -BeLessThan ([array]::IndexOf($kinds, 'WslMount'))
    }

    It 'never places an online before its unmount step' {
        $plan = & $newPlan 'windows' $true $true
        $kinds = @($plan | ForEach-Object Kind)
        [array]::IndexOf($kinds, 'WslUnmount') |
            Should -BeLessThan ([array]::IndexOf($kinds, 'OnlineDisk'))
    }

    It 'carries the disk number and partition index on every step' {
        $plan = & $newPlan 'wsl' $false $false 7
        foreach ($step in $plan) {
            $step.DiskNumber | Should -Be 3
            if ($step.Kind -in @('WslMount', 'VerifyWslMount')) {
                $step.PartitionIndex | Should -Be 7
            }
        }
    }
}

Describe 'Format-Step' {
    It 'renders the offline command' {
        Format-Step ([pscustomobject]@{ Kind = 'OfflineDisk'; DiskNumber = 3 }) |
            Should -Be 'Set-Disk -Number 3 -IsOffline $true'
    }
    It 'renders the online command' {
        Format-Step ([pscustomobject]@{ Kind = 'OnlineDisk'; DiskNumber = 3 }) |
            Should -Be 'Set-Disk -Number 3 -IsOffline $false'
    }
    It 'renders the wsl mount command with 1-based partition and ext4' {
        Format-Step ([pscustomobject]@{ Kind = 'WslMount'; DiskNumber = 3; PartitionIndex = 2 }) |
            Should -Be 'wsl.exe --mount \\.\PHYSICALDRIVE3 --partition 2 --type ext4'
    }
    It 'renders the path-scoped unmount command' {
        Format-Step ([pscustomobject]@{ Kind = 'WslUnmount'; DiskNumber = 3 }) |
            Should -Be 'wsl.exe --unmount \\.\PHYSICALDRIVE3'
    }
    It 'renders the mount verification against the exact path' {
        Format-Step ([pscustomobject]@{ Kind = 'VerifyWslMount'; DiskNumber = 3; PartitionIndex = 2 }) |
            Should -Be 'wsl.exe -e ls /mnt/wsl/PHYSICALDRIVE3p2'
    }
}

Describe 'Format-ActionPlan' {
    It 'renders a wsl plan as the exact command sequence' {
        $plan = Get-ActionPlan -Action 'wsl' -DiskNumber 3 -PartitionIndex 2 `
                               -DiskIsOffline $false -WslMounted $false
        Format-ActionPlan -Plan $plan | Should -Be @(
            'Set-Disk -Number 3 -IsOffline $true'
            'wsl.exe --mount \\.\PHYSICALDRIVE3 --partition 2 --type ext4'
            'wsl.exe -e ls /mnt/wsl/PHYSICALDRIVE3p2'
        )
    }

    It 'renders a windows plan as the exact command sequence' {
        $plan = Get-ActionPlan -Action 'windows' -DiskNumber 3 -PartitionIndex 2 `
                               -DiskIsOffline $true -WslMounted $true
        Format-ActionPlan -Plan $plan | Should -Be @(
            'wsl.exe --unmount \\.\PHYSICALDRIVE3'
            'Set-Disk -Number 3 -IsOffline $false'
            'Get-Disk -Number 3 | Where-Object IsOffline'
        )
    }

    It 'renders an empty plan as an empty array' {
        $plan = Get-ActionPlan -Action 'wsl' -DiskNumber 3 -PartitionIndex 2 `
                               -DiskIsOffline $true -WslMounted $true
        Format-ActionPlan -Plan $plan | Should -HaveCount 0
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `./windows/tests/run.sh`
Expected: FAIL with `Get-ActionPlan : The term 'Get-ActionPlan' is not recognized`

- [ ] **Step 3: Implement the plan builders**

Insert after `Get-DiskMode` in `windows/disk-switch.ps1`:

```powershell
function Get-ActionPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('wsl', 'windows')][string]$Action,
        [Parameter(Mandatory)][int]$DiskNumber,
        [Parameter(Mandatory)][int]$PartitionIndex,
        [Parameter(Mandatory)][bool]$DiskIsOffline,
        [Parameter(Mandatory)][bool]$WslMounted
    )

    $plan = @()

    if ($Action -eq 'wsl') {
        if ($WslMounted) { return @() }
        if (-not $DiskIsOffline) {
            $plan += [pscustomobject]@{ Kind = 'OfflineDisk'; DiskNumber = $DiskNumber; PartitionIndex = $PartitionIndex }
        }
        $plan += [pscustomobject]@{ Kind = 'WslMount'; DiskNumber = $DiskNumber; PartitionIndex = $PartitionIndex }
        $plan += [pscustomobject]@{ Kind = 'VerifyWslMount'; DiskNumber = $DiskNumber; PartitionIndex = $PartitionIndex }
        return $plan
    }

    if (-not $WslMounted -and -not $DiskIsOffline) { return @() }
    if ($WslMounted) {
        $plan += [pscustomobject]@{ Kind = 'WslUnmount'; DiskNumber = $DiskNumber; PartitionIndex = $PartitionIndex }
    }
    if ($DiskIsOffline) {
        $plan += [pscustomobject]@{ Kind = 'OnlineDisk'; DiskNumber = $DiskNumber; PartitionIndex = $PartitionIndex }
    }
    $plan += [pscustomobject]@{ Kind = 'VerifyDiskOnline'; DiskNumber = $DiskNumber; PartitionIndex = $PartitionIndex }
    return $plan
}

function Format-Step {
    [CmdletBinding()]
    param([Parameter(Mandatory)][object]$Step)

    switch ($Step.Kind) {
        'OfflineDisk' {
            return 'Set-Disk -Number {0} -IsOffline $true' -f $Step.DiskNumber
        }
        'OnlineDisk' {
            return 'Set-Disk -Number {0} -IsOffline $false' -f $Step.DiskNumber
        }
        'WslMount' {
            return 'wsl.exe --mount \\.\PHYSICALDRIVE{0} --partition {1} --type ext4' -f `
                $Step.DiskNumber, $Step.PartitionIndex
        }
        'WslUnmount' {
            return 'wsl.exe --unmount \\.\PHYSICALDRIVE{0}' -f $Step.DiskNumber
        }
        'VerifyWslMount' {
            return 'wsl.exe -e ls {0}' -f (
                Get-WslMountPath -DiskNumber $Step.DiskNumber -PartitionIndex $Step.PartitionIndex
            )
        }
        'VerifyDiskOnline' {
            return 'Get-Disk -Number {0} | Where-Object IsOffline' -f $Step.DiskNumber
        }
        default {
            return 'unknown plan step: {0}' -f $Step.Kind
        }
    }
}

function Format-ActionPlan {
    [CmdletBinding()]
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Plan)
    return @($Plan | ForEach-Object { Format-Step -Step $_ })
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `./windows/tests/run.sh`
Expected: PASS — all Task 1 and Task 2 tests green, analyzer clean.

- [ ] **Step 5: Commit**

```bash
git add windows/disk-switch.ps1 windows/tests/disk-switch.Tests.ps1
git commit -m "feat(windows): add ordered action plan and dry-run renderer"
```

---

### Task 3: Candidate detection — pure formatting and filtering

**Files:**
- Modify: `windows/disk-switch.ps1`
- Modify: `windows/tests/disk-switch.Tests.ps1`

**Interfaces:**
- Produces: `Test-CandidateDisk -Partitions <object[]> -> bool`; `Format-PartitionSummary -Partitions <object[]> -> string`; `Read-DiskSelection -Candidates <object[]> -Requested <int> -> object|$null`
- Partition object shape: `[pscustomobject]@{ PartitionNumber; DriveLetter; Size; FileSystem }` where `FileSystem` is `$null` when Windows cannot identify it (that is the ext4 partition)

- [ ] **Step 1: Write the failing tests**

```powershell
Describe 'Test-CandidateDisk' {
    BeforeAll {
        $part = {
            param([int]$N, [string]$Fs)
            [pscustomobject]@{ PartitionNumber = $N; DriveLetter = ''; Size = 1GB; FileSystem = $Fs }
        }
    }

    It 'accepts NTFS plus an unidentified (ext4) partition' {
        Test-CandidateDisk -Partitions @(& $part 1 'NTFS', (& $part 2 $null)) | Should -BeTrue
    }

    It 'accepts ReFS plus an unidentified partition' {
        Test-CandidateDisk -Partitions @(& $part 1 'ReFS', (& $part 2 '')) | Should -BeTrue
    }

    It 'rejects a disk with only NTFS' {
        Test-CandidateDisk -Partitions @(& $part 1 'NTFS') | Should -BeFalse
    }

    It 'rejects a disk with NTFS plus FAT32 (both are Windows filesystems)' {
        Test-CandidateDisk -Partitions @(& $part 1 'NTFS', (& $part 2 'FAT32')) | Should -BeFalse
    }

    It 'rejects a disk with no NTFS/ReFS partition' {
        Test-CandidateDisk -Partitions @(& $part 1 $null) | Should -BeFalse
    }

    It 'rejects an empty partition list' {
        Test-CandidateDisk -Partitions @() | Should -BeFalse
    }
}

Describe 'Format-PartitionSummary' {
    It 'renders the Windows and the ext4 side exactly as documented' {
        $parts = @(
            [pscustomobject]@{ PartitionNumber = 1; DriveLetter = 'E'; Size = 465.8GB; FileSystem = 'NTFS' }
            [pscustomobject]@{ PartitionNumber = 2; DriveLetter = '';   Size = 100GB;  FileSystem = $null }
        )
        Format-PartitionSummary -Partitions $parts |
            Should -Be '1:NTFS 465.8GB  |  2:no Windows FS'
    }

    It 'sorts by partition number' {
        $parts = @(
            [pscustomobject]@{ PartitionNumber = 2; DriveLetter = ''; Size = 1GB; FileSystem = $null }
            [pscustomobject]@{ PartitionNumber = 1; DriveLetter = 'D'; Size = 1GB; FileSystem = 'NTFS' }
        )
        (Format-PartitionSummary -Partitions $parts) -like '1:NTFS*' | Should -BeTrue
    }
}

Describe 'Read-DiskSelection' {
    BeforeAll {
        $script:Disks = @(
            [pscustomobject]@{ Number = 3; FriendlyName = 'T5' }
            [pscustomobject]@{ Number = 5; FriendlyName = 'Seagate' }
        )
    }

    It 'returns the disk matching a requested number' {
        (Read-DiskSelection -Candidates $script:Disks -Requested 5).FriendlyName | Should -Be 'Seagate'
    }

    It 'returns null when the requested number is not a candidate' {
        Read-DiskSelection -Candidates $script:Disks -Requested 0 | Should -BeNullOrEmpty
    }

    It 'returns null when there are no candidates' {
        Read-DiskSelection -Candidates @() -Requested -1 | Should -BeNullOrEmpty
    }

    It 'returns null when the user quits at the prompt' {
        Mock Read-Host { 'q' }
        Read-DiskSelection -Candidates $script:Disks -Requested -1 | Should -BeNullOrEmpty
    }

    It 'returns the chosen row when the user types its index' {
        Mock Read-Host { '1' }
        (Read-DiskSelection -Candidates $script:Disks -Requested -1).FriendlyName | Should -Be 'T5'
    }

    It 're-prompts on an out-of-range answer' {
        $script:Answers = @('99', '2')
        $script:Idx = 0
        Mock Read-Host {
            $a = $script:Answers[$script:Idx]
            $script:Idx++
            return $a
        }
        (Read-DiskSelection -Candidates $script:Disks -Requested -1).FriendlyName | Should -Be 'Seagate'
        $script:Idx | Should -Be 2
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `./windows/tests/run.sh`
Expected: FAIL with `Test-CandidateDisk : The term 'Test-CandidateDisk' is not recognized`

- [ ] **Step 3: Implement the filter and formatting**

Insert before `Get-ActionPlan`:

```powershell
$script:WindowsFileSystems = @('NTFS', 'ReFS', 'FAT', 'FAT32', 'exFAT', 'UDF', 'CDFS')

function Test-CandidateDisk {
    [CmdletBinding()]
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Partitions)

    $hasWindowsSide = $false
    $hasForeignSide = $false

    foreach ($p in $Partitions) {
        $fs = $p.FileSystem
        if ([string]::IsNullOrWhiteSpace($fs)) {
            $hasForeignSide = $true
        } elseif ($fs -in @('NTFS', 'ReFS')) {
            $hasWindowsSide = $true
        } elseif ($fs -notin $script:WindowsFileSystems) {
            $hasForeignSide = $true
        }
    }

    return ($hasWindowsSide -and $hasForeignSide)
}

function Format-PartitionSummary {
    [CmdletBinding()]
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Partitions)

    $parts = foreach ($p in ($Partitions | Sort-Object PartitionNumber)) {
        $label = if ([string]::IsNullOrWhiteSpace($p.FileSystem)) {
            'no Windows FS'
        } else {
            '{0} {1:N1}GB' -f $p.FileSystem, ($p.Size / 1GB)
        }
        '{0}:{1}' -f $p.PartitionNumber, $label
    }
    return ($parts -join '  |  ')
}

function Read-DiskSelection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Candidates,
        [int]$Requested = -1
    )

    if ($Candidates.Count -eq 0) { return $null }

    if ($Requested -ge 0) {
        $hit = @($Candidates | Where-Object { $_.Number -eq $Requested })
        if ($hit.Count -eq 0) { return $null }
        return $hit[0]
    }

    Write-Host ''
    Write-Host 'Candidate disks:'
    $i = 0
    foreach ($c in $Candidates) {
        $i++
        $size = '{0:N1} GB' -f ($c.Size / 1GB)
        Write-Host ('  {0}) [{1}] {2} {3}  {4}' -f `
            $i, $c.Number, $size.PadRight(9), $c.FriendlyName.PadRight(28),
            (Format-PartitionSummary -Partitions $c.Partitions))
    }

    while ($true) {
        $answer = Read-Host ('Select disk [1-{0}], q to quit' -f $Candidates.Count)
        if ($answer -match '^[Qq]$') { return $null }
        $n = 0
        if ([int]::TryParse($answer, [ref]$n) -and $n -ge 1 -and $n -le $Candidates.Count) {
            return $Candidates[$n - 1]
        }
        Write-Host 'Please enter a number from the list, or q to quit.'
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `./windows/tests/run.sh`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add windows/disk-switch.ps1 windows/tests/disk-switch.Tests.ps1
git commit -m "feat(windows): add candidate filter, partition summary, disk picker"
```

---

### Task 4: Candidate discovery — the impure layer

**Files:**
- Modify: `windows/disk-switch.ps1`
- Modify: `windows/tests/disk-switch.Tests.ps1`

**Interfaces:**
- Consumes: `Test-CandidateDisk`, `Format-PartitionSummary` (Task 3)
- Produces: `Get-DiskCandidates -> object[]` with fields `Number, Path, FriendlyName, BusType, Size, IsOffline, PartitionStyle, Partitions`
- Produces: `Get-PartitionFileSystem -Partition <object> -> string|$null`
- Produces: `Invoke-WslCommand -WslArgs <string[]> -> @{Output; ExitCode}` and `Test-WslDiskAttached -DiskNumber <int> -> bool`

- [ ] **Step 1: Write the failing tests**

```powershell
Describe 'Get-PartitionFileSystem' {
    It 'returns the filesystem when Get-Volume reports one' {
        Mock Get-Volume { [pscustomobject]@{ FileSystem = 'NTFS' } }
        Get-PartitionFileSystem -Partition ([pscustomobject]@{}) | Should -Be 'NTFS'
    }

    It 'returns null when Get-Volume reports a blank filesystem' {
        Mock Get-Volume { [pscustomobject]@{ FileSystem = '   ' } }
        Get-PartitionFileSystem -Partition ([pscustomobject]@{}) | Should -BeNullOrEmpty
    }

    It 'returns null when Get-Volume throws (partition Windows cannot read)' {
        Mock Get-Volume { throw 'No MSFT_Volume objects found' }
        Get-PartitionFileSystem -Partition ([pscustomobject]@{}) | Should -BeNullOrEmpty
    }
}

Describe 'Get-DiskCandidates' {
    BeforeAll {
        # Storage cmdlets do not exist on Linux; define stubs so Pester can Mock them.
        function Get-Disk { param($Number) }
        function Get-Partition { param($DiskNumber, $DriveLetter) }
        function Get-Volume { param($Partition) }
    }

    BeforeEach {
        $script:WindowsDisk = 0
        $script:PartitionsOf = @{}

        Mock Get-Partition {
            param($DiskNumber, $DriveLetter)
            if ($PSBoundParameters.ContainsKey('DriveLetter')) {
                return [pscustomobject]@{ DiskNumber = $script:WindowsDisk }
            }
            return $script:PartitionsOf[[int]$DiskNumber]
        }
        Mock Get-Volume {
            param($Partition)
            if ([string]::IsNullOrWhiteSpace([string]$Partition.FileSystem)) {
                return [pscustomobject]@{ FileSystem = '' }
            }
            return [pscustomobject]@{ FileSystem = $Partition.FileSystem }
        }
    }

    It 'excludes boot, system and cluster disks' {
        Mock Get-Disk {
            [pscustomobject]@{ Number = 1; FriendlyName = 'Boot'; BusType = 'NVMe'; Size = 1GB
                               IsOffline = $false; IsBoot = $true; IsSystem = $false; IsClustered = $false }
        }
        Get-DiskCandidates | Should -HaveCount 0
    }

    It 'excludes the disk holding the Windows volume' {
        $script:WindowsDisk = 4
        Mock Get-Disk {
            [pscustomobject]@{ Number = 4; FriendlyName = 'Windows'; BusType = 'NVMe'; Size = 1GB
                               IsOffline = $false; IsBoot = $false; IsSystem = $false; IsClustered = $false }
        }
        $script:PartitionsOf = @{
            4 = @(
                [pscustomobject]@{ PartitionNumber = 1; DriveLetter = 'C'; Size = 100GB; FileSystem = 'NTFS' }
                [pscustomobject]@{ PartitionNumber = 2; DriveLetter = '';   Size = 50GB;  FileSystem = $null }
            )
        }
        Get-DiskCandidates | Should -HaveCount 0
    }

    It 'includes an online removable disk with NTFS plus an ext4 partition' {
        Mock Get-Disk {
            [pscustomobject]@{ Number = 3; FriendlyName = 'Samsung Portable SSD T5'; BusType = 'USB'
                               Size = 500GB; IsOffline = $false; IsBoot = $false; IsSystem = $false; IsClustered = $false }
        }
        $script:PartitionsOf = @{
            3 = @(
                [pscustomobject]@{ PartitionNumber = 1; DriveLetter = 'E'; Size = 465GB; FileSystem = 'NTFS' }
                [pscustomobject]@{ PartitionNumber = 2; DriveLetter = '';   Size = 35GB;  FileSystem = $null }
            )
        }
        $c = Get-DiskCandidates
        $c | Should -HaveCount 1
        $c[0].Number | Should -Be 3
        $c[0].Path | Should -Be '\\.\PHYSICALDRIVE3'
        $c[0].Partitions.Count | Should -Be 2
    }

    It 'includes a disk that is already offline (state is visible either way)' {
        Mock Get-Disk {
            [pscustomobject]@{ Number = 3; FriendlyName = 'T5'; BusType = 'USB'; Size = 500GB
                               IsOffline = $true; IsBoot = $false; IsSystem = $false; IsClustered = $false }
        }
        $script:PartitionsOf = @{
            3 = @(
                [pscustomobject]@{ PartitionNumber = 1; DriveLetter = ''; Size = 465GB; FileSystem = 'NTFS' }
                [pscustomobject]@{ PartitionNumber = 2; DriveLetter = ''; Size = 35GB;  FileSystem = $null }
            )
        }
        $c = Get-DiskCandidates
        $c | Should -HaveCount 1
        $c[0].IsOffline | Should -BeTrue
    }
}

Describe 'Test-WslDiskAttached' {
    It 'is true when the WSL glob resolves' {
        Mock Invoke-WslCommand { [pscustomobject]@{ Output = ''; ExitCode = 0 } }
        Test-WslDiskAttached -DiskNumber 3 | Should -BeTrue
    }
    It 'is false when the WSL glob does not resolve' {
        Mock Invoke-WslCommand { [pscustomobject]@{ Output = ''; ExitCode = 2 } }
        Test-WslDiskAttached -DiskNumber 3 | Should -BeFalse
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `./windows/tests/run.sh`
Expected: FAIL with `Get-PartitionFileSystem : The term 'Get-PartitionFileSystem' is not recognized`

- [ ] **Step 3: Implement discovery**

Insert before `Test-CandidateDisk`:

```powershell
function Invoke-WslCommand {
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$WslArgs)
    $out = & wsl.exe @WslArgs 2>&1
    return [pscustomobject]@{ Output = ($out | Out-String); ExitCode = $LASTEXITCODE }
}

function Get-PartitionFileSystem {
    [CmdletBinding()]
    param([Parameter(Mandatory)][object]$Partition)

    try {
        $vol = Get-Volume -Partition $Partition -ErrorAction Stop
        if ($null -eq $vol) { return $null }
        if ([string]::IsNullOrWhiteSpace($vol.FileSystem)) { return $null }
        return $vol.FileSystem
    } catch {
        return $null
    }
}

function Test-WslDiskAttached {
    [CmdletBinding()]
    param([Parameter(Mandatory)][int]$DiskNumber)

    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) { return $false }
    $probe = 'ls -d /mnt/wsl/PHYSICALDRIVE{0}p* >/dev/null 2>&1' -f $DiskNumber
    $result = Invoke-WslCommand -e sh -c $probe
    return ($result.ExitCode -eq 0)
}

function Get-DiskCandidates {
    [CmdletBinding()]
    param()

    $windowsDiskNumber = $null
    $winDrive = ($env:SystemDrive -replace ':$', '')
    if ($winDrive) {
        $winPartition = Get-Partition -DriveLetter $winDrive -ErrorAction SilentlyContinue
        if ($winPartition) { $windowsDiskNumber = [int]$winPartition.DiskNumber }
    }

    $candidates = @()
    foreach ($disk in @(Get-Disk -ErrorAction Stop)) {
        if ($disk.IsBoot -or $disk.IsSystem -or $disk.IsClustered) { continue }
        if ($null -ne $windowsDiskNumber -and [int]$disk.Number -eq $windowsDiskNumber) { continue }

        $parts = @(Get-Partition -DiskNumber $disk.Number -ErrorAction SilentlyContinue)
        if ($parts.Count -eq 0) { continue }

        $detail = @(
            foreach ($p in $parts) {
                [pscustomobject]@{
                    PartitionNumber = [int]$p.PartitionNumber
                    DriveLetter     = if ($p.DriveLetter) { [string]$p.DriveLetter } else { '' }
                    Size            = [int64]$p.Size
                    FileSystem      = Get-PartitionFileSystem -Partition $p
                }
            }
        )

        if (-not (Test-CandidateDisk -Partitions $detail)) { continue }

        $candidates += [pscustomobject]@{
            Number         = [int]$disk.Number
            Path           = '\\.\PHYSICALDRIVE{0}' -f $disk.Number
            FriendlyName   = [string]$disk.FriendlyName
            BusType        = [string]$disk.BusType
            Size           = [int64]$disk.Size
            IsOffline      = [bool]$disk.IsOffline
            PartitionStyle = [string]$disk.PartitionStyle
            Partitions     = $detail
        }
    }
    return $candidates
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `./windows/tests/run.sh`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add windows/disk-switch.ps1 windows/tests/disk-switch.Tests.ps1
git commit -m "feat(windows): add disk discovery and WSL attachment probe"
```

---

### Task 5: Execution — real commands, real error mapping

**Files:**
- Modify: `windows/disk-switch.ps1`
- Modify: `windows/tests/disk-switch.Tests.ps1`

**Interfaces:**
- Consumes: `Get-ActionPlan`, `Format-Step`, `Get-WslMountPath` (Task 2), `Invoke-WslCommand` (Task 4)
- Produces: `Invoke-ActionPlan -Plan <object[]> [-WhatIf]` (throws on failure); `New-WslMountError -DiskNumber -ExitCode -Output -> string`; `New-SetDiskError -DiskNumber -ErrorRecord -> string`

- [ ] **Step 1: Write the failing tests**

```powershell
Describe 'New-WslMountError' {
    It 'explains a sharing violation (0x80070020)' {
        $msg = New-WslMountError -DiskNumber 3 -ExitCode 1 `
               -Output 'The process cannot access the file because it is being used by another process. Error code: Wsl/Service/AttachDisk/0x80070020'
        $msg | Should -Match 'still in use by Windows'
    }

    It 'names the USB flash drive limitation (0x8007000f)' {
        $msg = New-WslMountError -DiskNumber 3 -ExitCode 1 `
               -Output 'The system cannot find the drive specified. Error code: Wsl/Service/AttachDisk/0x8007000f'
        $msg | Should -Match '6011'
        $msg | Should -Match 'usbipd'
    }

    It 'falls back to a dmesg hint for any other failure' {
        $msg = New-WslMountError -DiskNumber 3 -ExitCode 22 -Output 'some other error'
        $msg | Should -Match 'dmesg'
    }
}

Describe 'Invoke-ActionPlan' {
    BeforeEach {
        $script:Calls = @()
        $script:WslExit = 0

        Mock Set-Disk { $script:Calls += "Set-Disk:$($Number):$IsOffline" }
        Mock Get-Disk {
            $script:Calls += "Get-Disk:$($Number)"
            [pscustomobject]@{
                Number   = $Number
                IsOffline = ($script:Calls -contains "Set-Disk:$($Number):True")
            }
        }
        Mock Invoke-WslCommand {
            $script:Calls += ('Wsl:' + ($WslArgs -join ' '))
            [pscustomobject]@{ Output = ''; ExitCode = $script:WslExit }
        }
    }

    It 'offlines the disk before mounting it' {
        $plan = Get-ActionPlan -Action 'wsl' -DiskNumber 3 -PartitionIndex 2 `
                               -DiskIsOffline $false -WslMounted $false
        Invoke-ActionPlan -Plan $plan

        $setIdx   = [array]::IndexOf($script:Calls, 'Set-Disk:3:True')
        $mountIdx = -1
        for ($i = 0; $i -lt $script:Calls.Count; $i++) {
            if ($script:Calls[$i] -like 'Wsl:--mount*') { $mountIdx = $i; break }
        }
        $setIdx   | Should -BeGreaterOrEqual 0
        $mountIdx | Should -BeGreaterThan $setIdx
    }

    It 'unmounts from WSL before onlining the disk' {
        $plan = Get-ActionPlan -Action 'windows' -DiskNumber 3 -PartitionIndex 2 `
                               -DiskIsOffline $true -WslMounted $true
        Invoke-ActionPlan -Plan $plan

        $unmountIdx = -1
        $onlineIdx  = [array]::IndexOf($script:Calls, 'Set-Disk:3:False')
        for ($i = 0; $i -lt $script:Calls.Count; $i++) {
            if ($script:Calls[$i] -like 'Wsl:--unmount*') { $unmountIdx = $i; break }
        }
        $unmountIdx | Should -BeGreaterOrEqual 0
        $onlineIdx  | Should -BeGreaterThan $unmountIdx
    }

    It 'throws a named error when wsl --mount reports a sharing violation' {
        Mock Invoke-WslCommand {
            [pscustomobject]@{ Output = 'Error code: Wsl/Service/AttachDisk/0x80070020'; ExitCode = 1 }
        }
        $plan = Get-ActionPlan -Action 'wsl' -DiskNumber 3 -PartitionIndex 2 `
                               -DiskIsOffline $true -WslMounted $false
        { Invoke-ActionPlan -Plan $plan } | Should -Throw '*still in use by Windows*'
    }

    It 'tolerates a failing wsl --unmount and continues to online the disk' {
        Mock Invoke-WslCommand {
            $script:Calls += ('Wsl:' + ($WslArgs -join ' '))
            if ($WslArgs[0] -eq '--unmount') { return [pscustomobject]@{ Output = 'nope'; ExitCode = 1 } }
            return [pscustomobject]@{ Output = ''; ExitCode = 0 }
        }
        $plan = Get-ActionPlan -Action 'windows' -DiskNumber 3 -PartitionIndex 2 `
                               -DiskIsOffline $true -WslMounted $true
        { Invoke-ActionPlan -Plan $plan } | Should -Not -Throw
        $script:Calls | Should -Contain 'Set-Disk:3:False'
    }

    It 'throws when Set-Disk fails because files are open' {
        Mock Set-Disk { throw 'Access denied because the disk is in use' }
        $plan = Get-ActionPlan -Action 'wsl' -DiskNumber 3 -PartitionIndex 2 `
                               -DiskIsOffline $false -WslMounted $false
        { Invoke-ActionPlan -Plan $plan } | Should -Throw '*still has files open*'
    }

    It 'does nothing for an empty plan' {
        { Invoke-ActionPlan -Plan @() } | Should -Not -Throw
        Should -Invoke Set-Disk -Times 0 -Exactly
        Should -Invoke Invoke-WslCommand -Times 0 -Exactly
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `./windows/tests/run.sh`
Expected: FAIL with `New-WslMountError : The term 'New-WslMountError' is not recognized`

- [ ] **Step 3: Implement the executors**

Insert after `Format-ActionPlan`:

```powershell
function New-WslMountError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$DiskNumber,
        [Parameter(Mandatory)][int]$ExitCode,
        [AllowEmptyString()][string]$Output = ''
    )

    $text = $Output.Trim()
    $hint = if ($text -match '0x80070020') {
        'The disk is still in use by Windows. Close every program holding files on it, then run "windows" followed by "wsl" again.'
    } elseif ($text -match '0x8007000f') {
        'wsl --mount could not open the disk. On USB flash drives and SD readers this is the known limitation ' +
        'github.com/microsoft/WSL/issues/6011 - use usbipd-win instead. Otherwise the disk number may have ' +
        'changed: run "status" and retry with -DiskNumber.'
    } else {
        'Run "wsl.exe -e dmesg | tail -n 20" inside WSL for kernel details.'
    }

    return ('wsl --mount of disk {0} failed (exit code {1}).' + [Environment]::NewLine +
            '  {2}' + [Environment]::NewLine + '  {3}') -f $DiskNumber, $ExitCode, $text, $hint
}

function New-SetDiskError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$DiskNumber,
        [Parameter(Mandatory)][System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    $msg = $ErrorRecord.Exception.Message
    if ($msg -match 'in use|being used|cannot access|denied') {
        return ('Cannot change the online state of disk {0}: it still has files open. ' +
                'Close Explorer windows and any application using its drive letters, then retry.') -f $DiskNumber
    }
    return ('Failed to change the online state of disk {0}: {1}') -f $DiskNumber, $msg
}

function Invoke-ActionPlan {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Plan)

    foreach ($step in $Plan) {
        $label = Format-Step -Step $step
        Write-Host ('> ' + $label)

        switch ($step.Kind) {
            'OfflineDisk' {
                if ($PSCmdlet.ShouldProcess($label)) {
                    try {
                        Set-Disk -Number $step.DiskNumber -IsOffline $true -ErrorAction Stop
                    } catch {
                        throw (New-SetDiskError -DiskNumber $step.DiskNumber -ErrorRecord $_)
                    }
                    $after = Get-Disk -Number $step.DiskNumber -ErrorAction Stop
                    if (-not $after.IsOffline) {
                        throw ('Set-Disk did not take disk {0} offline.' -f $step.DiskNumber)
                    }
                }
            }
            'OnlineDisk' {
                if ($PSCmdlet.ShouldProcess($label)) {
                    Set-Disk -Number $step.DiskNumber -IsOffline $false -ErrorAction Stop
                    $after = Get-Disk -Number $step.DiskNumber -ErrorAction Stop
                    if ($after.IsOffline) {
                        throw ('Set-Disk did not bring disk {0} online.' -f $step.DiskNumber)
                    }
                }
            }
            'WslMount' {
                if ($PSCmdlet.ShouldProcess($label)) {
                    $result = Invoke-WslCommand --mount ('\\.\PHYSICALDRIVE{0}' -f $step.DiskNumber) `
                                                 --partition $step.PartitionIndex --type ext4
                    if ($result.ExitCode -ne 0) {
                        throw (New-WslMountError -DiskNumber $step.DiskNumber `
                                                  -ExitCode $result.ExitCode -Output $result.Output)
                    }
                }
            }
            'WslUnmount' {
                if ($PSCmdlet.ShouldProcess($label)) {
                    $result = Invoke-WslCommand --unmount ('\\.\PHYSICALDRIVE{0}' -f $step.DiskNumber)
                    if ($result.ExitCode -ne 0) {
                        Write-Warning 'wsl --unmount returned a non-zero exit; the disk may not have been attached. Continuing.'
                    }
                }
            }
            'VerifyWslMount' {
                $path = Get-WslMountPath -DiskNumber $step.DiskNumber -PartitionIndex $step.PartitionIndex
                $result = Invoke-WslCommand -e ls $path
                if ($result.ExitCode -ne 0) {
                    throw ('Disk {0} reports mounted, but {1} is not readable inside WSL.' -f $step.DiskNumber, $path)
                }
            }
            'VerifyDiskOnline' {
                $after = Get-Disk -Number $step.DiskNumber -ErrorAction Stop
                if ($after.IsOffline) {
                    throw ('Disk {0} is still offline.' -f $step.DiskNumber)
                }
            }
            default {
                throw ('Unknown plan step: {0}' -f $step.Kind)
            }
        }
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `./windows/tests/run.sh`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add windows/disk-switch.ps1 windows/tests/disk-switch.Tests.ps1
git commit -m "feat(windows): execute plan steps with verified state changes and error mapping"
```

---

### Task 6: Orchestration, preflight, elevation, exit codes

**Files:**
- Modify: `windows/disk-switch.ps1`
- Modify: `windows/tests/disk-switch.Tests.ps1`

**Interfaces:**
- Consumes: everything from Tasks 1–5
- Produces: `Invoke-SwitchAction ... -> int`; `Invoke-StatusAction -Candidates -> int`; `Assert-WslAvailable`; `Test-IsAdministrator -> bool`; `Start-Elevation -ArgumentList <string[]>`; `Confirm-DiskAction ... -> bool`; full `Main`

- [ ] **Step 1: Write the failing tests**

```powershell
Describe 'Main' {
    BeforeEach {
        Mock Test-IsAdministrator { $true }
        Mock Assert-WslAvailable { }
        Mock Get-DiskCandidates { @(
            [pscustomobject]@{
                Number = 3; Path = '\\.\PHYSICALDRIVE3'; FriendlyName = 'T5'; BusType = 'USB'
                Size = 500GB; IsOffline = $false; PartitionStyle = 'GPT'
                Partitions = @(
                    [pscustomobject]@{ PartitionNumber = 1; DriveLetter = 'E'; Size = 465GB; FileSystem = 'NTFS' }
                    [pscustomobject]@{ PartitionNumber = 2; DriveLetter = '';   Size = 35GB;  FileSystem = $null }
                )
            }
        ) }
        Mock Read-DiskSelection { $script:Pick }
        Mock Confirm-DiskAction { $true }
        Mock Test-WslDiskAttached { $false }
        Mock Invoke-ActionPlan { $script:Executed = $true }
        $script:Pick = $null
        $script:Executed = $false
    }

    It 'returns 1 and prints usage when no action is given' {
        Main -Action '' | Should -Be 1
    }

    It 'returns 2 when no candidate disks are found' {
        Mock Get-DiskCandidates { @() }
        Main -Action 'wsl' | Should -Be 2
    }

    It 'requests elevation when not running as administrator' {
        Mock Test-IsAdministrator { $false }
        Mock Start-Elevation { }
        Main -Action 'wsl' | Should -Be 1
        Should -Invoke Start-Elevation -Times 1 -Exactly
        Should -Invoke Get-DiskCandidates -Times 0 -Exactly
    }

    It 'skips the WSL preflight for status' {
        Main -Action 'status' | Should -Be 0
        Should -Invoke Assert-WslAvailable -Times 0 -Exactly
    }

    It 'runs the WSL preflight for wsl and windows' {
        Main -Action 'wsl' | Should -Be 0
        Should -Invoke Assert-WslAvailable -Times 1 -Exactly
    }

    It 'returns 0 without executing when the disk is already in Windows mode' {
        $script:Pick = Get-DiskCandidates | Select-Object -First 1
        Main -Action 'windows' | Should -Be 0
        $script:Executed | Should -BeFalse
    }

    It 'executes nothing in dry-run mode' {
        $script:Pick = Get-DiskCandidates | Select-Object -First 1
        Main -Action 'wsl' -DryRun | Should -Be 0
        Should -Invoke Invoke-ActionPlan -Times 0 -Exactly
    }

    It 'executes the plan when moving the disk to WSL' {
        $script:Pick = Get-DiskCandidates | Select-Object -First 1
        Main -Action 'wsl' | Should -Be 0
        Should -Invoke Invoke-ActionPlan -Times 1 -Exactly
    }

    It 'propagates a thrown execution error' {
        $script:Pick = Get-DiskCandidates | Select-Object -First 1
        Mock Invoke-ActionPlan { throw 'boom' }
        { Main -Action 'wsl' } | Should -Throw 'boom'
    }
}

Describe 'Assert-WslAvailable' {
    It 'throws when wsl.exe is missing' {
        Mock Get-Command { $null } -ParameterFilter { $Name -eq 'wsl.exe' }
        { Assert-WslAvailable } | Should -Throw '*wsl.exe not found*'
    }

    It 'throws when the default version is confirmed to be 1' {
        Mock Get-Command { [pscustomobject]@{} } -ParameterFilter { $Name -eq 'wsl.exe' }
        Mock Invoke-WslCommand { [pscustomobject]@{ Output = "Default Version: 1`n"; ExitCode = 0 } }
        { Assert-WslAvailable } | Should -Throw '*set-default-version 2*'
    }

    It 'passes when the default version is 2' {
        Mock Get-Command { [pscustomobject]@{} } -ParameterFilter { $Name -eq 'wsl.exe' }
        Mock Invoke-WslCommand { [pscustomobject]@{ Output = "Default Version: 2`n"; ExitCode = 0 } }
        { Assert-WslAvailable } | Should -Not -Throw
    }

    It 'passes when --status is unparseable but --version confirms WSL 2' {
        Mock Get-Command { [pscustomobject]@{} } -ParameterFilter { $Name -eq 'wsl.exe' }
        Mock Invoke-WslCommand {
            if ($WslArgs -contains '--version') {
                return [pscustomobject]@{ Output = 'WSL version: 2.4.13.0'; ExitCode = 0 }
            }
            return [pscustomobject]@{ Output = ''; ExitCode = 0 }
        }
        { Assert-WslAvailable } | Should -Not -Throw
    }

    It 'throws when neither check confirms WSL 2' {
        Mock Get-Command { [pscustomobject]@{} } -ParameterFilter { $Name -eq 'wsl.exe' }
        Mock Invoke-WslCommand { [pscustomobject]@{ Output = ''; ExitCode = 1 } }
        { Assert-WslAvailable } | Should -Throw '*Unable to confirm WSL 2*'
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `./windows/tests/run.sh`
Expected: FAIL — `Main` still prints `TODO: implement action`.

- [ ] **Step 3: Implement preflight, elevation, and the actions**

Insert before `Main`:

```powershell
function Test-IsAdministrator {
    [CmdletBinding()]
    param()
    try {
        $identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
        return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

function Start-Elevation {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string[]]$ArgumentList)

    $exe = (Get-Process -Id $PID).ProcessName
    if ($exe -notin @('powershell', 'pwsh')) { $exe = 'powershell' }

    Write-Host 'Administrator privileges are required - relaunching elevated...'
    try {
        Start-Process -FilePath $exe -Verb RunAs -ArgumentList $ArgumentList -ErrorAction Stop | Out-Null
    } catch {
        throw 'Administrator privileges are required. Re-run from an elevated PowerShell prompt.'
    }
    exit 0
}

function Assert-WslAvailable {
    [CmdletBinding()]
    param()

    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
        throw 'wsl.exe not found. Install WSL first: wsl --install'
    }

    $status = (Invoke-WslCommand --status).Output
    if ($status -match 'Default Version:\s*1') {
        throw 'The default WSL version is 1; wsl --mount requires WSL 2. Run: wsl --set-default-version 2'
    }
    if ($status -match 'Default Version:\s*2') { return }

    $version = (Invoke-WslCommand --version).Output
    if ($version -match 'WSL version:\s*2\.') {
        Write-Warning 'Could not parse the default WSL version from "wsl --status"; continuing because wsl --version reports WSL 2.'
        return
    }

    throw 'Unable to confirm WSL 2 is installed. Run "wsl --version" and "wsl --update".'
}

function Confirm-DiskAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$Disk,
        [Parameter(Mandatory)][string]$Action,
        [Parameter(Mandatory)][int]$PartitionIndex,
        [bool]$DryRun = $false
    )

    if ($DryRun) { return $true }

    Write-Host ''
    Write-Host ('Disk {0} ({1}, {2})' -f $Disk.Number, $Disk.FriendlyName, $Disk.Path)

    if ($Action -eq 'wsl') {
        Write-Host ('  will be OFFLINED in Windows; partition {0} mounted in WSL.' -f $PartitionIndex)
        $letters = @($Disk.Partitions | Where-Object { $_.DriveLetter } | ForEach-Object { $_.DriveLetter + ':' })
        if ($letters.Count -gt 0) {
            Write-Host ('  Close any open files on {0} first.' -f ($letters -join ', '))
        }
    } else {
        Write-Host '  will be detached from WSL and brought ONLINE in Windows.'
    }

    $answer = Read-Host 'Proceed? [Y/n]'
    return ($answer -eq '' -or $answer -match '^[Yy]')
}

function Invoke-SwitchAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('wsl', 'windows')][string]$Action,
        [Parameter(Mandatory)][object[]]$Candidates,
        [int]$RequestedDisk = -1,
        [int]$PartitionIndex = 2,
        [switch]$DryRun
    )

    $disk = Read-DiskSelection -Candidates $Candidates -Requested $RequestedDisk
    if ($null -eq $disk) {
        if ($RequestedDisk -ge 0) {
            throw ('Disk {0} is not a candidate. It is either the system disk, lacks an NTFS partition, ' +
                   'or lacks a partition Windows cannot read. Run "status" to inspect.') -f $RequestedDisk
        }
        Write-Host 'No disk selected.'
        return 1
    }

    if (-not (Confirm-DiskAction -Disk $disk -Action $Action -PartitionIndex $PartitionIndex -DryRun:$DryRun)) {
        Write-Host 'Aborted.'
        return 1
    }

    $attached = Test-WslDiskAttached -DiskNumber $disk.Number
    $plan = Get-ActionPlan -Action $Action -DiskNumber $disk.Number -PartitionIndex $PartitionIndex `
                           -DiskIsOffline $disk.IsOffline -WslMounted $attached

    if ($plan.Count -eq 0) {
        if ($Action -eq 'wsl') {
            Write-Host ('Already in WSL mode: ' +
                (Get-WslMountPath -DiskNumber $disk.Number -PartitionIndex $PartitionIndex))
        } else {
            Write-Host 'Already in Windows mode (disk online, not attached to WSL).'
        }
        return 0
    }

    if ($DryRun) {
        Write-Host ''
        Write-Host 'Dry run - would execute:'
        foreach ($line in (Format-ActionPlan -Plan $plan)) {
            Write-Host ('  ' + $line)
        }
        return 0
    }

    Invoke-ActionPlan -Plan $plan

    if ($Action -eq 'wsl') {
        $path = Get-WslMountPath -DiskNumber $disk.Number -PartitionIndex $PartitionIndex
        Write-Host ''
        Write-Host ('Mounted partition {0} at {1}' -f $PartitionIndex, $path)
        Write-Host ('Reverse with:  .\disk-switch.ps1 windows -DiskNumber {0}' -f $disk.Number)
    } else {
        $letters = @(
            Get-Partition -DiskNumber $disk.Number -ErrorAction SilentlyContinue |
                Where-Object { $_.DriveLetter } |
                ForEach-Object { $_.DriveLetter + ':' }
        )
        Write-Host ''
        Write-Host 'Disk is back in Windows.'
        if ($letters.Count -gt 0) {
            Write-Host ('Available in Explorer: ' + ($letters -join ', '))
        }
    }
    return 0
}

function Invoke-StatusAction {
    [CmdletBinding()]
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Candidates)

    if ($Candidates.Count -eq 0) {
        Write-Host 'No candidate disks found.'
        return 2
    }

    foreach ($c in $Candidates) {
        $attached = Test-WslDiskAttached -DiskNumber $c.Number
        $mode     = Get-DiskMode -IsOffline $c.IsOffline -WslMounted $attached
        Write-Host ''
        Write-Host ('Disk {0}  {1}  ({2})  [{3}]' -f $c.Number, $c.FriendlyName, $c.BusType, $c.Path)
        Write-Host ('  mode: {0}   offline: {1}   partition style: {2}' -f $mode, $c.IsOffline, $c.PartitionStyle)
        Write-Host ('  partitions: ' + (Format-PartitionSummary -Partitions $c.Partitions))
        if ($mode -eq 'unknown') {
            Write-Host '  note: offline but not attached to WSL - a previous run was interrupted.'
            Write-Host '        Run ".\disk-switch.ps1 windows" to recover.'
        }
    }
    Write-Host ''
    return 0
}
```

Replace `Main` with:

```powershell
function Main {
    [CmdletBinding()]
    param(
        [string]$Action,
        [int]$DiskNumber = -1,
        [int]$PartitionIndex = 2,
        [switch]$DryRun
    )

    if ([string]::IsNullOrWhiteSpace($Action)) {
        Write-Host ''
        Write-Host 'Usage: .\disk-switch.ps1 <wsl|windows|status> [-DiskNumber <n>] [-PartitionIndex <n>] [-DryRun]'
        Write-Host ''
        return 1
    }

    if (-not (Test-IsAdministrator)) {
        $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, $Action)
        if ($DiskNumber -ge 0) { $argList += @('-DiskNumber', "$DiskNumber") }
        $argList += @('-PartitionIndex', "$PartitionIndex")
        if ($DryRun) { $argList += '-DryRun' }
        Start-Elevation -ArgumentList $argList
        return 1
    }

    if ($Action -ne 'status') { Assert-WslAvailable }

    $candidates = @(Get-DiskCandidates)

    if ($Action -eq 'status') {
        return Invoke-StatusAction -Candidates $candidates
    }

    if ($candidates.Count -eq 0) {
        Write-Host 'No candidate disks found.'
        Write-Host 'List every disk with:  Get-Disk | Format-Table Number,FriendlyName,BusType,Size,IsOffline'
        return 2
    }

    return Invoke-SwitchAction -Action $Action -Candidates $candidates `
                               -RequestedDisk $DiskNumber -PartitionIndex $PartitionIndex -DryRun:$DryRun
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `./windows/tests/run.sh`
Expected: PASS — all suites green, analyzer still clean.

- [ ] **Step 5: Commit**

```bash
git add windows/disk-switch.ps1 windows/tests/disk-switch.Tests.ps1
git commit -m "feat(windows): wire preflight, elevation, actions and exit codes"
```

---

### Task 7: Lint gate, README runbook, final verification

**Files:**
- Create: `windows/README.md`
- Modify: `windows/tests/run.sh` only if the lint gate is missing

**Interfaces:**
- Consumes: the finished script from Tasks 1–6

- [ ] **Step 1: Run the full suite and the analyzer**

Run: `./windows/tests/run.sh`
Expected: `Pester: ... Passed: N` with 0 failed, then `No analyzer findings.`

If PSScriptAnalyzer reports findings, the two most likely are:

| Rule | Fix |
|---|---|
| `PSUseShouldProcessForStateChangingFunctions` on `Invoke-ActionPlan` | verify `[CmdletBinding(SupportsShouldProcess)]` and the `if ($PSCmdlet.ShouldProcess($label))` guards are present |
| `PSUseApprovedVerbs` on any helper | rename to an approved verb (`Get`, `Set`, `Test`, `Invoke`, `Format`, `Read`, `Confirm`, `Assert`, `Start`, `New`) |

Fix each finding by editing the script, then re-run. Do not suppress with `SuppressMessageAttribute` unless the rule is provably wrong.

- [ ] **Step 2: Write the README with the manual runbook**

````markdown
# disk-switch.ps1

Moves a removable USB disk between Windows and WSL 2.

| Partition | Filesystem | Owner |
|---|---|---|
| 1 | NTFS | Windows — needs the disk online |
| 2 | ext4 | WSL — needs the disk offlined and attached |

Windows cannot mount ext4, and `wsl --mount` refuses a disk Windows still holds
open, so the disk can only be owned by one side at a time.

## Usage

Open PowerShell **as Administrator**:

```powershell
.\disk-switch.ps1 status                # inspect, change nothing
.\disk-switch.ps1 wsl                   # give the disk to WSL
.\disk-switch.ps1 windows               # give the disk back to Windows
.\disk-switch.ps1 wsl -DryRun           # print the exact commands, run nothing
.\disk-switch.ps1 wsl -DiskNumber 3     # skip the picker
```

Exit codes: `0` success or already in the requested state, `1` action failed,
`2` no candidate disks found.

## What each action does

`wsl` — offline the disk, then `wsl --mount \\.\PHYSICALDRIVE<n> --partition <p> --type ext4`,
verify the mount:

    /mnt/wsl/PHYSICALDRIVE<n>p<p>

`windows` — `wsl --unmount` first, *then* bring the disk online, then report the
drive letters that came back.

## Safety

- Boot, system and clustered disks are filtered out before you are prompted; the
  Windows volume's disk can never be selected.
- Every step is verified before the next runs, and each action is idempotent.
- Interrupted runs leave the disk offline but unattached. `status` reports this as
  `unknown`; run `.\disk-switch.ps1 windows` to recover.
- `windows` always unmounts before onlining, so a WSL-owned disk is never
  yanked out from under the kernel.

## Known limitation: USB flash drives

`wsl --mount` attaches USB **disks** (HDD/SSD enclosures) but fails on many USB
**flash** sticks and SD readers — see
[microsoft/WSL#6011](https://github.com/microsoft/WSL/issues/6011). The script
detects error `0x8007000f` after a successful offline and says so explicitly;
use `usbipd-win` in that case.

## Manual runbook (on Windows)

1. `.\disk-switch.ps1 status` — the disk is listed, `mode: windows`, both partitions shown.
2. Close any open files on the NTFS volume, then `.\disk-switch.ps1 wsl`.
3. In WSL: `ls /mnt/wsl/PHYSICALDRIVE<n>p2` shows your files.
4. `.\disk-switch.ps1 wsl` again — prints "Already in WSL mode" and exits 0.
5. `.\disk-switch.ps1 windows` — the NTFS partition returns with a drive letter in Explorer.
6. Failure drill: hold a file open on the NTFS volume, run `wsl` — clean error
   naming that drive letter, and the disk is left online.
7. Failure drill: run `status` from a non-elevated prompt — the elevation prompt appears.

## Tests

```bash
./windows/tests/run.sh
```

Runs Pester and PSScriptAnalyzer inside `mcr.microsoft.com/powershell` via Docker.
No Windows machine is needed; the Storage and `wsl.exe` cmdlets are mocked.
````

- [ ] **Step 3: Verify the runbook strings against the script**

Run: `grep -n "Already in WSL mode\|Already in Windows mode\|mode: \|Close any open files\|Available in Explorer" windows/disk-switch.ps1`
Expected: every string quoted in the README's runbook section appears in `windows/disk-switch.ps1`.

- [ ] **Step 4: Full verification**

Run: `./windows/tests/run.sh`
Expected: Pester all green, `No analyzer findings.`

Run: `grep -n "^  - windows" ansible/vars/common.yml`
Expected: no match — confirm the directory is not stowed.

- [ ] **Step 5: Commit**

```bash
git add windows/README.md windows/tests/run.sh
git commit -m "docs(windows): add disk-switch runbook and safety notes"
```

---

## Plan self-review

**1. Spec coverage**

| Spec section | Covered by |
|---|---|
| Placement (`windows/`, not stowed) | Global Constraints, Task 7 Step 4 |
| Interface + 3 params + exit codes | Task 1 (skeleton), Task 6 (`Main`), README |
| Detection (5 conditions) | Task 3 `Test-CandidateDisk`, Task 4 `Get-DiskCandidates` |
| Picker UX + `-DiskNumber`/`-DryRun` prompting rules | Task 3 `Read-DiskSelection`, Task 6 `Confirm-DiskAction` |
| State machine, stateless, no marker files | Task 1 `Get-DiskMode`, Task 2 `Get-ActionPlan` |
| `wsl` flow (8 steps) | Task 2 plan + Task 5 exec + Task 6 orchestration |
| `windows` flow (5 steps) | same |
| `status` action | Task 6 `Invoke-StatusAction` |
| Ordering safety | Task 2 ordering tests + Task 5 call-order tests |
| Elevation | Task 6 `Start-Elevation` + `Main` test |
| Error-handling table (8 rows) | Task 5 (4), Task 6 (3), Task 7 (README) |
| USB flash caveat | Task 5 `New-WslMountError`, Task 7 README |
| Verification: `-DryRun` / analyzer / runbook | Task 2, Task 7 Steps 1 & 4 |
| Verification: Pester suite (approved in brainstorming) | every task |

No gaps found.

**2. Placeholder scan** — one defect found and fixed before saving: the original Task 3 "re-prompts on an out-of-range answer" test used a convoluted double-`Mock` construction with a note telling the implementer to replace it. It has been replaced inline with the single counter-based version above.

**3. Type consistency**
- Plan steps are `[pscustomobject]@{Kind; DiskNumber; PartitionIndex}`; `Format-Step` and `Invoke-ActionPlan` read exactly those three fields.
- Disk objects are `Number/Path/FriendlyName/BusType/Size/IsOffline/PartitionStyle/Partitions`; `Read-DiskSelection`, `Confirm-DiskAction`, `Invoke-SwitchAction` and `Invoke-StatusAction` read only `Number`, `FriendlyName`, `Path`, `BusType`, `Size`, `IsOffline`, `PartitionStyle`, `Partitions`.
- Partition objects are `PartitionNumber/DriveLetter/Size/FileSystem` in Tasks 3, 4 and 6.
- `Invoke-WslCommand` returns `@{Output; ExitCode}` and is consumed only as such in Tasks 4, 5 and 6.

Consistent.
