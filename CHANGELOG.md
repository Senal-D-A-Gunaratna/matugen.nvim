# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### ⚠ BREAKING CHANGES

- **Cursor color is now themed by shape, not by mode.** Three new required
  palette keys replace the per-mode semantic mapping: `cursor_block`
  (`primary`), `cursor_beam` (`tertiary`), and `cursor_underline`
  (`secondary`). Existing generated palette files lack these keys and will
  fail validation, falling back to the whole fallback palette — re-copy the
  updated `nvim-colors.json` template and re-run matugen to regenerate.

### Added

- **Per-shape cursor theming** via `guicursor`. Block-shaped cursors
  (`Cursor`, `smCursor`, `TermCursor`) use `cursor_block`; beam/vertical
  cursors (`iCursor`, `lCursor`) use `cursor_beam`; underline/horizontal
  cursors (`rCursor`, `oCursor`) use `cursor_underline`. Highlight groups are
  defined in `lua/matugen/templates/editor.lua` and the `guicursor` string is
  set once in `setup()`.
- **`TermCursorNC` highlight** for unfocused terminal buffers, which previously
  fell back to plain reverse-video. It follows the existing `*NC` dimming
  convention (`fg = on_surface_variant`, `bg = surface_low`) relative to
  `TermCursor` (`fg = on_primary`, `bg = cursor_block`).

### Fixed

- **Cursor no longer intermittently shows the terminal-default color on
  startup.** `guicursor` is assigned synchronously in `setup()`, but the
  `Cursor`/`TermCursor`/etc. highlight groups it references are only defined
  once the async palette load completes, so the correct color previously
  had to wait on an unrelated redraw to appear. `_apply_highlights` now
  calls `vim.api.nvim__redraw({ cursor = true, flush = true })` right after
  the templates apply, forcing an immediate cursor repaint.
- **Cursor foreground contrast paired to background.** Block cursors
  (`Cursor`, `smCursor`, `TermCursor`) keep `on_primary` on `cursor_block`;
  beam cursors (`iCursor`, `lCursor`) and underline cursors (`rCursor`,
  `oCursor`) now use the neutral high-contrast `on_surface` on their mid-tone
  accents, since no `on_tertiary`/`on_secondary` key exists.
- **Removed the dead `vCursor` highlight.** It is not a Neovim default group
  and is never referenced by the `guicursor` string in `setup()` — visual mode
  is already covered by `n-v-c:block-Cursor`.
- **Terminal cursor color no longer falls back to default.** Neovim now maps
  Terminal mode to the `TermCursor` highlight group via a `t:` entry in
  `guicursor`, so matugen's `TermCursor` color is applied. `termguicolors` is
  enabled in `setup()` since cursor color (not shape) requires it.
- **Removed the `TermCursorNC` bg override in init.lua** that incorrectly set
  it to `TermCursor`'s bg, breaking the dimmed *NC convention.

### Changed

- **CI replaced with luacheck + typecheck pipeline** (bunson.nvim style).
  `lua-language-server` is downloaded with retries and an auth token; it runs
  against `lua/`, `plugin/`, and `colors/` and fails on severity-1 diagnostics.
- **Removed `.gitignore` from tracking**; the remaining ignore rules
  (`cspell.json`, `.neovim-stubs/`) are implicit.
- **Docs updated** to point `palette_path` at the matugen cache directory
  (`~/.cache/matugen/nvim-colors.json`).
- **Standardized `*NC` dimming convention:** `fg = on_surface_variant`, with `bg = surface_low` for anchored UI elements and `bg = nil` for content.

## [2026-07-19] — test tooling cleanup

### Removed

- **Plenary.nvim dependency and the test workflow.**
- **Trivial test directory** and the **validator test file** (the CI pipeline
  now validates the palette directly instead of via unit tests).
- Test target from the Makefile.

### Changed

- Resolved all luacheck warnings.
- Wrapped `README.md` at 80 characters.
- Rewrote the changelog to cover the full project history.

## [2026-07-16] — breaking palette keys and signal debounce removal

### ⚠ BREAKING CHANGES

- **Palette JSON keys changed to direct semantic names.** The `nvim-colors.json`
  palette no longer uses the `workbench.colorCustomizations` wrapper. Colors are
  keyed directly by semantic names (`surface`, `on_surface`, `primary`, etc.).
- **Removed all JSONC support.** The `lua/matugen/jsonc.lua` module has been
  deleted. Palette files must now be plain `.json`. Update any `.jsonc` palette
  files by removing comments.
- **`jsonc_path` renamed to `palette_path`.** Update your config:
  `require("matugen").setup({ palette_path = "..." })`.
- **Removed `:MatugenStatus` command.** Use `:checkhealth matugen` instead.

### Changed

- **Removed the SIGUSR1 debounce timer entirely**, after reducing it from
  300ms → 100ms → 50ms, in favor of a trailing-edge debounce.
- Formatted `nvim-colors.json` with 2-space indentation.
- Removed the VS Code Parity section from the README.

### Added

- `AGENTS.md` documenting commit discipline and conventional commits (with the
  `BRAKING_CHANGES!` type).
- opencode configuration with commit-on-each-step instructions.

## [2026-07-15] — trailing-edge debounce

### Fixed

- **Trailing-edge debounce** for the SIGUSR1 signal and reload notifications,
  preventing duplicate reloads and stale notifications when multiple signals
  arrive in quick succession.

## [2026-07-14] — reload robustness

### Added

- **Generation counter** to discard stale async palette reads that complete out
  of order.
- Demo video section in the README.

### Fixed

