--- @type table<string, any>
local M = {}

local render = require("matugen.render")(M)

M.reload_templates = render.reload_templates

--- @param on_done? fun()
--- @param force_sync? boolean
function M.load(on_done, force_sync)
	if M._cached_w then
		local w = M._cached_w
		local path = M._cached_path
		M._cached_w = nil
		M._cached_path = nil
		render.apply_highlights(w, path, on_done)
		return
	end

	local path = vim.fn.expand(M.opts.palette_path)

	if not path or path == "" then
		render.notify(
			"No palette_path configured. Using fallback color scheme",
			vim.log.levels.WARN
		)
		if force_sync then
			render.apply_highlights({}, path, on_done)
		else
			vim.schedule(function()
				render.apply_highlights({}, path, on_done)
			end)
		end
		return
	elseif not path:match("%.[Jj][Ss][Oo][Nn]$") then
		render.notify(
			"palette_path must end in .json — refusing to open: " .. path,
			vim.log.levels.ERROR
		)
		return
	end

	if force_sync then
		local f = io.open(path, "r")
		if not f then
			render.notify(
				"Could not open color file at: " .. path .. "\nUsing fallback color scheme",
				vim.log.levels.WARN
			)
			render.apply_highlights({}, path, on_done)
			return
		end

		local raw = f:read("*a")
		f:close()

		local ok, parsed = pcall(vim.json.decode, raw)
		if not ok or type(parsed) ~= "table" then
			render.notify(
				"Failed to parse JSON from " .. path .. "\nUsing fallback color scheme",
				vim.log.levels.WARN
			)
			parsed = {}
		end
		render.apply_highlights(parsed, path, on_done)
		return
	end

	-- Non-blocking read via vim.uv so the main loop is not stalled.
	-- Highlight application is deferred to vim.schedule() which runs on
	-- the main thread after the async callbacks complete.
	-- A generation counter prevents stale reads from a previous
	-- load_theme call from overwriting a newer palette when async
	-- reads complete out of order.
	M._load_gen = (M._load_gen or 0) + 1
	local gen = M._load_gen

	local uv = vim.uv or vim.loop
	uv.fs_open(path, "r", 438, function(err_open, fd)
		if err_open or not fd then
			vim.schedule(function()
				if M._load_gen ~= gen then
					return
				end
				render.notify(
					"Could not open color file at: " .. path .. "\nUsing fallback color scheme",
					vim.log.levels.WARN
				)
				render.apply_highlights({}, path, on_done)
			end)
			return
		end

		uv.fs_fstat(fd, function(err_stat, stat)
			if err_stat or not stat then
				uv.fs_close(fd, function() end)
				vim.schedule(function()
					if M._load_gen ~= gen then
						return
					end
					render.notify("Could not stat color file at: " .. path, vim.log.levels.WARN)
					render.apply_highlights({}, path, on_done)
				end)
				return
			end

			uv.fs_read(fd, stat.size, 0, function(err_read, data)
				uv.fs_close(fd, function() end)
				vim.schedule(function()
					if M._load_gen ~= gen then
						return
					end
					if err_read or not data then
						render.notify(
							"Could not read color file at: "
								.. path
								.. "\nUsing fallback color scheme",
							vim.log.levels.WARN
						)
						render.apply_highlights({}, path, on_done)
						return
					end

					local ok, parsed = pcall(vim.json.decode, data)
					if not ok or type(parsed) ~= "table" then
						render.notify(
							"Failed to parse JSON from " .. path .. "\nUsing fallback color scheme",
							vim.log.levels.WARN
						)
						parsed = {}
					end
					render.apply_highlights(parsed, path, on_done)
				end)
			end)
		end)
	end)
end

--- @param opts? {palette_path?: string, load_theme?: boolean}
function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", {
		palette_path = "",
		load_theme = true,
	}, opts or {})
	vim.opt.guicursor =
		"n-v-c:block-Cursor,i-ci-ve:ver25-iCursor,r-cr:hor20-rCursor,o:hor50-oCursor,sm:block-smCursor,t:block-TermCursor,a:blinkwait175-blinkoff150-blinkon175"
	vim.opt.termguicolors = true
	render.watch_lazy_active_mnemonic()
	if M.opts.load_theme then
		M.load_theme(false) -- Non-blocking async load at startup
	end
end

--- @param force_sync? boolean
function M.load_theme(force_sync)
	if force_sync == nil then
		force_sync = true
	end
	M.load(function()
		-- render.apply_highlights runs twice/load (via :colorscheme ->
		-- cached M.load path), so redraws happen once here, not inside it,
		-- avoiding flicker.

		vim.cmd.colorscheme("matugen")

		-- lualine.refresh({force=true}) forces immediate redraw; without it,
		-- refresh only queues and returns, landing a tick late via debounced
		-- vim.schedule.
		if package.loaded["lualine"] then
			local ok_lualine, lualine = pcall(require, "lualine")
			if ok_lualine then
				lualine.refresh({ force = true })
			end
		end

		-- valid=false forces a full repaint of the entire editor (all
		-- windows, statusline, winbar, tabline, cursor) in one call —
		-- the Lua equivalent of :redraw!. Avoids having to enumerate
		-- individual scope keys (cursor, statusline, ...) here as new
		-- UI subsystems hit the same "refreshed in memory but not
		-- painted" staleness issue.
		vim.api.nvim__redraw({ valid = false, flush = true })
	end, force_sync)
end

return M
