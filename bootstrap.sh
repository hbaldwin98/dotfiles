#!/usr/bin/env bash
# Clone (or update) this repository on Linux and link its configuration.
#
#   curl -fsSL https://raw.githubusercontent.com/hbaldwin98/dotfiles/main/bootstrap.sh | bash
#
# To also install the editor, shell prompt, toolchains, and LazyVim prerequisites:
#
#   curl -fsSL https://raw.githubusercontent.com/hbaldwin98/dotfiles/main/bootstrap.sh | bash -s -- --install-tools
set -euo pipefail

DESTINATION="${DOTFILES_DESTINATION:-$HOME/github.com/hbaldwin98/dotfiles}"
INSTALL_TOOLS=0

for arg in "$@"; do
    case "$arg" in
        --install-tools) INSTALL_TOOLS=1 ;;
        *) echo "Unknown argument: $arg" >&2; exit 1 ;;
    esac
done

apt_packages=(
    git
    make
    gawk
    ripgrep
    fd-find
    bat
    fzf
    zoxide
    lazygit
    tree-sitter-cli
    nodejs
    npm
)

# LazyVim requires Neovim 0.11.2+; Debian/Ubuntu's apt package lags behind, so
# install the official prebuilt release instead of the distro package.
install_neovim() {
    local current
    current="$(command -v nvim >/dev/null 2>&1 && nvim --version | head -1 | awk '{print $2}' | sed 's/^v//')" || true
    if [[ -n "$current" ]] && printf '%s\n%s\n' "$NEOVIM_MIN_VERSION" "$current" | sort -V -C; then
        return 0
    fi

    echo "Installing Neovim (prebuilt release, apt's version is too old for LazyVim)"
    local arch tarball
    arch="$(uname -m)"
    case "$arch" in
        x86_64) tarball="nvim-linux-x86_64.tar.gz" ;;
        aarch64) tarball="nvim-linux-arm64.tar.gz" ;;
        *) echo "Unsupported architecture for prebuilt Neovim: $arch; install it manually." >&2; return 1 ;;
    esac

    curl -fsSL -o /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/$tarball"
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf /tmp/nvim.tar.gz
    sudo mv "/opt/${tarball%.tar.gz}" /opt/nvim
    rm /tmp/nvim.tar.gz
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
}

NEOVIM_MIN_VERSION="0.11.2"

# Ubuntu/Debian's apt repos often lack (or lag behind) the gh package, so
# install from GitHub's official apt repo instead.
install_gh_cli() {
    if command -v gh >/dev/null 2>&1; then
        return 0
    fi

    echo "Installing GitHub CLI"
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y gh
}

# Fish-like autosuggestions for Bash (not packaged usefully on Debian/Ubuntu).
install_blesh() {
    local installed="${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh"
    if [[ -f "$installed" ]]; then
        return 0
    fi

    echo "Installing ble.sh (Bash autosuggestions / line editor)"
    local src="${XDG_CACHE_HOME:-$HOME/.cache}/ble.sh-src"
    if [[ -d "$src/.git" ]]; then
        git -C "$src" pull --ff-only
    else
        rm -rf "$src"
        git clone --recursive --depth 1 --shallow-submodules \
            https://github.com/akinomyoga/ble.sh.git "$src"
    fi
    make -C "$src" install PREFIX="$HOME/.local"
}

# Official Go release (apt's golang package lags behind).
install_golang() {
    local latest current arch tarball
    latest="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)"
    if [[ -z "$latest" ]]; then
        echo "Could not resolve the latest Go version from go.dev." >&2
        return 1
    fi

    current="$(command -v go >/dev/null 2>&1 && go env GOVERSION 2>/dev/null)" || true
    if [[ "$current" == "$latest" && -x /usr/local/go/bin/go ]]; then
        return 0
    fi

    arch="$(uname -m)"
    case "$arch" in
        x86_64) arch=amd64 ;;
        aarch64) arch=arm64 ;;
        *) echo "Unsupported architecture for Go: $arch; install it manually." >&2; return 1 ;;
    esac
    tarball="${latest}.linux-${arch}.tar.gz"

    echo "Installing Go ${latest}"
    curl -fsSL -o "/tmp/${tarball}" "https://go.dev/dl/${tarball}"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "/tmp/${tarball}"
    rm "/tmp/${tarball}"
}

# rustup manages the Rust toolchain; PATH is handled by bash/profile.sh.
install_rustup() {
    if command -v rustup >/dev/null 2>&1; then
        return 0
    fi

    echo "Installing rustup"
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
}

if [[ "$INSTALL_TOOLS" -eq 1 ]]; then
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "apt-get is required for --install-tools on this script; install the tools listed in README.md manually." >&2
        exit 1
    fi

    echo "Installing apt packages: ${apt_packages[*]}"
    sudo apt-get update
    sudo apt-get install -y "${apt_packages[@]}"

    install_neovim
    install_gh_cli
    install_blesh
    install_golang
    install_rustup

    if ! command -v herdr >/dev/null 2>&1; then
        echo "Installing Herdr"
        curl -fsSL https://herdr.dev/install.sh | sh
    fi

    if ! command -v oh-my-posh >/dev/null 2>&1; then
        echo "Installing Oh My Posh"
        curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
    fi

    mkdir -p "$HOME/.cache/oh-my-posh/themes"
    if [[ ! -f "$HOME/.cache/oh-my-posh/themes/catppuccin_mocha.omp.json" ]]; then
        echo "Downloading Oh My Posh themes"
        curl -fsSL -o /tmp/oh-my-posh-themes.zip \
            https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip
        unzip -o -q /tmp/oh-my-posh-themes.zip -d "$HOME/.cache/oh-my-posh/themes"
        rm /tmp/oh-my-posh-themes.zip
    fi

    echo "Note: install a Nerd Font (e.g. JetBrainsMono) manually from https://www.nerdfonts.com/font-downloads"
fi

if ! command -v git >/dev/null 2>&1; then
    echo "Git is required to clone the dotfiles. Install it or rerun with --install-tools." >&2
    exit 1
fi

mkdir -p "$(dirname "$DESTINATION")"

if [[ -d "$DESTINATION/.git" ]]; then
    git -C "$DESTINATION" pull --ff-only
else
    if [[ -d "$DESTINATION" && -n "$(ls -A "$DESTINATION" 2>/dev/null)" ]]; then
        echo "$DESTINATION exists and is not empty. Move it or set DOTFILES_DESTINATION." >&2
        exit 1
    fi
    git clone https://github.com/hbaldwin98/dotfiles.git "$DESTINATION"
fi

bash "$DESTINATION/setup.sh"

echo "Machine setup complete. Open a new terminal, then run nvim or herdr."
