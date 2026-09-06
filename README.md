# dotfiles

Personal configuration for Neovim, PowerShell 7 (Windows) or Bash (Linux), Herdr, and OpenCode.

## Linux

To clone and link the configuration without installing applications:

```bash
curl -fsSL https://raw.githubusercontent.com/hbaldwin98/dotfiles/main/bootstrap.sh | bash
```

To also install the editor, shell prompt, Go, rustup, and LazyVim prerequisites via
`apt`, opt in with `--install-tools`:

```bash
curl -fsSL https://raw.githubusercontent.com/hbaldwin98/dotfiles/main/bootstrap.sh | bash -s -- --install-tools
```

The bootstrap clones this repository to `~/github.com/hbaldwin98/dotfiles`
(override with `DOTFILES_DESTINATION`) and runs `setup.sh`. As on Windows,
OpenCode and the other agent CLIs below are never installed by the bootstrap.

`setup.sh` symlinks Neovim, OpenCode, the shared agent skills, and Herdr's
Linux config (`herdr/config.linux.toml`, which uses `bash` instead of `pwsh`)
into place, backing up any existing paths with a timestamped suffix, and adds
a line to `~/.bashrc` that sources `bash/profile.sh` (the Bash equivalent of
`powershell/Microsoft.PowerShell_profile.ps1`: Oh My Posh prompt, zoxide,
ble.sh autosuggestions, fzf key bindings, and the `git*` functions/aliases).

Debian/Ubuntu package the `fd-find` and `bat` binaries as `fdfind` and
`batcat`; `bash/profile.sh` aliases `fd`/`bat` to them automatically when the
canonical names aren't already on `PATH`.

Typing suggestions come from [ble.sh](https://github.com/akinomyoga/ble.sh)
(ghost text from history/completions; accept with Right Arrow or End). fzf adds
Ctrl-R history search, Ctrl-T file pick, and Alt-C directory jump. Suggestion
colors live in `bash/blerc` (Catppuccin Mocha, dim ghost text, no suggestion
background).

### Agent CLIs

Install any combination of opencode, Cursor's `cursor-agent`, and OpenAI's
`codex` with:

```bash
./install-agents.sh --opencode --cursor-agent --codex
# or
./install-agents.sh --all
```

Each of these runs the tool's official install script (or `npm install -g` for
codex when npm is available), so review `install-agents.sh` before running it
on a machine where you haven't vetted those upstream scripts.

### Existing checkout

Re-run `setup.sh` at any time to relink an existing checkout; it is
idempotent and only backs up paths that don't already point here.

### Installed tools

| Tool | Purpose | Installation |
| --- | --- | --- |
| Git, make, gawk, ripgrep, fd, bat, fzf, zoxide, lazygit, tree-sitter-cli, Node.js | LazyVim requirements and ble.sh build deps | `apt` (via `--install-tools`) |
| Neovim | Editor | Official prebuilt release (via `--install-tools`); apt's version is too old for LazyVim's 0.11.2+ requirement |
| GitHub CLI (`gh`) | GitHub from the command line | Official apt repo (via `--install-tools`) |
| ble.sh | Bash autosuggestions / line editor | Built from [akinomyoga/ble.sh](https://github.com/akinomyoga/ble.sh) into `~/.local` (via `--install-tools`) |
| Go | Latest stable toolchain | Official tarball from [go.dev](https://go.dev/dl/) into `/usr/local/go` (via `--install-tools`) |
| rustup | Rust toolchain manager | Official [rustup.rs](https://rustup.rs/) installer (via `--install-tools`) |
| Herdr | Terminal workspace manager | [herdr.dev/docs/install](https://herdr.dev/docs/install/) |
| Oh My Posh | Bash prompt | [ohmyposh.dev/docs/installation/linux](https://ohmyposh.dev/docs/installation/linux) |
| JetBrains Mono Nerd Font | Icons in Neovim and the prompt | [nerdfonts.com](https://www.nerdfonts.com/font-downloads) (not automated; install manually) |
| opencode, cursor-agent, codex | Optional AI coding agent CLIs | `install-agents.sh` |

The enabled LazyVim Dart extra needs a separate
[Flutter SDK installation](https://docs.flutter.dev/get-started/install/linux) for
Dart or Flutter development. The editor still starts without it.

## Shared configuration

Set `CONTEXT7_API_KEY` and `GODOT_PATH` as environment variables on either OS
when the corresponding OpenCode MCP servers are used. Secrets are
intentionally not stored here. Restart OpenCode after changing its
configuration.

Herdr plugin installations are intentionally not tracked. Install plugins with
Herdr itself; `plugins.json`, downloaded plugin code, sessions, sockets, and logs
are generated machine-specific state.

## Windows

### New machine

Enable [Windows Developer Mode](https://learn.microsoft.com/windows/apps/get-started/enable-your-device-for-development)
so a non-administrator can create file symbolic links.

To clone and link the configuration without installing applications, run this
from Windows PowerShell. Git and PowerShell 7 must already be installed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm https://raw.githubusercontent.com/hbaldwin98/dotfiles/main/bootstrap.ps1)))"
```

To also install the editor, shell, terminal tools, font, Go, rustup, and LazyVim
prerequisites, opt in with `-InstallTools`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm https://raw.githubusercontent.com/hbaldwin98/dotfiles/main/bootstrap.ps1))) -InstallTools"
```

The bootstrap clones this repository to
`C:\Source\github.com\hbaldwin98\dotfiles` and runs the link setup. OpenCode is
never installed by the bootstrap; install it separately if needed.

### Existing checkout

The repository is the source of truth. Run the setup script from PowerShell to
back up existing live configuration and link each application to this checkout:

```powershell
.\setup.ps1
```

The script creates directory junctions for Neovim, OpenCode, and the shared
agent skills, plus symbolic links for the PowerShell and Herdr files. Existing
paths are retained as timestamped backups. File symbolic links require Windows
Developer Mode or an elevated PowerShell session.

### Installed tools

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
| Go | Latest stable toolchain | winget `GoLang.Go` (via `-InstallTools`) |
| rustup | Rust toolchain manager | Official [rustup.rs](https://rustup.rs/) installer (via `-InstallTools`) |
| JetBrains Mono Nerd Font | Icons in Neovim and the prompt | [nerdfonts.com](https://www.nerdfonts.com/font-downloads) |

The enabled LazyVim Dart extra needs a separate
[Flutter SDK installation](https://docs.flutter.dev/get-started/install/windows) for
Dart or Flutter development. The editor still starts without it.