- Deferred the reload notification until the theme is actually applied (later
  reverted, then re-landed inside the debounced apply callback).

## [2026-07-11] — CI expansion

### Added

- Lua syntax validation step to the CI pipeline.
- Validator test suite (Plenary.nvim-based) and a dedicated test palette file.
- Palette-file verification step in CI, run against `.github/nvim-colors.json`.

### Changed

- Moved the Makefile and check-syntax script into `.github/`.

## [2026-07-10] — validator, RGBA, and async loading

### Added

- **Palette validator** (moved from `tests/` to `lua/matugen/validator.lua`).
  Colors are validated before loading the theme; invalid hex values or missing
  keys fall back to `fallback_palette` instead of crashing.
- **Support for `#RGBA` (4-hex-digit) color format** in the validator and
  `hex()` normalizer. The normalizer also handles `#RGB` and `#RRGGBBAA`.
- **Async startup** — the palette file is read via `vim.uv` and highlight
  application is deferred with `vim.schedule`, so startup is non-blocking.
- **GitHub Actions workflow** and a **Makefile** for local headless testing,
  with a `minimal_init.lua` runner.
- `:checkhealth` reports template count, palette path, and last-reload status.

### Fixed

- Broken regex in `is_valid_hex` replaced with explicit length checks.
- Non-hex color values no longer cause false validation failures.
- Deduplicated invalid-palette warning on cache replay.
- Loop variable renamed to avoid shadowing Lua's global `type()`.
- Removed spurious warning when `load_theme` is set to `false`.
- Removed unrelated `winblend` autocmd from `plugin/matugen.lua`.
- Always re-apply all template highlights on reload; templates are re-applied
  on the Mason `FileType` event.
- Duplicate `Normal` highlight definition removed.
- Removed unused `vim.g` writes that triggered global `OptionSet` events.
- Deduplicated `fallback_palette` merge into a single post-resolution step.
- Removed per-file `vim.fn.resolve` calls by resolving the template dir once.

## [2026-07-07] — palette_path rename and JSONC stripper

### ⚠ BREAKING CHANGES

- **`jsonc_path` renamed to `palette_path`**, and the JSONC stripper is
  auto-bypassed for `.json` files.

### Added

- **JSONC comment stripper extracted** into `lua/matugen/jsonc.lua`, shared by
  `init.lua` and `health.lua`, with a fix for comments at byte 0 of a file.

### Changed

- Hoisted `hex()` from inside `_apply_highlights` to module level.
- Added `---@param` / `---@return` type annotations to the public API.
- Enhanced `.luarc.json` with proper LSP settings.
- `:MatugenReload` clears the template cache so modified templates are re-read
  from disk.

## [2026-07-04] — caching, security, and health checks

### Added

- **Template function caching** across reloads for better performance.
- **Dual sync/async loading** with the recursion guard replaced by a caching
  bypass to prevent double load.
- **SIGUSR1 reload debouncing** to prevent rapid flicker.
- **`load_theme()` used in reload paths**; double-require removed.
- **`*:checkhealth matugen*` integration** for diagnostic checks.
- **Robust fallback color scheme** with graceful degradation on load failure.

### Fixed

- Security: template loading pinned to the plugin's own directory.
- Security: palette path anonymized in globals; status leak dropped.
- Security: `jsonc_path` extension validated and the path reused expanded.
- Security: `opts` validated in `setup()` with defaults.
- Safer JSONC comment stripping to avoid clobbering string values.
- Template cache cleared on manual `:MatugenReload`.
- Floating window backgrounds made opaque.

### Removed

- `:MatugenStatus` command (folded into `:checkhealth matugen`).

## [2026-06-28] — diagnostics and docs

### Added

- **`:MatugenStatus` command** with diagnostics globals (later superseded by
  `:checkhealth`).
- Supported Plugins section and collapsible plugin list in the README.

## [2026-06-05] — template split and load_theme

### Added

- **Split templates into individual modules** under `lua/matugen/templates/`
  for nvim-cmp, neo-tree, nvim-tree, oil.nvim, mini.nvim, dropbar.nvim,
  barbecue.nvim, aerial.nvim, zen-mode, twilight, diffview, lazygit, fzf-lua,
  avante.nvim, render-markdown, todo-comments, flash.nvim, dressing.nvim, and
  indent-blankline.
- **`load_theme` option** with a notification when disabled.
- **Plugin config now provides opts** via `vim.g.matugen_opts` instead of
  hardcoded defaults.

### Changed

- Renamed the lazygit template to `TUI_theme.lua`, then removed it entirely.
- Docs updated for the new opts syntax and the `load_theme` flag.

### Fixed

- Prevented a crash when `jsonc_path` is nil.

## [2026-06-03] — fallback color scheme

### Added

- **Robust fallback color scheme** (`lua/matugen/fallback_palette.lua`) with
  graceful degradation when the palette file is missing or invalid.
- Local development configurations (`.luarc.json`, `cspell.json`).

### Changed

- Fallback notifications formatted to two lines for readability.

## [2026-05-25] — decoupled architecture

### Changed

- **Major refactor:** palette logic moved to `lua/matugen/palette.lua` with a
  decoupled architecture. Template placeholders changed from the `.hex` suffix
  to direct color variable names.
- **`nvim-template.jsonc` renamed** to `nvim-colors.jsonc`.
- README rewritten around cross-editor color parity and the decoupled
  architecture.

## [2026-05-23] — initial release

### Added

- Initial release of matugen.nvim — Material You colorscheme integration for
  Neovim, reading a JSON template generated by the matugen CLI and applying it
  to Neovim highlight groups.
