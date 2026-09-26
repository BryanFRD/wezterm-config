# wezterm-config

My [WezTerm](https://wezterm.org) setup on Windows.

- `wezterm.lua`: Catppuccin Mocha, JetBrains Mono with ligatures, Acrylic backdrop, tabs in the title bar, PowerShell by default and Git Bash one shortcut away.
- `starship.toml`: the [Starship](https://starship.rs) prompt used inside WezTerm (the `catppuccin-powerline` preset). `wezterm.lua` points `STARSHIP_CONFIG` at it, so other terminals keep `~/.config/starship.toml`.

## Install

WezTerm reads `~/.config/wezterm/wezterm.lua`, so clone the repository there:

```powershell
git clone https://github.com/BryanFRD/wezterm-config "$HOME\.config\wezterm"
winget install wezfurlong.wezterm Starship.Starship
```

Starship still needs its line in each shell: `Invoke-Expression (& starship init powershell)` in the PowerShell profile and `eval "$(starship init bash)"` in `~/.bashrc`.

## On a VPS

Over SSH the prompt and completion come from the server's shell, so they need installing there once. `remote/install.sh` does it in the user's home, without root, for bash and zsh:

- Starship with the same Catppuccin theme (the icons are drawn by WezTerm on this side, so they render over SSH);
- bash: [ble.sh](https://github.com/akinomyoga/ble.sh), with suggestions from history as you type and a completion menu (needs `ps`, from procps);
- zsh: [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) and menu completion;
- `LANG` set to `C.UTF-8` when the session has none.

It can be run again safely: it backs up any file it replaces and adds a single line to `~/.bashrc` or `~/.zshrc`. From PowerShell or Git Bash:

```powershell
scp $HOME\.config\wezterm\remote\install.sh user@vps:/tmp/terminal-install.sh
ssh user@vps "bash /tmp/terminal-install.sh && rm /tmp/terminal-install.sh"
```

Hosts listed in `~/.ssh/config` also appear in the launcher (`Ctrl+Shift+L`), where WezTerm opens them as SSH tabs.

## Shortcuts

| Keys | Action |
| --- | --- |
| `Ctrl+Shift+D` / `Ctrl+Shift+E` | Split side by side / top and bottom |
| `Alt+Arrows` | Move between panes |
| `Ctrl+Shift+W` | Close the pane |
| `Ctrl+Shift+B` | New Git Bash tab |
| `Ctrl+Shift+L` | Pick a shell (PowerShell, Git Bash, cmd) |
| `Ctrl+Shift+K` | Clear the screen and scrollback |
