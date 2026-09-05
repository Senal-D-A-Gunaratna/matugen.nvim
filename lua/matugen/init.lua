--- @type table<string, any>
local M = {}

--- @param msg string
--- @param lvl? integer
local function notify(msg, lvl)
	vim.notify("matugen: " .. msg, lvl or vim.log.levels.INFO)
end

local _notify_timer = nil
local _notify_ms = 100
local _first_load = true

local function _notify_reload()
	if _first_load then
		_first_load = false
		return
	end
	local uv = vim.uv or vim.loop
	if not uv then
		notify("theme reloaded")
		return
	end
	if _notify_timer then
		_notify_timer:stop()
		_notify_timer:close()
	end
	_notify_timer = uv.new_timer()
	_notify_timer:start(
		_notify_ms,
		0,
		vim.schedule_wrap(function()
			if _notify_timer then
				_notify_timer:stop()
				_notify_timer:close()
				_notify_timer = nil
			end
			notify("theme reloaded")
		end)
	)
end

--- @return fun(table, fun(string, table):nil)[]
local function _load_templates()
	if M._templates then
		return M._templates
	end

	local templates = {}
	-- Pin template loading to this plugin's own directory via its resolved
	-- path, preventing rogue plugins from injecting files via runtimepath.
	local _self = debug.getinfo(1, "S").source:sub(2)
	local _plugin_lua_dir = _self:match("^(.*)/init%.lua$")
	local _templates_dir = _plugin_lua_dir .. "/templates"
	local _real_tpl_dir = vim.fn.resolve(_templates_dir)

	for name, ftype in vim.fs.dir(_real_tpl_dir) do
		if ftype == "file" and name:match("%.lua$") then
			local file = _real_tpl_dir .. "/" .. name
			local chunk, err = loadfile(file)
			if chunk then
				local ok_chunk, res = pcall(chunk)
				if ok_chunk and type(res) == "function" then
					table.insert(templates, res)
				end
			else
				notify(
					"Failed to load template " .. file .. ": " .. tostring(err),
					vim.log.levels.WARN
				)
			end
		end
	end

	M._templates = templates
	return templates
end

function M.reload_templates()
	M._templates = nil
end

-- Apply palette colors and highlight groups. Always called from the
-- main thread (either directly or via vim.schedule).
-- on_done: optional function called after highlights are applied.
--- @param v string
--- @return string?
local function hex(v)
	if not v then
		return nil
	end
	if v:sub(1, 1) ~= "#" then
		return v
	end
	local len = #v
	if len == 9 then
		return v:sub(1, 7)
	elseif len == 4 then
		local r, g, b = v:sub(2, 2), v:sub(3, 3), v:sub(4, 4)
		return "#" .. r .. r .. g .. g .. b .. b
	elseif len == 5 then
		local r, g, b = v:sub(2, 2), v:sub(3, 3), v:sub(4, 4)
		return "#" .. r .. r .. g .. g .. b .. b
	end
	return v
end

-- Recolors the active lazy.nvim tab's "(<key>)" mnemonic via an ephemeral
-- extmark set inside Neovim's own redraw cycle (nvim_set_decoration_provider),
-- so it paints in sync with lazy.nvim's own render instead of a frame behind
-- it. Reads only lazy.nvim's public state (view.state.mode,
-- view.config.get_commands()) and its own rendered buffer text — never
-- overrides or replaces any lazy.nvim function.
local function _watch_lazy_active_mnemonic()
	local ns = vim.api.nvim_create_namespace("matugen_lazy_active_mnemonic")
	local active_bufs = {}

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "lazy",
		callback = function(args)
			active_bufs[args.buf] = true
		end,
	})

	vim.api.nvim_create_autocmd("BufWipeout", {
		callback = function(args)
			active_bufs[args.buf] = nil
		end,
	})

	vim.api.nvim_set_decoration_provider(ns, {
		on_win = function(_, _, bufnr)
			return active_bufs[bufnr] == true
		end,
		on_line = function(_, _, bufnr, row)
			if row > 3 then
				return
			end

			local ok_view, LazyView = pcall(require, "lazy.view")
			if not ok_view or not LazyView.view then
				return
			end
			local mode = LazyView.view.state and LazyView.view.state.mode
			if not mode or mode == "home" then
				return
			end

			local ok_cfg, ViewConfig = pcall(require, "lazy.view.config")
			if not ok_cfg then
				return
			end

			local key
			for _, cmd in ipairs(ViewConfig.get_commands()) do
				if cmd.button and cmd.name == mode then
					key = cmd.key
					break
				end
			end
			if not key then
				return
			end

			local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
			if not line then
				return
			end
			local s, e = line:find("%(" .. vim.pesc(key) .. "%)")
			if s then
				vim.api.nvim_buf_set_extmark(bufnr, ns, row, s - 1, {
					end_col = e,
					hl_group = "LazySpecialActive",
					priority = 5000, -- above lazy.nvim's own default (4096) extmark priority
					ephemeral = true,
				})
			end
		end,
	})
