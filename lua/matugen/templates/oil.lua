return function(c, hl)
	hl("OilDir", { fg = c.primary, bold = true })
	hl("OilDirIcon", { fg = c.primary })
	hl("OilFile", { fg = c.on_surface })
	hl("OilLink", { fg = c.secondary, underline = true })
	hl("OilLinkTarget", { fg = c.on_surface_variant })
	hl("OilSocket", { fg = c.tertiary })
	hl("OilFifo", { fg = c.tertiary })
	hl("OilDevice", { fg = c.secondary })
	hl("OilExecutable", { fg = c.git_added, bold = true })
	hl("OilHidden", { fg = c.outline })

	-- Action/move highlights
	hl("OilMoveFrom", { fg = c.on_primary, bg = c.primary })
	hl("OilMoveTo", { fg = c.on_primary, bg = c.primary })
	hl("OilCopyFrom", { fg = c.on_primary, bg = c.primary })
	hl("OilCopyTo", { fg = c.on_primary, bg = c.primary })

	-- Permission bits (visible in detailed list view)
	hl("OilPermissionNone", { fg = c.outline })
	hl("OilPermissionRead", { fg = c.tertiary })
	hl("OilPermissionWrite", { fg = c.secondary })
	hl("OilPermissionExecute", { fg = c.git_added })

	-- Type columns
	hl("OilTypeDir", { fg = c.primary })
	hl("OilTypeFile", { fg = c.on_surface })
	hl("OilTypeLink", { fg = c.secondary })
	hl("OilTypeSocket", { fg = c.tertiary })
	hl("OilTypeFifo", { fg = c.tertiary })
	hl("OilTypeDevice", { fg = c.secondary })
end
