return function(c, hl)
	-- Modern indent-blankline (v3+)
	hl("IblIndent", { fg = c.outline_variant })
	hl("IblScopeChar", { fg = c.primary })
	hl("IblWhitespace", { fg = c.outline_variant })
	hl("IblScope", { fg = c.primary })

	-- Legacy indent-blankline (v2)
	hl("IndentBlanklineChar", { fg = c.outline_variant })
	hl("IndentBlanklineContextChar", { fg = c.primary })
	hl("IndentBlanklineSpaceChar", { fg = c.outline_variant })
	hl("IndentBlanklineSpaceCharActive", { fg = c.outline_variant })
end
