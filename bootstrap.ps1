[CmdletBinding()]
param(
    [string] $Destination = "C:\Source\github.com\hbaldwin98\dotfiles",

    [switch] $InstallTools
)

$ErrorActionPreference = "Stop"

$packages = @(
    "Git.Git",
    "Microsoft.PowerShell",
    "Neovim.Neovim",
    "BurntSushi.ripgrep.MSVC",
    "sharkdp.fd",
    "sharkdp.bat",
    "junegunn.fzf",
    "ajeetdsouza.zoxide",
    "JanDeDobbeleer.OhMyPosh",
    "JesseDuffield.lazygit",
    "tree-sitter.tree-sitter-cli",
    "LLVM.LLVM",
    "OpenJS.NodeJS.LTS",
    "DEVCOM.JetBrainsMonoNerdFont"
)

if ($InstallTools) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget is required to install tools. Install or update App Installer from the Microsoft Store, then rerun this command."
    }

    foreach ($package in $packages) {
        Write-Host "Installing $package"
        winget install --id $package --exact --source winget --silent `
            --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) {
            throw "winget failed to install $package (exit code $LASTEXITCODE)."
        }
    }

    # Make applications installed during this process visible without opening a new shell.
    $env:Path = @(
        [Environment]::GetEnvironmentVariable("Path", "Machine"),
        [Environment]::GetEnvironmentVariable("Path", "User")
    ) -join ";"

    if (-not (Get-Command herdr -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Herdr"
        Invoke-RestMethod https://herdr.dev/install.ps1 | Invoke-Expression
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git is required to clone the dotfiles. Install Git or rerun the bootstrap with -InstallTools."
}

$parent = Split-Path -Parent $Destination
New-Item -ItemType Directory -Path $parent -Force | Out-Null

if (Test-Path -LiteralPath (Join-Path $Destination ".git")) {
    git -C $Destination pull --ff-only
    if ($LASTEXITCODE -ne 0) {
        throw "Could not update the existing dotfiles checkout."
    }
} else {
    if ((Test-Path -LiteralPath $Destination) -and
        (Get-ChildItem -LiteralPath $Destination -Force)) {
        throw "$Destination exists and is not empty. Move it or choose another -Destination."
    }

    git clone https://github.com/hbaldwin98/dotfiles.git $Destination
    if ($LASTEXITCODE -ne 0) {
        throw "Could not clone the dotfiles repository."
    }
}

$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $pwsh) {
    throw "PowerShell 7 is required to link the dotfiles. Install it or rerun the bootstrap with -InstallTools."
}

& $pwsh.Source -NoProfile -File (Join-Path $Destination "setup.ps1")

Write-Host "Machine setup complete. Open a new terminal, then run nvim or herdr."
