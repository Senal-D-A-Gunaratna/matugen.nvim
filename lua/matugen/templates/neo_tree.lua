return function(c, hl)
	hl("NeoTreeNormal", { fg = c.on_surface, bg = c.surface_low })
	hl("NeoTreeNormalNC", { fg = c.on_surface_variant, bg = c.surface_low })
	hl("NeoTreeSignColumn", { bg = c.surface_low })
	hl("NeoTreeFloatNormal", { fg = c.on_surface, bg = c.surface_container })
	hl("NeoTreeFloatBorder", { fg = c.primary, bg = c.surface_container })
	hl("NeoTreeDirectoryName", { fg = c.on_surface })
	hl("NeoTreeDirectoryIcon", { fg = c.primary })
	hl("NeoTreeFileName", { fg = c.on_surface })
	hl("NeoTreeFileNameOpened", { fg = c.primary, bold = true })
	hl("NeoTreeRootName", { fg = c.primary, bold = true })
	hl("NeoTreeSymbolicLinkTarget", { fg = c.secondary })

	-- Git status indicators in Neo-tree
	hl("NeoTreeGitAdded", { fg = c.git_added })
	hl("NeoTreeGitConflict", { fg = c.error, bold = true })
	hl("NeoTreeGitDeleted", { fg = c.git_deleted })
	hl("NeoTreeGitIgnored", { fg = c.outline })
	hl("NeoTreeGitModified", { fg = c.git_modified })
	hl("NeoTreeGitUntracked", { fg = c.git_added, italic = true })

	hl("NeoTreeIndentMarker", { fg = c.outline_variant })
	hl("NeoTreeTitleBar", { fg = c.on_primary, bg = c.primary, bold = true })

	-- Tabs at the top of the tree panel
	hl("NeoTreeTabActive", { fg = c.primary, bg = c.surface_high, bold = true })
	hl("NeoTreeTabInactive", { fg = c.outline, bg = c.surface_low })
	hl("NeoTreeTabSeparatorActive", { fg = c.outline_variant, bg = c.surface_low })
	hl("NeoTreeTabSeparatorInactive", { fg = c.outline_variant, bg = c.surface_low })
end
