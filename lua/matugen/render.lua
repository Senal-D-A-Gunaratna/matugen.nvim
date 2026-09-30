local validator = require("matugen.validator")
local templates_dir = require("matugen.templates_dir")

--- Builds the rendering API bound to the given plugin state table `M`.
--- All state (`M._templates`, `M._status`, `M._last_reload`, etc.) lives on
--- the shared `M` returned by `require("matugen")`, so external readers
--- (health.lua, plugin/matugen.lua) keep working unchanged.
--- @param M table
--- @return table
return function(M)
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

	--- @param file string
	--- @return fun(table, hl: fun(string, table):nil)?
	local function _try_load(file)
		local chunk, err = loadfile(file)
		if not chunk then
			notify("Failed to load template " .. file .. ": " .. tostring(err), vim.log.levels.WARN)
			return nil
		end
		local ok_chunk, res = pcall(chunk)
		if ok_chunk and type(res) == "function" then -- firma (c, hl)
			return res
		end
		return nil
	end

	--- Every readable `*.lua` file in `dir`, sorted for a deterministic load
	--- order. `filereadable` follows symlinks, so a symlinked template is
	--- picked up; a missing directory yields an empty list.
	--- @param dir string
	--- @return string[] absolute paths
	local function _discover(dir)
		local files = {}
		for name, _ in vim.fs.dir(dir) do
			local file = dir .. "/" .. name
			if file:match("%.lua$") then
				if vim.fn.filereadable(file) == 1 then
					table.insert(files, file)
				end
			end
		end

		table.sort(files)
		return files
	end

	--- @return fun(table, hl: fun(string, table):nil)[]
	local function _load_templates()
		if M._templates then
			return M._templates
		end
		local templates = {}

		-- Built-in templates are loaded first and the custom ones last, so a
		-- custom template only needs to set the highlight groups it cares
		-- about: they win because they are applied afterwards. A custom file
		-- sharing a name with a built-in one replaces it wholesale, which is
		-- also how a built-in is disabled — an empty custom file loads to no
		-- template at all, and the built-in is skipped.
		-- The built-in dir is pinned to this plugin's own install location
		-- (resolved in templates_dir.lua from that module's own path), so a
		-- rogue plugin can't shadow or inject template files via runtimepath.
		-- A custom dir is user-chosen and therefore trusted.
		local custom_dir = templates_dir.is_custom() and templates_dir.get_active() or nil
		if custom_dir == templates_dir.builtin then
			custom_dir = nil
		end

		local builtin_files = templates_dir.builtin and _discover(templates_dir.builtin) or {}
		local custom_files = custom_dir and _discover(custom_dir) or {}

		local replaced = {}
		for _, file in ipairs(custom_files) do
			replaced[vim.fs.basename(file)] = true
		end

		for _, file in ipairs(builtin_files) do
			if not replaced[vim.fs.basename(file)] then
				local fn = _try_load(file)
				if fn then
					table.insert(templates, fn)
				end
			end
		end

		for _, file in ipairs(custom_files) do
			local fn = _try_load(file)
			if fn then
				table.insert(templates, fn)
			end
		end

		M._templates = templates
		return templates
	end

	local function reload_templates()
		M._templates = nil
	end

	--- Point the custom templates directory elsewhere and drop the template
	--- cache so the next load re-reads the built-in and custom templates. Pass
	--- nil (or "") to fall back to the plugin's built-in templates only. Unlike
	--- `custom_templates`, this does not validate that the directory exists; a
	--- missing one is reported and only the built-in templates are loaded.
	--- @param path? string
	local function set_templates_dir(path)
		templates_dir.set_custom(path)
		local active = templates_dir.get_active()
		if templates_dir.is_custom() and vim.fn.isdirectory(active) == 0 then
			notify(
				"custom_templates dir not found, using built-in templates only: " .. active,
				vim.log.levels.WARN
			)
		end
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

	local function apply_highlights(w, path, on_done)
		local templates = _load_templates()
		local nvim_set_hl = vim.api.nvim_set_hl
		local hl = function(g, o)
			nvim_set_hl(0, g, o)
		end

		local fallback_palette = require("matugen.fallback_palette")
		local c

		if w and next(w) ~= nil and not validator.is_valid(w) then
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

	return {
		notify = notify,
		apply_highlights = apply_highlights,
		reload_templates = reload_templates,
		set_templates_dir = set_templates_dir,
	}
end
