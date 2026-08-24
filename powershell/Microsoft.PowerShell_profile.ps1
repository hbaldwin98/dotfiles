$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

oh-my-posh init pwsh --config (Join-Path $env:POSH_THEMES_PATH "catppuccin_mocha.omp.json") | Invoke-Expression

Set-Alias -Name cd -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name cdi -Value __zoxide_zi -Option AllScope -Scope Global -Force

function gitdiff {
    git diff --relative --diff-filter=d | bat
}

function gitdiffs {
    git diff --relative --diff-filter=d --staged | bat
}

function gitstatus {
    git status --short
}

function gitadd {
    git add -A
}

function gitamend {
    git commit --amend
}

function gitamendnoedit {
    git commit --amend --no-edit
}

function gitcheckoutmain {
    git checkout main
}

function gitpullmain {
    git pull origin main --rebase
}

function gitpushmain {
    git push origin main
}

function gitrebasemain {
    git rebase main
}

function gitlog {
    git log $args
}

function gitreview {
    git review
}

function gitstash {
    git stash
}

function gitstashpop {
    git stash pop
}

# the above function is not working. fix it
Set-Alias -Name ga -Value gitadd -Option AllScope -Scope Global -Force
Set-Alias -Name gd -Value gitdiff -Option AllScope -Scope Global -Force
Set-Alias -Name gs -Value gitstatus -Option AllScope -Scope Global -Force
Set-Alias -Name gl -Value gitlog -Option AllScope -Scope Global -Force
Set-Alias -Name gr -Value gitreview -Option AllScope -Scope Global -Force
Set-Alias -Name gst -Value gitstash -Option AllScope -Scope Global -Force
Set-Alias -Name gstp -Value gitstashpop -Option AllScope -Scope Global -Force
Set-Alias -Name gca -Value gitamend -Option AllScope -Scope Global -Force
Set-Alias -Name gcn -Value gitamendnoedit -Option AllScope -Scope Global -Force
Set-Alias -Name gds -Value gitdiffs -Option AllScope -Scope Global -Force
Set-Alias -Name gcd -Value gitcheckoutmain -Option AllScope -Scope Global -Force
Set-Alias -Name gpu -Value gitpushmain -Option AllScope -Scope Global -Force
Set-Alias -Name gpd -Value gitpullmain -Option AllScope -Scope Global -Force
Set-Alias -Name grd -Value gitrebasemain -Option AllScope -Scope Global -Force
Set-Alias -Name cat -Value bat -Option AllScope -Scope Global -Force

Invoke-Expression (& { (zoxide init powershell --no-cmd | Out-String) })
