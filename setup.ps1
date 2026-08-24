[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

function Backup-Path {
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $ExpectedTarget
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    $item = Get-Item -LiteralPath $Path -Force
    if ($item.LinkType -and $item.Target) {
        $resolvedTarget = [System.IO.Path]::GetFullPath(
            [System.IO.Path]::Combine($item.DirectoryName, [string] $item.Target)
        )
        if ($resolvedTarget -eq [System.IO.Path]::GetFullPath($ExpectedTarget)) {
            return
        }
    }

    $backupPath = "$Path.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "Backing up $Path"
    Move-Item -LiteralPath $Path -Destination $backupPath
    Write-Host "Backed up $Path to $backupPath"
}

function New-ManagedLink {
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $Target,

        [Parameter(Mandatory)]
        [ValidateSet("Junction", "SymbolicLink")]
        [string] $LinkType
    )

    $parent = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    Backup-Path -Path $Path -ExpectedTarget $Target

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType $LinkType -Path $Path -Target $Target | Out-Null
        Write-Host "Linked $Path -> $Target"
    }
}

$links = @(
    @{
        Path = Join-Path $env:LOCALAPPDATA "nvim"
        Target = Join-Path $PSScriptRoot "nvim"
        LinkType = "Junction"
    },
    @{
        Path = $PROFILE.CurrentUserCurrentHost
        Target = Join-Path $PSScriptRoot "powershell\Microsoft.PowerShell_profile.ps1"
        LinkType = "SymbolicLink"
    },
    @{
        Path = Join-Path (Split-Path -Parent $PROFILE.CurrentUserCurrentHost) "powershell.config.json"
        Target = Join-Path $PSScriptRoot "powershell\powershell.config.json"
        LinkType = "SymbolicLink"
    },
    @{
        Path = Join-Path $env:APPDATA "herdr\config.toml"
        Target = Join-Path $PSScriptRoot "herdr\config.toml"
        LinkType = "SymbolicLink"
    },
    @{
        Path = Join-Path $HOME ".config\opencode"
        Target = Join-Path $PSScriptRoot "opencode"
        LinkType = "Junction"
    },
    @{
        Path = Join-Path $HOME ".agents\skills"
        Target = Join-Path $PSScriptRoot ".agents\skills"
        LinkType = "Junction"
    }
)

$testLink = Join-Path $env:TEMP "dotfiles-symlink-test-$PID"
try {
    New-Item -ItemType SymbolicLink -Path $testLink -Target (Join-Path $PSScriptRoot "README.md") | Out-Null
} catch {
    throw "File symbolic links are unavailable. Enable Windows Developer Mode or rerun setup.ps1 as administrator."
} finally {
    if (Test-Path -LiteralPath $testLink) {
        Remove-Item -LiteralPath $testLink -Force
    }
}

foreach ($link in $links) {
    New-ManagedLink @link
}

Write-Host "Dotfiles are linked to $PSScriptRoot"
