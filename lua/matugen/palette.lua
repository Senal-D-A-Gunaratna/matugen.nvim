local M = {}

M.keys = {
	"surface",
	"surface_low",
	"surface_container",
	"surface_high",
	"surface_highest",
	"on_surface",
	"on_surface_variant",
	"outline",
	"outline_variant",
	"primary",
	"on_primary",
	"primary_container",
	"on_primary_container",
	"primary_fixed_dim",
	"inverse_primary",
	"secondary",
	"secondary_container",
	"on_secondary_container",
	"secondary_fixed_dim",
	"tertiary",
	"tertiary_container",
	"tertiary_fixed_dim",
	"error",
	"error_container",
	"selection_bg",
	"word_highlight",
	"word_highlight_strong",
	"cursor_block",
	"cursor_beam",
	"cursor_underline",
	"git_added",
	"git_modified",
	"git_deleted",
}

function M.get_colors(get)
	local colors = {}
	for _, key in ipairs(M.keys) do
		colors[key] = get(key)
	end
	return colors
end

return M
