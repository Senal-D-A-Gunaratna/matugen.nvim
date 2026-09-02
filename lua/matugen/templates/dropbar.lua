return function(c, hl)
	hl("DropbarMenuNormal", { fg = c.on_surface, bg = c.surface_container })
	hl("DropbarMenuBorder", { fg = c.outline_variant, bg = c.surface_container })
	hl("DropbarMenuHoverEntry", { fg = c.on_primary_container, bg = c.primary_container })
	hl("DropbarMenuHoverIcon", { fg = c.on_primary_container, bg = c.primary_container })
	hl("DropbarMenuHoverSymbol", { fg = c.on_primary_container, bg = c.primary_container })
	hl(
		"DropbarMenuSelectedEntry",
		{ fg = c.on_primary_container, bg = c.primary_container, bold = true }
	)
	hl("DropbarMenuSelectedIcon", { fg = c.on_primary_container, bg = c.primary_container })
	hl("DropbarMenuSelectedSymbol", { fg = c.on_primary_container, bg = c.primary_container })

	-- Icons mapping
	hl("DropbarIconKindMethod", { fg = c.secondary })
	hl("DropbarIconKindFunction", { fg = c.secondary })
	hl("DropbarIconKindField", { fg = c.tertiary })
	hl("DropbarIconKindVariable", { fg = c.on_surface })
	hl("DropbarIconKindClass", { fg = c.primary })
	hl("DropbarIconKindInterface", { fg = c.primary })
	hl("DropbarIconKindModule", { fg = c.on_surface_variant })
	hl("DropbarIconKindProperty", { fg = c.tertiary })
end
