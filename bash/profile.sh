# Linux equivalent of powershell/Microsoft.PowerShell_profile.ps1.
# Sourced from ~/.bashrc by setup.sh.

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
