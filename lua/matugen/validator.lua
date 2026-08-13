local M = {}
local palette = require("matugen.palette")

M.required_keys = palette.keys

local function is_valid_hex(color)
	if type(color) ~= "string" then
		return false
	end
	if color:sub(1, 1) ~= "#" then
		return false
	end
	local hex = color:sub(2)
	local len = #hex
	if len ~= 3 and len ~= 4 and len ~= 6 and len ~= 8 then
		return false
	end
	return hex:match("^%x+$") ~= nil
end

function M.validate(path)
	local result = { ok = true, errors = {}, warnings = {} }

	local expanded = vim.fn.expand(path)
	if vim.fn.filereadable(expanded) ~= 1 then
		result.ok = false
		table.insert(result.errors, "Palette file not found or not readable: " .. path)
		return result
	end

	local f = io.open(expanded, "r")
	if not f then
		result.ok = false
		table.insert(result.errors, "Could not open palette file: " .. path)
		return result
	end

	local content = f:read("*a")
	f:close()

	local ok, parsed = pcall(vim.json.decode, content)
	if not ok or type(parsed) ~= "table" then
		result.ok = false
		table.insert(result.errors, "Failed to decode JSON from palette file: " .. path)
		return result
	end

	for key, value in pairs(parsed) do
		if
			type(key) == "string"
			and type(value) == "string"
			and value:sub(1, 1) == "#"
			and not is_valid_hex(value)
		then
			result.ok = false
			table.insert(
				result.errors,
				string.format(
					"Invalid color value '%s' for key '%s' (expected hex color)",
					value,
					key
				)
			)
		end
	end

	if result.ok then
		table.insert(result.warnings, "All color values in palette are valid")
	end

	return result
end

function M.is_valid_hex(color)
	return is_valid_hex(color)
end

--- Validate that every color value is a hex color.
--- Every value must start with "#" and be valid hex.
--- @param colors table<string, string>
--- @return boolean
function M.validate_colors(colors)
	for _, value in pairs(colors) do
		if type(value) ~= "string" or value:sub(1, 1) ~= "#" or not is_valid_hex(value) then
			return false
		end
	end
	return true
end

--- Full palette validation: all values valid hex + all required keys present.
--- @param w table<string, string>
--- @return boolean
function M.is_valid(w)
	if type(w) ~= "table" or next(w) == nil then
		return false
	end
	for _, value in pairs(w) do
		if type(value) ~= "string" or value:sub(1, 1) ~= "#" or not is_valid_hex(value) then
			return false
		end
	end
	for _, key in ipairs(M.required_keys) do
		if w[key] == nil then
			return false
		end
	end
	return true
end

return M
