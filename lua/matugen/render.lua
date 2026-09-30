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

	--- Load one template file. Failures are returned rather than reported so the
	--- caller can word the message with the context it has: a broken custom
	--- file keeps the built-in of the same name, a broken built-in one has no
	--- fallback at all.
	--- @param file string
	--- @return fun(table, hl: fun(string, table):nil)? template, or nil plus the
	--- reason it could not be used
	local function _try_load(file)
		local chunk, err = loadfile(file)
		if not chunk then
			return nil, tostring(err)
		end
		local ok_chunk, res = pcall(chunk)
		if not ok_chunk then
			return nil, tostring(res)
		end
		if type(res) ~= "function" then -- must be firma (c, hl)
			return nil, "must return a function(c, hl), or be blank to disable a built-in"
		end
		return res
	end

	--- A blank custom file is the documented way to disable a built-in
	--- template of the same name. Anything else has to return a template
	--- function, so an empty or whitespace-only file is the only content that
	--- is intentionally skipped.
	--- @param file string
	--- @return boolean
	local function _is_blank(file)
		local f = io.open(file, "r")
		if not f then
			return false
		end
		local content = f:read("*a")
		f:close()
		return content:match("^%s*$") ~= nil
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

		-- Built-in templates are applied first and the custom ones last, so a
		-- custom template only needs to set the highlight groups it cares
		-- about: they win because they are applied afterwards.
		-- A custom file that loads and returns a function replaces the built-in
		-- of the same name; a blank one disables it. A custom file that fails to
		-- load replaces nothing — the built-in is kept, so a typo can't silently
		-- strip a plugin's highlights.
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

		-- Classify the custom files before touching the built-in ones, since
		-- whether a built-in survives depends on what its custom counterpart
		-- turned out to be. Custom files are loaded up front only to learn that;
		-- they are still applied after every built-in below.
		local blank, loaded = {}, {}
		local builtin_names = {}
		for _, file in ipairs(builtin_files) do
			builtin_names[vim.fs.basename(file)] = true
		end

		for _, file in ipairs(custom_files) do
			local base = vim.fs.basename(file)
			if _is_blank(file) then
				blank[base] = true
			else
				local fn, reason = _try_load(file)
				if fn then
					loaded[base] = fn
				else
					notify(
						"custom_templates template failed: "
							.. file
							.. ": "
							.. reason
							.. (
								builtin_names[base] and "; keeping built-in " .. base or "; ignored"
							),
						vim.log.levels.ERROR
					)
				end
			end
		end

		for _, file in ipairs(builtin_files) do
			local base = vim.fs.basename(file)
			if not blank[base] and not loaded[base] then
				local fn, reason = _try_load(file)
				if fn then
					table.insert(templates, fn)
				else
					notify(
						"built-in template failed: " .. file .. ": " .. reason,
						vim.log.levels.WARN
					)
				end
			end
		end

		for _, file in ipairs(custom_files) do
			local fn = loaded[vim.fs.basename(file)]
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
		local palette = require("matugen.palette")
		local c = {}

		-- Per-key recovery. A palette with one bad or missing entry still
		-- contributes every value it does provide, so a single typo no longer
		-- replaces the whole theme with the fallback colors — only the keys that
		-- are unusable are substituted. Those keys are named in the warning, so
		-- the offender is obvious without a trip to `:checkhealth`.
		local unusable = {}
		for _, k in ipairs(palette.keys) do
			local v = w and w[k] or nil
			if validator.is_valid_hex(v) then
				c[k] = hex(v)
			else
				table.insert(unusable, k)
			end
		end

		if next(w) ~= nil and #unusable > 0 then
			-- Not latched: a palette that is still broken on the next reload is
			-- still worth reporting, since the affected keys keep coming from the
			-- fallback. An empty palette (`w` is `{}`) is a separate failure the
			-- loader already reports, so it isn't double-reported here.
			local named = {}
			for i = 1, math.min(#unusable, 6) do
				table.insert(named, unusable[i])
			end
			local listed = table.concat(named, ", ")
			if #unusable > 6 then
				listed = listed .. " (+" .. (#unusable - 6) .. " more)"
			end
			notify(
				"palette has "
					.. #unusable
					.. " invalid or missing color value(s), using fallback for: "
					.. listed,
				vim.log.levels.WARN
			)
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
