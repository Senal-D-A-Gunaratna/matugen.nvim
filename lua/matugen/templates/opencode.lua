return function(c, hl)
	-- Panel window
	hl("OpencodeBackground", { bg = c.surface_container })
	hl("OpencodeBorder", { fg = c.outline_variant })
	hl("OpencodeToolBorder", { fg = c.outline_variant })
	hl("OpencodeHint", { fg = c.outline, italic = true })

	-- Session tabs
	hl("OpencodeSessionDescription", { fg = c.outline, italic = true })
	hl("OpencodeSessionTabActive", { fg = c.primary, bg = c.surface_high, bold = true })
	hl("OpencodeSessionTabInactive", { fg = c.outline, bg = c.surface_low })
	hl("OpencodeSessionTabIndex", { fg = c.secondary_fixed_dim })
	hl("OpencodeSessionTabSeparator", { fg = c.outline_variant })
	hl("OpencodeSessionTabOverflow", { fg = c.tertiary, bold = true })
	hl("OpencodeSessionTabPendingPermission", { fg = c.tertiary_fixed_dim, bg = c.tertiary_container, bold = true })
	hl("OpencodeSessionTabPendingQuestion", { fg = c.on_primary_container, bg = c.primary_container, bold = true })

	-- Mentions & message roles
	hl("OpencodeMention", { fg = c.tertiary })
	hl("OpencodeMessageRoleAssistant", { fg = c.git_added, bold = true })
	hl("OpencodeMessageRoleUser", { fg = c.primary, bold = true })
	hl("OpencodeQueued", { fg = c.tertiary_fixed_dim, bold = true })

	-- Diffs
	hl("OpencodeDiffAdd", { bg = c.secondary_container })
	hl("OpencodeDiffDelete", { bg = c.error_container })
	hl("OpencodeDiffAddText", { fg = c.git_added })
	hl("OpencodeDiffDeleteText", { fg = c.git_deleted })
	hl("OpencodeDiffGutter", { fg = c.outline, bg = c.surface_container })
	hl("OpencodeDiffAddGutter", { fg = c.git_added, bg = c.secondary_container })
	hl("OpencodeDiffDeleteGutter", { fg = c.git_deleted, bg = c.error_container })
	hl("OpencodeChangedLines", { bg = c.tertiary_container })

	-- Agent mode badges
	hl("OpencodeAgentPlan", { fg = c.on_secondary_container, bg = c.secondary_container, bold = true })
	hl("OpencodeAgentBuild", { fg = c.on_primary, bg = c.primary, bold = true })
	hl("OpencodeAgentCustom", { fg = c.tertiary_fixed_dim, bg = c.tertiary_container, bold = true })
	hl("OpencodeContextualActions", { fg = c.primary, bg = c.surface_high, bold = true })
	hl("OpencodeInputLegend", { fg = c.on_surface_variant })

	-- Variant & guard
	hl("OpencodeVariant", { fg = c.secondary, bold = true })
	hl("OpencodeGuardDenied", { fg = c.error, bold = true })

	-- Context bar
	hl("OpencodeContextBar", { fg = c.outline })
	hl("OpencodeContextFile", { fg = c.primary })
	hl("OpencodeContextCurrentFile", { fg = c.primary })
	hl("OpencodeContextCurrentFileNotUpdated", { fg = c.outline, italic = true })
	hl("OpencodeContextAgent", { fg = c.primary })
	hl("OpencodeContextSelection", { fg = c.primary })
	hl("OpencodeContextError", { fg = c.error })
	hl("OpencodeContextWarning", { fg = c.tertiary })
	hl("OpencodeContextInfo", { fg = c.secondary })
	hl("OpencodeContextSwitchOn", { fg = c.secondary_fixed_dim, bold = true })

	-- References & debugging
	hl("OpencodePickerTime", { fg = c.outline })
	hl("OpencodeDebugText", { fg = c.outline, italic = true })
	hl("OpencodeReference", { fg = c.primary_fixed_dim })
	hl("OpencodeSymbolReference", { fg = c.on_surface })
	hl("OpencodeReasoningText", { fg = c.outline, italic = true })

	-- Permissions & questions
	hl("OpencodeRevertBorder", { bg = c.tertiary })
	hl("OpencodePermissionBorder", { fg = c.tertiary })
	hl("OpencodePermissionTitle", { fg = c.tertiary, bold = true })
	hl("OpencodeDialogOptionHover", { fg = c.primary, bg = c.primary_container })
	hl("OpencodeQuestionOption", { fg = c.on_surface })
	hl("OpencodeQuestionBorder", { fg = c.primary_container })
	hl("OpencodeQuestionTitle", { fg = c.primary, bold = true })
	hl("OpencodeQuestionTabActive", { fg = c.on_primary_container, bg = c.primary_container, bold = true })
	hl("OpencodeQuestionTabDone", { fg = c.git_added, bold = true })
	hl("OpencodeQuestionTabPending", { fg = c.outline })
	hl("OpencodeQuestionKeyHint", { fg = c.primary, bold = true })
end