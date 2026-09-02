return function(c, hl)
	-- Window chrome — matches FloatBorder/NormalFloat conventions used
	-- for other floating windows (telescope.lua, noice.lua)
	hl("NeominimapBackground", { fg = c.on_surface, bg = c.surface_container })
	hl("NeominimapBorder", { fg = c.primary, bg = c.surface_container })

	-- Cursor line — matches CursorLine/CursorLineNr/SignColumn conventions
	hl("NeominimapCursorLine", { bg = c.surface_high })
	hl("NeominimapCursorLineNr", { fg = c.primary, bold = true })
	hl("NeominimapCursorLineSign", { fg = c.outline, bg = c.surface_high })
	hl("NeominimapCursorLineFold", { fg = c.outline, bg = c.surface_high })

	-- Diagnostics — matches lsp.lua's severity mapping
	hl("NeominimapErrorSign", { fg = c.error })
	hl("NeominimapWarnSign", { fg = c.tertiary })
	hl("NeominimapInfoSign", { fg = c.secondary })
	hl("NeominimapHintSign", { fg = c.primary })

	hl("NeominimapErrorIcon", { fg = c.error })
	hl("NeominimapWarnIcon", { fg = c.tertiary })
	hl("NeominimapInfoIcon", { fg = c.secondary })
	hl("NeominimapHintIcon", { fg = c.primary })

	hl("NeominimapErrorLine", { bg = c.error })
	hl("NeominimapWarnLine", { bg = c.tertiary })
	hl("NeominimapInfoLine", { bg = c.secondary })
	hl("NeominimapHintLine", { bg = c.primary })

	-- Git hunks (gitsigns.nvim backend) — matches gitsigns.lua
	hl("NeominimapGitAddSign", { fg = c.git_added })
	hl("NeominimapGitChangeSign", { fg = c.git_modified })
	hl("NeominimapGitDeleteSign", { fg = c.git_deleted })

	hl("NeominimapGitAddIcon", { fg = c.git_added })
	hl("NeominimapGitChangeIcon", { fg = c.git_modified })
	hl("NeominimapGitDeleteIcon", { fg = c.git_deleted })

	hl("NeominimapGitAddLine", { bg = c.git_added })
	hl("NeominimapGitChangeLine", { bg = c.git_modified })
	hl("NeominimapGitDeleteLine", { bg = c.git_deleted })

	-- Git hunks (mini.diff backend) — same colors as the gitsigns hunks
	-- above, since both represent the same add/change/delete semantics
	hl("NeominimapMiniDiffAddSign", { fg = c.git_added })
	hl("NeominimapMiniDiffChangeSign", { fg = c.git_modified })
	hl("NeominimapMiniDiffDeleteSign", { fg = c.git_deleted })

	hl("NeominimapMiniDiffAddIcon", { fg = c.git_added })
	hl("NeominimapMiniDiffChangeIcon", { fg = c.git_modified })
	hl("NeominimapMiniDiffDeleteIcon", { fg = c.git_deleted })

	hl("NeominimapMiniDiffAddLine", { bg = c.git_added })
	hl("NeominimapMiniDiffChangeLine", { bg = c.git_modified })
	hl("NeominimapMiniDiffDeleteLine", { bg = c.git_deleted })

	-- Search matches — matches editor.lua's Search/IncSearch treatment
	hl("NeominimapSearchSign", { fg = c.primary })
	hl("NeominimapSearchIcon", { fg = c.primary })
	hl("NeominimapSearchLine", { bg = c.primary })

	-- Marks — matches Normal/CursorLine defaults, since neominimap
	-- links these to Normal/CursorLine when no custom mark color is set
	hl("NeominimapMarkSign", { fg = c.on_surface })
	hl("NeominimapMarkIcon", { fg = c.on_surface })
	hl("NeominimapMarkLine", { bg = c.surface_high })
end
