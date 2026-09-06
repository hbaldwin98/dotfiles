#!/usr/bin/env bash
# Install optional AI coding agent CLIs. Never run automatically by
# bootstrap.sh/setup.sh; opt in per tool or with --all.
#
#   ./install-agents.sh --opencode --cursor-agent --codex --claude
#   ./install-agents.sh --all
set -euo pipefail

install_opencode=0
install_cursor_agent=0
install_codex=0
install_claude=0

if [[ "$#" -eq 0 ]]; then
    echo "Usage: $0 [--opencode] [--cursor-agent] [--codex] [--claude] [--all]" >&2
    exit 1
fi

for arg in "$@"; do
    case "$arg" in
        --opencode) install_opencode=1 ;;
        --cursor-agent) install_cursor_agent=1 ;;
        --codex) install_codex=1 ;;
        --claude) install_claude=1 ;;
        --all)
            install_opencode=1
            install_cursor_agent=1
            install_codex=1
            install_claude=1
            ;;
        *) echo "Unknown argument: $arg" >&2; exit 1 ;;
    esac
done

if [[ "$install_opencode" -eq 1 ]]; then
    echo "Installing opencode"
    curl -fsSL https://opencode.ai/install | bash
fi

if [[ "$install_cursor_agent" -eq 1 ]]; then
    echo "Installing cursor-agent"
    curl https://cursor.com/install -fsS | bash
fi

if [[ "$install_codex" -eq 1 ]]; then
    echo "Installing codex"
    if command -v npm >/dev/null 2>&1; then
        # Install into a user-writable prefix; the system npm's default global
        # prefix (/usr/local) usually requires root.
        mkdir -p "$HOME/.local"
        npm install -g --prefix "$HOME/.local" @openai/codex
        echo "Ensure $HOME/.local/bin is on PATH to run 'codex'."
    else
        curl -fsSL https://chatgpt.com/codex/install.sh | sh
    fi
fi

if [[ "$install_claude" -eq 1 ]]; then
    echo "Installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
fi
