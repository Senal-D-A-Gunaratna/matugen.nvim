local M = {}

local health = vim.health or require("health")

function M.check()
	health.start("matugen report")

	-- 1. Neovim version check
	if vim.fn.has("nvim-0.10") == 1 then
		health.ok("Neovim version is 0.10+")
	else
		health.error("Neovim version is less than 0.10.0. This plugin requires Neovim 0.10+.")
	end

	-- 2. matugen CLI executable check
	if vim.fn.executable("matugen") == 1 then
		health.ok("matugen CLI is installed")
	else
		health.info(
			"matugen CLI is not installed or not in system PATH."
				.. " (Optional if you generate your palette elsewhere and sync it.)"
		)
	end

	-- 3. Palette file validation
	local ok, validator = pcall(require, "matugen.validator")
	if not ok then
		health.warn("Could not load matugen.validator — falling back to inline check")

		local matugen = require("matugen")
		local opts = matugen.opts or { palette_path = "" }
		local palette_path = opts.palette_path

		if not palette_path or palette_path == "" then
			health.warn("palette_path is not configured. Falling back to the built-in theme.", {
				"Set `palette_path` in your `opts` configuration.",
			})
			return
		end

		local expanded_path = vim.fn.expand(palette_path)
		if vim.fn.filereadable(expanded_path) == 1 then
			health.ok("Palette file is readable: " .. palette_path)
			local f = io.open(expanded_path, "r")
			if f then
				local content = f:read("*a")
				f:close()
				local parsed_ok, parsed = pcall(vim.json.decode, content)
				if parsed_ok and type(parsed) == "table" then
					health.ok("Palette file parsed successfully")
					local palette = require("matugen.palette")
					for _, key in ipairs(palette.keys) do
						if parsed[key] == nil then
							health.error(string.format("Missing required color key '%s'", key))
						end
					end
				else
					health.error("Failed to decode JSON from palette file at: " .. palette_path, {
						"Check for syntax errors in " .. palette_path,
					})
				end
			else
				health.error(
					"Could not open color file even though filereadable returned true: "
						.. palette_path
				)
			end
		else
			health.error("Palette file not found or not readable: " .. palette_path, {
				"Check that your matugen output path matches: " .. palette_path,
				"Verify your matugen config.toml contains the correct output template path.",
			})
		end
		return
	end

	local matugen = require("matugen")
	local opts = matugen.opts
	if not opts then
		health.warn("matugen setup() has not been called yet. Using default configurations.", {
			"Call require('matugen').setup({ ... }) in your Neovim configuration.",
		})
		opts = { palette_path = "" }
	end

	local palette_path = opts.palette_path
	if not palette_path or palette_path == "" then
		health.warn("palette_path is not configured. Falling back to the built-in theme.", {
			"Set `palette_path` in your `opts` configuration.",
		})
	else
		local result = validator.validate(palette_path)
		for _, err in ipairs(result.errors) do
			health.error(err)
		end
		for _, warn in ipairs(result.warnings) do
			health.warn(warn)
		end
		if result.ok then
			health.ok("Palette file validated successfully")
		end
	end

	-- 4. Live Loaded Status
	local status = matugen._status or "Not loaded"
	local count = matugen._template_count or 0
	local path = matugen._palette_path or "No path"
	local last = matugen._last_reload and os.date("%Y-%m-%d %H:%M:%S", matugen._last_reload)
		or "No data"

	health.info(string.format("Loaded Palette: %s", path))
	health.info(string.format("Status: %s", status))
	health.info(string.format("Active Templates count: %d", count))
	health.info(string.format("Last Reload: %s", last))
end

return M
