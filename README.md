# matugen.nvim

A Material You colorscheme bridge for Neovim. Built as a drop-in solution
that maps [matugen](https://github.com/InioX/matugen)'s colors straight to
Neovim highlight groups through a semantic palette, with minimal setup
required

---

<https://github.com/user-attachments/assets/5b9e40a9-a8e1-4b9b-badd-f4b667d55f5e>

---

## Requirements

- [Neovim](https://github.com/neovim/neovim) 0.10+
- [matugen](https://github.com/InioX/matugen)
- [lazy.nvim](https://github.com/folke/lazy.nvim) (recommended)

## Setup

**1. Copy the template**

Copy [`nvim-colors.json`](nvim-colors.json) to your matugen templates folder

**2. Add it to `config.toml`**

```toml
[templates.neovim]
input_path = "~/.config/matugen/templates/nvim-colors.json"
output_path = "~/.cache/matugen/nvim-colors.json"
post_hook = "pkill -SIGUSR1 nvim"
```

**3. Install with `lazy.nvim`**

```lua
{
  "Senal-D-A-Gunaratna/matugen.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    palette_path = "~/.cache/matugen/nvim-colors.json",
    -- load_theme = false,
  },
},
```

By default, the plugin automatically loads the generated palette and sets
itself as your active colorscheme — no extra `vim.cmd.colorscheme(...)` call
needed

Set `load_theme = false` if you'd rather manage the colorscheme yourself and
don't want the plugin to apply it automatically

> If the palette file can't be loaded, the plugin falls back to a built-in
> dark theme and notifies you.

**4. Terminal opacity (optional)**

> Terminal opacity can be achieved on most other DEs/WMs too (window rules,
> compositor configs, etc) — this section covers the Hyprland-specific approach

For transparency in Neovim that doesn't affect your regular terminal, use
[hyprfade.nvim](https://github.com/Senal-D-A-Gunaratna/hyprfade.nvim). Unlike
a static Hyprland window rule, it toggles opacity only while Neovim is
focused — and it works even when Neovim's window title doesn't update in
time for a class/title match (e.g. launching from Yazi)

Or set a static rule yourself:

```lua
hl.window_rule({
  match = { class = "kitty", title = "nvim" },
  opacity = "0.7",
})
```

## Live reload

The `post_hook` in `config.toml` reloads Neovim automatically on every
`matugen` run. To trigger it manually:

```bash
pkill -SIGUSR1 nvim
```

or, from inside Neovim:

```vim
:MatugenReload
```

## Health check

```vim
:checkhealth matugen
```

Verifies your config, template parsing, active templates, and load status

## Supported plugins

Built-in templates live in `lua/matugen/templates`:

<details>
<summary>Show all supported plugins</summary>

- [aerial.nvim](lua/matugen/templates/aerial.lua)
- [avante.nvim](lua/matugen/templates/avante.lua)
- [barbecue.nvim](lua/matugen/templates/barbecue.lua)
- [blink.nvim](lua/matugen/templates/blink.lua)
- [bufferline.nvim](lua/matugen/templates/bufferline.lua)
- [cmp.nvim](lua/matugen/templates/cmp.lua)
- [diffview.nvim](lua/matugen/templates/diffview.lua)
- [dressing.nvim](lua/matugen/templates/dressing.lua)
- [dropbar.nvim](lua/matugen/templates/dropbar.lua)
- [editor](lua/matugen/templates/editor.lua)
- [flash.nvim](lua/matugen/templates/flash.lua)
- [fzf-lua.nvim](lua/matugen/templates/fzf_lua.lua)
- [gitsigns.nvim](lua/matugen/templates/gitsigns.lua)
- [ibl.nvim](lua/matugen/templates/ibl.lua)
- [lsp.nvim](lua/matugen/templates/lsp.lua)
- [lualine.nvim](lua/matugen/templates/lualine.lua)
- [mason.nvim](lua/matugen/templates/mason.lua)
- [mini.nvim](lua/matugen/templates/mini.lua)
- [neo-tree.nvim](lua/matugen/templates/neo_tree.lua)
- [neominimap.nvim](lua/matugen/templates/neominimap.lua)
- [noice.nvim](lua/matugen/templates/noice.lua)
- [nvim-tree.nvim](lua/matugen/templates/nvim_tree.lua)
- [oil.nvim](lua/matugen/templates/oil.lua)
- [render-markdown.nvim](lua/matugen/templates/render_markdown.lua)
- [snacks.nvim](lua/matugen/templates/snacks.lua)
- [syntax](lua/matugen/templates/syntax.lua)
- [telescope.nvim](lua/matugen/templates/telescope.lua)
- [todo-comments.nvim](lua/matugen/templates/todo_comments.lua)
- [trouble.nvim](lua/matugen/templates/trouble.lua)
- [twilight.nvim](lua/matugen/templates/twilight.lua)
- [which-key.nvim](lua/matugen/templates/whichkey.lua)
- [zen-mode.nvim](lua/matugen/templates/zen_mode.lua)

</details>

## Customization

**Tweaking colors** doesn't require touching any plugin code. Edit your
[`nvim-colors.json`](nvim-colors.json) template directly — remap a semantic
key to a different matugen color role (e.g. point `cursor_block` at
`tertiary` instead of `primary`), adjust the alpha suffix on
`selection_bg`/`word_highlight`, or swap in a hardcoded hex value. Run
`matugen` again (or `:MatugenReload`) to see the change

Every highlight group comes from one semantic palette in
`lua/matugen/palette.lua`, so adding a new plugin or UI component stays
consistent

**Cursor theming** is done by shape, not mode:

| Shape     | Cursors                            | Palette key        |
| --------- | ---------------------------------- | ------------------ |
| Block     | `Cursor`, `smCursor`, `TermCursor` | `cursor_block`     |
| Beam      | `iCursor`, `lCursor`               | `cursor_beam`      |
| Underline | `rCursor`, `oCursor`               | `cursor_underline` |

Block cursor colors work in any terminal. Per-shape colors need a terminal
that honors cursor coloring (kitty, wezterm, foot); terminals that don't
(GNOME Terminal, Alacritty) just get a plain cursor

Foreground pairing follows contrast needs: block cursors use high-contrast
`on_primary`, while beam/underline cursors use the softer `on_surface`.
Unfocused terminal windows get the dimmed `TermCursorNC`, matching the rest
of the `*NC` groups

See [Creating Custom Templates](doc/TEMPLATES.md) to extend it

## Contributing

PRs welcome — new plugin support, bug fixes, anything that makes this better

## Support

If you find this useful, consider giving it a ⭐ — it helps others discover the project

## License

MIT
