#!/usr/bin/env bash
# Links this checkout's configuration into place on Linux.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

backup_path() {
    local path="$1" expected_target="$2"

    [[ -e "$path" || -L "$path" ]] || return 0

    if [[ -L "$path" && "$(readlink -f "$path" 2>/dev/null)" == "$(readlink -f "$expected_target")" ]]; then
        return 0
    fi

    local backup="${path}.backup-$(date +%Y%m%d-%H%M%S)"
    echo "Backing up $path"
    mv "$path" "$backup"
    echo "Backed up $path to $backup"
}

link() {
    local path="$1" target="$2"
    mkdir -p "$(dirname "$path")"
    backup_path "$path" "$target"
    if [[ ! -e "$path" ]]; then
        ln -s "$target" "$path"
        echo "Linked $path -> $target"
    fi
}

link "$HOME/.config/nvim" "$REPO_ROOT/nvim"
link "$HOME/.config/opencode" "$REPO_ROOT/opencode"
link "$HOME/.config/herdr/config.toml" "$REPO_ROOT/herdr/config.linux.toml"
link "$HOME/.agents/skills" "$REPO_ROOT/.agents/skills"

marker="# dotfiles: source shared bash profile"
bashrc="$HOME/.bashrc"
touch "$bashrc"
if ! grep -qF "$marker" "$bashrc"; then
    {
        echo ""
        echo "$marker"
        echo "[ -f \"$REPO_ROOT/bash/profile.sh\" ] && source \"$REPO_ROOT/bash/profile.sh\""
    } >>"$bashrc"
    echo "Added dotfiles profile source line to $bashrc"
fi

echo "Dotfiles are linked to $REPO_ROOT"
