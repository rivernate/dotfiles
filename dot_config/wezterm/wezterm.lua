local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'Gruvbox Dark (Gogh)'
config.font = wezterm.font_with_fallback({
  'FiraMono Nerd Font',
})
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.8

return config
