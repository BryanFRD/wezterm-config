local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

local scheme_name = "Catppuccin Mocha"
local scheme = wezterm.color.get_builtin_schemes()[scheme_name]

local background = "#000000"

config.color_scheme = scheme_name

config.font = wezterm.font_with_fallback({
  { family = "JetBrains Mono", weight = "Medium" },
  "Cascadia Code",
  "Symbols Nerd Font Mono",
})
config.font_size = 11
config.line_height = 1.1
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

config.set_environment_variables = {
  STARSHIP_CONFIG = wezterm.config_dir .. "\\starship.toml",
}

local git_bash = { "C:\\Program Files\\Git\\bin\\bash.exe", "--login", "-i" }

config.default_prog = git_bash
config.launch_menu = {
  { label = "Git Bash", args = git_bash },
  { label = "PowerShell", args = { "powershell.exe", "-NoLogo" } },
  { label = "Command Prompt", args = { "cmd.exe" } },
}

config.ssh_domains = {}
for _, domain in ipairs(wezterm.default_ssh_domains()) do
  if domain.multiplexing == "WezTerm" then
    domain.name = domain.name:gsub("^SSHMUX:", "")
    domain.remote_wezterm_path = "~/.local/bin/wezterm"
    table.insert(config.ssh_domains, domain)
  end
end

config.initial_cols = 130
config.initial_rows = 34
config.window_padding = { left = 14, right = 14, top = 10, bottom = 8 }
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.adjust_window_size_when_changing_font_size = false

config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = true
config.window_frame = {
  font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
  font_size = 10,
  active_titlebar_bg = background,
  inactive_titlebar_bg = background,
}
config.colors = {
  background = background,
  tab_bar = {
    inactive_tab_edge = background,
    active_tab = { bg_color = scheme.brights[5], fg_color = scheme.background },
    inactive_tab = { bg_color = background, fg_color = scheme.ansi[8] },
    inactive_tab_hover = { bg_color = scheme.ansi[1], fg_color = scheme.foreground },
    new_tab = { bg_color = background, fg_color = scheme.ansi[8] },
    new_tab_hover = { bg_color = scheme.ansi[1], fg_color = scheme.foreground },
  },
}

config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.7 }

config.scrollback_lines = 20000
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_duration_ms = 60,
  fade_out_duration_ms = 120,
  target = "CursorColor",
}
config.window_close_confirmation = "NeverPrompt"
config.notification_handling = "SuppressFromFocusedWindow"
config.front_end = "WebGpu"
config.max_fps = 120

local new_tab_at_home = act.SpawnCommandInNewTab({ domain = "CurrentPaneDomain", cwd = "~" })

local max_panes = 4

local function cwd_of(pane)
  local url = pane:get_current_working_dir()
  return url and (url.file_path:gsub("^/(%a:)", "%1"))
end

local split_into_grid = wezterm.action_callback(function(_, pane)
  local panes = pane:tab():panes_with_info()
  if #panes >= max_panes then
    return
  end
  local target = panes[1]
  for _, info in ipairs(panes) do
    if info.width * info.height >= target.width * target.height then
      target = info
    end
  end
  local direction = target.pixel_width >= target.pixel_height and "Right" or "Bottom"
  target.pane:split({ direction = direction, cwd = cwd_of(pane) }):activate()
end)

local split_down = wezterm.action_callback(function(window, pane)
  if #pane:tab():panes() < max_panes then
    window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
  end
end)

config.keys = {
  { key = "t", mods = "CTRL|SHIFT", action = new_tab_at_home },
  { key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },
  { key = "d", mods = "CTRL|SHIFT", action = split_into_grid },
  { key = "d", mods = "ALT", action = split_into_grid },
  { key = "e", mods = "CTRL|SHIFT", action = split_down },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "w", mods = "ALT", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },
  { key = "l", mods = "CTRL|SHIFT", action = act.ShowLauncherArgs({ flags = "LAUNCH_MENU_ITEMS|DOMAINS|FUZZY" }) },
  { key = "b", mods = "CTRL|SHIFT", action = act.SpawnCommandInNewTab({ args = git_bash, cwd = "~" }) },
  { key = "k", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },
  { key = '"', mods = "CTRL|ALT", action = act.DisableDefaultAssignment },
  { key = '"', mods = "CTRL|SHIFT|ALT", action = act.DisableDefaultAssignment },
  { key = "'", mods = "CTRL|SHIFT|ALT", action = act.DisableDefaultAssignment },
  { key = "%", mods = "CTRL|ALT", action = act.DisableDefaultAssignment },
  { key = "%", mods = "CTRL|SHIFT|ALT", action = act.DisableDefaultAssignment },
  { key = "5", mods = "CTRL|SHIFT|ALT", action = act.DisableDefaultAssignment },
}

for i = 1, 9 do
  table.insert(config.keys, { key = "phys:" .. i, mods = "ALT", action = act.ActivateTab(i - 1) })
end

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.CompleteSelection("ClipboardAndPrimarySelection"),
  },
  { event = { Up = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.OpenLinkAtMouseCursor },
  { event = { Down = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.Nop },
}

wezterm.on("new-tab-button-click", function(window, pane, button)
  if button == "Left" then
    window:perform_action(new_tab_at_home, pane)
    return false
  end
end)

return config
