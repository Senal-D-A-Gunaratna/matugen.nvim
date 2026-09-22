--- @see doc/matugen.txt
--- @type table<string, any>
local M = {}

--- Resolve the built-in templates directory from this file's own location
--- rather than the runtimepath, so a rogue plugin can't shadow or inject
--- templates. Stored once as an internal variable so other modules (and the
--- `custom_templates` option) can point the templates source elsewhere.
local _self = debug.getinfo(1, "S").source:sub(2)
local _plugin_lua_dir = _self:match("^(.*)/templates_dir%.lua$")

--- Absolute path of the plugin's own templates directory.
M.builtin = _plugin_lua_dir and vim.fn.resolve(_plugin_lua_dir .. "/templates") or nil

--- @type string? active templates directory; nil means built-in
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

--- @return string? active templates directory (custom if set, else built-in)
function M.get_active()
	return custom or M.builtin
end

--- Ensure `path` exists, fill it with any built-in template files it is
--- missing (existing files are never overwritten), and activate it as the
--- templates directory.
--- @param path string
--- @return string? resolved path, or nil on failure
function M.sync(path)
	local dest = _resolve(path)
	if not dest then
		return nil
	end
	if vim.fn.isdirectory(dest) == 0 then
		pcall(vim.fn.mkdir, dest, "p")
		if vim.fn.isdirectory(dest) == 0 then
			vim.notify(
				"matugen: could not create custom_templates dir: " .. dest,
				vim.log.levels.WARN
			)
			return nil
		end
	end
	if M.builtin then
		local uv = vim.uv or vim.loop
		for name, ftype in vim.fs.dir(M.builtin) do
			if ftype == "file" then
				local target = dest .. "/" .. name
				if vim.fn.filereadable(target) == 0 then
					local ok_copy = pcall(uv.fs_copyfile, M.builtin .. "/" .. name, target)
					if not ok_copy or vim.fn.filereadable(target) == 0 then
						vim.notify(
							"matugen: could not copy template " .. name .. " to " .. target,
							vim.log.levels.WARN
						)
					end
				end
			end
		end
	end
	M.set_custom(dest)
	return dest
end

return M
