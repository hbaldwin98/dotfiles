# dotfiles

Personal configuration for Neovim, PowerShell 7, Herdr, and OpenCode on Windows.

## New machine

Enable [Windows Developer Mode](https://learn.microsoft.com/windows/apps/get-started/enable-your-device-for-development)
so a non-administrator can create file symbolic links.

To clone and link the configuration without installing applications, run this
from Windows PowerShell. Git and PowerShell 7 must already be installed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm https://raw.githubusercontent.com/hbaldwin98/dotfiles/main/bootstrap.ps1)))"
```

To also install the editor, shell, terminal tools, font, and LazyVim
prerequisites, opt in with `-InstallTools`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm https://raw.githubusercontent.com/hbaldwin98/dotfiles/main/bootstrap.ps1))) -InstallTools"
```

The bootstrap clones this repository to
`C:\Source\github.com\hbaldwin98\dotfiles` and runs the link setup. OpenCode is
never installed by the bootstrap; install it separately if needed.

## Existing checkout

The repository is the source of truth. Run the setup script from PowerShell to
back up existing live configuration and link each application to this checkout:

```powershell
.\setup.ps1
```

The script creates directory junctions for Neovim, OpenCode, and the shared
agent skills, plus symbolic links for the PowerShell and Herdr files. Existing
paths are retained as timestamped backups. File symbolic links require Windows
Developer Mode or an elevated PowerShell session.

Set `CONTEXT7_API_KEY` and `GODOT_PATH` as user environment variables when the
corresponding OpenCode MCP servers are used. Secrets are intentionally not
stored here. Restart OpenCode after changing its configuration.

Herdr plugin installations are intentionally not tracked. Install plugins with
Herdr itself; `plugins.json`, downloaded plugin code, sessions, sockets, and logs
are generated machine-specific state.

## Installed tools

| Tool | Purpose | Installation |
| --- | --- | --- |
| Git | Repository and LazyVim plugin downloads | [git-scm.com](https://git-scm.com/download/win) |
| PowerShell 7 | Interactive shell and profile host | [Microsoft PowerShell](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows) |
| Neovim | Editor | [neovim.io](https://neovim.io/doc/install/) |
| Herdr | Terminal workspace manager | [herdr.dev](https://herdr.dev/docs/install/) |
| Oh My Posh | PowerShell prompt | [ohmyposh.dev](https://ohmyposh.dev/docs/installation/windows) |
| zoxide | Directory navigation | [github.com/ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide#installation) |
| bat | Profile output pager | [github.com/sharkdp/bat](https://github.com/sharkdp/bat#installation) |
| ripgrep, fd, and fzf | LazyVim search tools | [LazyVim requirements](https://www.lazyvim.org/) |
| lazygit | Git UI used by LazyVim | [github.com/jesseduffield/lazygit](https://github.com/jesseduffield/lazygit#installation) |
| tree-sitter CLI and LLVM | Parser compilation | [tree-sitter.github.io](https://tree-sitter.github.io/tree-sitter/creating-parsers/1-getting-started.html) |
| Node.js LTS | Markdown preview and language tooling | [nodejs.org](https://nodejs.org/en/download) |
| JetBrains Mono Nerd Font | Icons in Neovim and the prompt | [nerdfonts.com](https://www.nerdfonts.com/font-downloads) |

The enabled LazyVim Dart extra needs a separate
[Flutter SDK installation](https://docs.flutter.dev/get-started/install/windows) for
Dart or Flutter development. The editor still starts without it.
