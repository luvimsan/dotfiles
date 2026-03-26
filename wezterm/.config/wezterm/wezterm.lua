local wezterm = require("wezterm")
local act = wezterm.action

return {

	font = wezterm.font_with_fallback({
		"JetBrainsMono Nerd Font",
		"Noto Sans Arabic",
	}),

	font_size = 12.0,
	color_scheme = "Bamboo",
	colors = {
		background = "#1c1c1c",
	},
	warn_about_missing_glyphs = false,
	adjust_window_size_when_changing_font_size = false,

	-- arabic
	bidi_enabled = true,
	bidi_direction = "LeftToRight",

	-- more history
	scrollback_lines = 10000,
	cursor_blink_rate = 0,

	-- window managing
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",

	-- Key bindings
	keys = {
		{
			key = "]",
			mods = "CTRL",
			action = act.IncreaseFontSize,
		},
		{
			key = "[",
			mods = "CTRL",
			action = act.DecreaseFontSize,
		},
		{
			key = "0",
			mods = "CTRL",
			action = act.ResetFontSize,
		},
		{
			key = "T",
			mods = "CTRL|SHIFT",
			action = act.ScrollByLine(-1),
		},
		{
			key = "H",
			mods = "CTRL|SHIFT",
			action = act.ScrollByLine(1),
		},
		{
			key = "U",
			mods = "CTRL|SHIFT",
			action = act.ScrollByPage(-0.5),
		},
		{
			key = "D",
			mods = "CTRL|SHIFT",
			action = act.ScrollByPage(0.5),
		},
		{
			key = "C",
			mods = "CTRL|SHIFT",
			action = act.CopyTo("ClipboardAndPrimarySelection"),
		},
		{
			key = "v",
			mods = "CTRL",
			action = act.PasteFrom("Clipboard"),
		},
		{
			key = "8",
			mods = "CTRL",
			action = act.Multiple({
				act.IncreaseFontSize,
				act.IncreaseFontSize,
			}),
		},
	},
}
