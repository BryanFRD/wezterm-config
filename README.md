# wezterm-config

My [WezTerm](https://wezterm.org) setup on Windows.

- `wezterm.lua`: Catppuccin Mocha on a pure black background (OLED), JetBrains Mono with ligatures, tabs in the title bar, Git Bash by default and PowerShell in the launcher.
- `gitbash.bash`: the Git Bash side, sourced from `~/.bashrc`: Starship, [ble.sh](https://github.com/akinomyoga/ble.sh) suggestions, the current directory and tab title for WezTerm, and a notification when a command over 45 s ends while WezTerm is in the background.
- `starship.toml`: the [Starship](https://starship.rs) prompt used inside WezTerm (the `catppuccin-powerline` preset). `wezterm.lua` points `STARSHIP_CONFIG` at it, so other terminals keep `~/.config/starship.toml`.

## Install

WezTerm reads `~/.config/wezterm/wezterm.lua`, so clone the repository there:

```powershell
git clone https://github.com/BryanFRD/wezterm-config "$HOME\.config\wezterm"
winget install wezfurlong.wezterm Starship.Starship
```

Then, in Git Bash, install ble.sh and load `gitbash.bash` from `~/.bashrc`:

```bash
mkdir -p ~/.local/share && curl -fsSL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar -xJ -C ~/.local/share && mv ~/.local/share/ble-nightly* ~/.local/share/blesh
echo '[ -f ~/.config/wezterm/gitbash.bash ] && . ~/.config/wezterm/gitbash.bash' >> ~/.bashrc
```

PowerShell still needs `Invoke-Expression (& starship init powershell)` in its profile.

## On a VPS

Over SSH the prompt and completion come from the server's shell, so they need installing there once. `remote/install.sh` does it in the user's home, without root, for bash and zsh:

- Starship with the same Catppuccin theme (the icons are drawn by WezTerm on this side, so they render over SSH);
- bash: [ble.sh](https://github.com/akinomyoga/ble.sh), with suggestions from history as you type and a completion menu (needs `ps`, from procps);
- zsh: [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) and menu completion;
- [eza](https://github.com/eza-community/eza) as `ls`/`ll` and [bat](https://github.com/sharkdp/bat) as `cat`;
- the WezTerm mux server, for sessions that survive a disconnect;
- the shell reports its directory and sets the tab title (`host dir`), so splits open in the same directory;
- a notification when a command over 45 s ends while WezTerm is in the background;
- `LANG` set to `C.UTF-8` when the session has none.

It can be run again safely: it backs up any file it replaces and adds a single line to `~/.bashrc` or `~/.zshrc`. From PowerShell or Git Bash:

```powershell
scp $HOME\.config\wezterm\remote\install.sh user@vps:/tmp/terminal-install.sh
ssh user@vps "bash /tmp/terminal-install.sh && rm /tmp/terminal-install.sh"
```

Hosts listed in `~/.ssh/config` also appear in the launcher (`Ctrl+Shift+L`). WezTerm opens them through its mux server, so tabs and splits stay alive on the server and come back when you reconnect. WezTerm ignores `ProxyJump`, so hosts behind a jump host need `ProxyCommand ssh -W %h:%p <jump>` instead.

## Shortcuts

| Keys | Action |
| --- | --- |
| `Ctrl+Shift+T` | New tab, in the home directory |
| `Ctrl+Shift+D` or `Alt+D` | Add a pane, filling a 2x2 grid (4 panes max), in the same directory |
| `Ctrl+Shift+E` | Split top and bottom (4 panes max) |
| `Alt+Arrows` | Move between panes |
| `Alt+&` `Alt+é` `Alt+"` … (`Alt+1` to `Alt+9`) | Go to tab 1 to 9 |
| `Ctrl+Shift+W` or `Alt+W` | Close the pane |
| `Ctrl+Shift+B` | New Git Bash tab |
| `Ctrl+Shift+L` | Pick a shell (PowerShell, Git Bash, cmd) |
| `Ctrl+Shift+K` | Clear the screen and scrollback |
| `Ctrl+V` | Paste |
| `Ctrl+Click` | Open the link under the cursor |
