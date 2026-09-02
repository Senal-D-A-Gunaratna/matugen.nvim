# Creating Custom Templates

This plugin bridges the gap between Material You colors and your Neovim environment. It reads a `JSON` file containing semantic color keys and maps them to Neovim's highlight groups.

`matugen.nvim` uses a modular template system. Each template is a Lua file that receives the current color palette and a high-level API to set Neovim highlights.

## Template Structure

Create a new file in `lua/matugen/templates/`.

To load the new template (or apply changes to existing ones), run the `:MatugenReload` command or restart Neovim. The plugin caches templates in-memory during background/signal updates for maximum performance, but `:MatugenReload` will clear the cache and re-read the templates from disk.

A template file must return a function that accepts two arguments: `c` (the color palette) and `hl` (the highlight function).

```lua
return function(c, hl)
  -- hl(group_name, { options })
  hl("MyHighlightGroup", { fg = c.primary, bg = c.surface_container, bold = true })
end
```

## Available Colors (`c`)

The `c` object contains your theme's colors mapped from the JSON file. The full list of keys is defined in `lua/matugen/palette.lua`.

**Surfaces:**
`surface`, `surface_low`, `surface_container`, `surface_high`, `surface_highest`

**Text / Outlines:**
`on_surface`, `on_surface_variant`, `outline`, `outline_variant`

**Primary:**
`primary`, `on_primary`, `primary_container`, `on_primary_container`

**Secondary:**
`secondary`, `secondary_container`, `on_secondary_container`

**Tertiary:**
`tertiary`, `tertiary_container`

**Error / Selection:**
`error`, `error_container`, `selection_bg`

**Word Highlight:**
`word_highlight`, `word_highlight_strong`

**Git:**
`git_added`, `git_modified`, `git_deleted`

Color values are automatically normalized: `#RGB`, `#RGBA`, and `#RRGGBBAA` formats are converted to `#RRGGBB` (alpha is stripped).

## Highlighting API (`hl`)

The `hl` function is a wrapper around `vim.api.nvim_set_hl`.

```lua
-- Example
hl("Normal", { fg = c.on_surface, bg = c.surface })
```

## Example: Theming a New Plugin

If you want to add support for a new plugin, simply create `lua/matugen/templates/my-plugin.lua`:

```lua
return function(c, hl)
  hl("MyPluginClass", { fg = c.primary })
  hl("MyPluginBorder", { fg = c.outline_variant, bg = c.surface_container })
end
```