end

local function _apply_highlights(w, path, on_done)
	local templates = _load_templates()
	local nvim_set_hl = vim.api.nvim_set_hl
	local hl = function(g, o)
		nvim_set_hl(0, g, o)
	end

	local fallback_palette = require("matugen.fallback_palette")
	local c

	if validator and w and next(w) ~= nil and not validator.is_valid(w) then
		if not M._invalid_warned then
			notify(
				"palette contains invalid or incomplete color values, using fallback",
				vim.log.levels.WARN
			)
			M._invalid_warned = true
		end
		c = {}
	else
		local palette = require("matugen.palette")
		c = palette.get_colors(function(k)
			return hex(w[k])
		end)
		if not c then
			return notify("palette not found", 3)
		end
	end

	for k, v in pairs(fallback_palette) do
		if c[k] == nil then
			c[k] = v
		end
	end

	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.g.colors_name = "matugen"
	for _, t in ipairs(templates) do
		t(c, hl)
	end

	local now = os.time()
	M._last_reload = now
	M._template_count = #templates
	M._status = "Loaded successfully"
	M._palette_path = vim.fn.fnamemodify(path, ":~")

	-- matugen_status intentionally not written to vim.g to avoid
	-- leaking the palette path to other plugins via global state
	if on_done then
		M._cached_w = w
		M._cached_path = path
		on_done()
		M._cached_w = nil
		M._cached_path = nil
		_notify_reload()
	end
end

--- @param on_done? fun()
--- @param force_sync? boolean
function M.load(on_done, force_sync)
	if M._cached_w then
		local w = M._cached_w
		local path = M._cached_path
		M._cached_w = nil
		M._cached_path = nil
		_apply_highlights(w, path, on_done)
		return
	end

	local path = vim.fn.expand(M.opts.palette_path)

	if not path or path == "" then
		notify("No palette_path configured. Using fallback color scheme", vim.log.levels.WARN)
		if force_sync then
			_apply_highlights({}, path, on_done)
		else
			vim.schedule(function()
				_apply_highlights({}, path, on_done)
			end)
		end
		return
	elseif not path:match("%.[Jj][Ss][Oo][Nn]$") then
		notify(
			"palette_path must end in .json — refusing to open: " .. path,
			vim.log.levels.ERROR
		)
		return
	end

	if force_sync then
		local f = io.open(path, "r")
		if not f then
			notify(
				"Could not open color file at: " .. path .. "\nUsing fallback color scheme",
				vim.log.levels.WARN
			)
			_apply_highlights({}, path, on_done)
			return
		end

		local raw = f:read("*a")
		f:close()

		local ok, parsed = pcall(vim.json.decode, raw)
		if not ok or type(parsed) ~= "table" then
			notify(
				"Failed to parse JSON from " .. path .. "\nUsing fallback color scheme",
				vim.log.levels.WARN
			)
			parsed = {}
		end
		_apply_highlights(parsed, path, on_done)
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
				notify(
					"Could not open color file at: " .. path .. "\nUsing fallback color scheme",
					vim.log.levels.WARN
				)
				_apply_highlights({}, path, on_done)
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
					notify("Could not stat color file at: " .. path, vim.log.levels.WARN)
					_apply_highlights({}, path, on_done)
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
						notify(
							"Could not read color file at: "
								.. path
								.. "\nUsing fallback color scheme",
							vim.log.levels.WARN
						)
						_apply_highlights({}, path, on_done)
						return
					end

					local ok, parsed = pcall(vim.json.decode, data)
					if not ok or type(parsed) ~= "table" then
						notify(
							"Failed to parse JSON from " .. path .. "\nUsing fallback color scheme",
							vim.log.levels.WARN
						)
						parsed = {}
					end
					_apply_highlights(parsed, path, on_done)
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
	_watch_lazy_active_mnemonic()
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
		-- _apply_highlights runs twice/load (via :colorscheme ->
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
