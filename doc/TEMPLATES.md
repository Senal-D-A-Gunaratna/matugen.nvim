# Creating Custom Templates

This plugin bridges the gap between Material You colors and your Neovim environment. It reads a `JSON` file containing semantic color keys and maps them to Neovim's highlight groups.

`matugen.nvim` uses a modular template system. Each template is a Lua file that receives the current color palette and a high-level API to set Neovim highlights.

Templates are loaded from the plugin's built-in `lua/matugen/templates/` plus, when `custom_templates` is configured, your own directory layered on top of it. That directory is created empty if it doesn't exist yet, and creating it is reported. You only add the files you actually want to change — nothing is copied out of the plugin, so a plugin update never overwrites your work.

## Overriding a built-in template

Built-in templates are applied first and custom ones last, so a custom template always wins the highlight groups it sets. What a custom file does depends on its name and its content:

| File in `custom_templates`                    | Effect                                                                                        |
| --------------------------------------------- | --------------------------------------------------------------------------------------------- |
| A new name (`my_lualine.lua`) with a function | Added to the set. It only overrides the groups it defines.                                    |
| Same name as a built-in, with a function      | Replaces that built-in template entirely.                                                     |
| Same name as a built-in, blank (no content)   | Disables that built-in template. Leave the file empty, with no comment in it.                 |
| Same name as a built-in, but it fails to load | Reported as an error, the built-in stays, and the theme is rendered from the fallback colors. |
| A new name, but it fails to load              | Reported as an error and ignored; there is no built-in to fall back to.                       |

A failed file also counts as broken if it loads but throws while applying its highlight groups — for example by handing Neovim a color it rejects. The pass is redone from the fallback colors so one bad template can't leave the editor half-themed.

Because a file that fails to load is a customization you believe is active but isn't, one broken file makes the whole theme use the fallback colors until you fix it, rather than rendering your palette through a partially applied customization. The built-in template of the same name is used in the meantime.

Fix a failed file and run `:MatugenReload` to re-read it — the real palette returns as soon as no custom file is failing. `:checkhealth matugen` lists which files failed and which palette is in use.

## Template Structure

Create a new file in your `custom_templates` directory (the built-in
`lua/matugen/templates/` is not meant to be edited). Templates are read
from the top level of that directory only — a `.lua` file inside a
subdirectory is ignored.

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
`primary`, `on_primary`, `primary_container`, `on_primary_container`, `primary_fixed_dim`, `inverse_primary`

**Secondary:**
`secondary`, `secondary_container`, `on_secondary_container`, `secondary_fixed_dim`

**Tertiary:**
`tertiary`, `tertiary_container`, `tertiary_fixed_dim`

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

If you want to add support for a new plugin, create `my-plugin.lua` in your `custom_templates` directory:

```lua
return function(c, hl)
  hl("MyPluginClass", { fg = c.primary })
  hl("MyPluginBorder", { fg = c.outline_variant, bg = c.surface_container })
end
```
