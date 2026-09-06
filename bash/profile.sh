# Linux equivalent of powershell/Microsoft.PowerShell_profile.ps1.
# Sourced from ~/.bashrc by setup.sh.

# Toolchain bins before interactive polish so completions see them.
[[ -d /usr/local/go/bin ]] && PATH="/usr/local/go/bin:$PATH"
[[ -d "$HOME/go/bin" ]] && PATH="$HOME/go/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]] && PATH="$HOME/.cargo/bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
export PATH

# ble.sh: fish-like autosuggestions and a richer line editor. Attach at the end
# so Oh My Posh / zoxide / fzf can initialize first.
_blesh="${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh"
if [[ $- == *i* && -f "$_blesh" ]]; then
    # shellcheck disable=SC1090
    source -- "$_blesh" --attach=none
fi
unset _blesh

if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init bash --config "$HOME/.cache/oh-my-posh/themes/catppuccin_mocha.omp.json")"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
    alias cd='z'
    alias cdi='zi'
fi

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    alias bat='batcat'
fi

if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    alias fd='fdfind'
fi

# fzf: Ctrl-R history, Ctrl-T files, Alt-C directories. Use ble.sh's integration
# when available so bindings work with its line editor.
if [[ ${BLE_VERSION-} ]]; then
    ble-import -d integration/fzf-completion
    ble-import -d integration/fzf-key-bindings
else
    for _fzf_base in \
        /usr/share/doc/fzf/examples \
        /usr/share/fzf/shell \
        /usr/share/fzf \
        "$HOME/.fzf/shell"; do
        if [[ -f "$_fzf_base/key-bindings.bash" ]]; then
            # shellcheck disable=SC1090
            source -- "$_fzf_base/key-bindings.bash"
            [[ -f "$_fzf_base/completion.bash" ]] && source -- "$_fzf_base/completion.bash"
            break
        fi
    done
    unset _fzf_base
fi

gitdiff() {
    git diff --relative --diff-filter=d | bat
}

gitdiffs() {
    git diff --relative --diff-filter=d --staged | bat
}

gitstatus() {
    git status --short
}

gitadd() {
    git add -A
}

gitamend() {
    git commit --amend
}

gitamendnoedit() {
    git commit --amend --no-edit
}

gitcheckoutmain() {
    git checkout main
}

gitpullmain() {
    git pull origin main --rebase
}

gitpushmain() {
    git push origin main
}

gitrebasemain() {
    git rebase main
}

gitlog() {
    git log "$@"
}

gitreview() {
    git review
}

gitstash() {
    git stash
}

gitstashpop() {
    git stash pop
}

alias ga='gitadd'
alias gd='gitdiff'
alias gs='gitstatus'
alias gl='gitlog'
alias gr='gitreview'
alias gst='gitstash'
alias gstp='gitstashpop'
alias gca='gitamend'
alias gcn='gitamendnoedit'
alias gds='gitdiffs'
alias gcd='gitcheckoutmain'
alias gpu='gitpushmain'
alias gpd='gitpullmain'
alias grd='gitrebasemain'
{ command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; } && alias cat='bat'

[[ ! ${BLE_VERSION-} ]] || ble-attach
