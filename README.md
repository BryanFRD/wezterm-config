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

## Shortcuts

| Keys | Action |
| --- | --- |
| `Ctrl+Shift+D` / `Ctrl+Shift+E` | Split side by side / top and bottom |
| `Alt+Arrows` | Move between panes |
| `Ctrl+Shift+W` | Close the pane |
| `Ctrl+Shift+B` | New Git Bash tab |
| `Ctrl+Shift+L` | Pick a shell (PowerShell, Git Bash, cmd) |
| `Ctrl+Shift+K` | Clear the screen and scrollback |
