return function(c, hl)
	hl("NvimTreeNormal", { fg = c.on_surface, bg = c.surface_low })
	hl("NvimTreeNormalNC", { fg = c.on_surface_variant, bg = c.surface_low })
	hl("NvimTreeRootFolder", { fg = c.primary, bold = true })
	hl("NvimTreeFolderName", { fg = c.on_surface })
	hl("NvimTreeFolderIcon", { fg = c.primary })
	hl("NvimTreeOpenedFolderName", { fg = c.primary, bold = true })
	hl("NvimTreeEmptyFolderName", { fg = c.outline })
	hl("NvimTreeIndentMarker", { fg = c.outline_variant })
	hl("NvimTreeWinSeparator", { fg = c.outline_variant, bg = nil })

	-- Git status indicators
	hl("NvimTreeGitDirty", { fg = c.git_modified })
	hl("NvimTreeGitStaged", { fg = c.git_added })
	hl("NvimTreeGitMerge", { fg = c.secondary })
	hl("NvimTreeGitRenamed", { fg = c.secondary })
	hl("NvimTreeGitNew", { fg = c.git_added })
	hl("NvimTreeGitDeleted", { fg = c.git_deleted })

	-- Special files
	hl("NvimTreeSpecialFile", { fg = c.secondary, underline = true })
	hl("NvimTreeImageFile", { fg = c.tertiary })
	hl("NvimTreeSymlink", { fg = c.secondary })
	hl("NvimTreeWindowPicker", { fg = c.on_primary, bg = c.primary, bold = true })
end
