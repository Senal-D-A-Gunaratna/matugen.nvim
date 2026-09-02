return function(c, hl)
	hl("FlashBackdrop", { fg = c.outline })
	hl("FlashCurrent", { fg = c.on_primary, bg = c.primary, bold = true })
	hl("FlashLabel", { fg = c.on_primary, bg = c.primary_container, bold = true })
	hl("FlashMatch", { fg = c.primary, bg = c.surface_high })
	hl("FlashPrompt", { fg = c.on_surface, bg = c.surface_container })
	hl("FlashPromptIcon", { fg = c.primary, bg = c.surface_container })
	hl("FlashCursor", { fg = c.on_primary, bg = c.primary })
end
