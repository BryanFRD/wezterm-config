local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

local scheme_name = "Catppuccin Mocha"
local scheme = wezterm.color.get_builtin_schemes()[scheme_name]

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

config.default_prog = { "powershell.exe", "-NoLogo" }
config.launch_menu = {
  { label = "PowerShell", args = { "powershell.exe", "-NoLogo" } },
  { label = "Git Bash", args = { "C:\\Program Files\\Git\\bin\\bash.exe", "--login", "-i" } },
  { label = "Command Prompt", args = { "cmd.exe" } },
}

config.initial_cols = 130
config.initial_rows = 34
config.window_padding = { left = 14, right = 14, top = 10, bottom = 8 }
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.92
config.win32_system_backdrop = "Acrylic"
config.adjust_window_size_when_changing_font_size = false

config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = true
config.window_frame = {
  font = wezterm.font({ family = "JetBrains Mono", weight = "Bold" }),
  font_size = 10,
  active_titlebar_bg = scheme.background,
  inactive_titlebar_bg = scheme.background,
}
config.colors = {
  tab_bar = {
    inactive_tab_edge = scheme.background,
    active_tab = { bg_color = scheme.brights[5], fg_color = scheme.background },
    inactive_tab = { bg_color = scheme.background, fg_color = scheme.ansi[8] },
    inactive_tab_hover = { bg_color = scheme.ansi[1], fg_color = scheme.foreground },
    new_tab = { bg_color = scheme.background, fg_color = scheme.ansi[8] },
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
config.front_end = "WebGpu"
config.max_fps = 120

config.keys = {
  { key = "d", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "e", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },
  { key = "l", mods = "CTRL|SHIFT", action = act.ShowLauncherArgs({ flags = "LAUNCH_MENU_ITEMS|FUZZY" }) },
  { key = "b", mods = "CTRL|SHIFT", action = act.SpawnCommandInNewTab({ args = { "C:\\Program Files\\Git\\bin\\bash.exe", "--login", "-i" } }) },
  { key = "k", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },
}

wezterm.on("update-right-status", function(window, pane)
  local cwd = pane:get_current_working_dir()
  local folder = cwd and (cwd.file_path or tostring(cwd)):gsub("[/\\]+$", ""):match("([^/\\]+)$") or ""
  window:set_right_status(wezterm.format({
    { Foreground = { Color = scheme.ansi[8] } },
    { Text = folder ~= "" and ("  " .. folder .. "   ") or "" },
    { Foreground = { Color = scheme.brights[5] } },
    { Text = wezterm.strftime("%H:%M") .. "  " },
  }))
end)

return config
