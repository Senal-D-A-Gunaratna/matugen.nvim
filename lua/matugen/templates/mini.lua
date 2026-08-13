return function(c, hl)
	-- mini.files
	hl("MiniFilesBorder", { fg = c.outline_variant, bg = c.surface_low })
	hl("MiniFilesBorderModified", { fg = c.secondary, bg = c.surface_low })
	hl("MiniFilesCursorLine", { bg = c.surface_high })
	hl("MiniFilesDirectory", { fg = c.primary, bold = true })
	hl("MiniFilesFile", { fg = c.on_surface })
	hl("MiniFilesNormal", { fg = c.on_surface, bg = c.surface_low })
	hl("MiniFilesTitle", { fg = c.primary, bg = c.surface_low, bold = true })
	hl("MiniFilesTitleFocused", { fg = c.on_primary, bg = c.primary, bold = true })

	-- mini.indentscope
	hl("MiniIndentscopeSymbol", { fg = c.primary })
	hl("MiniIndentscopeSymbolOff", { fg = c.outline_variant })

	-- mini.jump
	hl("MiniJump", { fg = c.on_primary, bg = c.primary, bold = true })

	-- mini.map
	hl("MiniMapNormal", { fg = c.on_surface_variant, bg = c.surface_low })
	hl("MiniMapSymbolCount", { fg = c.secondary })
	hl("MiniMapSymbolLine", { fg = c.primary })
	hl("MiniMapSymbolView", { fg = c.tertiary })

	-- mini.operators
	hl("MiniOperatorsExchangeTemplates", { fg = c.on_primary, bg = c.primary })

	-- mini.pick
	hl("MiniPickBorder", { fg = c.primary, bg = c.surface_container })
	hl("MiniPickBorderText", { fg = c.primary, bg = c.surface_container, bold = true })
	hl("MiniPickMatchCurrent", { fg = c.on_primary_container, bg = c.primary_container })
	hl("MiniPickMatchMarked", { fg = c.on_secondary_container, bg = c.secondary_container })
	hl("MiniPickNormal", { fg = c.on_surface, bg = c.surface_container })
	hl("MiniPickPrompt", { fg = c.primary, bg = c.surface_container, bold = true })

	-- mini.surround
	hl("MiniSurround", { fg = c.on_secondary_container, bg = c.secondary_container })

	-- mini.statusline
	hl("MiniStatuslineDevinfo", { fg = c.on_surface_variant, bg = c.surface_high })
	hl("MiniStatuslineFileinfo", { fg = c.on_surface, bg = c.surface_container })
	hl("MiniStatuslineFilename", { fg = c.on_surface_variant, bg = c.surface_low })
	hl("MiniStatuslineModeCommand", { fg = c.on_primary, bg = c.primary, bold = true })
	hl(
		"MiniStatuslineModeInsert",
		{ fg = c.on_secondary_container, bg = c.secondary_container, bold = true }
	)
	hl(
		"MiniStatuslineModeNormal",
		{ fg = c.on_primary_container, bg = c.primary_container, bold = true }
	)
	hl("MiniStatuslineModeOther", { fg = c.on_surface, bg = c.surface_high, bold = true })
	hl("MiniStatuslineModeReplace", { fg = c.on_primary, bg = c.error, bold = true })
	hl("MiniStatuslineModeVisual", { fg = c.on_primary, bg = c.primary, bold = true })
end
