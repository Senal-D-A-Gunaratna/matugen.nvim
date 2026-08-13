return function(c, hl)
	hl("AvanteTitle", { fg = c.on_primary, bg = c.primary, bold = true })
	hl("AvanteReversedTitle", { fg = c.primary, bg = c.surface_container })
	hl("AvanteSubtitle", { fg = c.on_primary_container, bg = c.primary_container })
	hl("AvanteReversedSubtitle", { fg = c.primary_container, bg = c.surface_container })
	hl("AvanteThirdTitle", { fg = c.on_surface_variant, bg = c.surface_high })
	hl("AvanteReversedThirdTitle", { fg = c.surface_high, bg = c.surface_container })
	hl("AvanteConflictCurrent", { bg = c.primary_container })
	hl("AvanteConflictIncoming", { bg = c.tertiary_container })
	hl(
		"AvanteConflictCurrentLabel",
		{ fg = c.on_primary_container, bg = c.primary_container, bold = true }
	)
	hl("AvanteConflictIncomingLabel", { fg = c.tertiary, bg = c.tertiary_container, bold = true })
	hl("AvantePopupHint", { fg = c.outline, italic = true })
	hl("AvanteInlineHint", { fg = c.outline, italic = true })
end
