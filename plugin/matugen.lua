local matugen = require("matugen")

vim.api.nvim_create_user_command("MatugenReload", function()
	matugen.reload_templates()
	matugen.load_theme(true)
	vim.notify("matugen: theme and templates reloaded")
end, { desc = "Reload templates from disk and reapply the theme" })

local signal = (vim.uv or vim.loop).new_signal()
signal:start(
	"sigusr1",
	vim.schedule_wrap(function()
		matugen.load_theme(false)
	end)
)
