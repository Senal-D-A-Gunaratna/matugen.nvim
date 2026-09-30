--- @see doc/matugen.txt
--- @type table<string, any>
local M = {}

--- Resolve the built-in templates directory from this file's own location
--- rather than the runtimepath, so a rogue plugin can't shadow or inject
--- templates. Stored once as an internal variable so other modules (and the
--- `custom_templates` option) can layer custom templates on top of it.
local _self = debug.getinfo(1, "S").source:sub(2)
local _plugin_lua_dir = _self:match("^(.*)/templates_dir%.lua$")

--- Absolute path of the plugin's own templates directory.
M.builtin = _plugin_lua_dir and vim.fn.resolve(_plugin_lua_dir .. "/templates") or nil

--- @type string? custom templates directory layered over the built-in one;
--- nil means the built-in directory is the only source
local custom = nil

--- @param path? string
--- @return string?
local function _resolve(path)
	if not path or path == "" then
		return nil
	end
	return vim.fn.resolve(vim.fn.expand(path))
end

--- @param path? string
function M.set_custom(path)
	custom = _resolve(path)
end

--- @return string? custom templates directory if set, else the built-in one
function M.get_active()
	return custom or M.builtin
end

--- @return boolean true if a custom templates directory is active
function M.is_custom()
	return custom ~= nil
end

--- Validate `path` and activate it as the custom templates directory, which
--- is then layered on top of the built-in templates. The directory is never
--- created and built-in templates are never copied into it, so a missing
--- directory is reported and leaves the built-in templates as the only source.
--- @param path string
--- @return string? resolved path, or nil if unset or missing
function M.activate(path)
	local dest = _resolve(path)
	if not dest then
		return nil
	end
	if vim.fn.isdirectory(dest) == 0 then
		vim.notify(
			"matugen: could not find custom_templates dir, using built-in templates only: " .. dest,
			vim.log.levels.WARN
		)
		return nil
	end
	M.set_custom(dest)
	return dest
end

return M
